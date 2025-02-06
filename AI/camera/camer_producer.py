def get_image_from_rpi():
    pass

def get_random_image():
    folder_path = "../test_images"
    image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp'}
    images = [f for f in os.listdir(folder_path) if os.path.splitext(f)[1].lower() in image_extensions]
    
    if not images:
        raise ValueError("No image files found in the specified folder.")
    
    # Select a random image
    return os.path.join(folder_path, random.choice(images))

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

def produce(data):
    producer = KafkaProducer(
    bootstrap_servers=BOOTSTRAP_SERVERS,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )
    topic = os.getenv("CAMERA_TOPIC")
    image_path = get_random_image()
    data["encoding"] = images_to_base64(image_path)
    producer.send(topic, value=data)
    producer.flush()
    producer.close()
