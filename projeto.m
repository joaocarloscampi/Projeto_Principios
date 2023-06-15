%% Leitura do audio

[y,Fs] = audioread("nota.wav");

% Reprodução do audio
%soundsc(y(:,1),Fs);

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

f_sup = fundamental + banda/2;      % Frequência superior do filtro
f_inf = fundamental - banda/2;      % Frequência inferior do filtro

Y_f = [];                           % Inicialização do vetor de dados filtrados

% Filtragem manual do sinal
for i=1:length(f_p2)
    if f_p2(i) < f_sup && f_p2(i) > f_inf       % Verificação das frequências positivas
        Y_f(i) = Y(i);
    else
        if ( f_p2(i) < f_p2(end)-f_inf ) && (f_p2(i) > f_p2(end)-f_sup-banda )  % Verificação das frequências negativas (espelho)
            Y_f(i) = Y(i);
        else
            Y_f(i) = 0;     % Fora da banda -> cortar
        end
    end
end

figure(4)
plot(f_p2,abs(Y_f/L)) 
title("Filtragem da primeira fundamental - Espectro completo")
xlabel("f (Hz)")
ylabel("Amplitude")

%% Transformada inversa do filtro da fundamental

inversa = ifft(Y_f);            % Transformada inversa do sinal filtrado
inversa = real(inversa);        % Retirar a parte complexa residual do sinal

figure(5)
hold on
plot(t_audio,y(:,1))
plot(t_audio,inversa)
legend("Original", "Filtrada")
xlabel("Tempo [s]")
ylabel("Amplitude")
xlim([t_audio(1), t_audio(end)])
