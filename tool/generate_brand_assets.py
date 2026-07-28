#!/usr/bin/env python3
"""Generate miToosa Aetheric Pulse brand master and iOS launch images (BL-33)."""
from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]


def draw_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (10, 12, 28, 255))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    scale = size / 1024
    points = [
        (cx, int(cy - 312 * scale)),
        (int(cx - 162 * scale), int(cy + 20 * scale)),
        (int(cx + 162 * scale), int(cy)),
        (int(cx - 92 * scale), int(cy + 128 * scale)),
        (int(cx + 92 * scale), int(cy + 140 * scale)),
        (cx, cy),
    ]
    for i, point in enumerate(points):
        nxt = points[(i + 1) % len(points)]
        draw.line([point, nxt], fill=(72, 132, 210, 200), width=max(2, int(5 * scale)))
    for point in points[:-1]:
        radius = max(6, int(14 * scale))
        draw.ellipse(
            (point[0] - radius, point[1] - radius, point[0] + radius, point[1] + radius),
            fill=(130, 210, 255, 255),
        )
    radius = max(10, int(40 * scale))
    draw.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=(186, 132, 255, 255))
    inner = int(radius * 0.55)
    draw.ellipse((cx - inner, cy - inner, cx + inner, cy + inner), fill=(240, 220, 255, 255))
    return img


def main() -> None:
    brand_dir = ROOT / "assets" / "brand"
    brand_dir.mkdir(parents=True, exist_ok=True)
    master_path = brand_dir / "aetheric_pulse_mark_1024.png"
    draw_mark(1024).save(master_path)

    launch_dir = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    for name, size in [("LaunchImage.png", 168), ("LaunchImage@2x.png", 336), ("LaunchImage@3x.png", 504)]:
        draw_mark(size).save(launch_dir / name)

    digest = hashlib.sha256(master_path.read_bytes()).hexdigest()
    print(f"Wrote {master_path} sha256={digest}")


if __name__ == "__main__":
    main()
