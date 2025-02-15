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
import os
from dotenv import load_dotenv
load_dotenv()

from pymongo import MongoClient
client = MongoClient(os.getenv("MONGO_URI"))
db = client[os.getenv("MONGO_DB")]

model = None
usersProfiles = None
model_path = './models/yolov8_ppe_m.pt'

def display_image(img_rgb):
    if img_rgb is None:
        print("The image is empty or not loaded.")
        return

    # Display the image
    plt.imshow(img_rgb)
    plt.axis('off')  # Hide the axes for better visualization
    plt.show()

def analyze_image(base64_str, image_path):
    global model
    if model is None:
        model = YOLO(model_path)
    
    if base64_str is None:
        raise ValueError("Failed to import the input image.")
    
    image_data = base64.b64decode(base64_str)
    
    np_arr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    
    image_array = np.array(image)

    results = model.predict(source=image_array)
    
    annotated_image = results[0].plot()  # Returns image with annotations
    
    # Save the annotated image to the specified path
    if not os.path.exists("./images"):
        os.makedirs("./images")
    cv2.imwrite(os.path.join(f"./images/{image_path}"), annotated_image)
    
    return results, image
    
def facenet_embed(img_rgb: np.ndarray):
    try:
        # Load the pretrained FaceNet model
        model = InceptionResnetV1(pretrained='vggface2').eval()

        # Define a transform pipeline to preprocess the image
        preprocess = transforms.Compose([
            transforms.Resize((160, 160)),       # Resize the image to 160x160 (required by FaceNet)
            transforms.ToTensor(),              # Convert image to PyTorch tensor
            transforms.Normalize(               # Normalize with FaceNet's required mean and std
                mean=[0.5, 0.5, 0.5],
                std=[0.5, 0.5, 0.5]
            )
        ])

        # Convert NumPy array to PIL Image
        img_pil = Image.fromarray(img_rgb)

        # Apply preprocessing
        img_tensor = preprocess(img_pil).unsqueeze(0)  # Add batch dimension

        # Generate embeddings
        with torch.no_grad():
            embeddings = model(img_tensor).cpu().numpy()

        return embeddings
    except Exception as e:
        print(f"Error generating embeddings: {e}")
        return None

def best_similarity(face_embedding, known_embeddings):
    face_embedding = np.array(face_embedding)  # Ensure input is a NumPy array
    known_embeddings = np.array(known_embeddings)  # Ensure known embeddings are NumPy arrays

    # Normalize embeddings to unit vectors
    face_norm = face_embedding / np.linalg.norm(face_embedding)
    known_norms = known_embeddings / np.linalg.norm(known_embeddings, axis=1, keepdims=True)

    # Compute cosine similarity
    similarity_scores = np.dot(known_norms, face_norm.T)
    return similarity_scores

def load_user_profiles():
    global usersProfiles
    users_collection = db['Users'] 
    
    pipeline = [
        {"$unwind": "$face_identity_vector"},
        {"$project": {"_id":1, "name": 1, "face_identity_vector": 1}}
    ]

    usersProfiles = list(users_collection.aggregate(pipeline))

def find_best_match(face_embedding):
    global usersProfiles
    if usersProfiles == None:
        load_user_profiles()
    known_embeddings = [user["face_identity_vector"] for user in usersProfiles]
    similarities = best_similarity(face_embedding, known_embeddings)
    best_match_index = np.argmax(similarities)
    best_match_name = usersProfiles[best_match_index]["name"]
    best_match_id = usersProfiles[best_match_index]["_id"]
    similarity_score = similarities[best_match_index]
    return best_match_id, best_match_name, similarity_score

def recognize_face(image, bounding_box):

    x1, y1, x2, y2 = bounding_box
    padding = 20
    dimensions = image.shape
    height, width, channels = dimensions
    
    x1 = int(max(0, x1 - padding))
    y1 = int(max(0, y1 - padding))
    x2 = int(min(width, x2 + padding))
    y2 = int(min(height, y2 + padding))
    
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

def draw_objects(image, all_persons):

    image_copy = image.copy()

    def get_random_color():
        return tuple(random.randint(0, 255) for _ in range(3))
    
    for person in all_persons:
        if "identity" not in person:
            continue
        
        color = get_random_color()

        if "person" in person:
            x1, y1, x2, y2 = map(int, person["person"])
            cv2.rectangle(image_copy, (x1, y1), (x2, y2), color, 2)
            cv2.putText(image_copy, "person", (x1, y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        
        if "face" in person:
            face_x1, face_y1, face_x2, face_y2 = map(int, person["face"])
            cv2.rectangle(image_copy, (face_x1, face_y1), (face_x2, face_y2), color, 2)
            cv2.putText(image_copy, person["identity"], (face_x1, face_y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            
        if "helmet" in person:
            helmet_x1, helmet_y1, helmet_x2, helmet_y2 = map(int, person["helmet"])
            cv2.rectangle(image_copy, (helmet_x1, helmet_y1), (helmet_x2, helmet_y2), color, 2)
            cv2.putText(image_copy, "helmet", (helmet_x1, helmet_y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        
        if "goggles" in person:
            goggles_x1, goggles_y1, goggles_x2, goggles_y2 = map(int, person["goggles"])
            cv2.rectangle(image_copy, (goggles_x1, goggles_y1), (goggles_x2, goggles_y2), color, 2)
            cv2.putText(image_copy, "goggles", (goggles_x1, goggles_y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            
        if "mask" in person:
            mask_x1, mask_y1, mask_x2, mask_y2 = map(int, person["mask"])
            cv2.rectangle(image_copy, (mask_x1, mask_y1), (mask_x2, mask_y2), color, 2)
            cv2.putText(image_copy, "mask", (mask_x1, mask_y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            
        if "lab coat" in person:
            lab_coat_x1, lab_coat_y1, lab_coat_x2, lab_coat_y2 = map(int, person["lab coat"])
            cv2.rectangle(image_copy, (lab_coat_x1, lab_coat_y1), (lab_coat_x2, lab_coat_y2), color, 2)
            cv2.putText(image_copy, "lab coat", (lab_coat_x1, lab_coat_y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        
        if "gloves" in person:
            for glove_bbox in person["gloves"]:
                gloves_x1, gloves_y1, gloves_x2, gloves_y2 = map(int, glove_bbox)
                cv2.rectangle(image_copy, (gloves_x1, gloves_y1), (gloves_x2, gloves_y2), color, 2)
                cv2.putText(image_copy, "gloves", (gloves_x1, gloves_y1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
    
    plt.imshow(cv2.cvtColor(image_copy, cv2.COLOR_BGR2RGB))
    plt.axis("off")
    plt.title("Image with Bounding Boxes")
    plt.show()
    
    return image_copy

