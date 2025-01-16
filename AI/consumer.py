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

                    # Assigning faces to people
                    for face in faces:
                        fbbox = face["bounding_box"]
                        possible_persons_indexes = []
                        for index, person in enumerate(person_objs):
                            pbbox = person["person"]
                            if overlap_percentage(fbbox, pbbox) > 90:
                                possible_persons_indexes.append(index)

                        index = -1
                        if len(possible_persons_indexes) == 1:
                            index = possible_persons_indexes[0]
                        elif len(possible_persons_indexes) > 1:
                            max_area = 0
                            for i in possible_persons_indexes:
                                area = bbox_area(person_objs[index]["person"])
                                if area > max_area:
                                    max_area = area
                                    index = i

                        person_objs[index]["face"] = face["bounding_box"]
                        person_objs[index]["identity"] = face["identity"]
                        person_objs[index]["_id"] = face["_id"]
                        person_objs[index]["identity_confidence"] = face["identity_confidence"]

                    # Deleting people without faces
                    person_objs = [person for person in person_objs if "face" in person]

                    # Assigning other objects to people
                    for obj in other_objs:
                        # Assigning helmets, goggles, mask to people
                        if obj["class_name"] in ["helmet", "goggles", "mask"]:
                            object_bbox = obj["bounding_box"]
                            class_name = obj["class_name"]
                            oxm = (object_bbox[0] + object_bbox[2]) / 2
                            for person in person_objs:
                                person_bbox = person["person"]
                                fx1, fy1, fx2, fy2 = person["face"]
                                if overlap_percentage(object_bbox, person_bbox) > 90:
                                    if fx1 <= oxm <= fx2:
                                        person[class_name] = object_bbox
                                        break

                        # Assigning lab coat to people
                        if obj["class_name"] == "lab coat":
                            object_bbox = obj["bounding_box"]
                            for person in person_objs:
                                person_bbox = person["person"]
                                if overlap_percentage(object_bbox, person_bbox) > 90:
                                    person["lab coat"] = object_bbox
                                    break

                        # Assigning gloves to people
                        if obj["class_name"] == "gloves":
                            object_bbox = obj["bounding_box"]
                            possible_persons_indexes = []
                            for index, person in enumerate(person_objs):
                                person_bbox = person["person"]
                                if overlap_percentage(object_bbox, person_bbox) > 90:
                                    possible_persons_indexes.append(index)

                            index = -1
                            if len(possible_persons_indexes) == 1:
                                index = possible_persons_indexes[0]
                            else:
                                min_distance = float("inf")
                                for i in possible_persons_indexes:
                                    person_bbox = person_objs[i]["person"]
                                    distance = min(abs(obj - person) for obj, person in zip(object_bbox, person_bbox))
                                    if distance < min_distance:
                                        min_distance = distance
                                        index = i
                            if "gloves" not in person_objs[index]:
                                person_objs[index]["gloves"] = []
                            person_objs[index]["gloves"].append(object_bbox)

                    # draw_objects(image, person_objs)
                    people = []
                    pprint(person_objs)
                    
                    # Prepare the data to be inserted into the database
                    for person in person_objs:
                        person_data = {
                            "id": person["_id"],
                            "name": person["identity"],
                            "ppe": {}
                        }
                        for ppe in required_ppe:
                            if ppe not in person.keys():
                                person_data["ppe"][ppe] = 0
                            else:
                                person_data["ppe"][ppe] = 1

                        people.append(person_data)

                    

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
     