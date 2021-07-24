
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;


entity Butterfly_registers is
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 in  std_logic;
		control: 	 in  std_logic;
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end Butterfly_registers;

architecture Butterfly_registers_arch of Butterfly_registers is

component DelayReg 

	generic(	
		WL: integer:=8;			-- Word Length
		BL: integer:= 1024);		-- Buffer Length
	port(
	  	clk:  in  std_logic;
	  	Din:  in  std_logic_vector(WL -1 downto 0); 
	  	Dout: out std_logic_vector(WL -1 downto 0));
end component;


SIGNAL M: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1_aux: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1:	signed(Input_Data_size -1 downto 0);
SIGNAL S2:	signed(Input_Data_size -1 downto 0);
SIGNAL out_sig:	signed(Input_Data_size downto 0);

begin

	Mem1:DelayReg generic map(WL => Input_Data_size, BL => (2**(N_Stages - Stage))) port map(clk => clk, Din => Din, Dout => S1_aux);
	
	S1 <= signed(S1_aux);

	Mem2:DelayReg generic map(WL => Input_Data_size, BL => (2**(N_Stages - Stage))) port map(clk => clk, Din => S1_aux, Dout => M);
	
	with control select
	    S2 <=  	signed(Din) when '1',
			signed(M) when others;

	with control select
	    out_sig <=  	resize(S2, Input_Data_size+1) + resize(S1, Input_Data_size+1)when '1',
							resize(S2, Input_Data_size+1) - resize(S1, Input_Data_size+1) when others;
			
	Dout <=  std_logic_vector(out_sig(Input_Data_size downto 1));
	

end Butterfly_registers_arch;