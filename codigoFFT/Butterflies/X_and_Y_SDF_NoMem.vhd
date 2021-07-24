
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity X_Y_Butterfly_SDF_NoMem is

	generic(	 
		N_Stages: 		integer:=10;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=6			-- Butterfly Stage of the butterfly
		);	
	port(
	  	clk:  		 	 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	X_in:  		 in  std_logic_vector(15 downto 0);
		Y_in:  		 in  std_logic_vector(15 downto 0);
		In_Mem:  		 out  std_logic_vector(31 downto 0); 
	  	Out_Mem: 		 in std_logic_vector(31 downto 0);
	  	X_out: 		 out std_logic_vector(15 downto 0);
		Y_out: 		 out std_logic_vector(15 downto 0)
		);
		
end X_Y_Butterfly_SDF_NoMem;

architecture X_Y_Butterfly_SDF_NoMem_behaviour of X_Y_Butterfly_SDF_NoMem is

Constant Input_Data_size: 	   integer:= 16;


component No_Mem_SDF
	generic(	 
		N_Stages: 		integer:=10;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=6;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 in  std_logic;
		control: 	 in  std_logic;
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		M_in:  		 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out: 		 in std_logic_vector(Input_Data_size -1 downto 0);
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end component;

begin

	UUTX : No_Mem_SDF	
	generic map (N_Stages => 10, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (clk => clk, M_in =>  In_Mem(15 downto 0), M_out =>  Out_Mem(15 downto 0),	control => control(N_Stages - Stage), Din => X_in, Dout => X_out);

	UUTY : No_Mem_SDF	
	generic map (N_Stages => 10, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (clk => clk, M_in =>  In_Mem(31 downto 16), M_out =>  Out_Mem(31 downto 16), control => control(N_Stages - Stage), Din => Y_in, Dout => Y_out);

	
end X_Y_Butterfly_SDF_NoMem_behaviour;
