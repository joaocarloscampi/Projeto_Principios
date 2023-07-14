function y_sintetizado = sintetizacao(t,f,A1,I1,A2,I2,phi)
%SINTETIZACAO Summary of this function goes here
%   Detailed explanation goes here
n = round((t(I2) - t(I1))/(1/f));   % Numero do ciclo após o máximo global

zeta = 1/(2*pi) * 1/n * log(A1/A2);         % Operações do artigo
%zeta = 0;

w0 = 2*pi*f;
wd = w0*sqrt(1-zeta^2);
y_sintetizado = A1*exp(-zeta * w0 * t) .* cos(wd*t + phi);
end

