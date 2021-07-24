-- CSD UD CORDIC that receives the angle in radians, in the range from -1.0000... to 0.11111... (as a signed with 2*n bits)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UD_CORDIC_csd is
	generic(	
		WL: integer:=8;	   -- Data word length
		n: integer:=4);    -- Number of stages of the CSD UD CORDIC.
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  signed(2*n-1 downto 0);  -- Rotation angle (in radians from -1.0000... to 0.11111...)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	  	
end UD_CORDIC_csd;


architecture arch of UD_CORDIC_csd is

component bin2csd is
	generic(	
		WL: integer:=8);		-- Word Length
	port(
	  	b:    in  signed(WL -1 downto 0);  -- Input binary number in 2s complement
	  	CSDs: out std_logic_vector(WL -1 downto 0);  -- Sign of the CSD bits
	  	CSDm: out std_logic_vector(WL -1 downto 0)); -- Magnitude of the CSD bits
end component;

component ctrl_csd is
	generic(	
		WL: integer:=8);		-- Word Length
	port(
	  	CSDs: in std_logic_vector(WL -1 downto 0);  -- Sign of the CSD bits
	  	CSDm: in std_logic_vector(WL -1 downto 0);  -- Magnitude of the CSD bits
	  	m: out std_logic_vector(WL/2 downto 0);
	  	s: out std_logic_vector(WL-1 downto 0));
end component;

component Datapath_csd is
	generic(	
		WL: integer:=8;	   -- Data word length
		n: integer:=4);    -- Number of stages of the CSD UD CORDIC.
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
	  	m:     in  std_logic_vector(n downto 0);
	  	s:     in  std_logic_vector(2*n-1 downto 0);
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0));  -- Imaginary part of the output	  	
end component;

signal CSDs, CSDm: std_logic_vector(2*n -1 downto 0);
signal m: std_logic_vector(n downto 0);
signal s: std_logic_vector(2*n-1 downto 0);

begin

CSD: bin2csd 
	generic map(	
		WL   => 2*n)	-- Word Length
	port map(
	  	b    => angle,  -- Input binary number in 2s complement
	  	CSDs => CSDs,   -- Sign of the CSD bits
	  	CSDm => CSDm);  -- Magnitude of the CSD bits


CTRL: ctrl_csd 
	generic map(	
		WL   => 2*n)	-- Word Length
	port map(
	  	CSDs => CSDs,   -- Sign of the CSD bits
	  	CSDm => CSDm,   -- Magnitude of the CSD bits
	  	m    => m,
	  	s    => s);


Datapath: Datapath_csd 
	generic map(	
		WL    => WL,	 -- Data word length
		n     => n)    -- Number of stages of the CSD UD CORDIC.
	port map(
	    clk   => clk,
	    reset => reset,
	  	xin   => xin,  -- Real part of the input
	  	yin   => yin,  -- Imaginary part of the input
	  	m     => m,
	  	s     => s,
	  	xout  => xout, -- Real part of the output
	  	yout  => yout);  -- Imaginary part of the output	  	


end arch;