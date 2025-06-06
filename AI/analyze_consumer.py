from kafka import KafkaConsumer, TopicPartition
from kafka.errors import KafkaError
import json
import base64
from PIL import Image
import numpy as np
from pprint import pprint
import time
from consumer_utils import *
import datetime
import os
from dotenv import load_dotenv
load_dotenv()

topic = os.getenv("ANALYSIS_TOPIC")

consumer = KafkaConsumer(
    topic,
    bootstrap_servers=os.getenv("BOOTSTRAP_SERVERS"),
    group_id=os.getenv("MODEL_GROUP"),
    auto_offset_reset='latest',
    enable_auto_commit=True,
    value_deserializer=lambda x: x.decode('utf-8'),
)
print("Consumer Started")
try:
    for msg in consumer:
        try:
            print("Message Received")
            # The value is already deserialized via value_deserializer.
            data = json.loads(msg.value)
            image_base64 = data['encoding']

            required_ppe = data['ppe_arr']
            # Assuming db is already defined/imported from consumer_utils or elsewhere.
            sessions = db['Sessions']
            session_id = data["session_id"]
            lab_id = data["lab_id"]
            date = datetime.date.today().strftime("%Y-%m-%d")
            time_data = data["time"]
            image_name = data["image_name"]

            results, image = analyze_image(image_base64,image_name)

            person_objs = []
            faces = []
            other_objs = []

            # Extracting objects from the image.
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

                    if confidence < 0.7:
                        continue

                    obj = {
                        "class_name": class_name,
                        "confidence": confidence,
                        "bounding_box": (x1, y1, x2, y2)
                    }

                    if class_name == "person":
                        # Rename key to "person" for further processing.
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

            # Assigning faces to people.
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
                        area = bbox_area(person_objs[i]["person"])
                        if area > max_area:
                            max_area = area
                            index = i
                if index != -1:
                    person_objs[index]["face"] = face["bounding_box"]
                    person_objs[index]["identity"] = face["identity"]
                    person_objs[index]["_id"] = face["_id"]
                    person_objs[index]["identity_confidence"] = face["identity_confidence"]

            # Deleting people without faces.
            person_objs = [person for person in person_objs if "face" in person]

            # Assigning other objects to people.
            for obj in other_objs:
                # For helmets, goggles, mask:
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

                # For lab coat:
                if obj["class_name"] == "lab coat":
                    object_bbox = obj["bounding_box"]
                    for person in person_objs:
                        person_bbox = person["person"]
                        if overlap_percentage(object_bbox, person_bbox) > 90:
                            person["lab coat"] = object_bbox
                            break

                # For gloves:
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
                            distance = min(abs(o - p) for o, p in zip(object_bbox, person_bbox))
                            if distance < min_distance:
                                min_distance = distance
                                index = i
                    if index != -1:
                        if "gloves" not in person_objs[index]:
                            person_objs[index]["gloves"] = []
                        person_objs[index]["gloves"].append(object_bbox)

            # Optionally, draw objects on the image.
            # draw_objects(image, person_objs)

            people = []
            # pprint(person_objs)

            # Prepare the data for the database.
            for person in person_objs:
                person_data = {
                    "id": person["_id"],
                    "name": person["identity"],
                    "ppe": {}
                }
                for ppe in required_ppe:
                    person_data["ppe"][ppe] = 1 if ppe in person.keys() else 0

                people.append(person_data)

            session_exists = sessions.find_one({"_id": session_id})
            if not session_exists:
                sessions.insert_one({
                    "_id": session_id,
                    "lab_id": lab_id,
                    "date": date,
                    "outputs": []
                })

            session_entry = {
                "time": time_data,
                "people": people
            }

            sessions.update_one(
                {"_id": session_id},
                {"$push": {"outputs": session_entry}}
            )

            if data["command"] == "end":                
                total_attendance = 0
                total_ppe_compliance = {ppe:0 for ppe in required_ppe}

                users = db["Users"]
                lab = db["Labs"].find_one({"_id": lab_id})
                
                students_in_lab = lab["Students"]

                result = {
                    str(student_id): {
                        "name": users.find_one(
                            {"_id": student_id},
                            {"_id": 0, "name": 1},
                        )["name"],
                        "attendance_percentage": 0,
                        "ppe_compliance": {ppe: 0 for ppe in required_ppe},
                    }
                    for student_id in students_in_lab
                }

                session = sessions.find_one({"_id": session_id})
                
                images = session["outputs"]
                images_count = len(images)
                images_per_student = {str(student_id): 0 for student_id in students_in_lab}
                
                total_people_attended = set()

                analysis_per_x_images = 10
                counter = 0
                ppe_compliance_bytime = {ppe: [] for ppe in required_ppe}
                temp_ppe_compliance_bytime = {ppe: 0 for ppe in required_ppe}
                temp_ppe_compliance_per_image = {ppe: 0 for ppe in required_ppe}
                total_ppe_compliance_bytime = []
                
                for image in images:
                    students_in_frame = set()
                    for person in image["people"]:
                        student_id = str(person["id"])
    
                        if student_id in result: # Check if student is in this lab
                            total_people_attended.add(student_id)
                        
                            if student_id not in students_in_frame: # Check if student appeard before in this image 
                                students_in_frame.add(student_id)
                                images_per_student[student_id] += 1
                                students_in_frame.add(student_id)
                                
                                # Calculate Attendance Percentage
                                result[student_id]["attendance_percentage"] += round( 100 / images_count)
                                total_attendance += round(100 / images_count)
                                
                                # Calculate PPE Compliance per student and by time 
                                for ppe in required_ppe:
                                    result[student_id]["ppe_compliance"][ppe] += person["ppe"][ppe]
                                    temp_ppe_compliance_per_image[ppe]+= person["ppe"][ppe] 
                    
                    # Calculate Avg PPE Compliance in each image and add it to temp_ppe_complaince
                    if (len(students_in_frame) != 0):
                        temp_ppe_compliance_bytime = {ppe : value + temp_ppe_compliance_per_image[ppe]/len(students_in_frame) for ppe, value in temp_ppe_compliance_bytime.items()}
                        temp_ppe_compliance_per_image = {ppe: 0 for ppe in required_ppe}
                    
                    # Calculate Avg PPE Compliance by x images
                    if (counter % analysis_per_x_images == 0 and counter != 0) or counter == len(images) - 1:
                        total_ppe_compliance_bytime_temp = 0
                        for ppe in required_ppe:
                            ppe_compliance_bytime[ppe].append(round(temp_ppe_compliance_bytime[ppe] * 100 / analysis_per_x_images)) # Calculate Avg PPE Compliance by x images
                            total_ppe_compliance_bytime_temp += round(temp_ppe_compliance_bytime[ppe] * 100 / analysis_per_x_images) # Calculate Total PPE Compliance for each ppe
                        
                        total_ppe_compliance_bytime.append(round(total_ppe_compliance_bytime_temp / len(required_ppe)))
                        temp_ppe_compliance_bytime = {ppe: 0 for ppe in required_ppe}  

                    counter += 1
                    
                for ppe in required_ppe:
                    total_ppe_compliance[ppe] = 0
                    for student_id in result:
                        if images_per_student[student_id] == 0:
                            result[student_id]["ppe_compliance"][ppe] = 0
                        else:
                            result[student_id]["ppe_compliance"][ppe] = round(result[student_id]["ppe_compliance"][ppe] * 100 / images_per_student[student_id])
                            total_ppe_compliance[ppe] += round(result[student_id]["ppe_compliance"][ppe])
                            
                    total_ppe_compliance[ppe] = round(total_ppe_compliance[ppe]/ len(total_people_attended))

                
                
                total_attendance = round(total_attendance / len(students_in_lab))
                print("result", result)
                # print("total_attendance", total_attendance)
                # print("total_ppe_compliance", total_ppe_compliance)
                # print("total_people_attended", total_people_attended)
                # print("Total students in lab", students_in_lab)
                
                results_arr = [{"_id": int(key), **value} for key, value in result.items()]
                
                report = f"""
                Lab Report - {date}
                
                Total Attendance: {total_attendance}%
                
                Total PPE Compliance: {total_ppe_compliance}%

                Individual Compliance:
                """

                for person in results_arr:
                    report += f"""
                Name: {person['name']}
                Attendance: {person['attendance_percentage']}%
                PPE Compliance:
                """
                    for ppe, compliance in person["ppe_compliance"].items():
                        report += f"\t- {ppe}: {compliance}%\n"
        
                sessions.update_one(
                    {"_id": session_id},
                    {"$set": {"result": results_arr, "total_attendance": total_attendance, "total_ppe_compliance": total_ppe_compliance,"ppe_compliance_bytime":ppe_compliance_bytime ,"total_ppe_compliance_bytime": total_ppe_compliance_bytime, "report":report}}
                )
                
                

        except Exception as e:
            print(f"Error processing message: {e}")
            time.sleep(1)

except KeyboardInterrupt:
    consumer.close()
    print("Consumer closed")
    exit(0)
