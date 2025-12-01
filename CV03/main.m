clear; clc; close all;

%% Zbytecny ale chtel jsem se podivat na vsechny jednoduse :D 
valid_choice = false; 

while ~valid_choice
    fprintf('\nVyberte datový soubor pro analýzu:\n');
    fprintf('1: Koma\n');
    fprintf('2: Novorozenec\n');
    fprintf('3: Spánek\n');
    fprintf('4: OpenBCI\n');
    disp('----------------------------------');

    choice = input('Zadejte číslo (1-4): ');

    switch choice
        case 1
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/koma.mat';
            file_name = 'koma.mat';
            fs = 256; 
            disp('-> Vybráno: Koma');
            valid_choice = true; 
            
        case 2
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/novorozenec.mat';
            file_name = 'novorozenec.mat';
            fs = 128; 
            disp('-> Vybráno: Novorozenec');
            valid_choice = true; 
            
        case 3
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/spanek.mat';
            file_name = 'spanek.mat';
            fs = 256; 
            disp('-> Vybráno: Spánek');
            valid_choice = true; 
            
        case 4
            file_url = 'http://neuro.ciirc.cvut.cz/eeg-data/openbci.mat';
            file_name = 'openbci.mat';
            fs = 250; 
            disp('-> Vybráno: OpenBCI');
            valid_choice = true; 
            
        otherwise
            clc;
            fprintf(2, 'CHYBA: Neplatná volba "%d". Zkuste to znovu.\n', choice);
    end
end

download_folder = 'downloads';

if ~exist(download_folder, 'dir')
    disp(['Vytvářím složku: ' download_folder]);
    mkdir(download_folder);
end

file_path = fullfile(download_folder, file_name);

if ~isfile(file_path)
    disp(['Stahuji soubor: ' file_name ' do složky ' download_folder '...']);
    websave(file_path, file_url);
    disp('Stažení dokončeno.');
else
    disp(['Soubor ' file_name ' již existuje, načítám...']);
end

data_struct = load(file_path);
vars = fieldnames(data_struct);
signal = data_struct.(vars{1}); 
signal = double(signal(:));      

N = length(signal);
t = (0:N-1) / fs; 

figure('Name', ['Analýza: ' file_name], 'Color', 'w', 'Position', [100, 100, 1000, 900]);
tiledlayout(4,1, 'TileSpacing', 'compact', 'Padding', 'compact');

%% A. 
nexttile;
plot(t, signal);
title(['A. Celý EEG signál (' file_name ')']);
xlabel('Čas [s]');
ylabel('Amplituda [\muV]');
axis tight;
grid on;

%% B. 
nexttile;

idx_start = round(5 * fs);
idx_end = round(10 * fs);

% Kdyby náhodou byl signál kratší než 10 sekund, v nejhorsim se zkrati na delku signalu / vezme od konce 5 sekund
if idx_end > N
    idx_end = N;
    idx_start = N - round(5 * fs);
end
if idx_start >= N 
    idx_start = 1;
end

plot(t(idx_start:idx_end), signal(idx_start:idx_end));
title('B. Výřez signálu (5 - 10 s)');
xlabel('Čas [s]');
ylabel('Amplituda [\muV]');
axis tight;
grid on;

%% C. 
nexttile;

window_sec = 2;          
window = round(window_sec * fs); 
overlap = round(0.90 * window); 
nfft = 2^nextpow2(window); 

[S, F, T] = spectrogram(signal, window, overlap, nfft, fs);

imagesc(T/60, F, abs(S)); 

axis xy; 
colormap jet; 
ylim([0 40]); 

title('C. Spektrogram (Základní magnituda)');
xlabel('Čas [min]'); 
ylabel('Frekvence [Hz]');
colorbar;

%% D. 
nexttile;

S_log = 10 * log10(abs(S).^2 + eps); 

imagesc(T/60, F, S_log);

axis xy;
colormap jet; 
ylim([0 40]); 

title('D. Spektrogram (Logaritmická škála - dB)');
xlabel('Čas [min]');
ylabel('Frekvence [Hz]');
c = colorbar;
c.Label.String = 'Výkon [dB]';