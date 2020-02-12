%%% Base de datos %% Unidades en microvolts
% 1. Marzo 13        - CRF
% 2. ABRIL 11        - CRF
% 3. Diciembre 18_N1 - CRF   %% Posible excluído
% 4. Diciembre 18_N2 - VEH 
% 5. Enero25_R1      - CRF 
% 6. Febrero 7_N1    - VEH 
% 7.Febrero 7_V1     - VEH 
%%%Sharp wave ripples detection
   Fs = 1000;
    % Vector de tiempo
time = 0:1/Fs:length(DATA_CRF)/Fs;
    time (end) = [];
    % Diseño de filtros
    [b1,a1] = butter(4,[80  180]/(Fs/2),'bandpass'); % filter Rpples**
    [b2,a2] = butter(4,[1 30]/(Fs/2),'bandpass'); % filtering Sharp Wave**
%prealocate 
            Ripples = zeros (2700000,size(DATA_CRF,2));
            Sharp_Wave = zeros (2700000,size(DATA_CRF,2));
            RMS3 = zeros (size(DATA_CRF,2),1);
            
for i = 1:size(DATA_CRF,2)
    Ripples(:,i) = filtfilt(b1,a1,DATA_CRF(:,i));
    Sharp_Wave(:,i) = filtfilt(b2,a2,DATA_CRF(:,i));
    RMS3(i) = 3*rms (Ripples(:,i)); %% Umbral para detección de ripples
    [pks{i},locs{i}] = findpeaks((abs(Ripples(:,i))),time,'MinPeakDistance',0.05,'MinPeakHeight', ...
        RMS3(i)); 
end   %% Ripples

 
for i = 1:size(DATA_CRF,2)
    temporal_locs = locs{:,i};
    for j = 1:size (temporal_locs,2)
     Presuntos{i,j,:} = Ripples(abs(temporal_locs(1,j)*1000-49):temporal_locs(1,j)*1000+50,i);   
    end
    clear temporal_locs
end   %% 
for i = 1:size(DATA_CRF,2)
    temporal_locs = locs{:,i};
    for j = 1:size (temporal_locs,2)
     Wideband{i,j,:} = DATA_CRF(abs(temporal_locs(1,j)*1000-49):temporal_locs(1,j)*1000+50,i);   
    end
    clear temporal_locs
end   %% Wideband
for i = 1:size(DATA_CRF,2)
    temporal_locs = locs{:,i};
    for j = 1:size (temporal_locs,2)
     Presuntos_SW{i,j,:} = Sharp_Wave(abs(temporal_locs(1,j)*1000-49):temporal_locs(1,j)*1000+50,i);   
    end
    clear temporal_locs
end  %% P/ hallar sharp wave

%% Contraste de 3 bandas de frecuencia 
figure 
subplot(311)
plot(Wideband{7, 739}  )
subplot(312)
plot(Presuntos {7, 739}  )
subplot(313)
plot(Presuntos_SW{7, 739}  )


     temporal_locs = locs{:,1};
for i = 1:size (temporal_locs,2)
    Sujeto_1(i,:) = squeeze(Presuntos{1,i,:});
end
  

%%%%% Visualización Ripples %%%%
% plot(mean (Sujeto_2(1:1000,1:100))) 
figure
 pspectrum(Sujeto_2,Fs,'spectrogram', 'Leakage',0.85,'OverlapPercent',98, ...
            'FrequencyLimits',[80 250], 'TimeResolution',0.029);




%%%%% Visualización Sharp waves %%%%%
temporal_locs = locs{:,5};
for i = 1:size (temporal_locs,2)
    Sujeto_5(i,:) = squeeze(Presuntos_SW{5,i,:});
end 

figure
for i = 1:size (temporal_locs,2)
plot((Sujeto_5(i,1:100)))
hold on
pause
end 
plot(mean (Sujeto_5(1:104,1:100)))
hold on
plot(mean (Sujeto_5(105:307,1:100)))
clear Sujeto_1
X1 = mean (Sujeto_1(:,:));
%  pspectrum(X1,Fs,'spectrogram', 'Leakage',0.85,'OverlapPercent',99, ...
%             'FrequencyLimits',[80 180], 'TimeResolution',0.029);


%%% Frecuencia Complejos SWR %%%
for i = 1: size(DATA_CRF,2)
    SWR_HZ_Baseline(i) = size(find(locs{1,i}<900),2)/900; 
end %Linea base
for i = 1: size(DATA_CRF,2)
    SWR_HZ_After(i) = size(find(locs{1,i}>960 & locs{1,i}<2700) ,2)/900; 
end %Postinyección

%%% Amplitud Complejos SWR %%%
for i = 1: size(DATA_CRF,2)
     temp_locs = (find(locs{1,i}<900));
    for j = 1:size((temp_locs),2)
        rms_presunt(i,j) = rms(Presuntos{i,temp_locs(j)});
    end 
    SWR_uV_Baseline(i) = mean(rms_presunt(i,:)); 
    clear temp_locs 
end %Linea base
for i = 1: size(DATA_CRF,2)
     temp_locs = (find(locs{1,i}>960 & locs{1,i}<2700));
    for j = 1:size((temp_locs),2)
        rms_presunt_after(i,j) = rms(Presuntos{i,temp_locs(j)});
    end 
    SWR_uV_After(i) = mean(rms_presunt_after(i,:)); 
    clear temp_locs 
end %Postinyección

delta_HZ = ( SWR_HZ_After - SWR_HZ_Baseline  )./ SWR_HZ_Baseline;
delta_HZ_perc = delta_HZ.*100;

delta_uV = ( SWR_uV_After - SWR_uV_Baseline  )./ SWR_uV_Baseline;
delta_uV_perc = delta_uV.*100;

