import json
import datetime
import time
from kafka import KafkaProducer
from dotenv import load_dotenv
import os
from dotenv import load_dotenv
load_dotenv()

producer = KafkaProducer(
    bootstrap_servers=os.getenv("BOOTSTRAP_SERVERS"),
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

topic = os.getenv("RECORDING_TOPIC")
images_folder = "./test_images"

data = {
            "command": "end",
            "ppe_arr": ["gloves", "goggles"],
            "session_id": 4,
            "lab_id": 6,
            "room": "B-103",
        }

future = producer.send(topic, value=data)
result = future.get(timeout=10)  # Ensure message is sent
print("Start Message Sent")
producer.flush()
producer.close()

