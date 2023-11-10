import os
from PIL import Image, ImageFilter

def blur_image(input_filename):
    with Image.open(input_filename) as img:
        # Apply a GaussianBlur filter
        blurred_img = img.filter(ImageFilter.GaussianBlur(5))

        # Construct the output filename by splitting the input filename
        name_parts = input_filename.rsplit(".", 1)
        output_filename = f"{name_parts[0]}_blurred.{name_parts[1]}"

        # Save the blurred image to the output file
        blurred_img.save(output_filename)
        print(f"Saved blurred image as {output_filename}")

def blur_all_images_in_directory(directory):
    # List all files in the given directory
    for filename in os.listdir(directory):
        # Check for file extensions for jpg, jpeg, or png
        if filename.lower().endswith(('.jpg', '.jpeg', '.png')) and 'blurred' not in filename:
            blur_image(filename)

# Assuming the current directory should be blurred
blur_all_images_in_directory('.')
