library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity No_Mem_SFF is
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
end No_Mem_SFF;

architecture No_Mem_SFF_arch of No_Mem_SFF is

SIGNAL M: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1_aux: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1:	signed(Input_Data_size -1 downto 0);
SIGNAL S2:	signed(Input_Data_size -1 downto 0);
SIGNAL out_sig:	signed(Input_Data_size downto 0);

begin


	M_in1 <= Din;
	S1_aux <= M_out1;
	M_in2 <= S1_aux;
	M <= M_out2;
	
	
		S1 <= signed(S1_aux);

	with control(N_Stages - Stage) select
	    S2 <=  	signed(Din) when '1',
			signed(M) when others;

	with control(N_Stages - Stage) select
	    out_sig <=  	resize(S2, Input_Data_size+1) + resize(S1, Input_Data_size+1)when '1',
							resize(S2, Input_Data_size+1) - resize(S1, Input_Data_size+1) when others;
			
	Dout <=  std_logic_vector(out_sig(Input_Data_size downto 1));

end No_Mem_SFF_arch;