library ieee;
use ieee.std_logic_1164.all;
 
entity Adder_carry is
  generic (
    g_WIDTH : natural := 24
    );
  port (
    i_add_term1  : in std_logic_vector(g_WIDTH-1 downto 0);
    i_add_term2  : in std_logic_vector(g_WIDTH-1 downto 0);
    Add_Subst	 : in std_logic;
    o_result   : out std_logic_vector(g_WIDTH downto 0)
    );
end Adder_carry;
 
 
architecture rtl of Adder_carry is
 
  component Full_adder is
    port (
      i_bit1  : in  std_logic;
      i_bit2  : in  std_logic;
      i_carry : in  std_logic;
      o_sum   : out std_logic;
      o_carry : out std_logic);
  end component Full_adder;
 
  signal w_CARRY : std_logic_vector(g_WIDTH downto 0);
  signal w_SUM   : std_logic_vector(g_WIDTH-1 downto 0);
 
   
begin
 
  w_CARRY(0) <= Add_Subst;                    -- Selection of substraction or addition
   

  SET_WIDTH : for ii in 0 to g_WIDTH-1 generate
    i_FULL_ADDER_INST : Full_adder
      port map (
        i_bit1  => i_add_term1(ii),
        i_bit2  => i_add_term2(ii),
        i_carry => w_CARRY(ii),
        o_sum   => w_SUM(ii),
        o_carry => w_CARRY(ii+1)
        );
  end generate SET_WIDTH;
 
  o_result <= w_CARRY(g_WIDTH) & w_SUM;  -- VHDL Concatenation
   
end rtl;
