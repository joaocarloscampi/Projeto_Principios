function filtragem = filtro(frequencia, dados,frequenciaCentral,banda)
%FILTRO Summary of this function goes here
%   Detailed explanation goes here

f_sup = frequenciaCentral + banda/2;      % Frequência superior do filtro
f_inf = frequenciaCentral - banda/2;      % Frequência inferior do filtro

filtragem = [];                           % Inicialização do vetor de dados filtrados

% Filtragem manual do sinal
for i=1:length(frequencia)
    if frequencia(i) < f_sup && frequencia(i) > f_inf       % Verificação das frequências positivas
        filtragem(i) = dados(i);
    else
        if ( frequencia(i) < frequencia(end)-f_inf ) && (frequencia(i) > frequencia(end)-f_sup-banda )  % Verificação das frequências negativas (espelho)
            filtragem(i) = dados(i);
        else
            filtragem(i) = 0;     % Fora da banda -> cortar
        end
    end
end
end

