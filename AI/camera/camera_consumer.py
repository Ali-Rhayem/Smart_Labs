import os
import json
import time
import signal
from kafka import KafkaConsumer
from dotenv import load_dotenv

load_dotenv()

def periodic_function(data):
    print(f"Processing data")

def main():
    consumer = KafkaConsumer(
        os.getenv("SERVER_TOPIC"),
        bootstrap_servers=os.getenv("BOOTSTRAP_SERVERS").split(','),
        group_id=os.getenv("GROUP_ID"),
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        value_deserializer=lambda x: x.decode('utf-8')
    )
    print("Consumer started")

    is_running = False
    current_data = None
    last_execution_time = 0
    shutdown = False

    # Signal handler for graceful shutdown
    def signal_handler(sig, frame):
        nonlocal shutdown
        print("\nCtrl+C detected, initiating shutdown...")
        shutdown = True

    signal.signal(signal.SIGINT, signal_handler)

    try:
        while not shutdown:
            message_pack = consumer.poll(timeout_ms=1000)

            if message_pack:
                for tp, messages in message_pack.items():
                    for msg in messages:
                        try:
                            data = json.loads(msg.value)
                            command = data.get('command')

                            if command == 'start':
                                print("Start command received")
                                is_running = True
                                current_data = data
                                last_execution_time = time.time()
                            elif command == 'end':
                                print("End command received")
                                periodic_function(data)
                                is_running = False
                        except Exception as e:
                            print(f"Error processing message: {e}")

            # Check if we should execute periodic task
            if is_running and (time.time() - last_execution_time) >= 5:
                periodic_function(current_data)
                last_execution_time = time.time()

    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        print("Closing consumer...")
        consumer.close()
        print("Shutdown complete")

if __name__ == "__main__":
    main()