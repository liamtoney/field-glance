# /// script
# requires-python = ">=3.12"
# dependencies = ["pillow>=11"]
# ///
"""Place the website's screenshots inside Apple's device bezels.

Run from anywhere with:

    uv run scripts/frame_screenshots.py

Reads the raw screenshots and bezels from screenshots/ and writes the framed images,
under the same names, to pages/static/screenshots/ for the website. Each screenshot is
centered behind its bezel's transparent screen opening, so the screenshot must have the
same pixel dimensions as that opening (the file names say which device it's from). The
result is scaled down to twice its displayed width on the home page, for sharp rendering
on high-resolution screens.
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'screenshots'
BEZELS = SOURCE / 'apple-product-bezels'
OUTPUT = ROOT / 'pages' / 'static' / 'screenshots'

# Download from https://developer.apple.com/design/resources/#product-bezels
IPHONE_16 = BEZELS / 'iPhone 16 - Black - Portrait.png'
WATCH_11_46MM = (
    BEZELS / 'Apple Watch S11 - 46mm - Aluminum Jet Black + Sport Band Black.png'
)

# Screenshot -> (bezel, output width in pixels). The widths are 2x the widths the home
# page displays them at (see .screenshots in pages/stylesheets/extra.css).
JOBS = {
    'iphone-16.png': (IPHONE_16, 560),
    'watch-11-46mm-1.png': (WATCH_11_46MM, 350),
    'watch-11-46mm-2.png': (WATCH_11_46MM, 350),
}


def frame(screenshot_path: Path, bezel_path: Path, width: int) -> Image.Image:
    screenshot = Image.open(screenshot_path).convert('RGBA')
    bezel = Image.open(bezel_path).convert('RGBA')

    canvas = Image.new('RGBA', bezel.size, (0, 0, 0, 0))
    x = (bezel.width - screenshot.width) // 2
    y = (bezel.height - screenshot.height) // 2
    canvas.paste(screenshot, (x, y))
    canvas.alpha_composite(bezel)

    height = round(canvas.height * width / canvas.width)
    return canvas.resize((width, height), Image.Resampling.LANCZOS)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for name, (bezel, width) in JOBS.items():
        out = OUTPUT / name
        frame(SOURCE / name, bezel, width).save(out, optimize=True)
        print(f'Wrote {out.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
