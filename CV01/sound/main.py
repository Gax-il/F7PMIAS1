import numpy as np
import sounddevice as sd
import librosa
from scipy.signal import decimate
from sklearn.preprocessing import normalize


def load_audio(filename: str):
    y, fs = librosa.load(filename, sr=None, mono=True)
    print(f"Načten soubor: {filename} - {fs} Hz - {len(y)} vzorků")
    return y, fs


def decimate_audio(y: np.ndarray, factor: int):
    y_dec = decimate(
        y, factor, zero_phase=True
    )  # s audiem jsem nedelal ale vygooglil jsem si ze zerophase je lepsi
    y_dec_norm = normalize(y_dec.reshape(1, -1)).flatten()
    new_fs = fs // factor
    return y_dec_norm, new_fs


def subsample_audio(y: np.ndarray, factor: int):
    y_sub = y[::factor]
    y_sub_norm = normalize(y_sub.reshape(1, -1)).flatten()
    new_fs = fs // factor
    return y_sub_norm, new_fs


def play_audio(y: np.ndarray, fs: int, desc: str):
    print(f"▶️  Přehrávám: {desc}")
    sd.play(y, fs)
    sd.wait()


if __name__ == "__main__":
    filename = "breath.mp3"
    factor = 16
    y, fs = load_audio(filename)
    y_dec_norm, fs_dec = decimate_audio(y, factor)
    y_sub_norm, fs_sub = subsample_audio(y, factor)
    play_audio(y_dec_norm, fs_dec, "decim")
    play_audio(y_sub_norm, fs_sub, "norm")
