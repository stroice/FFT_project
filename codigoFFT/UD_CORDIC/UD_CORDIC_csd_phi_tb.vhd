
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.all;

library STD;
use STD.TEXTIO.all;


entity UD_CORDIC_csd_phi_tb is
	generic(	
		WL: integer:= 16;	 -- Data word length
		b:  integer:= 10;    -- Number of bits to represent phi
		n:  integer:= 4);    -- Number of stages of the CSD UD CORDIC. n must be equal or smaller than (b+6)/2 	
end UD_CORDIC_csd_phi_tb;

architecture arch of UD_CORDIC_csd_phi_tb is

component UD_CORDIC_csd_phi is
	generic(	
		WL: integer:= 8;	 -- Data word length
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
end component;

signal clk: std_logic;
signal reset: std_logic;
constant clk_period: time := 10 ns;

signal xin, yin, xin_reg, yin_reg, xout, yout: signed(WL-1 downto 0);
signal angle, angle_reg: unsigned(b-1 downto 0);


-- Text files
   
file infile:  TEXT is in  "E:\Sync\Work\Papers-Ideas\UD_CORDIC\Matlab\DataIn.dat";
file outfile: TEXT is out "E:\Sync\Work\Papers-Ideas\UD_CORDIC\Matlab\DataOut.dat";
      
-- Control signals for the simulation

signal simulate: std_logic;
signal start:    std_logic;
constant latency: integer:= n+3;                          -- ADJUST  --

begin

DUT: UD_CORDIC_csd_phi
	generic map(	
		WL     => WL,    -- Data word length
		b      => b,     -- Number of bits to represent phi
		n      => n)     -- Number of stages of the CSD UD CORDIC. n must be equal or smaller than (b+6)/2
	port map(
	    clk    => clk,
	    reset  => reset,
	  	xin    => xin_reg,   -- Real part of the input
	  	yin    => yin_reg,   -- Imaginary part of the input
        angle  => angle_reg, -- Rotation angle (in phi, from 0 to (2^b)-1)
	  	xout   => xout,  -- Real part of the output
	  	yout   => yout); -- Imaginary part of the output	  	

reset <= '0', '1' after 20 ns, '0' after 30 ns;

process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- Register the inputs

process(reset, clk)
begin
    if reset = '1' then
        xin_reg   <= (others => '0');
        yin_reg   <= (others => '0');
        angle_reg <= (others => '0');
    elsif rising_edge(clk) then
        xin_reg <= xin;
        yin_reg <= yin;
        angle_reg <= angle;
    end if;
end process;

reading: process

   variable lineIn: line; 
   variable value: integer;

begin

    simulate <= '1';
    start <= '0'; 
      
    wait until reset = '1';  
	wait until reset = '0';    
   
    start <= '1';
  
	while not endfile(infile) loop
      
        readline(infile,lineIn);
        read(lineIn,value);        
        xin <= to_signed(value,WL);
        
        readline(infile,lineIn);
        read(lineIn,value);        
        yin <= to_signed(value,WL);
        
        readline(infile,lineIn);
        read(lineIn,value);        
        angle <= to_unsigned(value,b); 

		wait for clk_period;
    end loop;      
   
    -- We have finished the reading of the file. From now on, we make the inputs equal to zero.   
    
    xin   <= (others => '0');  
    yin   <= (others => '0'); 
    angle <= (others => '0');     
								   
	wait for (latency-1) * clk_period;
		simulate <= '0';   -- we stop writing to the output file
      
	wait for 4*clk_period;
	   readline(infile,lineIn); -- We generate an error to stop the simulation
      
	wait;
   
end process;


writing: process
        
    variable value: integer;
	variable lineOut: line;

    begin
     
    wait until start = '1';
      
    wait for latency * clk_period;    
      
    while simulate = '1' loop
      
        value := to_integer(xout);
        write(lineOut,value);        
        writeline(outfile,lineOut);
        
        value := to_integer(yout);
        write(lineOut,value);        
        writeline(outfile,lineOut);

        wait for clk_period;			
        
    end loop;				    
		
	wait;

end process;


end arch;