LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.MATH_REAL.all;
--use work.componentes.all;

library STD;
use STD.TEXTIO.all;
 
ENTITY tb_ConsumptionTest_but IS
END tb_ConsumptionTest_but;
 
ARCHITECTURE behavior OF tb_ConsumptionTest_but IS 

constant N_Stages : integer := 10;
constant Stage : integer := 1;


constant P  : integer := 1;
constant WL : integer := 16;	 
constant crecimiento: integer := 0;
constant n_etapas: integer:= 10;

component X_Y_Butterfly_SFF_NoMem
generic(	 
		N_Stages: 		integer:=10;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=6		-- Butterfly Stage of the butterfly
		);	
	port(
	  	clk:  		 	 in  std_logic;
		control: 	 in  std_logic_vector(N_Stages - Stage downto 0);
	  	X_in:  		 in  std_logic_vector(15 downto 0);
		Y_in:  		 in  std_logic_vector(15 downto 0);
		In_Mem1:   out  std_logic_vector(31 downto 0); 
	  	Out_Mem1: in std_logic_vector(31 downto 0);
		In_Mem2:   out  std_logic_vector(31 downto 0); 
	  	Out_Mem2: in std_logic_vector(31 downto 0);
	  	X_out: 		 out std_logic_vector(15 downto 0);
		Y_out: 		 out std_logic_vector(15 downto 0)
		);
		
end component;
 
component EntryInterface
	generic(	
	  WL: 	   integer:= 16);		  -- Word Length	
	port(
	  clk:     in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out std_logic_vector(WL - 1 downto 0)
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
	  Dout:    out std_logic_vector(WL -1 downto 0)
	  );
	end component;
 

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
signal M_in1: std_logic_vector(2*WL -1 downto 0);
signal M_out1: std_logic_vector(2*WL -1 downto 0);
signal M_in2: std_logic_vector(2*WL -1 downto 0);
signal M_out2: std_logic_vector(2*WL -1 downto 0);
signal account: std_logic_vector(9 downto 0);

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
signal start: std_logic;
signal parte_real, parte_imaginaria: integer;
   
 
BEGIN

	Mem1:DelayMem generic map(WL => 2*WL, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => account(N_Stages - Stage -1 downto 0), WE => '1',
			  	Din => M_in1, Dout => M_out1);
	
	Mem2:DelayMem generic map(WL => 2*WL, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => account(N_Stages - Stage -1 downto 0), WE => '1',
			  	Din => M_in2, Dout => M_out2);


	DUT: X_Y_Butterfly_SFF_NoMem  
	generic map(	 
		N_Stages => N_Stages,			-- Butterfly Stage of the butterfly
		Stage => Stage				-- Butterfly Stage of the butterfly
		)
	port map(
	 	clk  => clk,
	 	control => account(N_Stages - Stage downto 0),
	  	X_in  => Din(2*WL-1 downto WL), 
		Y_in  => Din(WL-1 downto 0),  
		In_Mem1  => M_in1(2*WL-1 downto 0),
	  	Out_Mem1  => M_out1(2*WL-1 downto 0), 
		In_Mem2  => M_in2(2*WL-1 downto 0), 
	  	Out_Mem2  => M_out2(2*WL-1 downto 0), 
		X_out  => Dout(2*WL-1 downto WL), 
		Y_out  => Dout(WL-1 downto 0)
		); 
		
	UUT1 : COUNTER	
	generic map (WIDTH => N_Stages)
  	port map (account => account, start => start_not, rst => rst, clk => clk);	
	
	
	
	
rstn <= '1', '0' after 10 ns, '1' after 25.05 ns; -- 100 ms; 
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

         parte_real <= dato_r;
         parte_imaginaria <= dato_i;
         
         array_entradas(0) <= Conv_Std_Logic_Vector(dato_r, WL) & Conv_Std_Logic_Vector(dato_i, WL);
           
		   
      wait for clk_period;
   end loop;      
   
	wait;
   
end process;

END;

