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