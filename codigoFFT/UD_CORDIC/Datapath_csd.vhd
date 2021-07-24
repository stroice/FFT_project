library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath_csd is
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
end Datapath_csd;

architecture arch of Datapath_csd is

component buffer_1bit is
  generic(
  	tamano: integer:= 1024);   						  
  port( 
	reset: in std_logic;
	clk: in std_logic;
	entrada: in std_logic;
	salida: out std_logic);
end component;

component MicroRot_csd is
	generic(	
		WL: integer:=8;		-- Word Length
		st: integer:=4);    -- Stage
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
	  	si:    in  std_logic; -- Control signal s_i
	  	si1:   in  std_logic; -- Control signal s_{i+1}
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0));  -- Imaginary part of the output	  	
end component;

type datasignal is array(0 to n) of signed(WL -1 downto 0);
signal x,y,x_mux,y_mux: datasignal;

signal si, si1, si_reg, si1_reg: std_logic_vector(n-1 downto 0);
signal m_reg: std_logic_vector(n downto 0);

begin

process (reset, clk)
begin
    if reset = '1' then
        x(0) <= (others => '0');
        y(0) <= (others => '0');
    elsif rising_edge(clk) then
        x(0) <= xin;
        y(0) <= yin;
    end if;
end process;

xout <= x_mux(n);
yout <= y_mux(n);

-- Control signals

process(s)
begin
    for i in 0 to n-1 loop
        si(i) <= s(2*i);
        si1(i) <= s(2*i+1);
    end loop;
end process;

ctrl_buffers: for i in 0 to n-1 generate

begin

buf_si: buffer_1bit 
    generic map(
  	    tamano  => i+1) 
    port map( 
	   reset   => reset,
	   clk     => clk,
	   entrada => si(i),
	   salida  => si_reg(i));
	   
buf_si1: buffer_1bit 
    generic map(
  	    tamano  => i+1) 
    port map( 
	   reset   => reset,
	   clk     => clk,
	   entrada => si1(i),
	   salida  => si1_reg(i));

end generate;

ctrl_buffers_mux: for i in 0 to n generate
	   
buf_m: buffer_1bit 
    generic map(
  	    tamano  => i+1) 
    port map( 
	   reset   => reset,
	   clk     => clk,
	   entrada => m(i),
	   salida  => m_reg(i));	   

end generate;


-- Multiplexers used to calculate the negative rotation

negativeRot: for i in 0 to n generate

x_mux(i) <= x(i) when m_reg(i) = '0' else y(i);
y_mux(i) <= y(i) when m_reg(i) = '0' else x(i);

end generate;


-- Micro-rotation stages

RotStages: for i in 1 to n generate

MicroRot_stage: MicroRot_csd
	generic map(	
		WL    => WL,	 -- Word Length
		st    => i)    -- Stage
	port map(
	    clk   => clk,
	    reset => reset,
	  	xin   => x_mux(i-1),  -- Real part of the input
	  	yin   => y_mux(i-1),  -- Imaginary part of the input
	  	si    => si_reg(i-1), -- Control signal s_i
	  	si1   => si1_reg(i-1), -- Control signal s_{i+1}
	  	xout  => x(i),  -- Real part of the output
	  	yout  => y(i));  -- Imaginary part of the output	  	

end generate;


end arch;