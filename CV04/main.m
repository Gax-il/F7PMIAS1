clc; clear; close all;

Fs = 1000;
T = 20;
t = 0:1/Fs:T-1/Fs;

f1 = 13; f2 = 45; f3 = 93; f4 = 171;
sig_pure = sin(2*pi*f1*t) + sin(2*pi*f2*t) + sin(2*pi*f3*t) + sin(2*pi*f4*t);
noise1 = 0.5 * randn(size(t));
noise2 = 0.2 * randn(size(t));
sig_total = sig_pure + noise1 + noise2;

figure;
subplot(2,1,1);
plot(t, sig_total);
title('Signál');
xlabel('t [s]'); ylabel('A');
grid on;

L = length(sig_total);
Y = fft(sig_total);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f_axis = Fs*(0:(L/2))/L;

subplot(2,1,2);
plot(f_axis, P1);
title('FFT');
xlabel('f [Hz]'); ylabel('|P1|');
grid on;

fc1 = 15;
N1 = 100;
b1 = fir1(N1, fc1/(Fs/2), 'low', hamming(N1+1));
a1 = 1;

Rp = 0.6; Rs = 65;
fc2 = 15;
[n2, Wn2] = ellipord(fc2/(Fs/2), (fc2+5)/(Fs/2), Rp, Rs);
[b2, a2] = ellip(n2, Rp, Rs, Wn2, 'low');

fc3 = 94;
N3 = 50;
b3 = fir1(N3, fc3/(Fs/2), 'high', blackman(N3+1));
a3 = 1;

fc4 = 94;
[n4, Wn4] = ellipord((fc4)/(Fs/2), (fc4-5)/(Fs/2), Rp, Rs);
[b4, a4] = ellip(n4, Rp, Rs, Wn4, 'high');

freqs6 = [20 80];
N6 = 100;
b6 = fir1(N6, freqs6/(Fs/2), 'bandpass', hamming(N6+1));
a6 = 1;

[b7, a7] = cheby1(4, 1, [20 80]/(Fs/2), 'bandpass');

freqs8 = [40 50];
N8 = 80;
b8 = fir1(N8, freqs8/(Fs/2), 'stop', hanning(N8+1));
a8 = 1;

[b9, a9] = ellip(4, 1, 50, [40 50]/(Fs/2), 'stop');

b1_swap = fir1(N1, fc1/(Fs/2), 'low', blackman(N1+1));
b3_swap = fir1(N3, fc3/(Fs/2), 'high', hamming(N3+1));

figure;
freqz(b1, 1, 1024, Fs); hold on;
freqz(b1_swap, 1, 1024, Fs);
freqz(b3, 1, 1024, Fs);
freqz(b3_swap, 1, 1024, Fs);
legend('F1-Ham', 'F1-Blk', 'F3-Blk', 'F3-Ham');
title('Okna');

% bod5:
%  Blackman má menší postranní laloky → lepší útlum mimo pásmo,
%  ale přechod je širší, takže filtr není tak strmý.
%  Hamming je ostřejší, ale víc propouští mimo pásmo.
%  Po prohození je to pěkně vidět na LP vs HP filtrech.

figure;
subplot(2,1,1);
[h6, w6] = freqz(b6, a6, 1024, Fs);
[h7, w7] = freqz(b7, a7, 1024, Fs);
plot(w6, 20*log10(abs(h6)), 'b'); hold on;
plot(w7, 20*log10(abs(h7)), 'r--');
title('BP FIR vs IIR');
xlabel('f [Hz]'); ylabel('dB'); grid on; ylim([-100 10]);

subplot(2,1,2);
[h8, w8] = freqz(b8, a8, 1024, Fs);
[h9, w9] = freqz(b9, a9, 1024, Fs);
plot(w8, 20*log10(abs(h8)), 'b'); hold on;
plot(w9, 20*log10(abs(h9)), 'r--');
title('BS FIR vs IIR');
xlabel('f [Hz]'); ylabel('dB'); grid on; ylim([-100 10]);

% bod10:
%  IIR filtry mají ostřejší zlom, menší řád, víc útlumu mimo pásmo.
%  FIR je jemnější, má lineární fázi (lepší pro fázi signálu).
%  V grafech: červený = IIR (strmý), modrý = FIR (hladší).'

filters = {
    {b1, a1, '1 FIR LP'},
    {b2, a2, '2 IIR LP'},
    {b3, a3, '3 FIR HP'},
    {b4, a4, '4 IIR HP'},
    {b6, a6, '6 FIR BP'},
    {b7, a7, '7 IIR BP'},
    {b8, a8, '8 FIR BS'},
    {b9, a9, '9 IIR BS'}
};

for i = 1:length(filters)
    b = filters{i}{1};
    a = filters{i}{2};
    title_str = filters{i}{3};
    
    sig_filtered = filter(b, a, sig_total);
    
    Y_filt = fft(sig_filtered);
    P2_filt = abs(Y_filt/L);
    P1_filt = P2_filt(1:L/2+1);
    P1_filt(2:end-1) = 2*P1_filt(2:end-1);
    
    figure;
    subplot(2,1,1);
    plot(t, sig_filtered);
    title(['čas: ' title_str]);
    xlabel('t [s]'); ylabel('A');
    grid on; xlim([0 2]);
    
    subplot(2,1,2);
    plot(f_axis, P1_filt);
    title(['FFT: ' title_str]);
    xlabel('f [Hz]'); ylabel('|P1|');
    grid on;
end