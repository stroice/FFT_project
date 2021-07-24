

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_Rotator_DirectMult_W32 is
end tb_Rotator_DirectMult_W32;

architecture behaviour of tb_Rotator_DirectMult_W32 is

component Rotator_DirectMult_W32 
	generic(	 
		constant Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		Term1_bits: 	 in  std_logic_vector(1 downto 0);   -- b8, b9 order of the control bets
		Term2_bits: 	 in  std_logic_vector(2 downto 0);   -- b5, b6, b7 order of the control bets
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +10 downto 0);
		Y_out: 		 out signed(Input_Data_size +10 downto 0)
		);
end component;

component COUNTER
  generic (
    WIDTH    : integer
    );
  port (
    account  : out STD_LOGIC_VECTOR (WIDTH-1  downto 0);
    start    : in  STD_LOGIC;
    rst      : in  STD_LOGIC;
    clk      : in  STD_LOGIC
    );
end component;


CONSTANT Input_Data_size : integer:= 16;
CONSTANT period : time:= 10 ns;
 
SIGNAL rst, clk : STD_LOGIC;
SIGNAL account 	: std_logic_vector(4 downto 0);

SIGNAL X_in: 	signed(Input_Data_size -1 downto 0);
SIGNAL Y_in: 	signed(Input_Data_size -1 downto 0); 
SIGNAL X_out:	signed(Input_Data_size +10 downto 0);
SIGNAL Y_out:	signed(Input_Data_size +10 downto 0);

begin

	UUT1 : COUNTER	
	generic map (WIDTH => 5)
  	port map (account => account, start => '0', rst => rst, clk => clk);

	UUT : Rotator_DirectMult_W32
  	port map (Term1_bits => account(4 downto 3), Term2_bits => account(2 downto 0),X_in => X_in, Y_in => Y_in, X_out => X_out, Y_out => Y_out);


  Rst_process : process
  begin
    rst <= '1';
    wait for 10 ns;
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

    X_in <= X"0040";
    Y_in <= X"0040";
    wait;
  end process;
end behaviour;