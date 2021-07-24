
P = 1;
n_etapas = 10;
n_bits = 16;
N = 2^n_etapas;

% Muestras de prueba:
NFFT = N;
rin = zeros(N*NFFT,1);
iin = zeros(N*NFFT,1);
for i = 0: NFFT-1
    f = N/1024;
    %f = 0;
    t = (0:N-1);
    rin(i*N+1:(i+1)*N) = cos(2*pi*f*t/N);
    iin(i*N+1:(i+1)*N) = sin(2*pi*f*t/N);
%     rin(i*N+1:(i+1)*N) = t;
%     iin(i*N+1:(i+1)*N) = t;
end

entrada_real = rin;
entrada_imag = iin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Escribir en el archivo en el orden y escala adecuados: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ordenamos las muestras para aplicarlas a la entrada:
rin_aux = zeros(N/P,P);
iin_aux = zeros(N/P,P);
rin_aux2 = zeros(N/P,P);
iin_aux2 = zeros(N/P,P);

% % Ajustamos las muestras a los bits utilizados:
rin = round(rin*(2^(n_bits-3) -1));
iin = round(iin*(2^(n_bits-3) -1));

datos = reshape([rin'; iin'], length(rin) + length(iin), 1);



fd = fopen('FFTin.dat','w');
fprintf(fd,'%1.0f\r\n',datos);

fclose(fd);

disp('Pulsar intro cuando haya acabado la simulacion');
pause

% Postprocesado:

y = load('FFTout.dat');

y = y(:,1) + 1j*y(:,2);  % Parte real mas imaginaria

for i = 0:NFFT -1
    
    % Tomamos los resultados de una de las FFTs.
    w = y(i*N+1:(i+1)*N);
      
    % Hacemos el bit reversal.    
    w_aux = zeros(N,1);
    for k = 0:N-1
        q = dec2bin(k,log2(N));
        q = bin2dec(q(length(q):-1:1));
        w_aux(q+1) = w(k+1);
    end

    y(i*N+1:(i+1)*N) = w_aux; 
end

 figure(P);
 plot(abs(y));
% 
% mod(find(abs(y)>100) -1,N)




