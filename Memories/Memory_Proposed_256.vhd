
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity Memory_Proposed_256 is
	
	port(
		clk:  		 in  std_logic;
		CE1:  		 in  std_logic;
		CE2:  		 in  std_logic;
		control1:  in  std_logic_vector(7 downto 0);
		control2:  in  std_logic_vector(7 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
		);
		
end Memory_Proposed_256;

architecture Memory_Proposed_256_behaviour of Memory_Proposed_256 is

Constant Input_Data_size: 	   integer:= 16;
Constant L: 	   integer:= 8;

component TS5N40LPHSA128X32M2S is
		port(
			PD: in std_logic;
			CLK: in  std_logic;
			CEB: in  std_logic;
			WEB: in  std_logic;
			RTSEL: in  std_logic;
			TURBO: in  std_logic;			
            D: in std_logic_vector(Input_Data_size*2 -1 downto 0);
			A: in std_logic_vector(L -2 downto 0);
			BWEB: in std_logic_vector(Input_Data_size*2 -1 downto 0);
			TSEL: in std_logic_vector(1 downto 0);
            Q: out std_logic_vector(Input_Data_size*2 -1 downto 0)
			
			);
						
						
end component;

SIGNAL Out_Mem_1:	std_logic_vector(Input_Data_size*2 -1 downto 0);
SIGNAL Out_Mem_2:	std_logic_vector(Input_Data_size*2 -1 downto 0);

SIGNAL WE_1:	std_logic;
SIGNAL WE_2:	std_logic;

begin

	WE_1 <= CE1 or not(control1(0));
	WE_2 <= CE2 or control1(0);

	MEM1 : TS5N40LPHSA128X32M2S 	port map ( PD => '0', CLK => clk, CEB => '0', WEB => WE_1, RTSEL => '0', TURBO => '1', A => control1(L-1 downto 1), D => X, BWEB  => (others => '0'), TSEL => "01", Q => Out_Mem_1);
			
	MEM2 : TS5N40LPHSA128X32M2S 	port map ( PD => '0', CLK => clk, CEB => '0', WEB => WE_2, RTSEL => '0', TURBO => '1', A => control2(L-1 downto 1), D => X, BWEB  => (others => '0'), TSEL => "01", Q => Out_Mem_2);
			
	
	with control1(0) select	
	 	Y <= 	Out_Mem_1 when '1',
					Out_Mem_2 when others;
	
end Memory_Proposed_256_behaviour;
