-- 1-bit buffer.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Delay1bit is
  generic(
  	BL:   integer:= 1024); -- Buffer Length
  port( 
	clk:  in std_logic;
	Din:  in std_logic;
	Dout: out std_logic);
end Delay1bit;

architecture Delay1bit_arch of Delay1bit is
	
	signal b: std_logic_vector(BL-1 downto 0);

begin

   NoDelay: if BL = 0 generate   
         Dout <= Din;
   end generate;
   
   RegBuffer: if BL > 0 generate
	  
      process(clk)
         begin
         if rising_edge(clk) then
            b(0) <= Din;
            if (BL > 1) then
               for i in 1 to BL -1 loop
                  b(i) <= b(i-1);
               end loop;
            end if;
         
         end if;
      end process;
   
      Dout <= b(BL -1);

      end generate;
      
end Delay1bit_arch;
