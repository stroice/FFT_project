
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_Butterfly_overflow is
end tb_Butterfly_overflow;

architecture behaviour of tb_Butterfly_overflow is

component EntryInterface
	generic(	
	  WL: 	   integer);		  -- Word Length	
	port(
	  clk:       in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out std_logic_vector(WL - 1 downto 0)
	  );
end component;

component Butterfly_SDF_memories is

	generic(	 
		N_Stages: 		integer;	-- Butterfly Stage of the butterfly
		Stage: 			integer;	-- Butterfly Stage of the butterfly
		Input_Data_size:	integer		-- Size of the signal data to be processed
		);			
	port(
		rst:		 in  std_logic;
	  	clk:  		 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end component;

component COUNTER
  generic (
    WIDTH     : integer
    );
  port (
    account   : out STD_LOGIC_VECTOR (WIDTH-1  downto 0);
    start    : in  STD_LOGIC;
    rst      : in  STD_LOGIC;
    clk      : in  STD_LOGIC
    );
end component;


CONSTANT N_Stages 	 : integer:= 3;
CONSTANT Stage	  	 : integer:= 1;
CONSTANT Input_Data_size : integer:= 16;

CONSTANT period : time:= 10 ns;
 
SIGNAL rst, clk, start 	: STD_LOGIC;
SIGNAL control 		: std_logic_vector(N_Stages - Stage downto 0);
SIGNAL Din  		: std_logic_vector(Input_Data_size - 1 downto 0);
SIGNAL rdData  		: std_logic_vector(Input_Data_size - 1 downto 0);
SIGNAL Dout 		: std_logic_vector(Input_Data_size -1 downto 0);

begin

	UUT2 : EntryInterface	
	generic map (WL => Input_Data_size)
  	port map (clk => clk, Input => Din, Output => rdData);

	UUT1 : COUNTER	
	generic map (WIDTH => N_Stages)
  	port map (account => control, start => start, rst => rst, clk => clk);

	UUT : Butterfly_SDF_memories	
	generic map (N_Stages => N_Stages, Stage => Stage, Input_Data_size => Input_Data_size)
  	port map (rst => rst, clk => clk, control => control, Din => rdData, Dout => Dout);


  Rst_process : process
  begin
    rst <= '1';
    wait for 50 ns;
    rst <= '0';
    wait;
  end process;

  Clk_process : process
  begin
    clk <= '0';
    wait for period/2;
    clk <= '1';
    wait for period/2;
  end process;
  

  
  Data_process : process
  begin
    Din <= "0111111111111111";
    start <= '0';
    wait for 144 ns;
    start <= '1';
    wait for (period/2 -1 ns);
    start <= '0';
    wait;
  end process;

end behaviour;