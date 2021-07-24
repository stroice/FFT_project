library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;


entity EntryInterface is
	generic(	
	  WL: 	   integer:= 8);		  -- Word Length	
	port(
	  clk:     in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out std_logic_vector(WL - 1 downto 0));
end EntryInterface;

architecture arch of EntryInterface is

SIGNAL rdData: std_logic_vector(WL - 1 downto 0); 

begin 

      RW: process(clk)
         begin 
            if rising_edge(clk) then
		rdData <= Input;        
            end if;
	
      end process;   
           Output <= rdData;
   
end arch;