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
    "command": "start",
    "ppe_arr": [ "goggles","helmet"],
    "session_id": 7,
    "lab_id": 7,
    "room": "B-103",
    "start_time": datetime.datetime.now(datetime.timezone.utc).replace(hour=00, minute=10, second=0, microsecond=0).strftime("%H:%M"),
    "end_time": datetime.datetime.now(datetime.timezone.utc).replace(hour=00, minute=59, second=0, microsecond=0).strftime("%H:%M"),
}

future = producer.send(topic, value=data)
result = future.get(timeout=10)  # Ensure message is sent
print("Start Message Sent")
producer.flush()
producer.close()

