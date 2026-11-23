from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
MASTER = ROOT / "assets" / "branding" / "work_calendar_icon.png"


def resized(image: Image.Image, size: int) -> Image.Image:
    return image.resize((size, size), Image.Resampling.LANCZOS)


def main() -> None:
    master = Image.open(MASTER).convert("RGBA")
    if master.width != master.height:
        raise SystemExit("Icon master must be square")

    opaque = Image.new("RGBA", master.size, "#F5F5F7")
    opaque.alpha_composite(master)
    opaque = opaque.convert("RGB")
    resized(opaque, 1024).save(
        ROOT / "assets" / "branding" / "work_calendar_icon_opaque.png"
    )

    ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    for output in [
        ROOT / "windows" / "runner" / "resources" / "app_icon.ico",
        ROOT / "assets" / "tray" / "app_icon.ico",
    ]:
        master.save(output, format="ICO", sizes=ico_sizes)

    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in android_sizes.items():
        resized(master, size).save(
            ROOT / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher.png"
        )

    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    ios_dir = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for filename, size in ios_sizes.items():
        resized(opaque, size).save(ios_dir / filename)

    macos_dir = ROOT / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for size in [16, 32, 64, 128, 256, 512, 1024]:
        resized(master, size).save(macos_dir / f"app_icon_{size}.png")

    print("Generated Windows, tray, Android, iOS, and macOS app icons.")


if __name__ == "__main__":
    main()
