
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity X_Y_Butterfly_Proposed_DirectComp is

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
		
end X_Y_Butterfly_Proposed_DirectComp;

architecture X_Y_Butterfly_Proposed_DirectComp_behaviour of X_Y_Butterfly_Proposed_DirectComp is

component Butterfly_proposed
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
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end component;

begin

	UUTX : Butterfly_proposed	
	generic map (N_Stages => N_Stages, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (rst => rst, clk => clk, control => control, Din => X_in, Dout => X_out);

	UUTY : Butterfly_proposed	
	generic map (N_Stages => N_Stages, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (rst => rst,  clk => clk, control => control, Din => Y_in, Dout => Y_out);

	
end X_Y_Butterfly_Proposed_DirectComp_behaviour;
