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

    x1, y1, x2, y2 = bounding_box
    padding = 20
    x1 = int(max(0, x1 - padding))
    y1 = int(max(0, y1 - padding))
    x2 = int(min(640, x2 + padding))
    y2 = int(min(640, y2 + padding))
    
    face_crop = image[y1:y2, x1:x2]
    
    img_rgb = cv2.cvtColor(face_crop, cv2.COLOR_BGR2RGB)
    
    # plt.imshow(img_rgb)
    
    face_embedding = facenet_embed(img_rgb)
    
    best_id, best_name, score = find_best_match(face_embedding)
    if score[0] < 0.5:
        anonymous_collection = db['Anonymous']
        anonymous_count = anonymous_collection.count_documents({})
        anonymous_id = anonymous_count + 1
        # Save the face image
        img_pil = Image.fromarray(img_rgb)
        img_path = f"./anonymous_faces/anonymous_{anonymous_id}.png"
        img_pil.save(img_path)
        
        anonymous_collection.insert_one({
            "id": anonymous_id,
            "name": f"Anonymous_{anonymous_id}",
            "embedding": face_embedding.tolist(),
            "face_path": img_path
        })
        best_name = "Anonymous_{anonymous_id}"
        best_id = anonymous_id
        
    return best_id, best_name, score[0]

def overlap_percentage(bbox1, bbox2):
    x1_1, y1_1, x2_1, y2_1 = bbox1
    x1_2, y1_2, x2_2, y2_2 = bbox2

    inter_x1 = max(x1_1, x1_2)
    inter_y1 = max(y1_1, y1_2)
    inter_x2 = min(x2_1, x2_2)
    inter_y2 = min(y2_1, y2_2)

    inter_width = max(0, inter_x2 - inter_x1)
    inter_height = max(0, inter_y2 - inter_y1)
    inter_area = inter_width * inter_height

    area1 = (x2_1 - x1_1) * (y2_1 - y1_1)
    area2 = (x2_2 - x1_2) * (y2_2 - y1_2)

    smaller_area = min(area1, area2)

    if smaller_area == 0:
        return 0.0 
    percentage_inside = (inter_area / smaller_area) * 100

    return percentage_inside

def bbox_area(bbox):
    x1, y1, x2, y2 = bbox
    width = max(0, x2 - x1)
    height = max(0, y2 - y1)
    return width * height
