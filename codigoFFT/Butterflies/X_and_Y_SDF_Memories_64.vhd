
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity X_Y_Butterfly_SDF_Memories_64 is
	
	port(
	  	clk:  		 	 in  std_logic;
		control: in  std_logic_vector(6 downto 0);
		control2: in  std_logic_vector(6 downto 0);
	  	X_in:  		 in  std_logic_vector(15 downto 0);
		Y_in:  		 in  std_logic_vector(15 downto 0); 
	  	X_out: 		 out std_logic_vector(15 downto 0);
		Y_out: 		 out std_logic_vector(15 downto 0)
		);
		
end X_Y_Butterfly_SDF_Memories_64;

architecture X_Y_Butterfly_SDF_Memories_64_behaviour of X_Y_Butterfly_SDF_Memories_64 is

Constant Input_Data_size: 	   integer:= 16;
Constant L: 	   integer:= 6;


component No_Mem_SDF
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
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

component Memory_Proposed_64
	port(
		clk:  		 in  std_logic;
		CE1:  		 in  std_logic;
		CE2:  		 in  std_logic;
		control1:  in  std_logic_vector(5 downto 0);
		control2:  in  std_logic_vector(5 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
		);
end component;

SIGNAL In_Mem:	std_logic_vector(31 downto 0);
SIGNAL Out_Mem:	std_logic_vector(31 downto 0);

begin

	UUTX : No_Mem_SDF	
	generic map (N_Stages => 10, Stage => (10-L), Input_Data_size => Input_Data_size)
  	port map (clk => clk, control => control(L), Din => X_in, Dout => X_out, M_in => In_Mem(15 downto 0), M_out => Out_Mem(15 downto 0));

	UUTY : No_Mem_SDF	
	generic map (N_Stages => 10, Stage => (10-L), Input_Data_size => Input_Data_size)
  	port map (clk => clk, control => control(L), Din => Y_in, Dout => Y_out, M_in => In_Mem(31 downto 16), M_out => Out_Mem(31 downto 16));

	MEM : Memory_Proposed_64
	port map(clk => clk, CE1 => '0', CE2 => '0', control1 => control(L-1 downto 0), control2 => control2(L-1 downto 0), X => In_Mem, Y => Out_Mem);
	
end X_Y_Butterfly_SDF_Memories_64_behaviour;
