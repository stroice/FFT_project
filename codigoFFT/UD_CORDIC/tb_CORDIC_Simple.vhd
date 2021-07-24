

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_UD_CORDIC_simple is
end tb_UD_CORDIC_simple;

architecture behaviour of tb_UD_CORDIC_simple is

component UD_CORDIC_csd_phi
	generic(	
		WL: integer:= 8;	 -- Data word length
		b:  integer:= 10;    -- Number of bits to represent phi
		n:  integer:= 4);    -- Number of stages of the CSD UD CORDIC. n must be equal or smaller than (b+6)/2
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  unsigned(b-1 downto 0);  -- Rotation angle (in phi, from 0 to (2^b)-1)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	 
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
SIGNAL account 	: std_logic_vector(9 downto 0);

SIGNAL account_conv	: unsigned(9 downto 0);

SIGNAL X_in: 	signed(Input_Data_size -1 downto 0);
SIGNAL Y_in: 	signed(Input_Data_size -1 downto 0); 
SIGNAL X_out:	signed(Input_Data_size -1 downto 0);
SIGNAL Y_out:	signed(Input_Data_size -1 downto 0);

SIGNAL Rot_control5_0:	std_logic_vector(10 downto 0);
SIGNAL Rot_control5_1:	std_logic_vector(4 downto 0);
SIGNAL Rot_control5:	unsigned(9 downto 0);

begin

	UUT1 : COUNTER	
	generic map (WIDTH => 10)
  	port map (account => account, start => '0', rst => rst, clk => clk);

--Rotator 5 control:
Rot_control5_0 <= std_logic_vector(resize(unsigned(account), 11)) ;
Rot_control5_1 <= (Rot_control5_0(5) & Rot_control5_0(6) & Rot_control5_0(7) & Rot_control5_0(8) & Rot_control5_0(9));
Rot_control5 <= (unsigned(Rot_control5_1) *  unsigned(Rot_control5_0(4 downto 0)));

	UUT : UD_CORDIC_csd_phi
	generic map (WL => Input_Data_size, b => 10,	n=>	5)
  	port map (clk => clk, reset => rst, angle => Rot_control5, xin => X_in, yin => Y_in, xout => X_out, yout =>  Y_out);


  Rst_process : process
  begin
    rst <= '1';
    wait for 1 ns;
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

    X_in <= "0111111111111111";	--
    Y_in <= "0000000000000000";	--

    wait;
  end process;
end behaviour;