library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity tb_L_Memory is
end tb_L_Memory;

architecture tb_L_Memory_behaviour of tb_L_Memory is

component Memory_Proposed_64
	port(
		rst:  		 in  std_logic;
	  	clk:  		 in  std_logic;
		control1:  in  std_logic_vector(5 downto 0);
		control2:  in  std_logic_vector(5 downto 0);
	  	X:  		 in  std_logic_vector(31 downto 0);
		Y:  		 out  std_logic_vector(31 downto 0)
		);
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

component DelayReg 

	generic(	
		WL: integer:=8;			-- Word Length
		BL: integer:= 1024);		-- Buffer Length
	port(
	  	clk:  in  std_logic;
	  	Din:  in  std_logic_vector(WL -1 downto 0); 
	  	Dout: out std_logic_vector(WL -1 downto 0));
end component;

CONSTANT L 	 : integer:= 6;
CONSTANT Input_Data_size : integer:= 16;

CONSTANT period : time:= 10 ns;
CONSTANT desfase : time:= 0.5 ns;
 
SIGNAL rst, clk, clk_fake, start 	: STD_LOGIC;
SIGNAL control1 		: std_logic_vector(L - 1 downto 0);
SIGNAL control2 		: std_logic_vector(L - 1 downto 0);
SIGNAL Pipeline 		: std_logic_vector(L - 1 downto 0);
SIGNAL Din 		: std_logic_vector(Input_Data_size*2 -1 downto 0);
SIGNAL Dout 		: std_logic_vector(Input_Data_size*2 -1 downto 0);
SIGNAL Dout_comprobation 		: std_logic_vector(Input_Data_size*2 -1 downto 0);

begin

	UUT1 : COUNTER	
	generic map (WIDTH => L)
  	port map (account => control1, start => start, rst => rst, clk => clk_fake);

	UUT : Memory_Proposed_64	
	generic map (L => L, Input_Data_size => Input_Data_size)
  	port map (clk => clk, rst => rst, control1 => control1, control2 => control2, X =>Din, Y => Dout);

	Comprobation1:DelayReg generic map(WL => Input_Data_size*2, BL => (2**L)) port map(clk => clk, Din => Din, Dout => Dout_comprobation);


	Pip: process(clk_fake)
	begin

	if rising_edge(clk_fake) then
	
		Pipeline <= control1; 
		if rst = '1' then
		Din <= (others => '0');
		
		else
		Din <= std_logic_vector(unsigned(unsigned(Din) + 1));
		end if;
	 end if;
	
      end process;   
        
	control2 <= Pipeline;
	
	

  Rst_process : process
  begin
    rst <= '1';
	
    wait for 50 ns;
    rst <= '0';
    wait;
  end process;

  Clk_process : process
  begin
    clk_fake <= '0';
	
	wait for desfase ;
	clk <= '0';
	
    wait for period/2 -desfase;
	clk_fake <= '1';
	
	wait for desfase;
	clk <= '1';
	
    wait for period/2 -desfase;
  end process;
 
  
	
end tb_L_Memory_behaviour;