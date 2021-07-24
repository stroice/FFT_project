-- Delay using registers.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;

entity DelayReg is
	generic(	
		WL: integer:=8;			-- Word Length
		BL: integer:= 1024);		-- Buffer Length
	port(
	  	clk:  in  std_logic;
	  	Din:  in  std_logic_vector(WL -1 downto 0); 
	  	Dout: out std_logic_vector(WL -1 downto 0));
end DelayReg;

architecture arch of DelayReg is

   component Delay1bit
  	   generic(BL: integer); 
  		port( 
  		  clk:  in  std_logic;
		  Din:  in  std_logic;
	     Dout: out std_logic);
	end component;

begin

	GenBuffer: for i in 0 to WL-1 generate
	   
	   RegBuffer: Delay1bit
	     generic map( 
	        BL   => BL)
	     port map(
		     clk  => clk,
			  Din  => Din(i),
			  Dout => Dout(i));
			 
	end generate;

end arch;
