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