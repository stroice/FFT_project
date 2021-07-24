
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Butterfly_SDF_memories is
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	rst:		 in  std_logic;
	  	clk:  		 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end Butterfly_SDF_memories;

architecture Butterfly_SDF_memories_arch of Butterfly_SDF_memories is

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

SIGNAL M_in_aux: 	std_logic_vector(Input_Data_size downto 0);
SIGNAL M_in: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL M_out:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL out_sig:	signed(Input_Data_size downto 0);

begin

	with control(N_Stages - Stage) select
	    M_in_aux <=  	std_logic_vector(resize(signed(M_out), Input_Data_size+1) - resize(signed(Din), Input_Data_size+1)) when '1',
								std_logic_vector(Din & "0") when others;

		M_in <= M_in_aux(Input_Data_size downto 1);

	Mem1:DelayMem generic map(WL => Input_Data_size, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => control(N_Stages - Stage -1 downto 0), WE => '1',
			  	Din => M_in, Dout => M_out);


	with control(N_Stages - Stage) select
	    out_sig <=  	signed(resize(signed(M_out), Input_Data_size+1) + resize(signed(Din), Input_Data_size+1)) when '1',
						signed(M_out & "0") when others;
	
	
	Dout <= std_logic_vector(out_sig(Input_Data_size downto 1)) ;

end Butterfly_SDF_memories_arch;