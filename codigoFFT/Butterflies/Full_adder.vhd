library ieee;
use ieee.std_logic_1164.all;


entity Full_adder is
    port( -- Input of the full-adder
      i_bit1  : in  std_logic;
      i_bit2  : in  std_logic;
      i_carry : in  std_logic;
      o_sum   : out std_logic;
      o_carry : out std_logic );
      
end Full_adder;
architecture data_flow of Full_adder is

 begin

  o_sum   <= ((i_bit1 xor i_bit2) xor i_carry);
  
  o_carry <= ((i_bit1 and i_bit2) or (i_bit2 and i_carry) or (i_carry and i_bit1));

  end data_flow;
