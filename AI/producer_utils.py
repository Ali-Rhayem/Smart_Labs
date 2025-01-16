from confluent_kafka import Producer
import sys
import base64
import os

def images_to_base64(image_path):
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"The image {image_path} does not exist.")
    
    if os.path.isfile(image_path) and image_path.lower().endswith(('png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp')):
        try:
            # Read the file in binary mode
            with open(image_path, "rb") as image_file:
                # Encode the binary data to Base64
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                return encoded_string
            
        except Exception as e:
            print(f"Could not process file {filename}: {e}")
            
def produce(message):
    def delivery_report(err, msg):
        if err is not None:
            print('Message delivery failed: {}'.format(err))
        else:
            print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

    # Configuring the Kafka producer
    conf = {
        'bootstrap.servers': 'localhost:9092',  # Replace with your Kafka server address
        'client.id': 'python-producer'
    }
    producer = Producer(conf)

