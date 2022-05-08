library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin2csd is
	generic(	
		WL: integer:=8);		-- Word Length
	port(
	  	b:    in  signed(WL -1 downto 0);  -- Input binary number in 2s complement
	  	CSDs: out std_logic_vector(WL -1 downto 0);  -- Sign of the CSD bits
	  	CSDm: out std_logic_vector(WL -1 downto 0)); -- Magnitude of the CSD bits
end bin2csd;

architecture arch of bin2csd is

component bin2csd_stage
	port(
	  	bim1: in  std_logic;  -- b_{i-1}
	  	bi:   in  std_logic;  -- b_i
	  	bi1:  in  std_logic;  -- b_{i+1}
	  	pi:   in  std_logic;  -- p_i
	  	xis:  out std_logic;  -- sign of the CSD bit
	  	xim:  out std_logic;  -- magnitude of the CSD bit
	  	pi1:  out std_logic);  -- p_{i+1}
end component;

signal p:  std_logic_vector(WL-1 downto 1);
signal xs: std_logic_vector(WL-1 downto 0);
signal xm: std_logic_vector(WL-1 downto 0);

begin

-- Stage 0:

p(1) <= b(0);
xm(0) <= b(0);
xs(0) <= b(0) and b(1);

-- Intermediate stages:

stages: for i in 1 to WL-2 generate

    stage: bin2csd_stage
        port map(
            bim1 => b(i-1),  -- b_{i-1}
            bi   => b(i),  -- b_i
            bi1  => b(i+1),  -- b_{i+1}
            pi   => p(i),  -- p_i
            xis  => xs(i),  -- sign of the CSD bit
            xim  => xm(i), -- magnitude of the CSD bit
            pi1  => p(i+1));  -- p_{i+1}

end generate;

-- Last stage:

Last_stage: bin2csd_stage
    port map(
        bim1 => b(Wl-2),  -- b_{i-1}
        bi   => b(WL-1),  -- b_i
        bi1  => b(WL-1),  -- b_{i+1} = b_{i} (due to sign extension)
        pi   => p(WL-1),  -- p_i
        xis  => xs(WL-1), -- sign of the CSD bit
        xim  => xm(WL-1), -- magnitude of the CSD bit
        pi1  => open);  -- p_{i+1}
                
CSDs <= xs;
CSDm <= xm;

end arch;


-- Stage of the bin2csd module:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin2csd_stage is
	port(
	  	--clk:  in  std_logic;
	  	bim1: in  std_logic;  -- b_{i-1}
	  	bi:   in  std_logic;  -- b_i
	  	bi1:  in  std_logic;  -- b_{i+1}
	  	pi:   in  std_logic;  -- p_i
	  	xis:  out std_logic;  -- sign of the CSD bit
	  	xim:  out std_logic;  -- magnitude of the CSD bit
	  	pi1:  out std_logic);  -- p_{i+1}
end bin2csd_stage;

architecture arch of bin2csd_stage is

signal a: std_logic;

begin

a <= pi nor (bi xnor bim1); 
pi1 <= a;
xim <= a;
xis <= bi1 and a;

end arch;