import json
import os
import datetime
from producer_utils import *
from kafka import KafkaProducer
import time
images_folder = "./test_images"

producer = KafkaProducer(bootstrap_servers=os.getenv("BOOTSTRAP_SERVERS"), value_serializer=lambda v: str(v).encode('utf-8'))
topic = 'test_topic'

for filename in os.listdir(images_folder):
    if filename.endswith(".jpg") or filename.endswith(".png"):
        image_path = os.path.join(images_folder, filename)
        data = {
            "encoding": images_to_base64(image_path),
            "ppe_arr": ["gloves", "goggles"],
            "session_id" : 1,
            "lab_id" : 1,
            "room": "B-103",
            "date": datetime.date.today().strftime("%Y-%m-%d"),
            "time": datetime.datetime.now().strftime("%H:%M:%S")
        }
        producer.send(topic, value=json.dumps(data))
        print(f"Sent: {filename}")