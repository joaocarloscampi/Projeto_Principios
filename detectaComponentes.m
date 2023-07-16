function [index, componentes] = detectaComponentes(Y, Fs, harmonicas)

[max_Y,index_max] = max(abs(Y));
index_max = index_max - 1;
%fprintf("Fundamental: %6f\n", index_max*Fs/(length(Y)));

index_harmonicas = [];
banda = round(0.1*index_max);

for i=1:harmonicas
    [max_h, index_h] = max( abs( Y( (i+1)*index_max-banda:(i+1)*index_max+banda ) ) );
    index_h = (index_h - 1) + ((i+1)*index_max-banda - 1);
    index_harmonicas(i) = index_h;
end

%fundamental=index_max*Fs/(length(Y));
%harmonicas=index_harmonicas.*Fs./(length(Y));

index = [index_max index_harmonicas];
componentes = Y(index);
end

