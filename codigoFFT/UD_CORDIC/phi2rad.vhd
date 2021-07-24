-- Module that transforms an angle as phi in an angle in radians.
-- The calculation is angle_rad = - angle_phi*2*pi/N

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity phi2rad is
	generic(	
		b: integer:=8);	   -- Bits of phi
	port(
        angle_phi: in  signed(b-1 downto 0);  -- Rotation angle as phi in the range [-45,45)
	  	angle_rad: out signed(b-1+8 downto 0));  -- Rotation angle in radians  	
end phi2rad;

architecture arch of phi2rad is

signal x:      signed(b-1 downto 0);
signal x_m3:   signed(b-1+2 downto 0);
signal x_m192: signed(b-1+8 downto 0);
signal x_9:    signed(b-1+4 downto 0);
signal x_m201: signed(b-1+8 downto 0);

begin

x <= angle_phi;
x_m3 <= resize(x,b+2) - (x & "00");
x_m192 <= x_m3 & "000000";
x_9 <= resize(x & "000",b+4) + resize(x,b+4);
x_m201 <= x_m192 - resize(x_9,b+8);

angle_rad <= x_m201;


end arch;