import json
import os
import datetime
import time
from kafka import KafkaProducer
from dotenv import load_dotenv

producer = KafkaProducer(
    bootstrap_servers="localhost:9092",
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

topic = 'recording_se'
images_folder = "./test_images"

data = {
            "command": "end",
            # "encoding": images_to_base64(image_path),
            "ppe_arr": ["gloves", "goggles"],
            "session_id": 2,
            "lab_id": 1,
            "room": "B-103",
            "date": datetime.date.today().strftime("%Y-%m-%d"),
            "time": datetime.datetime.now().strftime("%H:%M:%S")
        }

future = producer.send(topic, value=data)
result = future.get(timeout=10)  # Ensure message is sent
print("Start Message Sent")
producer.flush()
producer.close()
