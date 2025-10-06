import sys
import json
from PIL import Image
import colormath.color_objects
import colormath.color_diff
import colormath.color_conversions

def quantize_image(input_path, output_path, num_colors, separation, kl, kc, kh):
    try:
        with Image.open(input_path) as img:
            img_rgb = img.convert("RGB")

            # 1. Generate a large color pool (256 colors) to work from.
            # This gives us a good starting selection of the most prominent colors.
            # We quantize first to create a manageable initial palette.
            initial_quant_img = img_rgb.quantize(colors=256, method=Image.Quantize.MEDIANCUT)
            
            # getcolors() returns a list of (count, index) tuples, sorted by count.
            color_counts_list = initial_quant_img.getcolors(256) 
            palette_rgb = initial_quant_img.getpalette()

            # Create a list of sRGBColor objects from the initial palette,
            # which will be inherently sorted by frequency due to getcolors().
            initial_palette = []
            if color_counts_list and palette_rgb:
                for count, index in color_counts_list:
                    r, g, b = palette_rgb[index*3 : index*3+3]
                    initial_palette.append(colormath.color_objects.sRGBColor(r, g, b, is_upscaled=True))

            # 2. Filter this large pool to get a list of perceptually distinct colors.
            # Since the list is sorted by prominence, we keep the first color we see
            # and discard any subsequent colors that are too similar to those already kept.
            distinct_palette = []
            for color in initial_palette:
                is_distinct_enough = True
                lab_color1 = colormath.color_conversions.convert_color(color, colormath.color_objects.LabColor)

                for existing_color in distinct_palette:
                    lab_color2 = colormath.color_conversions.convert_color(existing_color, colormath.color_objects.LabColor)
                    
                    delta_e = colormath.color_diff.delta_e_cie2000(lab_color1, lab_color2, Kl=kl, Kc=kc, Kh=kh)

                    if delta_e < separation:
                        # This color is too similar to a more prominent color already in our list.
                        is_distinct_enough = False
                        break
                
                if is_distinct_enough:
                    distinct_palette.append(color)

            # 3. Trim the list of distinct colors to the desired final count.
            final_palette = distinct_palette[:num_colors]
            
            # Convert final palette back to simple list for JSON output
            output_colors = [c.get_upscaled_value_tuple() for c in final_palette]

            # 4. Create the final image using the carefully selected palette.
            final_palette_img = Image.new('P', (1, 1))
            # Create a flat list of RGB values for the palette
            final_palette_flat = [val for color in final_palette for val in color.get_upscaled_value_tuple()]
            # Pad the palette to 256*3 values if it's smaller, as required by Pillow
            final_palette_flat.extend([0] * (256 * 3 - len(final_palette_flat)))
            final_palette_img.putpalette(final_palette_flat)
            
            # Quantize the original image using the final, calculated palette
            final_img = img_rgb.quantize(palette=final_palette_img, dither=Image.Dither.NONE)
            final_img = final_img.convert("RGB")
            final_img.save(output_path)
            
            print(json.dumps(output_colors))

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 8:
        print("Usage: python3 quantize.py <input_path> <output_path> <num_colors> <separation> <kl> <kc> <kh>", file=sys.stderr)
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    num_colors = int(sys.argv[3])
    separation = float(sys.argv[4])
    kl = float(sys.argv[5])
    kc = float(sys.argv[6])
    kh = float(sys.argv[7])
    
    quantize_image(input_path, output_path, num_colors, separation, kl, kc, kh) 