import json
import os
import datetime
import time
from producer_utils import images_to_base64
from kafka import KafkaProducer
from dotenv import load_dotenv

load_dotenv()

# Load environment variables
BOOTSTRAP_SERVERS = os.getenv("BOOTSTRAP_SERVERS")
if not BOOTSTRAP_SERVERS:
    raise ValueError("BOOTSTRAP_SERVERS environment variable is not set!")

# Kafka producer with proper JSON serialization
producer = KafkaProducer(
    bootstrap_servers=BOOTSTRAP_SERVERS,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

topic = os.getenv("SERVER_TOPIC")
images_folder = "./test_images"

for filename in os.listdir(images_folder):
    if filename.endswith(".jpg") or filename.endswith(".png"):
        image_path = os.path.join(images_folder, filename)
        
        # Prepare message
        data = {
            "command": "start",
            "encoding": images_to_base64(image_path),
            "ppe_arr": ["gloves", "goggles"],
            "session_id": 1,
            "lab_id": 1,
            "room": "B-103",
            "date": datetime.date.today().strftime("%Y-%m-%d"),
            "time": datetime.datetime.now().strftime("%H:%M:%S")
        }

        # Send message
        future = producer.send(topic, value=data)
        result = future.get(timeout=10)  # Ensure message is sent
        
        print(f"Sent: {filename} to partition {result.partition} at offset {result.offset}")
        break

# Ensure all messages are delivered
producer.flush()
producer.close()
