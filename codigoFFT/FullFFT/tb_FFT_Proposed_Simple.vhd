library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_FFT_Proposed_Simple is
end tb_FFT_Proposed_Simple;

architecture behaviour of tb_FFT_Proposed_Simple is

component FFT_Proposed
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		rst: 	 		 in  std_logic;
		clk: 	 		 in  std_logic;
	  	X_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		Y_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	X_out: 		 out std_logic_vector(Input_Data_size -1 downto 0);
		Y_out: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);	 
end component;

CONSTANT Input_Data_size : integer:= 16;
CONSTANT period : time:= 10 ns;
 
SIGNAL rst, clk : STD_LOGIC;

SIGNAL X_in: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL Y_in: 	std_logic_vector(Input_Data_size -1 downto 0); 
SIGNAL X_out:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL Y_out:	std_logic_vector(Input_Data_size -1 downto 0);
begin

	UUT : FFT_Proposed
	generic map (Input_Data_size => Input_Data_size)
  	port map (rst => rst, clk => clk, X_in => X_in, Y_in => Y_in, X_out => X_out, Y_out => Y_out);


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