
from PIL import Image, ImageFilter

def blur_image(input_filename):
    # Open an image file
    with Image.open(input_filename) as img:
        # Apply a GaussianBlur filter
        blurred_img = img.filter(ImageFilter.GaussianBlur(10))

        # Construct the output filename by splitting the input filename
        name_parts = input_filename.rsplit(".", 1)
        output_filename = f"{name_parts[0]}_blurred.{name_parts[1]}"

        # Save the blurred image to the output file
        blurred_img.save(output_filename)
        print(f"Saved blurred image as {output_filename}")

# Replace 'one.png' with the path to your image file
blur_image('diag.jpeg')
