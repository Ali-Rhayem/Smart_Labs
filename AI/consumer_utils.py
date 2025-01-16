from ultralytics import YOLO
import base64
from PIL import Image
import numpy as np
import cv2
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
import torch
import matplotlib.pyplot as plt
import random
from dotenv import load_dotenv
import os
load_dotenv()

from pymongo import MongoClient
client = MongoClient(os.getenv("MONGO_URI"))
db = client[os.getenv("MONGO_DB")]

model = None
usersProfiles = None
model_path = './models/yolov8_ppe3.pt'

def display_image(img_rgb):
    if img_rgb is None:
        print("The image is empty or not loaded.")
        return

    # Display the image
    plt.imshow(img_rgb)
    plt.axis('off')  # Hide the axes for better visualization
    plt.show()
    
def analyze_image(image):
    global model
    if model is None:
        model = YOLO(model_path)
    
    if image is None:
        raise ValueError("Failed to resize the input image.")

    image_array = np.array(image)

    results = model.predict(source=image_array)
    
    return results

def resize_base64_image_to_image(base64_str, target_size=(640, 640)):
    try:
        image_data = base64.b64decode(base64_str)

        np_arr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if img is None:
            raise ValueError("Failed to decode the image. Ensure the Base64 input is valid.")

        resized_img = cv2.resize(img, target_size)

        return resized_img

    except Exception as e:
        print(f"Error resizing image: {e}")
        return None
    
def facenet_embed(img_rgb: np.ndarray):
    try:
        model = InceptionResnetV1(pretrained='vggface2').eval()

        preprocess = transforms.Compose([
            transforms.Resize((160, 160)),       
            transforms.ToTensor(),              
            transforms.Normalize(               
                mean=[0.5, 0.5, 0.5],
                std=[0.5, 0.5, 0.5]
            )
        ])

        img_pil = Image.fromarray(img_rgb)

        img_tensor = preprocess(img_pil).unsqueeze(0) 

        with torch.no_grad():
            embeddings = model(img_tensor).cpu().numpy()

        return embeddings
    except Exception as e:
        print(f"Error generating embeddings: {e}")
        return None
    
def best_similarity(face_embedding, known_embeddings):
    face_embedding = np.array(face_embedding) 
    known_embeddings = np.array(known_embeddings) 

    face_norm = face_embedding / np.linalg.norm(face_embedding)
    known_norms = known_embeddings / np.linalg.norm(known_embeddings, axis=1, keepdims=True)

    similarity_scores = np.dot(known_norms, face_norm.T)
    return similarity_scores

def load_user_profiles():
    global usersProfiles
    users_collection = db['Users'] 
    
    pipeline = [
        {"$unwind": "$embeddings"},
        {"$project": {"_id":1, "name": 1, "embeddings": 1}}
    ]

    usersProfiles = list(users_collection.aggregate(pipeline))

def find_best_match(face_embedding):
    global usersProfiles
    if usersProfiles == None:
        load_user_profiles()
    known_embeddings = [user["embeddings"] for user in usersProfiles]
    similarities = best_similarity(face_embedding, known_embeddings)
    best_match_index = np.argmax(similarities)
    best_match_name = usersProfiles[best_match_index]["name"]
    best_match_id = usersProfiles[best_match_index]["_id"]
    similarity_score = similarities[best_match_index]
    return best_match_id, best_match_name, similarity_score

def recognize_face(image, bounding_box):
    pass
  