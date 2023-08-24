function [Amplitude, Expoente] = regressaoExp(tempo, dados, fig)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[maximo, indice] = max(dados);
dados_cortado = dados(indice:end); 

[picos, indices] = findpeaks(dados_cortado);
tempo_picos= [];

for i=1:length(picos)
    tempo_picos(i) = tempo(indices(i));
end

fun = @(x,tempo_picos)x(1)*exp(x(2)*tempo_picos);
x0 = [max(picos), -2];
x = lsqcurvefit(fun,x0,tempo_picos,picos)

%figure(fig)
%hold on
%time = linspace(tempo_picos(1), tempo_picos(end));
%stem(tempo_picos, picos)
%plot(time, fun(x,time))

Amplitude = x(1);
Expoente = x(2);
