library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;


entity Butterfly_proposed_adder is
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		rst:		 in  std_logic;
	  	clk:  		 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end Butterfly_proposed_adder;

architecture Butterfly_proposed_adder_arch of Butterfly_proposed_adder is

   component DelayMem 
	generic(	
	  WL: 	   integer;		 -- Word Length	
	  BL_exp:  integer);		  -- Buffer Length exponent
	port(
	  rst:     in  std_logic;
	  clk:     in  std_logic;
	  WE:	   in  std_logic;
	  counter: in  std_logic_vector(BL_exp -1 downto 0);
	  Din:     in  std_logic_vector(WL -1 downto 0); 
	  Dout:    out std_logic_vector(WL -1 downto 0));
end component;

component Adder_carry
  generic (g_WIDTH : natural);
  port (
    i_add_term1  : in std_logic_vector(g_WIDTH-1 downto 0);
    i_add_term2  : in std_logic_vector(g_WIDTH-1 downto 0);
    Add_Subst	 : in std_logic;
    o_result   : out std_logic_vector(g_WIDTH downto 0)
    );
end component;

SIGNAL M: 	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL B:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL A:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL AB_aux:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S1:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL S2:	std_logic_vector(Input_Data_size -1 downto 0);
SIGNAL out_sig:	std_logic_vector(Input_Data_size downto 0);
SIGNAL WE1_R:	std_logic;
SIGNAL Carry_controler:	std_logic;

begin


	WE1_R <= not(control(N_Stages - Stage));  --Selection of WE of the first memory and selection of substraction / addition in the ripple carry adder

	Mem1:DelayMem generic map(WL => Input_Data_size, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => control(N_Stages - Stage -1 downto 0), WE => WE1_R,
			  	Din => Din, Dout => S1);

	Mem2:DelayMem generic map(WL => Input_Data_size, BL_exp => (N_Stages - Stage)) port map(rst => rst, clk => clk, 
			  	counter => control(N_Stages - Stage -1 downto 0), WE => control(N_Stages - Stage),
			  	Din => Din, Dout => M);
	AB_aux <= (others => control(N_Stages - Stage));
	A  <= (Din AND AB_aux);
	B  <= (M NOR  AB_aux);
	S2 <= (A OR B);

	ADD:Adder_carry  generic map(g_WIDTH => Input_Data_size)
			 port map(i_add_term1 => S1, i_add_term2 => S2, Add_Subst => WE1_R, o_result => out_sig);
 
	Carry_controler <= S1(Input_Data_size -1) XOR S2(Input_Data_size -1);
	
	with Carry_controler select
	     Dout<= std_logic_vector(resize(signed(out_sig(Input_Data_size-1 downto 1)), Input_Data_size))		 when '1',
					 std_logic_vector(out_sig(Input_Data_size downto 1)) when others;

end Butterfly_proposed_adder_arch;