LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.MATH_REAL.all;
--use work.componentes.all;

library STD;
use STD.TEXTIO.all;
 
ENTITY tb_X_Y_Butterfly_Memories_64_consumpt IS
END tb_X_Y_Butterfly_Memories_64_consumpt;
 
ARCHITECTURE tb_X_Y_Butterfly_Memories_64_consumpt_behavior OF tb_X_Y_Butterfly_Memories_64_consumpt IS 

component X_Y_Butterfly

generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 	 in  std_logic;
		control: 	 in  std_logic;
	  	X_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		Y_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	X_out: 		 out std_logic_vector(Input_Data_size -1 downto 0);
		Y_out: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
		
end component;
 
 component X_Y_Butterfly_Proposed_DirectComp
	
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);	
	port(
	  	rst:		 in  std_logic;
	  	clk:  		 	 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	X_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		Y_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	X_out: 		 out std_logic_vector(Input_Data_size -1 downto 0);
		Y_out: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
		
end component;
 
 component X_Y_Butterfly_SDF_Memories_64
	
	port(
	  	clk:  		 	 in  std_logic;
		control: in  std_logic_vector(6 downto 0);
		control2: in  std_logic_vector(6 downto 0);
	  	X_in:  		 in  std_logic_vector(15 downto 0);
		Y_in:  		 in  std_logic_vector(15 downto 0); 
	  	X_out: 		 out std_logic_vector(15 downto 0);
		Y_out: 		 out std_logic_vector(15 downto 0)
		);
		
end component;
 
 component X_Y_Butterfly_Memories_Proposed_64
	
	port(
	  	clk:  		 	 in  std_logic;
		control: in  std_logic_vector(6 downto 0);
		control2: in  std_logic_vector(6 downto 0);
	  	X_in:  		 in  std_logic_vector(15 downto 0);
		Y_in:  		 in  std_logic_vector(15 downto 0); 
	  	X_out: 		 out std_logic_vector(15 downto 0);
		Y_out: 		 out std_logic_vector(15 downto 0)
		);
		
end component;
 
 component COUNTER
  generic (
    WIDTH     : integer
    );
  port (
    account   : out STD_LOGIC_VECTOR (WIDTH-1  downto 0);
    start    : in  STD_LOGIC;
    rst      : in  STD_LOGIC;
    clk      : in  STD_LOGIC
    );
end component;
 
constant N_Stages : integer := 10;
constant Stage : integer := 4;

constant P  : integer := 1;
constant WL : integer := 16;	 
constant crecimiento: integer := 0;
constant n_etapas: integer:= 10;

-------------------------
-------------------------

signal suma : integer;
signal control : std_logic;
signal rstn     : std_logic;
signal rst      : std_logic;
signal enable   : std_logic;
signal clk      : std_logic;
signal start_not     : std_logic;
--signal datain   : databus(P-1 downto 0, 2*WL -1 downto 0);
--signal dataout  : databus(P-1 downto 0, 2*(WL + crecimiento*n_etapas) -1 downto 0);
signal Din:  std_logic_vector(2*WL -1 downto 0);
signal Dout: std_logic_vector(2*WL -1 downto 0);
signal Comp_Out: std_logic_vector(2*WL -1 downto 0);
signal Synteth_Prop_Out: std_logic_vector(2*WL -1 downto 0);
signal SDF_Mem_Out: std_logic_vector(2*WL -1 downto 0);
signal account: std_logic_vector(9 downto 0);

signal control1: std_logic_vector(9 downto 0);
signal control2: std_logic_vector(9 downto 0);

type arrentrada is array (P-1 downto 0) of std_logic_vector(2*WL -1 downto 0);
signal array_entradas: arrentrada;

type arrsalida is array (P-1 downto 0) of std_logic_vector(2*(WL + crecimiento*n_etapas) -1 downto 0);
signal array_salidas: arrsalida;

constant logP : integer := integer(log2(real(P))); 
constant clk_period : time := 10 ns;
 
-- Archivos de texto
   
file entrada: TEXT is in  "/home/mcre310/TFM/Comparison_Butterfly/datos/Testin.dat";
      
-- Senales de control

signal simular: std_logic;
signal start, startt: std_logic;
signal parte_real, parte_imaginaria: integer;
   
 
BEGIN

Comprobation: X_Y_Butterfly
   generic map(	
		N_Stages => N_Stages,
		Stage => Stage,
		Input_Data_size => WL)	   
	port map(
	 	clk  => clk,
	 	control => control1(N_Stages - Stage),
	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		X_out  => Comp_Out(2*WL-1 downto WL), 
		Y_out  => Comp_Out(WL-1 downto 0)
		); 
		
Comprobation_Proposed: X_Y_Butterfly_Proposed_DirectComp
   generic map(	
		N_Stages => N_Stages,
		Stage => Stage,
		Input_Data_size => WL)	   
	port map(
		rst  => rst,
	 	clk  => clk,
	 	control => control1(N_Stages - Stage downto 0),
	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		X_out  => Synteth_Prop_Out(2*WL-1 downto WL), 
		Y_out  => Synteth_Prop_Out(WL-1 downto 0)
		); 	
	
		
DUT_SDF: X_Y_Butterfly_SDF_Memories_64
   generic map(	
		N_Stages => N_Stages,
		Stage => Stage,
		Input_Data_size => WL)	   
	port map(
	 	clk  => clk,
	 	control => control1( (N_Stages - Stage) downto 0),
		control2 => control2( (N_Stages - Stage) downto 0),
	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		X_out  => SDF_Mem_Out(2*WL-1 downto WL), 
		Y_out  => SDF_Mem_Out(WL-1 downto 0)
		); 
		
DUT: X_Y_Butterfly_Memories_Proposed_64
   generic map(	
		N_Stages => N_Stages,
		Stage => Stage,
		Input_Data_size => WL)	   
	port map(
	 	clk  => clk,
	 	control => control1( (N_Stages - Stage) downto 0),
		control2 => control2( (N_Stages - Stage) downto 0),
	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		X_out  => Dout(2*WL-1 downto WL), 
		Y_out  => Dout(WL-1 downto 0)
		); 
		
	UUT1 : COUNTER	
	generic map (WIDTH => N_Stages)
  	port map (account => account, start => startt, rst => rst, clk => clk);	
	

rstn <= '1', '0' after 10 ns, '1' after 25.4 ns; -- 100 ms; 
rst <= not(rstn);
enable <= '1';
start_not <= not(start);

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
      
         --Parte real:
         readline(entrada,linea_in);
         read(linea_in,dato_r);

         -- Parte imaginaria:
         readline(entrada,linea_in);
         read(linea_in,dato_i);

		 control2 <= control1;
		 control1 <= account;

         parte_real <= dato_r;
         parte_imaginaria <= dato_i;
         
         array_entradas(0) <= Conv_Std_Logic_Vector(dato_r, WL) & Conv_Std_Logic_Vector(dato_i, WL);
           
		   
      wait for clk_period;
   end loop;      
   
	wait;
   
end process;

END;

