
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity X_Y_Butterfly_Memories_Proposed_64 is
	
	port(
	  	clk:  		 	 in  std_logic;
		control: in  std_logic_vector(6 downto 0);
		control2: in  std_logic_vector(6 downto 0);
	  	X_in:  		 in  std_logic_vector(15 downto 0);
		Y_in:  		 in  std_logic_vector(15 downto 0); 
	  	X_out: 		 out std_logic_vector(15 downto 0);
		Y_out: 		 out std_logic_vector(15 downto 0)
		);
		
end X_Y_Butterfly_Memories_Proposed_64;

architecture X_Y_Butterfly_Memories_Proposed_64_behaviour of X_Y_Butterfly_Memories_Proposed_64 is

Constant Input_Data_size: 	   integer:= 16;
Constant L: 	   integer:= 6;
Constant Stage: integer:= (10-L);
Constant N_Stages: integer:= 10;


component No_Mem_proposed
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 in  std_logic;
		control: 	 in  std_logic_vector(6 downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
		M_in1:  		 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out1: 		 in std_logic_vector(Input_Data_size -1 downto 0);
		M_in2:  		 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out2: 		 in std_logic_vector(Input_Data_size -1 downto 0);
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

SIGNAL In_Mem1:	std_logic_vector(31 downto 0);
SIGNAL In_Mem2:	std_logic_vector(31 downto 0);
SIGNAL Out_Mem1:	std_logic_vector(31 downto 0);
SIGNAL Out_Mem2:	std_logic_vector(31 downto 0);

SIGNAL MEM1_CE1:	std_logic;
SIGNAL MEM1_CE2:	std_logic;
SIGNAL MEM2_CE1:	std_logic;
SIGNAL MEM2_CE2:	std_logic;

SIGNAL control_not:	std_logic;


begin

	--MEM1_CE1 <= '0';
	--MEM1_CE2 <= '0';

	--MEM2_CE1 <= '0';
	--MEM2_CE2 <= '0';

	control_not <= not(control(L));

	MEM1_CE1 <= control2(0) NOR control(L);
	MEM1_CE2 <= control(0) NOR control(L);

	MEM2_CE1 <= control2(0) NOR control_not;
	MEM2_CE2 <= control(0) NOR control_not;

	UUTX : No_Mem_proposed	
	generic map (N_Stages => 10, Stage => (10-L), Input_Data_size => Input_Data_size)
  	port map (clk => clk, M_in1 =>  In_Mem1(15 downto 0), M_in2 =>  In_Mem2(15 downto 0), M_out1 => Out_Mem1(15 downto 0), M_out2 => Out_Mem2(15 downto 0), 
					control => control, Din => X_in, Dout => X_out);

	UUTY : No_Mem_proposed	
	generic map (N_Stages => 10, Stage => (10-L), Input_Data_size => Input_Data_size)
  	port map (clk => clk, M_in1 =>  In_Mem1(31 downto 16), M_in2 =>  In_Mem2(31 downto 16), M_out1 => Out_Mem1(31 downto 16), M_out2 => Out_Mem2(31 downto 16), 
					control => control, Din => Y_in, Dout => Y_out);

	MEM1 : Memory_Proposed_64
	port map(clk => clk, CE1 => MEM1_CE1, CE2 => MEM1_CE2, control1 => control(L-1 downto 0), control2 => control2(L-1 downto 0), X => In_Mem1, Y => Out_Mem1);
	
	MEM2 : Memory_Proposed_64
	port map(clk => clk, CE1 => MEM2_CE1, CE2 => MEM2_CE2, control1 => control(L-1 downto 0), control2 => control2(L-1 downto 0), X => In_Mem2, Y => Out_Mem2);
	
end X_Y_Butterfly_Memories_Proposed_64_behaviour;
