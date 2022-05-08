-- W4 rotator (trivial rotator).
-- the input angle is "00" = 0º, "01" = -90º, "10" = 180º, "11" = +90º. 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity W4rot is
	generic(	
		WL: integer:=8);	   -- Data word length
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  unsigned(1 downto 0);  -- Rotation angle ("00" = 0º, "01" = -90º, "10" = 180º, "11" = +90º)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	  	
end W4rot;


architecture arch of W4rot is

signal notx, noty : signed(WL-1 downto 0);
signal anglexor: std_logic; 
signal x1, y1, x2, y2: signed(WL-1 downto 0);

begin

notx <= not(xin);
noty <= not(yin);

anglexor <= angle(1) xor angle(0);
x1 <= notx+1 when anglexor = '1' else xin; 
y1 <= noty+1 when angle(1) = '1' else yin;

x2 <= x1 when angle(0) = '0' else y1;
y2 <= y1 when angle(0) = '0' else x1;

-- We register the output

process(reset, clk)
begin
    if reset = '1' then
        xout <= (others => '0');
        yout <= (others => '0');
    elsif rising_edge(clk) then
        xout <= x2;
        yout <= y2;
    end if;
end process;

end arch;