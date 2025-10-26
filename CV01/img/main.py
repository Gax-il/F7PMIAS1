import cv2
import numpy as np
import matplotlib.pyplot as plt


def load_color(filename: str) -> np.ndarray:
    img = cv2.imread(filename, cv2.IMREAD_COLOR)
    if img is None:
        raise FileNotFoundError(filename)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    return img.astype(np.float32) / 255.0


def convolve_color(image: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    channels = cv2.split(image)
    filtered = [cv2.filter2D(ch, -1, kernel) for ch in channels]
    merged = cv2.merge(filtered)
    return np.clip(merged, 0, 1)


def blur_image(image: np.ndarray) -> np.ndarray:
    kernel = np.ones((5, 5), np.float32) / 25.0
    return convolve_color(image, kernel)


def sharpen_image(image: np.ndarray, kernel_center: int = 5) -> np.ndarray:
    kernel = np.array(
        [[0, -1, 0], [-1, kernel_center, -1], [0, -1, 0]], dtype=np.float32
    )
    sharpened = convolve_color(image, kernel)
    sharpened = (sharpened - sharpened.min()) / (sharpened.max() - sharpened.min())
    return sharpened


def show_images(**images: np.ndarray) -> None:
    n = len(images)
    plt.figure(figsize=(4 * n, 5))

    for i, (title, img) in enumerate(images.items(), start=1):
        plt.subplot(1, n, i)
        plt.imshow(img)
        plt.axis("off")
        plt.title(title)

    plt.tight_layout()
    plt.show()


def main():
    img = load_color("brain-mri.jpg")
    blurred = blur_image(img)
    sharpened5 = sharpen_image(img, kernel_center=5)
    # sharpened6 = sharpen_image(img, kernel_center=6)
    # sharpened9 = sharpen_image(img, kernel_center=9)

    show_images(
        Original=img,
        Blurred=blurred,
        Sharpen=sharpened5,  # vypada nejlip imo
        # Sharpen_k6=sharpened6,
        # Sharpen_k9=sharpened9,
    )


if __name__ == "__main__":
    main()
