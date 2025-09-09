#!/usr/bin/env python3
import sys
import json

try:
    import cv2
except Exception as e:
    print(json.dumps({"error": f"OpenCV import failed: {e}"}), file=sys.stderr)
    sys.exit(1)


def interp_from_string(name: str):
    name = (name or '').lower()
    if name in ('nearest', 'nn'):  # Nearest neighbour
        return cv2.INTER_NEAREST
    if name in ('linear', 'bilinear'):  # Bilinear
        return cv2.INTER_LINEAR
    if name in ('cubic', 'bicubic'):  # Bicubic
        return cv2.INTER_CUBIC
    if name in ('area',):  # Good for downscaling
        return cv2.INTER_AREA
    if name in ('lanczos', 'lanczos4'):  # Higher quality
        return cv2.INTER_LANCZOS4
    return cv2.INTER_LINEAR


def main():
    if len(sys.argv) < 6:
        print(
            "Usage: resize_cv.py <input_path> <output_path> <width> <height> <interpolation>",
            file=sys.stderr,
        )
        sys.exit(2)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    width = int(sys.argv[3])
    height = int(sys.argv[4])
    interpolation = interp_from_string(sys.argv[5])

    img = cv2.imread(input_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        print(json.dumps({"error": "Failed to read input image"}), file=sys.stderr)
        sys.exit(3)

    resized = cv2.resize(img, (width, height), interpolation=interpolation)
    ok = cv2.imwrite(output_path, resized)
    if not ok:
        print(json.dumps({"error": "Failed to write output image"}), file=sys.stderr)
        sys.exit(4)

    print(json.dumps({"width": width, "height": height}))


if __name__ == "__main__":
    main()


