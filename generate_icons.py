#!/usr/bin/env python3
"""
Generate Android app launcher icons based on current month's stage image.
"""

import os
import datetime
from PIL import Image, ImageDraw, ImageFilter

def get_stage_image_path():
    """Get the stage image path based on current month."""
    current_month = datetime.datetime.now().month
    
    if current_month in [12, 1, 2, 3]:
        return "assets/images/stages/stage_seed.jpg"
    elif current_month in [4, 5]:
        return "assets/images/stages/stage_sprout.jpg"
    elif current_month in [6, 7]:
        return "assets/images/stages/stage_stem.jpg"
    elif current_month in [8, 9]:
        return "assets/images/stages/stage_flower.jpg"
    else:  # Oct, Nov
        return "assets/images/stages/stage_harvest.jpg"

def crop_to_square(image):
    """Crop image to square using center crop."""
    width, height = image.size
    size = min(width, height)
    
    left = (width - size) // 2
    top = (height - size) // 2
    right = left + size
    bottom = top + size
    
    return image.crop((left, top, right, bottom))

def make_rounded_icon(img, size, radius_ratio=0.22):
    """Create rounded icon with drop shadow."""
    # Resize image to target size
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Create a slightly larger canvas for shadow
    shadow_size = size + 8
    shadow_canvas = Image.new('RGBA', (shadow_size, shadow_size), (0, 0, 0, 0))
    
    # Create mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    radius = int(size * radius_ratio)
    draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    
    # Apply drop shadow
    shadow_offset = 2
    shadow_img = Image.new('RGBA', (size, size), (0, 0, 0, 60))  # Semi-transparent black
    shadow_img.paste(shadow_img, (shadow_offset, shadow_offset))
    
    # Paste shadow onto canvas (centered)
    shadow_canvas.paste(shadow_img, (4, 4))
    
    # Create final result with rounded corners
    result = Image.new('RGBA', (shadow_size, shadow_size), (0, 0, 0, 0))
    
    # Paste the main image with rounded corners
    rounded_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    rounded_img.paste(img, mask=mask)
    
    # Center the rounded image on the shadow canvas
    paste_x = (shadow_size - size) // 2
    paste_y = (shadow_size - size) // 2
    shadow_canvas.paste(rounded_img, (paste_x, paste_y), mask=rounded_img.split()[-1])
    
    return shadow_canvas

def generate_icons():
    """Generate launcher icons at required sizes."""
    # Icon sizes and paths
    icon_configs = [
        (48, "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
        (72, "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
        (96, "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
        (144, "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
        (192, "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
    ]
    
    # Get source image path
    source_path = get_stage_image_path()
    
    if not os.path.exists(source_path):
        print(f"Error: Source image not found: {source_path}")
        return False
    
    try:
        # Open and crop source image
        with Image.open(source_path) as img:
            # Convert to RGB if necessary
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Crop to square
            square_img = crop_to_square(img)
            
            # Generate each icon size
            for size, output_path in icon_configs:
                # Create directory if it doesn't exist
                os.makedirs(os.path.dirname(output_path), exist_ok=True)
                
                # Create rounded icon with shadow
                final_icon = make_rounded_icon(square_img, size)
                
                # Save icon
                final_icon.save(output_path, "PNG")
                print(f"Generated: {output_path} ({size}x{size})")
        
        print(f"\n✅ Successfully generated launcher icons from {source_path}")
        return True
        
    except Exception as e:
        print(f"Error generating icons: {e}")
        return False

if __name__ == "__main__":
    print("🌱 OmniGarden Icon Generator")
    print("=" * 40)
    
    current_month = datetime.datetime.now().strftime("%B")
    stage_image = get_stage_image_path()
    
    print(f"Current month: {current_month}")
    print(f"Using stage image: {stage_image}")
    print()
    
    if generate_icons():
        print("🎉 Icon generation completed successfully!")
    else:
        print("❌ Icon generation failed. Check the error messages above.")
