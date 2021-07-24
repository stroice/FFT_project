
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.MATH_REAL.all;
--use work.componentes.all;

library STD;
use STD.TEXTIO.all;
 
ENTITY tb_FFT_1024_2021_texto IS
END tb_FFT_1024_2021_texto;
 
ARCHITECTURE behavior OF tb_FFT_1024_2021_texto IS 

component FFT_Proposed
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		rst: 	 		 in  std_logic;
		clk: 	 		 in  std_logic;
	  	X_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		Y_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	X_out: 		 out std_logic_vector(Input_Data_size -1 downto 0);
		Y_out: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end component;
 
constant P  : integer := 1;
constant WL : integer := 16;	 
constant crecimiento: integer := 0;
constant n_etapas: integer:= 10;

-------------------------
-------------------------

signal rstn     : std_logic;
signal rst      : std_logic;
signal enable   : std_logic;
signal clk      : std_logic;
--signal datain   : databus(P-1 downto 0, 2*WL -1 downto 0);
--signal dataout  : databus(P-1 downto 0, 2*(WL + crecimiento*n_etapas) -1 downto 0);
signal Din:  std_logic_vector(2*WL -1 downto 0);
signal Dout: std_logic_vector(2*WL -1 downto 0);

signal xin_sig   : std_logic_vector( WL downto 0);
signal yin_sig   : std_logic_vector( WL downto 0);
signal xout_sig  : std_logic_vector( WL downto 0);
signal yout_sig  : std_logic_vector( WL downto 0);

type arrentrada is array (P-1 downto 0) of std_logic_vector(2*WL -1 downto 0);
signal array_entradas: arrentrada;

type arrsalida is array (P-1 downto 0) of std_logic_vector(2*(WL + crecimiento*n_etapas) -1 downto 0);
signal array_salidas: arrsalida;

constant logP : integer := integer(log2(real(P))); 
constant clk_period : time := 10 ns;
 
-- Archivos de texto
   
file entrada: TEXT is in  "/home/mcre310/TFM/Main/Datos/FFTin.dat";
file salida : TEXT is out "/home/mcre310/TFM/Main/Datos/FFTout.dat";
      
-- Senales de control

signal simular: std_logic;
signal start: std_logic;
signal parte_real, parte_imaginaria: integer;
constant latencia: integer:= 1050;   --AJUSTAR
   
 
BEGIN

DUT: FFT_Proposed
   generic map(	
		Input_Data_size => WL)	   
	port map(
	 	clk  => clk,
	 	rst => rst,
	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		X_out  => Dout(2*WL-1 downto WL), 
		Y_out  => Dout(WL-1 downto 0)); 
		
		
rstn <= '1', '0' after 10 ns, '1' after 28 ns; -- 100 ms; 
rst <= not(rstn);
enable <= '1';

-- Clock process definitions
clk_process :process
begin
   clk   <= '0';
   wait for clk_period/2;
   clk   <= '1';
   wait for clk_period/2;
end process;

Din <= array_entradas(0);
array_salidas(0) <= Dout;

lectura: PROCESS

   variable linea_in: line; 
   variable dato_r: integer;
   variable dato_i: integer;

begin

	simular <= '1';
   start <= '0';
   
   wait until rstn = '0';  
	wait until rstn = '1'; 
   
   start <= '1';
  
   while not endfile(entrada) loop
      
      for i in 0 to P-1 loop
         --Parte real:
         readline(entrada,linea_in);
         read(linea_in,dato_r);

         -- Parte imaginaria:
         readline(entrada,linea_in);
         read(linea_in,dato_i);

         parte_real <= dato_r;
         parte_imaginaria <= dato_i;
         
         array_entradas(i) <= Conv_Std_Logic_Vector(dato_r, WL) & Conv_Std_Logic_Vector(dato_i, WL);
           
      end loop;   
   
      wait for clk_period;
   end loop;      
   
   -- YA HEMOS TERMINADO DE PASAR TODOS LOS DATOS DEL ARCHIVO:   
   -- Hacemos que las entradas valgan a partir de ahora cero.
   for i in 0 to P-1 loop
      array_entradas(i) <= (others => '0');	
   end loop;      
								   
	wait for (latencia-1)*clk_period;--(latencia -1) * clk_period;
		simular <= '0';   -- dejamos de escribir en el archivo de salida
      
	wait for 4*clk_period;
	   readline(entrada,linea_in); -- generamos un error para que pare el simulador
      
	wait;
   
end process;
    

escritura: PROCESS
        
     	variable dato_salida : integer;
		variable signo: std_logic;
		variable dato_aux: std_logic_vector((WL + crecimiento) -1 downto 0);
	   variable linea_out : line;
		variable espacio: character := ' ';
		variable menos: character := '-';

     begin
     
      wait until start = '1';
      
      wait for latencia*clk_period; 	
      
		while simular = '1' loop
      
         for i in 0 to P-1 loop

            -- PARTE REAL:

            dato_salida:= conv_integer(array_salidas(i)(2*(WL + crecimiento) -1 downto (WL + crecimiento))); 

            signo := array_salidas(i)(2*(WL + crecimiento) -1);
            
            if signo = '0' then  	-- Número positivo
               dato_salida:= conv_integer(array_salidas(i)(2*(WL + crecimiento) -1 downto (WL + crecimiento)));  	
            else 				-- Número negativo
               dato_aux:=	array_salidas(i)(2*(WL + crecimiento) -1 downto (WL + crecimiento));
               dato_aux:= not dato_aux;
               dato_salida:= conv_integer(dato_aux +1); 	-- obtenemos el valor absoluto del número
               write(linea_out,menos);				         -- escribimos el signo menos
            end if;

            write(linea_out,dato_salida);				-- escribimos la parte real

            -- Separamos la parte real de la imaginaria mediante un espacio:

            write(linea_out,espacio);

            -- PARTE IMAGINARIA:

            dato_salida:= conv_integer(array_salidas(i)((WL + crecimiento) -1 downto 0));  
            
            signo := array_salidas(i)((WL + crecimiento) -1);
         
            if signo = '0' then  	-- Número positivo
               dato_salida:= conv_integer(array_salidas(i)((WL + crecimiento) -1 downto 0));  	
            else 				-- Número negativo
               dato_aux:=	array_salidas(i)((WL + crecimiento) -1 downto 0);
               dato_aux:= not dato_aux;
               dato_salida:= conv_integer(dato_aux +1); 	-- obtenemos el valor absoluto del número
               write(linea_out,menos);				         -- escribimos el signo menos
            end if;

            write(linea_out,dato_salida);				-- escribimos la parte imaginaria
      
            -- Escribimos en el archivo la línea que hemos compuesto:

            writeline(salida,linea_out);
         end loop;
         
         wait for clk_period;			-- Esperamos un ciclo de reloj
         
         
		end loop;				         -- Volvemos al principio del bucle
		
		wait;

END PROCESS;


END;

