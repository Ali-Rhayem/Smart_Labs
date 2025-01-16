from confluent_kafka import Consumer, KafkaException, KafkaError
import json
import base64
from PIL import Image
import numpy as np
from pprint import pprint
import time
from consumer_utils import *
import os
from dotenv import load_dotenv
load_dotenv()

conf = {
    'bootstrap.servers': os.getenv("BOOTSTRAP_SERVERS"),
    'group.id': os.getenv("GROUP_ID"),
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)

consumer.subscribe([os.getenv("TOPIC")])

try:
    while True:
        try:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    print(f"End of partition reached: {msg.topic()} [{msg.partition()}] @ {msg.offset()}")
                else:
                    raise KafkaException(msg.error())
            else:
                pass
        except KafkaException as ke:
            print(f"KafkaException: {ke}")
            time.sleep(5)  # Retry after waiting for network issues or Kafka-related issues
        except Exception as e:
            print(f"Unexpected error: {e}")
            time.sleep(5)  # Retry in case of any other errors
except KeyboardInterrupt:
    print("Consuming interrupted by user")
finally:
    try:
        consumer.close()
    except Exception as e:
        print(f"Error closing the consumer: {e}")
     