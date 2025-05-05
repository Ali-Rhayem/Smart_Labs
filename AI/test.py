def capture_image(save_path="/home/pi/Desktop/image.jpg"):
    """
    Captures an image using the Raspberry Pi camera and saves it to the specified location.

    :param save_path: The file path where the image will be saved.
    """
    capture_command = f"libcamera-still -o {save_path}"
    subprocess.run(capture_command, shell=True, check=True)

from picamera2 import Picamera2

def capture_image(save_path="/home/pi/Desktop/image.jpg"):
    """
    Captures an image using the Raspberry Pi camera and saves it to the specified location.

    :param save_path: The file path where the image will be saved.
    """
    picam2 = Picamera2()
    picam2.configure(picam2.create_still_configuration())  # Set to still image mode
    picam2.start()
    picam2.capture_file(save_path)
    picam2.stop()

# Example usage
capture_image()