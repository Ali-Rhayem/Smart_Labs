from kafka import KafkaConsumer, KafkaProducer
import json
import base64
import datetime
import time
import random
import threading
import sys
import os
import subprocess
from dotenv import load_dotenv
load_dotenv()
is_started = False

def images_to_base64(image_path):
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"The image {image_path} does not exist.")
    
    if os.path.isfile(image_path) and image_path.lower().endswith(('png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp')):
        try:
            with open(image_path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                return encoded_string
        except Exception as e:
            print(f"Could not process file {image_path}: {e}")

def get_random_image():
    folder_path = "./test_images"
    image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp'}
    images = [f for f in os.listdir(folder_path)
              if os.path.splitext(f)[1].lower() in image_extensions]
    
    if not images:
        raise ValueError("No image files found in the specified folder.")
    
    return os.path.join(folder_path, random.choice(images))
    # return os.path.join("./image.jpg")

def take_image_from_camera():
    try:
        # Generate timestamp for filename
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        # Create images directory if it doesn't exist
        output_dir = os.path.expanduser("~/Desktop/images")
        os.makedirs(output_dir, exist_ok=True)
        # Create output path with timestamp
        output_path = os.path.expanduser(f"~/Desktop/images/image_{timestamp}.jpg")
        # Build capture command
        capture_command = f"sudo rpicam-still --timeout 100 -o {output_path} --vflip > /dev/null 2>&1"
        
        time.sleep(0.2)
        subprocess.run(capture_command, shell=True, check=True)
        return output_path
    except subprocess.CalledProcessError as e:
        print(f"Failed to capture image: {e}")
        return None
    
# Create a KafkaProducer instance to be reused.
producer = KafkaProducer(
    bootstrap_servers=os.getenv("BOOTSTRAP_SERVERS"),
    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
    max_request_size=10 * 1024 * 1024  # 10 MB
)

# An Event flag that indicates whether periodic production is active.
producing_event = threading.Event()

def produce_image(command_data):

    image_path = get_random_image()
    # image_path = take_image_from_camera()
    command_data["encoding"] = images_to_base64(image_path)
    command_data["image_name"] = os.path.basename(image_path)
    command_data["time"] = datetime.datetime.now(datetime.UTC).strftime("%H:%M:%S")
    future = producer.send(os.getenv("ANALYSIS_TOPIC"), value=command_data)
    try:
        # Wait for the send to complete.
        future.get(timeout=10)
        print("Image sent to analyze")
    except Exception as e:
        print("Failed to send image:", e)

def periodic_producer(command_data):
    try:
        # Parse end_time from command_data
        end_time_str = command_data["end_time"]
        end_time = datetime.datetime.strptime(end_time_str, "%H:%M").time()
    except KeyError:
        print("Missing 'end_time' in command_data.")
        return
    except ValueError:
        print(f"Invalid 'end_time' format: {end_time_str}. Expected 'HH:MM:SS'.")
        return

    while producing_event.is_set():
        # Check if current time is past end_time
        current_time = datetime.datetime.now().time()
        if current_time >= end_time:
            print(f"Current time {current_time} has reached or passed end time {end_time}. Stopping periodic production.")
            producing_event.clear()
            break

        # Produce an image
        produce_image(command_data)

        # Wait for 10 seconds, checking every second if we need to stop
        for _ in range(10):
            if not producing_event.is_set():
                break
            time.sleep(1)

    # After exiting the loop, send one final image
    # Update the global flag
    global is_started
    is_started = False
    print("Periodic production stopped due to end time reached.")
    print("Received 'end' command. Sending final image and terminating process.")
    command_data["command"] = "end"
    produce_image(command_data)

# Set up the consumer.
topic = os.getenv("RECORDING_TOPIC")

consumer = KafkaConsumer(
    topic,
    bootstrap_servers=os.getenv("BOOTSTRAP_SERVERS"),
    group_id=os.getenv("ROOM_GROUP"),
    auto_offset_reset='latest',
    enable_auto_commit=True,
    value_deserializer=lambda x: x.decode('utf-8'),
)

print("Consumer Started")
periodic_thread = None

try:
    for msg in consumer:
        print("Message received in camera")
        data = json.loads(msg.value)
        
        if data["room"] != os.getenv("ROOM_GROUP"):
            print("Ignoring message for another room:", data["room"])
            continue
        
        current_time_str = datetime.datetime.now().strftime("%H:%M")
        current_time = datetime.datetime.strptime(current_time_str, "%H:%M")
        start_time_str = data["start_time"]
        start_time = datetime.datetime.strptime(start_time_str, "%H:%M")
        end_time_str = data["end_time"]
        end_time = datetime.datetime.strptime(end_time_str, "%H:%M")
        
        start_time = start_time - datetime.timedelta(minutes=5)
        
        if current_time < start_time or current_time > end_time:
            print("Ignoring message outside of the time range.")
            continue
        
        command = data.get("command")
        
        if command == "start":
            is_started = True
            if not producing_event.is_set():
                print("Starting periodic production...")
                producing_event.set()
                # Pass a copy of the data to avoid unexpected modifications.
                periodic_thread = threading.Thread(target=periodic_producer, args=(data.copy(),))
                periodic_thread.start()
            else:
                print("Periodic production is already running.")
        
        elif command == "end":
            if not is_started:
                print("Ignoring 'end' command before 'start'.")
                continue
            is_started = False
            
            print("Received 'end' command. Sending final image and terminating process.")
            # Send one final image.
            # Stop periodic production.
            producing_event.clear()
            if periodic_thread is not None:
                periodic_thread.join()
                periodic_thread = None

            produce_image(data)
        
        else:
            print("Unknown command received:", command)

except KeyboardInterrupt:
    print("\nKeyboardInterrupt received. Terminating process.")
    producing_event.clear()
    if periodic_thread is not None:
        periodic_thread.join()

finally:
    # Ensure that both the consumer and producer are closed properly.
    consumer.close()
    producer.close()
    print("Consumer and Producer closed. Exiting.")
    sys.exit(0)
