clear; clc; close all;

download_folder = 'downloads';
if ~exist(download_folder, 'dir'), mkdir(download_folder); end

valid_choice = false;
while ~valid_choice
    fprintf('\nVyberte EEG soubor:\n1: Koma (256 Hz)\n2: Novorozenec (128 Hz)\n3: Spanek (256 Hz)\n4: OpenBCI (250 Hz)\n');
    choice = input('Zadejte cislo (1-4): ');
    switch choice
        case 1
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/koma.mat';
            file_name = 'koma.mat'; fs_eeg = 256; valid_choice = true;
        case 2
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/novorozenec.mat';
            file_name = 'novorozenec.mat'; fs_eeg = 128; valid_choice = true;
        case 3
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/spanek.mat';
            file_name = 'spanek.mat'; fs_eeg = 256; valid_choice = true;
        case 4
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/openbci.mat';
            file_name = 'openbci.mat'; fs_eeg = 250; valid_choice = true;
    end
end

file_path = fullfile(download_folder, file_name);
if ~isfile(file_path), websave(file_path, file_url); end
data_struct = load(file_path);
vars = fieldnames(data_struct);
sig_full = double(data_struct.(vars{1}));

N_samples_eeg = min(120 * fs_eeg, length(sig_full)); % kdyby byl signal kratkej
sig_eeg = sig_full(1:N_samples_eeg);
t_eeg = (0:length(sig_eeg)-1) / fs_eeg;

figure(1);
plot(t_eeg, sig_eeg);
xlabel('Čas [s]'); ylabel('Amplituda [\muV]');
title(['EEG signál: ', file_name]); grid on;

wavelets_cwt = {'morse', 'amor', 'bump'}; % nejlepsi je imo morse nebo amor 
figure(2);
for i = 1:3
    subplot(3, 1, i);
    [cfs, freqs] = cwt(sig_eeg, wavelets_cwt{i}, fs_eeg);
    imagesc(t_eeg, freqs, abs(cfs));
    axis xy; colorbar;
    xlabel('Čas [s]'); ylabel('Frekvence [Hz]');
    title(['Skalogram: ', wavelets_cwt{i}]);
end

figure(3);
subplot(3,1,1);
[cfs1, f1] = cwt(sig_eeg, 'morse', fs_eeg);
imagesc(t_eeg, f1, abs(cfs1)); axis xy; colorbar;
title('CWT: Morse'); ylabel('Freq [Hz]');

subplot(3,1,2);
[cfs2, f2] = cwt(sig_eeg, 'amor', fs_eeg);
imagesc(t_eeg, f2, abs(cfs2)); axis xy; colorbar;
title('CWT: Amor'); ylabel('Freq [Hz]');

subplot(3,1,3);
win = 2 * fs_eeg;
[s, f_s, t_s] = spectrogram(sig_eeg, win, round(win*0.75), win, fs_eeg, 'yaxis');
imagesc(t_s, f_s, 10*log10(abs(s) + eps)); axis xy; colorbar;
title('STFT Spektrogram'); xlabel('Čas [s]'); ylabel('Freq [Hz]');

ekg_url = 'http://neuro.ciirc.cvut.cz/ekg/MIT_BIH_ECG.mat';
ekg_path = fullfile(download_folder, 'MIT_BIH_ECG.mat');
if ~isfile(ekg_path), websave(ekg_path, ekg_url); end
load(ekg_path);

fs_ekg = 250;
sig_ekg = ekg(1:20*fs_ekg);
t_ekg = (0:length(sig_ekg)-1) / fs_ekg;

figure(4);
plot(t_ekg, sig_ekg);
xlabel('Čas [s]'); ylabel('Amplituda [mV]');
title('Originální EKG signál'); grid on;

wavelets_dwt = {'db4', 'sym4', 'coif3'};
level = 8;
f_app = figure(5);
f_det = figure(6);

for k = 1:3
    wt = modwt(sig_ekg, wavelets_dwt{k}, level);
    mra = modwtmra(wt, wavelets_dwt{k});
    
    figure(f_app);
    subplot(3,1,k);
    plot(t_ekg, mra(level+1, :));
    title(['Aproximace', wavelets_dwt{k}]);
    ylabel('Amp');
    
    figure(f_det);
    subplot(3,1,k);
    plot(t_ekg, mra(1, :));
    title(['Detail', wavelets_dwt{k}]);
    ylabel('Amp');
end
figure(f_app); xlabel('Čas [s]');
figure(f_det); xlabel('Čas [s]');

best_w = 'db4';
wt_f = modwt(sig_ekg, best_w, level);
wt_f(1, :) = 0;
wt_f(end, :) = 0;
sig_rec = imodwt(wt_f, best_w);

figure(7);
subplot(2,1,1);
plot(t_ekg, sig_ekg); title('Původní EKG'); grid on;
ylabel('Amplituda');
subplot(2,1,2);
plot(t_ekg, sig_rec, 'r'); title('EKG po rekonstrukci (Bez rušení a dechu)'); grid on;
xlabel('Čas [s]'); ylabel('Amplituda');