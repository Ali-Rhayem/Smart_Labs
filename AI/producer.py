import json
import os
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
            "date": "2021-08-01",
            "time": "12:00:00"
        }
        produce(json.dumps(image_data))