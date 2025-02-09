#!/usr/bin/env python3
import os
import sys
from PIL import Image

def remove_metadata(image_path):
    """
    Opens the image, extracts the raw pixel data, creates a new image without metadata,
    and saves it over the original file.
    """
    try:
        with Image.open(image_path) as img:
            # Extract raw pixel data.
            pixel_data = list(img.getdata())
            # Create a new image with the same mode and size.
            clean_img = Image.new(img.mode, img.size)
            clean_img.putdata(pixel_data)
            # Save the image without metadata.
            clean_img.save(image_path)
        print(f"Processed: {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

def process_directory(root_dir):
    """
    Recursively traverses directories starting from root_dir and processes image files.
    """
    # Define allowed image file extensions.
    allowed_extensions = {'.jpg', '.jpeg', '.png', '.webp', '.tiff', '.bmp'}
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            ext = os.path.splitext(filename)[1].lower()
            if ext in allowed_extensions:
                full_path = os.path.join(dirpath, filename)
                remove_metadata(full_path)

if __name__ == '__main__':
    # Use the first command-line argument as the root directory,
    # or default to the current directory.
    root_directory = sys.argv[1] if len(sys.argv) > 1 else '.'
    process_directory(root_directory)
