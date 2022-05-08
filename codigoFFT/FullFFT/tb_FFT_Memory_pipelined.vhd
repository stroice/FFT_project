
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.MATH_REAL.all;
--use work.componentes.all;

library STD;
use STD.TEXTIO.all;
 
ENTITY tb_fft_1024_RAM_Mems_texto IS
END tb_fft_1024_RAM_Mems_texto;
 
ARCHITECTURE behavior OF tb_fft_1024_RAM_Mems_texto IS 

constant Input_Data_size:	integer:=16;

component FFT_RAM_Memory_pipelined
	port(
		rst: 	 		 in  std_logic;
		clk: 	 		 in  std_logic;
	  	X_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		Y_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		
		M_in1_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out1_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control1: 	 out  std_logic_vector(8 downto 0);
		M_in1_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out1_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control1_2: 	 out  std_logic_vector(8 downto 0);
		
		M_in2_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out2_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control2: 	 out  std_logic_vector(7 downto 0);
		M_in2_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out2_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control2_2: 	 out  std_logic_vector(7 downto 0);
		
		M_in3_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out3_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control3: 	 out  std_logic_vector(6 downto 0);
		M_in3_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out3_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control3_2: 	 out  std_logic_vector(6 downto 0);
		
		M_in4_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out4_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control4: 	 out  std_logic_vector(5 downto 0);
		M_in4_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out4_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control4_2: 	 out  std_logic_vector(5 downto 0);
		
	  	X_out: 		 out std_logic_vector(Input_Data_size -1 downto 0);
		Y_out: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end component;
 
component DelayMem 
	generic(	
	  WL: 	   integer;		 -- Word Length	
	  BL_exp:  integer);		  -- Buffer Length exponent
	port(
	  rst:     in  std_logic;
	  clk:     in  std_logic;
	  WE:	   in  std_logic;
	  counter: in  std_logic_vector(BL_exp -1 downto 0);
	  Din:     in  std_logic_vector(WL -1 downto 0); 
	  Dout:    out std_logic_vector(WL -1 downto 0));
end component;
 
  
    component Memory_Proposed_512
	
	port(
	  	clk:  		 in  std_logic;
		CE1:  		 in  std_logic;
		CE2:  		 in  std_logic;
		control1:  in  std_logic_vector(8 downto 0);
		control2:  in  std_logic_vector(8 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
		);
		
end component;
  
  component Memory_Proposed_256
	
	port(
	  	clk:  		 in  std_logic;
		CE1:  		 in  std_logic;
		CE2:  		 in  std_logic;
		control1:  in  std_logic_vector(7 downto 0);
		control2:  in  std_logic_vector(7 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
		);
		
end component;
 
  component Memory_Proposed_128
	
	port(
	  	clk:  		 in  std_logic;
		CE1:  		 in  std_logic;
		CE2:  		 in  std_logic;
		control1:  in  std_logic_vector(6 downto 0);
		control2:  in  std_logic_vector(6 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
		);
		
end component;
  
component Memory_Proposed_64
	
	port(
	  	clk:  		 in  std_logic;
		control1:  in  std_logic_vector(5 downto 0);
		control2:  in  std_logic_vector(5 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
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

--Expected clock:
 --constant clk_period : time := 0.81 ns;
 constant clk_period : time := 0.75 ns;
 --constant clk_period : time := 0.99 ns;
-- Archivos de texto
   
file entrada: TEXT is in  "/home/mcre310/TFM/Main/Datos/FFTin.dat";
file salida : TEXT is out "/home/mcre310/TFM/Main/Datos/FFTout.dat";
      
-- Senales de control

signal simular: std_logic;
signal start: std_logic;
signal parte_real, parte_imaginaria: integer;
constant latencia: integer:= 1060;   --AJUSTAR
   
 -- Senales de memorias
 
signal		M_in1_X:  std_logic_vector(WL -1 downto 0); 
signal	  	M_out1_X: std_logic_vector(WL -1 downto 0);		
signal		control1:  std_logic_vector(8 downto 0);
signal		M_in1_Y: std_logic_vector(WL -1 downto 0); 
signal	  	M_out1_Y: std_logic_vector(WL -1 downto 0);		
signal		control1_2, control1_real, control1_real_2:  std_logic_vector(8 downto 0);
		
signal		M_in2_X:  std_logic_vector(WL -1 downto 0); 
signal	  	M_out2_X: std_logic_vector(WL -1 downto 0);		
signal		control2:  std_logic_vector(7 downto 0);
signal		M_in2_Y:  std_logic_vector(WL -1 downto 0); 
signal	  	M_out2_Y: std_logic_vector(WL -1 downto 0);		
signal		control2_2, control2_real, control2_real_2:  std_logic_vector(7 downto 0);
		
signal		M_in3_X : std_logic_vector(WL -1 downto 0); 
signal	  	M_out3_X :std_logic_vector(WL -1 downto 0);		
signal		control3: std_logic_vector(6 downto 0);
signal		M_in3_Y: std_logic_vector(WL -1 downto 0); 
signal	  	M_out3_Y: std_logic_vector(WL -1 downto 0);		
signal		control3_2, control3_real, control3_real_2: std_logic_vector(6 downto 0);
		
		
signal		M_in4_X:   std_logic_vector(WL -1 downto 0); 
signal	  	M_out4_X: std_logic_vector(WL -1 downto 0);		
signal		control4: std_logic_vector(5 downto 0);
signal		M_in4_Y:   std_logic_vector(WL -1 downto 0); 
signal	  	M_out4_Y: std_logic_vector(WL -1 downto 0);		
signal		control4_2, control4_real, control4_real_2: std_logic_vector(5 downto 0);

signal 		In_Mem1, Out_Mem1, Out_Mem1_del: std_logic_vector(31 downto 0); 
signal 		In_Mem2, Out_Mem2, Out_Mem2_del: std_logic_vector(31 downto 0);		
signal 		In_Mem3, Out_Mem3, Out_Mem3_del: std_logic_vector(31 downto 0); 
signal 		In_Mem4, Out_Mem4, Out_Mem4_del: std_logic_vector(31 downto 0);		
 
BEGIN

	   
	--Memory RAM control 1
	--with control1(8) select
	--    control1_real <= (control1(7 downto 0) & control1(8))  when '1',
	--		(not(control1(7 downto 0)) & control1(8))  when others;
	  
	--  with control1_2(8) select
	--    control1_real_2 <= (control1_2(7 downto 0) & control1_2(8))  when '1',
	--		(not(control1_2(7 downto 0)) & control1_2(8))  when others;
	  
	  --RAM1 L Ddelay 
	 --MEM1: Memory_Proposed_512
	--port map(clk => clk, CE1 => '0', CE2 => '0', control1 => control1_real, control2 => control1_real_2, X => In_Mem1, Y => Out_Mem1);
	 
	--Memory RAM control 2
	--with control2(7) select
	--    control2_real <= (control2(6 downto 0) & control2(7))  when '1',
	--		(not(control2(6 downto 0)) & control2(7))  when others;
	  
	--  with control2_2(7) select
	 --   control2_real_2 <= (control2_2(6 downto 0) & control2_2(7))  when '1',
	--		(not(control2_2(6 downto 0)) & control2_2(7))  when others;
	  
	  --RAM2 L Ddelay 
	-- MEM2: Memory_Proposed_256
	--port map(clk => clk, CE1 => '0', CE2 => '0', control1 => control2_real, control2 => control2_real_2, X => In_Mem2, Y => Out_Mem2);
	  
	  --Memory RAM control 3
	--with control3(6) select
	    --control3_real <= (control3(5 downto 0) & control3(6))  when '1',
			--(not(control3(5 downto 0)) & control3(6))  when others;
	  
	  --with control3_2(6) select
	    --control3_real_2 <= (control3_2(5 downto 0) & control3_2(6))  when '1',
			--(not(control3_2(5 downto 0)) & control3_2(6))  when others;
	  
	  --RAM3 L Ddelay 
	 --MEM3: Memory_Proposed_128
	--port map(clk => clk, CE1 => '0', CE2 => '0', control1 => control3, control2 => control3_2, X => In_Mem3, Y => Out_Mem3);
	  

	  --Memory RAM control 4
	 -- with control4(5) select
	    --control4_real <= (control4(4 downto 1) & control4(5) & control4(0))  when '0',
			--(not(control4(4 downto 1)) & control4(5) & control4(0))  when others;
	  
	  --RAM4 L Ddelay 
	 -- with control4_2(5) select
	    --control4_real_2 <= (control4_2(4 downto 1) & control4_2(5) & control4_2(0))  when '0',
			--(not(control4_2(4 downto 1)) & control4_2(5) & control4_2(0))  when others;
	  
	  
	 MEM4: Memory_Proposed_64
	port map(clk => clk, control1 => control4, control2 => control4_2, X => In_Mem4, Y => Out_Mem4);
	  
	  
	 --Memory simulation
	  
    Mem1_X:DelayMem 
	generic map(	
	  WL => WL,		 -- Word Length	
	  BL_exp => 9)		  -- Buffer Length exponent
	port map(
	  rst => rst,
	  clk  => clk,
	  
	  WE => '1',
	  counter => control1,
	  Din => In_Mem1(15 downto 0), 
	  Dout => Out_Mem1(15 downto 0));
	  
	Mem1_Y:DelayMem 
	generic map(	
	  WL => WL,		 -- Word Length	
	  BL_exp => 9)		  -- Buffer Length exponent
	port map(
	  rst => rst,
	  clk  => clk,
	  
	  WE => '1',
	  counter => control1,
	  Din => In_Mem1(31 downto 16), 
	  Dout => Out_Mem1(31 downto 16));

	Mem2_X:DelayMem 
	generic map(	
	  WL => WL,		 -- Word Length	
	  BL_exp => 8)		  -- Buffer Length exponent
	port map(
	  rst => rst,
	  clk  => clk,
	  
	  WE => '1',
	  counter => control2,
	  Din => In_Mem2(15 downto 0), 
	  Dout => Out_Mem2(15 downto 0));
	  
	Mem2_Y:DelayMem 
	generic map(	
	  WL => WL,		 -- Word Length	
	  BL_exp => 8)		  -- Buffer Length exponent
	port map(
	  rst => rst,
	  clk  => clk,
	  
	  WE => '1',
	  counter => control2,
	  Din => In_Mem2(31 downto 16), 
	  Dout => Out_Mem2(31 downto 16));
	  
	  
	 Mem3_X:DelayMem 
	generic map(	
	  WL => WL,		 -- Word Length	
	  BL_exp => 7)		  -- Buffer Length exponent
	port map(
	  rst => rst,
	  clk  => clk,
	  
	  WE => '1',
	  counter => control3,
	  Din => In_Mem3(15 downto 0), 
	  Dout => Out_Mem3(15 downto 0));
	  
	Mem3_Y:DelayMem 
	generic map(	
	  WL => WL,		 -- Word Length	
	  BL_exp => 7)		  -- Buffer Length exponent
	port map(
	  rst => rst,
	  clk  => clk,
	  
	  WE => '1',
	  counter => control3,
	  Din => In_Mem3(31 downto 16), 
	  Dout => Out_Mem3(31 downto 16));
	  
	--Mem4_X:DelayMem 
	--generic map(	
	  --WL => WL,		 -- Word Length	
	  --BL_exp => 6)		  -- Buffer Length exponent
	--port map(
	  --rst => rst,
	  --clk  => clk,
	  
	  --WE => '1',
	  --counter => control4,
	  --Din => In_Mem4(15 downto 0), 
	  --Dout => Out_Mem4(15 downto 0));
	  
	--Mem4_Y:DelayMem 
	--generic map(	
	  --WL => WL,		 -- Word Length	
	  --BL_exp => 6)		  -- Buffer Length exponent
	--port map(
	  --rst => rst,
	  --clk  => clk,
	  
	  --WE => '1',
	  --counter => control4,
	  --Din => In_Mem4(31 downto 16), 
	  --Dout => Out_Mem4(31 downto 16));

     Out_Mem1_del <= Out_Mem1 after 0.456 ns;
	 Out_Mem2_del <= Out_Mem2 after 0.430 ns;
	 Out_Mem3_del <= Out_Mem3 after 0.418 ns;
     --Out_Mem4_del <= Out_Mem4 after 0.392 ns;

dut: FFT_RAM_Memory_pipelined
	port map(
	 	clk  => clk,
	 	rst => rst,
		
		M_in1_X => In_Mem1(15 downto 0),
	  	M_out1_X => Out_Mem1_del(15 downto 0),		
		control1   => control1,
		M_in1_Y => In_Mem1(31 downto 16),
	  	M_out1_Y => Out_Mem1_del(31 downto 16),
		control1_2   => control1_2,
		
		M_in2_X => In_Mem2(15 downto 0),
	  	M_out2_X => Out_Mem2_del(15 downto 0),	
		control2   => control2,
		M_in2_Y => In_Mem2(31 downto 16),
	  	M_out2_Y => Out_Mem2_del(31 downto 16),	
		control2_2   => control2_2,
		
		M_in3_X => In_Mem3(15 downto 0),
	  	M_out3_X => Out_Mem3_del(15 downto 0),	
		control3 => control3,
		M_in3_Y => In_Mem3(31 downto 16),
	  	M_out3_Y => Out_Mem3_del(31 downto 16),
		control3_2 => control3_2,
		
		M_in4_X => In_Mem4(15 downto 0),
	  	M_out4_X => Out_Mem4(15 downto 0),	
		control4 => control4,
		M_in4_Y => In_Mem4(31 downto 16),
	  	M_out4_Y => Out_Mem4(31 downto 16),
		control4_2 => control4_2,

	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		X_out  => Dout(2*WL-1 downto WL), 
		Y_out  => Dout(WL-1 downto 0)); 
		
		
rstn <= '1', '0' after clk_period, '1' after (clk_period*2.85); -- 100 ms; 
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


