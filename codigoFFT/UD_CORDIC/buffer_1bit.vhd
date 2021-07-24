-- buffer de un solo bit con tamano (profundidad del buffer) variable 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity buffer_1bit is
  generic(
  	tamano: integer:= 1024); -- indica el numero de posiciciones del buffer, o lo que 
  						  -- es lo mismo, el numero de ciclos que retarda.
  port( 
	reset: in std_logic;
	clk: in std_logic;
	entrada: in std_logic;
	salida: out std_logic);
end buffer_1bit;

architecture escalable of buffer_1bit is
	
signal buf: std_logic_vector(tamano-1 downto 0);

begin
	  
	--process(reset, clk)
process(clk)
begin
	if reset = '1' then
	   buf <= (others => '0');
	elsif rising_edge(clk) then
	   buf(0) <= entrada;
	   if (tamano > 1) then
	       for i in 1 to tamano -1 loop
		      buf(i) <= buf(i-1);
		   end loop;
	   end if;
    end if;   
	
end process;

salida <= buf(tamano -1);

end escalable;
