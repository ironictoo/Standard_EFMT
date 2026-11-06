"""Make instruction slide 2 (practice and scan) with a photo of our button box.

Replaces the stock 4-button box on HARI_P_2_R.PNG and HARI_S_2_R.PNG with
Hariri/media/instructions/llu_button.png (2-button box: blue = left,
yellow = right) and writes HARI_P_2_LLU.PNG and HARI_S_2_LLU.PNG next to them.

Usage (from the repo root): .venv/bin/python tools/button_slides.py
"""
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from scipy import ndimage

folder = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                      'Hariri', 'media', 'instructions')
photo_file = os.path.join(folder, 'llu_button.png')
crop, fade = 340, 70  # keep the top of the photo (pixels), fading out the last part
# Button centres in the photo (pixels) and the radius of the circles around them
left_button, right_button, button_r = (88, 146), (171, 192), 46
font_file = '/usr/share/fonts/truetype/crosextra/Carlito-Bold.ttf'  # Calibri metrics
blue, yellow = (47, 85, 151), (255, 192, 0)  # label colours on the stock slides

# slide: (template, output, rows to replace with the photo)
slides = [('HARI_P_2_R.PNG', 'HARI_P_2_LLU.PNG', (350, 645)),
          ('HARI_S_2_R.PNG', 'HARI_S_2_LLU.PNG', (362, 635))]



def cut_out(photo):
    """Make the dark background around the box transparent."""
    dark = np.asarray(photo.convert('L')) < 150
    labels, _ = ndimage.label(dark)
    edge = np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
    background = np.isin(labels, edge[edge > 0])
    alpha = Image.fromarray(np.where(background, 0, 255).astype(np.uint8))
    alpha = alpha.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1))
    # crop the empty lower part of the box and fade it out
    ramp = np.clip((crop - np.arange(photo.height)) / fade, 0, 1)[:, None]
    photo.putalpha(Image.fromarray((np.asarray(alpha) * ramp).astype(np.uint8)))
    return photo.crop((0, 0, photo.width, crop))


ss = 4  # supersampling for smooth lines and circles
for template, output, (top, bottom) in slides:
    slide = Image.open(os.path.join(folder, template)).convert('RGBA')
    W, H = slide.size
    ImageDraw.Draw(slide).rectangle([0, top, W, bottom], fill='white')

    photo = cut_out(Image.open(photo_file).convert('RGBA'))
    h = bottom - top - 40
    scale = h / photo.height
    photo = photo.resize((round(photo.width * scale), h), Image.LANCZOS)
    x0, y0 = (W - photo.width) // 2, top + 25
    slide.alpha_composite(photo, (x0, y0))

    overlay = Image.new('RGBA', (W * ss, H * ss))
    d = ImageDraw.Draw(overlay)
    font = ImageFont.truetype(font_file, 43 * ss)
    for (bx, by), colour, text, side in [(left_button, blue, 'LEFT', -1),
                                        (right_button, yellow, 'RIGHT', 1)]:
        cx, cy, r = (x0 + bx * scale) * ss, (y0 + by * scale) * ss, button_r * scale * ss
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=colour, width=6 * ss)
        # label beside the box, joined to the circle by a line
        edge = (x0 if side < 0 else x0 + photo.width) * ss
        tx = edge + side * 70 * ss
        d.line([(cx + side * r, cy), (tx + side * 8 * ss, cy)], fill=colour, width=4 * ss)
        d.text((tx + side * 15 * ss, cy), text, font=font, fill=colour,
               anchor='rm' if side < 0 else 'lm')
    slide.alpha_composite(overlay.resize((W, H), Image.LANCZOS))
    slide.save(os.path.join(folder, output))
    print('wrote', output)
