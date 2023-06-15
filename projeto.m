%% Leitura do audio

[y,Fs] = audioread("nota.wav");

soundsc(y(:,1),Fs);

figure(1)
plot(y)
title("Nota")

%% Espectro de frequência do audio

Y = fft(y);
L = length(y);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

figure(2)
plot(f,P2) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

