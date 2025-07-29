import sys
import json
from PIL import Image

def resize_image(input_path, output_path, scale_percent, interpolation_str):
    """
    Resizes an image based on a percentage and saves it.
    """
    try:
        with Image.open(input_path) as img:
            # Determine the resampling filter based on the string input
            if interpolation_str == 'cubic':
                resample_filter = Image.Resampling.BICUBIC
            else:  # Default to nearest for 'none' or any other value
                resample_filter = Image.Resampling.NEAREST

            original_width, original_height = img.size
            
            # Calculate the new dimensions
            new_width = int(original_width * scale_percent / 100)
            new_height = int(original_height * scale_percent / 100)

            # Ensure the new dimensions are at least 1 pixel
            if new_width < 1:
                new_width = 1
            if new_height < 1:
                new_height = 1

            # Resize the image
            resized_img = img.resize((new_width, new_height), resample=resample_filter)
            
            # Save the new image
            resized_img.save(output_path)

            # Print the new dimensions as a JSON string to stdout
            # so the calling Dart process can retrieve them.
            print(json.dumps({'width': new_width, 'height': new_height}))

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 resize.py <input_path> <output_path> <scale_percent> <interpolation>", file=sys.stderr)
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    scale_percent = float(sys.argv[3])
    interpolation = sys.argv[4]  # 'cubic' or 'nearest'
    
    resize_image(input_path, output_path, scale_percent, interpolation) 