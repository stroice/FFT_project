-- CSD UD CORDIC that receives the angle as phi, i.e., as fractions of the circunference. 

-- phi ranges from 0 to (2^b)-1, and is represented with b bits.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UD_CORDIC_csd_phi is
	generic(	
		WL: integer:= 16;	 -- Data word length
		b:  integer:= 10;    -- Number of bits to represent phi
		n:  integer:= 4);    -- Number of stages of the CSD UD CORDIC. n must be equal or smaller than (b+6)/2
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  unsigned(b-1 downto 0);  -- Rotation angle (in phi, from 0 to (2^b)-1)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	  	
end UD_CORDIC_csd_phi;


architecture arch of UD_CORDIC_csd_phi is

component W4rot is
	generic(	
		WL: integer:=8);	   -- Data word length
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  unsigned(1 downto 0);    -- Rotation angle ("00" = 0º, "01" = -90º, "10" = 180º, "11" = +90º)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	  	
end component;

component phi2rad is
	generic(	
		b: integer:=8);	   -- bits of phi
	port(
        angle_phi: in  signed(b-1 downto 0);  -- Rotation angle as phi in the range [-45,45)
	  	angle_rad: out signed(b-1+8 downto 0));  -- Rotation angle in radians  	
end component;

component UD_CORDIC_csd is
	generic(	
		WL: integer:=8;	   -- Data word length
		n:  integer:=4);    -- Number of stages of the CSD UD CORDIC.
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  signed(2*n-1 downto 0);  -- Rotation angle (in radians from -1.0000 to 0.11111...)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	  	
end component;

signal angle_W4:  unsigned(1 downto 0);
signal angle_rem: signed(b-3 downto 0);
signal angle_rad: signed(b-3+8 downto 0);
signal angle_rad_reg: signed(2*n-1 downto 0);

signal x_W4, y_W4: signed(WL-1 downto 0);


begin

-- We carry out the trivial rotations according to the bits b-1, b-2 and b-3 of phi, placing the remaining angle in (-45º,45º]


angle_W4(1) <= angle(b-1) xor (angle(b-2) and angle(b-3));
angle_W4(0) <= angle(b-2) xor angle(b-3);

TrivRot: W4rot 
	generic map(	
		WL => WL)	        -- Data word length
	port map(
	    clk   => clk,
	    reset => reset,
	    xin   => xin,       -- Real part of the input
	  	yin   => yin,       -- Imaginary part of the input
        angle => angle_W4,  -- Rotation angle ("00" = 0º, "01" = -90º, "10" = 180º, "11" = +90º)
	  	xout  => x_W4,      -- Real part of the output
	  	yout  => y_W4);     -- Imaginary part of the output	  	


-- To rotate by the remaining angle in (-45º,45º], we transform it from phi to radians

angle_rem <= signed(angle(b-3 downto 0));

phiTOrad: phi2rad 
	generic map(	
		b  => b-2)	 
	port map(
        angle_phi => angle_rem,   -- Remaining angle as phi in the range [-45,45)
	  	angle_rad => angle_rad);  -- Rotation angle in radians  	


process(reset, clk)
begin
    if reset = '1' then
        angle_rad_reg <= (others => '0');
    elsif rising_edge(clk) then
        angle_rad_reg <= angle_rad(b-3+8 downto b-3+8-2*n+1);
    end if;
end process;


CORDIC: UD_CORDIC_csd
	generic map(	
		WL => WL,	-- Data word length
		n  => n)    -- Number of stages of the CSD UD CORDIC.
	port map(
	    clk   => clk,
	    reset => reset,
	  	xin   => x_W4,  -- Real part of the input
	  	yin   => y_W4,  -- Imaginary part of the input
        angle => angle_rad_reg,  -- Rotation angle (in radians from -1.0000 to 0.11111...)
	  	xout  => xout,  -- Real part of the output
	  	yout  => yout); -- Imaginary part of the output	 


end arch;