%% Leitura do audio

[y,Fs] = audioread("nota.wav");

% Reprodução do audio
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

inversa = ifft(Y_f);            % Transformada inversa do sinal filtrado
inversa = real(inversa);        % Retirar a parte complexa residual do sinal

inversa_1h = ifft(Y_1h);
inversa_1h = real(inversa_1h);

inversa_2h = ifft(Y_2h);
inversa_2h = real(inversa_2h);

inversa_3h = ifft(Y_3h);
inversa_3h = real(inversa_3h);

inversa_4h = ifft(Y_4h);
inversa_4h = real(inversa_4h);

figure(5)
hold on
%plot(t_audio,y(:,1))
plot(t_audio,inversa)
%plot(t_audio,inversa_1h)
%plot(t_audio,inversa_2h)
legend("Original", "Fundamental", "1 Harmonica", "2 Harmonica")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])

%% Reprodução do audio filtrado

audio_filtrado = inversa + inversa_1h + inversa_2h + inversa_3h + inversa_4h;
%soundsc(audio_filtrado,Fs);
