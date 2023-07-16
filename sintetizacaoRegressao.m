function y_sintetizado = sintetizacaoRegressao(amplitude,expoente,frequencia,fase, t)
    w0 = 2*pi*frequencia;
    zeta=expoente;
    wd = w0*sqrt(1-(zeta/w0)^2);
    y_sintetizado = amplitude*exp(zeta* t) .* cos(wd*t + fase);
end

