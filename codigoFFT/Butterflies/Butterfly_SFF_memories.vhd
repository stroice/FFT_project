

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Butterfly_FFT_Mem is
	generic(	 
		N_Stages: 		integer:=10;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=6;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		rst:  		 in  std_logic;
	  	clk:  		 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end Butterfly_FFT_Mem;

architecture Butterfly_FFT_Mem_arch of Butterfly_FFT_Mem is

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


SIGNAL M: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1_aux: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1:	signed(Input_Data_size -1 downto 0);
SIGNAL S2:	signed(Input_Data_size -1 downto 0);
SIGNAL out_sig:	signed(Input_Data_size downto 0);

begin


	Mem1:DelayMem generic map(WL => Input_Data_size, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => control(N_Stages - Stage -1 downto 0), WE => '1', Din => Din, Dout => S1_aux);

	S1 <= signed(S1_aux);

	Mem2:DelayMem generic map(WL => Input_Data_size, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => control(N_Stages - Stage -1 downto 0), WE => '1',
			  	Din => S1_aux, Dout => M);
	
	with control(N_Stages - Stage) select
	    S2 <=  	signed(Din) when '1',
			signed(M) when others;

	with control(N_Stages - Stage) select
	    out_sig <=  	resize(S2, Input_Data_size+1) + resize(S1, Input_Data_size+1)when '1',
							resize(S2, Input_Data_size+1) - resize(S1, Input_Data_size+1) when others;
			
	Dout <=  std_logic_vector(out_sig(Input_Data_size downto 1));

end Butterfly_FFT_Mem_arch;