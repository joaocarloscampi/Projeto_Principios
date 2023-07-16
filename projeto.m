%% Inicialização
clc
clear all
close all
%% Parametros do algoritmo
n_harmonicas = 16;                   % Numero de harmonicas desejado
banda = 140;                        % Largura de banda do filtro

% Tipos de estratégias: 
% 0 - Convencional
% 1 - Regressão Exponencial
estrategia = 1;

%% Leitura do audio

%[y,Fs] = audioread("nota.wav");
[y,Fs] = audioread("la_violao_solto_3.wav");

% Reprodução do audio - descomentar linha abaixo
soundsc(y(:,1),Fs);

% Duração do audio
t_audio = 0:(1/Fs):((length(y)-1)/Fs);

figure(1)
plot(t_audio, y(:,1))
title("Audio original")
xlim([t_audio(1), t_audio(end)])

%% Espectro de frequência do audio positivo

Y = fft(y);                     % Transformada de Fourier do audio
L = length(y);

P2 = abs(Y/L);                  % Normalização dos dados
P2 = P2(:,1);                   % Separação do primeiro canal de audio
P1 = P2(1:L/2+1);               % Separação do espectro positivo de frequências
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;             % Frequências do espectro dividido

figure(2)
plot(f,P1) 
title("Espectro de magnitude do audio")
xlabel("f (Hz)")
ylabel("Amplitude")

%phase = angle(Y);
%phase = phase(:,1);                   % Separação do primeiro canal de audio
%phase1 = phase(1:L/2+1);               % Separação do espectro positivo de frequências
%phase1(2:end-1) = 2*phase1(2:end-1);

%figure(20)
%plot(f,phase1)
%title("Espectro de fase do audio")
%xlabel("f (Hz)")
%ylabel("Fase")


%% Espectro de frequência do audio completo

f_p2 = linspace(0, Fs, L);      % Frequências do espectro completo

figure(3)
plot(f_p2,P2) 
title("Espectro de magnitude completo do audio")
xlabel("f (Hz)")
ylabel("Amplitude")

%% Detecção da fundamental e suas componentes

% realiza a detecção das componentes do espectro, fundamental e harmonicas
[index_componentes, componentes] = detectaComponentes(Y(:,1), Fs, n_harmonicas);
fundamental = index_componentes(1)*Fs/L;        % Componente fundamental
harmonicas = index_componentes(2:end)*Fs/L;     % Harmonicas

%% Filtro da componente fundamental

Y_f = filtro(f_p2, Y, fundamental, banda);              % Filtragem da componente fundamental
Y_h = zeros(n_harmonicas, L);                           % Vetor para armazenar a filtragem das harmonicas
for i=1:n_harmonicas
    Y_h(i,:) = filtro(f_p2, Y, harmonicas(i), banda);   % Filtragem de cada harmonica
end

figure(4)
hold on
plot(f_p2,abs(Y_f/L)) 
for i=1:n_harmonicas
    plot(f_p2,abs(Y_h(i,:)/L))
end
title("Filtragem da primeira fundamental - Espectro completo")
xlabel("f (Hz)")
ylabel("Amplitude")

%% Transformada inversa do filtro da fundamental

inversa = ifft(Y_f);            % Transformada inversa da fundamental
inversa = real(inversa);        % Retirar a parte complexa residual do sinal

inversa_h = zeros(n_harmonicas, L);         % Vetor para armazenar a inversa das harmonicas

for i=1:n_harmonicas
    inversa_aux = real(ifft(Y_h(i,:)));     % Inversa de cada harmonica
    inversa_h(i,:) = inversa_aux;
end

% Plot de algumas componentes
figure(5)
hold on
plot(t_audio,y(:,1))
plot(t_audio,inversa)
for i=1:n_harmonicas
    plot(t_audio,inversa_h(i,:))
end
legend("Original", "Fundamental", "1 Harmonica", "2 Harmonica")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])

%% Reprodução do audio filtrado

