%%% Database %% Units (uV)
% 1. Marzo 13        - CRF
% 2. ABRIL 11        - CRF
% 3. Diciembre 18_N1 - CRF   %% Excluded
% 4. Diciembre 18_N2 - VEH 
% 5. Enero25_R1      - CRF 
% 6. Febrero 7_N1    - VEH 
% 7. Febrero 7_V1    - VEH 
%% Preliminares
   Fs = 1000;                                                   % Frequency sample
time = 0:1/Fs:length(DATA_CRF)/Fs;                              % Time vector
time (end) = [];  
%%  1. Filtering Ripples
    % Filter design
[b1,a1] = butter(4,[90  180]/(Fs/2),'bandpass');                % Ripple
Ripples    = zeros (size(DATA_CRF,1),size(DATA_CRF,2));         % Preallocate
for i = 1:size(DATA_CRF,2)
    Ripples(:,i)     = filtfilt(b1,a1,DATA_CRF(:,i));
    RMS3(i)          = 3*rms (Ripples(:,i));                    % Thereshold 
    [pks{i},locs{i}] = findpeaks((abs(Ripples(:,i))),time,'MinPeakDistance',0.05,'MinPeakHeight', ...
        RMS3(i)); 
end                                   % Ripples
%%  2. Extracting Ripples
for i = 1:size(DATA_CRF,2)
    temporal_locs = locs{:,i};
    for j = 1:size (temporal_locs,2)
     Presuntos{i,j,:} = Ripples(abs(temporal_locs(1,j)*1000-49):temporal_locs(1,j)*1000+50,i);   
    end
    clear temporal_locs
end                                   % 

%% 3. Quantifiying Ripples
% Frequency %%%
for i = 1: size(DATA_CRF,2)
    SWR_HZ_Baseline(i) = size(find(locs{1,i}<900),2)/900; 
end %Baseline
for i = 1: size(DATA_CRF,2)
    SWR_HZ_After(i) = size(find(locs{1,i}>960 & locs{1,i}<2700) ,2)/900; 
end %Postinyección

%%% Amplitude  %%%
for i = 1: size(DATA_CRF,2)
     temp_locs = (find(locs{1,i}<900));
    for j = 1:size((temp_locs),2)
        rms_presunt(i,j) = rms(Presuntos{i,temp_locs(j)});
    end 
    SWR_uV_Baseline(i) = mean(rms_presunt(i,:)); 
    clear temp_locs 
end %Baseline
for i = 1: size(DATA_CRF,2)
     temp_locs = (find(locs{1,i}>960 & locs{1,i}<2700));
    for j = 1:size((temp_locs),2)
        rms_presunt_after(i,j) = rms(Presuntos{i,temp_locs(j)});
    end 
    SWR_uV_After(i) = mean(rms_presunt_after(i,:)); 
    clear temp_locs 
end %Postinyección
%% Spectrogram
Sujeto = 2;
limits = [80 180];
resolution = 10;
    figure 
pspectrum(Ripples(:,Sujeto),Fs,'spectrogram', 'Leakage',0.85,'OverlapPercent',90, ... 
            'FrequencyLimits',limits, 'TimeResolution',resolution); 
% Parameters
colormap('jet'); 
caxis ([-40 -10])    
title(['Sujeto: ' num2str(Sujeto)]);
    

