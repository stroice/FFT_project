library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity No_Mem_proposed is
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
		M_in1:  		 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out1: 		 in std_logic_vector(Input_Data_size -1 downto 0);
		M_in2:  		 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out2: 		 in std_logic_vector(Input_Data_size -1 downto 0);
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end No_Mem_proposed;

architecture No_Mem_proposed_arch of No_Mem_proposed is

SIGNAL M: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL B:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL A:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL AB_aux:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S2:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL out_sig:	std_logic_vector(Input_Data_size downto 0);

SIGNAL add_aux:	unsigned(0 downto 0);
SIGNAL Carry_controler:	std_logic;
SIGNAL WE1_R:	std_logic;

begin

	M_in1 <= Din;
	M_in2 <= Din;
	S1 <= M_out1;
	M <= M_out2;
 
	WE1_R <= not(control(N_Stages - Stage));
 
	AB_aux <= (others => control(N_Stages - Stage));
	A  <= (Din AND AB_aux);
	B  <= (M NOR  AB_aux);
	S2 <= (A OR B);
	
	add_aux(0) <= WE1_R;

	out_sig <= std_logic_vector(unsigned("0" & S1) + unsigned("0" & S2) + add_aux);

	Carry_controler <= S1(Input_Data_size -1) XOR S2(Input_Data_size -1);
	
	with Carry_controler select
	     Dout<= std_logic_vector(resize(signed(out_sig(Input_Data_size-1 downto 1)), Input_Data_size))		 when '1',
					 out_sig(Input_Data_size downto 1) when others;


end No_Mem_proposed_arch;