audio_filtrado = inversa;   % Soma do audio filtrado com a fundamental e suas harmonicas
for i=1:n_harmonicas
    audio_filtrado = audio_filtrado + inversa_h(i,:);
end

% Descomentar essa linha para ouvir o som filtrado
% soundsc(audio_filtrado,Fs);
% audiowrite("audio_filtrado.wav",audio_filtrado,Fs);

%% Sintetização convencional

if estrategia==0

    f = fundamental; % Frequência da componente fundamental

    %[A1, I1, A2, I2] = picos(t_audio, inversa, Fs, f); % Detecção dos picos
    [A1, I1, A2, I2] = picos_basica(inversa); % Detecção dos picos
    y_f_sint = sintetizacao(t_audio,f,A1,I1,A2,I2, angle(componentes(1))); % Sintetização da fundamental

    %regressaoExp(t_audio, inversa, 100)

    y_h_sint = zeros(n_harmonicas, L);      % Vetor para armazenar as harmonicas sintetizadas

    for i=1:n_harmonicas
        f = harmonicas(i); % Frequência da harmonica

        %[A1, I1, A2, I2] = picos(t_audio, inversa_h(i,:), Fs, angle(componentes(i+1))); % Detecção dos picos
        [A1, I1, A2, I2] = picos_basica(inversa_h(i,:)); % Detecção dos picos
        %regressaoExp(t_audio, inversa_h(i,:), 100+i)
        y_h_sint(i,:) = sintetizacao(t_audio,f,A1,I1,A2,I2, 0); % Sintetização da harmonica
    end
end

%% Sintetização regressão exponencial

if estrategia==1

    f = fundamental; % Frequência da componente fundamental

    [amplitude, zeta] = regressaoExp(t_audio, inversa, 100);
    y_f_sint = real(sintetizacaoRegressao(amplitude, zeta, f, angle(componentes(1)), t_audio));
    
    %figure(200)
    %hold on
    %plot(t_audio, inversa)
    %plot(t_audio, y_f_sint)
    
    %regressaoExp(t_audio, inversa, 100)

    y_h_sint = zeros(n_harmonicas, L);      % Vetor para armazenar as harmonicas sintetizadas

    for i=1:n_harmonicas
        f = harmonicas(i); % Frequência da harmonica
    
        [amplitude, zeta] = regressaoExp(t_audio, inversa_h(i,:), 100+i);
        y_h_sint(i,:) = real(sintetizacaoRegressao(amplitude, zeta, f, angle(componentes(i+1)), t_audio)); % Sintetização da harmonica
    end
end
%%
% Plot só para visualizar as harmonicas sintetizadas
% Caso desejar, trocar os termos y para visualização
figure(8)
hold on
%plot(t_audio,inversa)
plot(t_audio,y_f_sint)
legend("Original", "Sintetizado")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])

%% Som sintetizado final

y_sint = y_f_sint;      % Soma das componentes para obter o som final
for i=1:n_harmonicas
    y_sint = y_sint + y_h_sint(i,:);
end

% Descomentar a linha para ouvir o som
soundsc(y_sint, Fs)
%audiowrite("audio_sintetizado.wav",y_sint*2,Fs);

figure(9)
plot(t_audio, y(:,1))
hold on
plot(t_audio, y_sint)
legend("Original", "Sintetizado")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])

%% Transformada do sinal sintetizado

Y_sint = fft(y_sint);                     % Transformada de Fourier do audio

P2_sint = abs(Y_sint/L);                  % Normalização dos dados
%P2_sint = P2_sint(:,1);                   % Separação do primeiro canal de audio
P1_sint = P2_sint(1:L/2+1);               % Separação do espectro positivo de frequências
P1_sint(2:end-1) = 2*P1_sint(2:end-1);

f = Fs*(0:(L/2))/L;             % Frequências do espectro dividid

figure(10)
plot(f,P1_sint) 
title("Espectro de magnitude do audio sintetizado")
xlabel("f (Hz)")
ylabel("Amplitude")
