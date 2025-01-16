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
                try:
                    data = json.loads(msg.value().decode('utf-8'))
                    image_base64 = data['encoding']
                    required_ppe = data['ppe_arr']
                    sessions = db['Sessions']
                    session_id = data["session_id"]
                    lab_id = data["lab_id"]
                    date = data["date"]
                    time_data = data["time"]
                    
                    image = resize_base64_image_to_image(image_base64)
                    results = analyze_image(image)
                    
                    person_objs = []
                    faces = []
                    other_objs = []
                    
                    
                    # Extracting objects from the image
                    for bbox in results[0].boxes:
                        try:
                            x1, y1, x2, y2 = bbox.xyxy[0]
                            x1 = float(x1)
                            y1 = float(y1)
                            x2 = float(x2)
                            y2 = float(y2)
                            confidence = bbox.conf
                            class_id = int(bbox.cls)
                            class_name = results[0].names[class_id].lower()

                            if confidence < 0.5:
                                continue

                            obj = {
                                "class_name": class_name,
                                "confidence": confidence,
                                "bounding_box": (x1, y1, x2, y2)
                            }

                            if class_name == "person":
                                obj["person"] = obj.pop("bounding_box")
                                person_objs.append(obj)
                            elif class_name == "face":
                                obj["_id"], obj["identity"], obj["identity_confidence"] = recognize_face(image, obj["bounding_box"])

                                if not obj["identity"].split("_")[0] == "Anonymous":
                                    faces.append(obj)
                            else:
                                other_objs.append(obj)
                        except Exception as e:
                            print(f"Error processing bounding box: {e}")
                            continue

                    

                except Exception as e:
                    print(f"Error processing message: {e}")
                    time.sleep(1)  # Wait a bit before retrying
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
     