

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_Rotator_W32 is
end tb_Rotator_W32;

architecture behaviour of tb_Rotator_W32 is

component Rotator_W32
	generic(	 
		Input_Data_size:	integer		-- Size of the signal data to be processed
		);	
  	port (		
		clk: 	 	 in  std_logic;
		control: 	 in  std_logic_vector(4 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +16 downto 0);
		Y_out: 		 out signed(Input_Data_size +16 downto 0)
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

component Control_Rotator_W32
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	account: 		 in std_logic_vector(4 downto 0);
		control: 		 out std_logic_vector(4 downto 0)
		);
end component;


CONSTANT Input_Data_size : integer:= 8;
CONSTANT period : time:= 10 ns;
 
SIGNAL rst, clk : STD_LOGIC;
SIGNAL account 	: std_logic_vector(4 downto 0);

SIGNAL account_conv	: std_logic_vector(4 downto 0);

SIGNAL X_in: 	signed(Input_Data_size -1 downto 0);
SIGNAL Y_in: 	signed(Input_Data_size -1 downto 0); 
SIGNAL X_out:	signed(Input_Data_size +16 downto 0);
SIGNAL Y_out:	signed(Input_Data_size +16 downto 0);
SIGNAL angle: integer;
begin

	UUT1 : COUNTER	
	generic map (WIDTH => 5)
  	port map (account => account, start => '0', rst => rst, clk => clk);

	UUT2 : Control_Rotator_W32	
	generic map (Input_Data_size => Input_Data_size)
  	port map (account => account, control => account_conv );

	UUT : Rotator_W32
	generic map (Input_Data_size => Input_Data_size)
  	port map (clk => clk, control => account_conv, X_in => X_in, Y_in => Y_in, X_out => X_out, Y_out => Y_out);


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

    X_in <= "00001010";	--
    Y_in <= "00110001";	--

    wait;
  end process;
end behaviour;