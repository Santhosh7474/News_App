from PIL import Image
import sys

try:
    # Open the image with alpha channel
    img = Image.open('assets/app_icon.png').convert("RGBA")

    # Create a new solid black background image
    bg = Image.new("RGBA", img.size, (0, 0, 0, 255)) # Black background

    # Paste the original image on top of the black background, using the original's alpha channel as mask
    bg.paste(img, (0, 0), img)

    # Convert to RGB (dropping the alpha channel entirely to appease iOS)
    bg = bg.convert("RGB")

    # Save over the original or to a new file
    bg.save('assets/app_icon.png', "PNG")
    print("Successfully flattened app icon onto black background")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
