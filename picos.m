function [maximo,indice,maximo_10,indice_10] = picos(tempo, dados, fs, f)
%PICOS Summary of this function goes here
%   Detailed explanation goes here

[maximo, indice] = max(dados);                          % Encontra o máximo global do som
dados_cortado = dados(indice:end);                      % 

n_picos = floor((tempo(end)-tempo(indice))/(1/f));

[picos, indices] = findpeaks(dados_cortado);

dados_ordenados = sort(picos, 'descend');
maximo_10 = dados_ordenados(10);
indice_10 = find(dados_cortado==maximo_10)-1+indice;

%maximo = picos(100);
%indice = indices(100);

%maximo_10 = picos(250);
%indice_10 = indices(250);

end

