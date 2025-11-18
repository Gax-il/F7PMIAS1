clc;
clear;
close all;

N = 512;

figure('Name', 'Úloha č. 2', 'NumberTitle', 'off', 'WindowState', 'maximized');


fs_a = 256;
f_sig_a = 10;
A_a = 10e-3;
t_a = (0:N-1) / fs_a;
x_a = A_a * sin(2*pi * f_sig_a * t_a);
[f_a, P1_a] = compute_spectrum(x_a, fs_a, N);
subplot(7, 2, 1); plot(t_a, x_a); title('a) Sinusový signál (10 Hz)'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); grid on;
subplot(7, 2, 2); plot(f_a, P1_a); title('a) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); grid on;

fs_b = 256;
f_sig_b = 10;
A_pkpk_b = 20e-3;
A_b = A_pkpk_b / 2;
t_b = (0:N-1) / fs_b;
x_b = A_b * sawtooth(2*pi * f_sig_b * t_b, 0.5);
[f_b, P1_b] = compute_spectrum(x_b, fs_b, N);
subplot(7, 2, 3); plot(t_b, x_b); title('b) Trojúhelníkový signál (10 Hz)'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); grid on;
subplot(7, 2, 4); plot(f_b, P1_b); title('b) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); grid on;

fs_c = 128;
t_c = (0:N-1) / fs_c;
x_c = zeros(1, N);
x_c(1:128) = 1;
[f_c, P1_c] = compute_spectrum(x_c, fs_c, N);
subplot(7, 2, 5); plot(t_c, x_c); title('c) Impuls (n = 1 až 128)'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); ylim([-0.1, 1.1]); grid on;
subplot(7, 2, 6); plot(f_c, P1_c); title('c) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); grid on;

fs_d = 128;
t_d = (0:N-1) / fs_d;
x_d = zeros(1, N);
x_d(1:256) = 1;
[f_d, P1_d] = compute_spectrum(x_d, fs_d, N);
subplot(7, 2, 7); plot(t_d, x_d); title('d) Impuls (n = 1 až 256)'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); ylim([-0.1, 1.1]); grid on;
subplot(7, 2, 8); plot(f_d, P1_d); title('d) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); grid on;

fs_e = 1024;
t_e = (0:N-1) / fs_e;
x_e = 0.4 * cos(2*pi * 50 * t_e) + 0.3 * cos(2*pi * 100 * t_e) + 0.2 * cos(2*pi * 150 * t_e) + 0.1 * cos(2*pi * 200 * t_e);
[f_e, P1_e] = compute_spectrum(x_e, fs_e, N);
subplot(7, 2, 9); plot(t_e, x_e); title('e) Součet kosinusových signálů'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); grid on;
subplot(7, 2, 10); stem(f_e, P1_e); title('e) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); xlim([0, fs_e/2]); grid on;

T_f = 8;
fs_f = N / T_f;
t_f = (0:N-1) / fs_f;
x_f = (rand(1, N) * 0.2) - 0.1;
[f_f, P1_f] = compute_spectrum(x_f, fs_f, N);
subplot(7, 2, 11); plot(t_f, x_f); title('f) Náhodný signál (rovnoměrné rozdělení)'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); grid on;
subplot(7, 2, 12); plot(f_f, P1_f); title('f) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); grid on;

T_g = 8;
fs_g = N / T_g;
t_g = (0:N-1) / fs_g;
x_g = zeros(1, N);
x_g(64) = 64;
[f_g, P1_g] = compute_spectrum(x_g, fs_g, N);
subplot(7, 2, 13); stem(t_g, x_g); title('g) Diracův impuls na 64. vzorku'); xlabel('Čas (s)'); ylabel('Amplituda (V)'); grid on;
subplot(7, 2, 14); plot(f_g, P1_g); title('g) Jednostranné amplitudové spektrum'); xlabel('Frekvence (Hz)'); ylabel('|A(f)| (V)'); ylim([0, max(P1_g)*1.1 + eps]); grid on;

function [f, P1] = compute_spectrum(x, fs, N)
    Y = fft(x);
    P2 = abs(Y / N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    f = fs * (0:(N/2)) / N;
end
