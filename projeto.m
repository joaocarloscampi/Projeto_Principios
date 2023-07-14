%% Leitura do audio

[y,Fs] = audioread("nota.wav");
%[y,Fs] = audioread("la_violao_solto_3.wav");

% Reprodução do audio - descomentar linha abaixo
% soundsc(y(:,1),Fs);

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

%i_phase_f = 2837;
%i_phase_1h = 5674;
%i_phase_2h = 8509;


%% Espectro de frequência do audio completo

f_p2 = linspace(0, Fs, L);      % Frequências do espectro completo

figure(3)
plot(f_p2,P2) 
title("Espectro de magnitude completo do audio")
xlabel("f (Hz)")
ylabel("Amplitude")

%% Filtro da componente fundamental

fundamental = 490;                  % Frequência a ser filtrada
banda = 140;                        % Largura de banda do filtro

Y_f = filtro(f_p2, Y, fundamental, banda);
Y_1h = filtro(f_p2, Y, fundamental*2, banda);
Y_2h = filtro(f_p2, Y, fundamental*3, banda);
Y_3h = filtro(f_p2, Y, fundamental*4, banda);
Y_4h = filtro(f_p2, Y, fundamental*5, banda);

figure(4)
hold on
plot(f_p2,abs(Y_f/L)) 
plot(f_p2,abs(Y_1h/L)) 
plot(f_p2,abs(Y_2h/L)) 
plot(f_p2,abs(Y_3h/L)) 
plot(f_p2,abs(Y_4h/L)) 
title("Filtragem da primeira fundamental - Espectro completo")
xlabel("f (Hz)")
ylabel("Amplitude")

%% Transformada inversa do filtro da fundamental

inversa = ifft(Y_f);            % Transformada inversa da fundamental
inversa = real(inversa);        % Retirar a parte complexa residual do sinal

inversa_1h = ifft(Y_1h);        % Transformada inversa da primeira harmonica
inversa_1h = real(inversa_1h);

inversa_2h = ifft(Y_2h);        % Transformada inversa da segunda harmonica
inversa_2h = real(inversa_2h);

inversa_3h = ifft(Y_3h);        % Transformada inversa da terceira harmonica
inversa_3h = real(inversa_3h);

inversa_4h = ifft(Y_4h);        % Transformada inversa da quarta harmonica
inversa_4h = real(inversa_4h);

% Plot de algumas componentes
figure(5)
hold on
plot(t_audio,y(:,1))
plot(t_audio,inversa)
plot(t_audio,inversa_1h)
plot(t_audio,inversa_2h)
legend("Original", "Fundamental", "1 Harmonica", "2 Harmonica")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])

%% Reprodução do audio filtrado

audio_filtrado = inversa + inversa_1h + inversa_2h + inversa_3h + inversa_4h;

% Descomentar essa linha para ouvir o som filtrado
% soundsc(audio_filtrado,Fs);
% audiowrite("audio_filtrado.wav",audio_filtrado,Fs);

%% Sintetização

f = fundamental; % Frequência da componente fundamental

[A1, I1, A2, I2] = picos(t_audio, inversa, Fs, f); % Detecção dos picos
y_f_sint = sintetizacao(t_audio,f,A1,I1,A2,I2, 0); % Sintetização da frequencia fundamental

f = fundamental*2; % Frequência da primeira harmonica

[A1, I1, A2, I2] = picos(t_audio, inversa_1h, Fs, f); % Detecção dos picos
y_1h_sint = sintetizacao(t_audio,f,A1,I1,A2,I2, 0); % Sintetização da frequencia fundamental

f = fundamental*3; % Frequência da segunda harmonica

[A1, I1, A2, I2] = picos(t_audio, inversa_2h, Fs, f); % Detecção dos picos
y_2h_sint = sintetizacao(t_audio,f,A1,I1,A2,I2, 0); % Sintetização da frequencia fundamental

f = fundamental*4; % Frequência da terceira harmonica

[A1, I1, A2, I2] = picos(t_audio, inversa_3h, Fs, f); % Detecção dos picos
y_3h_sint = sintetizacao(t_audio,f,A1,I1,A2,I2, 0); % Sintetização da frequencia fundamental


% Plot só para visualizar as harmonicas sintetizadas
% Caso desejar, trocar os termos y para visualização
figure(8)
hold on
plot(t_audio,inversa_1h)
plot(t_audio,y_1h_sint)
legend("Original", "Sintetizado")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])

%% Som sintetizado final

y_sint = y_f_sint + y_1h_sint + y_2h_sint + y_3h_sint;

% Descomentar a linha para ouvir o som
%soundsc(y_sint, Fs)
%audiowrite("audio_sintetizado.wav",y_sint*2,Fs);

figure(8)
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

figure(9)
plot(f,P1_sint) 
title("Espectro de magnitude do audio sintetizado")
xlabel("f (Hz)")
ylabel("Amplitude")
