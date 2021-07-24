
%Generación de valores aleatorios:
rin = randi([0 65535],20000,1);
iin = randi([0 65535],20000,1);

datos = reshape([rin'; iin'], length(rin) + length(iin), 1);



fd = fopen('Testin.dat','w');
fprintf(fd,'%1.0f\r\n',datos);

fclose(fd);

disp('Pulsar intro cuando haya acabado la simulacion');
pause




