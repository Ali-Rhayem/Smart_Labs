import json
import os
import datetime
from producer_utils import *

images_folder = "./test_images"

for filename in os.listdir(images_folder):
    if filename.endswith(".jpg") or filename.endswith(".png"):
        image_path = os.path.join(images_folder, filename)
        image_data = {
            "encoding": images_to_base64(image_path),
            "ppe_arr": ["gloves", "goggles"],
            "session_id" : 1,
            "lab_id" : 1,
            "room"
            "date": datetime.date.today().strftime("%Y-%m-%d"),
            "time": datetime.datetime.now().strftime("%H:%M:%S")
        }
        produce(json.dumps(image_data))