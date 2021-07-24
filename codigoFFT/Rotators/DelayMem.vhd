--Delay implemented with memories.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.Components.ALL;


entity DelayMem is
	generic(	
	  WL: 	   integer:= 8;			  -- Word Length	
	  BL_exp:  integer:= 6);		  -- Buffer Length exponent
	port(
	  rst:     in  std_logic;
	  clk:     in  std_logic;
	  WE:	   in  std_logic;
	  counter: in  std_logic_vector(BL_exp - 1 downto 0);
	  Din:     in  std_logic_vector(WL - 1 downto 0); 
	  Dout:    out std_logic_vector(WL - 1 downto 0));
end DelayMem;


architecture arch of DelayMem is
 
      type memory is array ((2**BL_exp) -1 downto 0) of std_logic_vector(WL -1 downto 0);
      signal mem: memory;      
      signal rdData: std_logic_vector(WL -1 downto 0);

begin 

      RW: process(clk)
         begin 
            if rising_edge(clk) then    
		if WE = '1' then
			mem(to_integer(unsigned(counter))) <= Din;
		end if;
            end if;
      end process;
          
      Dout <= mem(to_integer(unsigned(counter)));               
   

end arch;
