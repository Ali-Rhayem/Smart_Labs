from confluent_kafka import Producer
import sys
import base64
import os

def images_to_base64(image_path):
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"The image {image_path} does not exist.")