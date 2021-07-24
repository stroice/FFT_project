
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity X_Y_Butterfly is

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
		
end X_Y_Butterfly;

architecture behaviour of X_Y_Butterfly is

component Butterfly_SDF_registers
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
end component;

begin

	UUTX : Butterfly_SDF_registers	
	generic map (N_Stages => N_Stages, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (clk => clk, control => control, Din => X_in, Dout => X_out);

	UUTY : Butterfly_SDF_registers	
	generic map (N_Stages => N_Stages, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (clk => clk, control => control, Din => Y_in, Dout => Y_out);

	
end behaviour;
