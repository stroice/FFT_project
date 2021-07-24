library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_Butterfly is
end tb_Butterfly;

architecture behaviour of tb_Butterfly is

component EntryInterface
	generic(	
	  WL: 	   integer);		  -- Word Length	
	port(
	  clk:       in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out std_logic_vector(WL - 1 downto 0)
	  );
end component;

component Butterfly_proposed_Bien is

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
CONSTANT Input_Data_size : integer:= 8;

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

	UUT : Butterfly_proposed_Bien	
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
    Din <= "01111111";
    start <= '0';
--Data 1
    Din <= "00010010";
    wait for 6 ns;

--Data 2
    Din <= "00010010";
    wait for period;

--Data 3
    Din <= "00010010";
    wait for period;

--Data 4
    Din <= "11100100";
    wait for 10 ns;

--Data 5
    Din <= "00010111";
    wait for period;

--Data 6
    Din <= "00010010";
    wait for period;

--Data 7
    Din <= "00011111";
    wait for period;

--Data 8
    Din <= "00010010";
    wait for period;

--Data 9
    Din <= "11100010";
    wait for period;

--Data 10
    Din <= "11111010";
    wait for period;

--Data 11
    Din <= "11110010";
    wait for period;

--Data 12
    Din <= "00000000";
    wait for period;


--Data 13
    Din <= "11111110";
    wait for period;

--Data 14
    Din <= "11110010";
    wait for 10 ns;

--Data 15
    Din <= "00010111";
    wait for period;

--Data 16
    Din <= "00010010";
    wait for period;

--Data 17
    Din <= "00011111";
    wait for period;

--Data 18
    Din <= "00010010";
    wait for period;
    start <= '0';
    wait;
  end process;

--Expected output from time 145ns:

--Cicle of M1 -M2
	--145 -> 185 "10010010" - "10010010" = "1 0000 0000" (100)

--Cicle of M1 + Input "moved one cicle because of the input registers"

--Expected output from time 145ns:

--Cicle of M1 -M2
	--145 -> 185 "10010010" - "10010010" = "1 0000 0000" (100)

--Cicle of M1 + Input "moved one cicle because of the input registers"
	--185 -> 195 "10010010" + "10010111" = "1 0010 1001" (129)
	--195 -> 205 "10010010" + "10010010" = "1 0010 0100" (124)
	--205 -> 215 "01010010" + "10011111" = "0 1111 0001" (F1)
	--215 -> 225 "10010010" + "00010010" = "0 1010 0100" (A4)

--Cicle of M1 + Input "moved one cicle because of the input registers"
	--235 -> 245 "10010010" - "10010111" = "0 1111 1011" (129)
	--245 -> 255 "10010010" - "10010010" = "1 0000 0000" (124)
	--255 -> 265 "01010010" - "10011111" = "0 1011 0011" (F1)
	--265 -> 275 "10010010" - "00010010" = "1 1000 0000" (A4)

	
end behaviour;