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
        pass
except KeyboardInterrupt:
    print("Consuming interrupted by user")
finally:
    try:
        consumer.close()
    except Exception as e:
        print(f"Error closing the consumer: {e}")
     