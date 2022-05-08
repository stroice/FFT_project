library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin2csd_tb is
generic(WL: integer:= 8);
end bin2csd_tb;

architecture arch of bin2csd_tb is

component bin2csd 
	generic(	
		WL: integer:=8);		-- Word Length
	port(
	  	b:    in  signed(WL -1 downto 0);  -- Input binary number in 2s complement
	  	CSDs: out std_logic_vector(WL -1 downto 0);  -- Sign of the CSD bits
	  	CSDm: out std_logic_vector(WL -1 downto 0)); -- Magnitude of the CSD bits
end component;

signal reset: std_logic;
signal clk: std_logic;
signal clk_period: time:= 10ns;

signal counter: signed(WL -1 downto 0);
signal CSDs: std_logic_vector(WL-1 downto 0);
signal CSDm: std_logic_vector(WL-1 downto 0);
signal y: integer;

begin

DUT: bin2csd 
	generic map(	
		WL => WL)		-- Word Length
	port map(
	  	b => counter,  -- Input binary number in 2s complement
	  	CSDs => CSDs,  -- Sign of the CSD bits
	  	CSDm => CSDm); -- Magnitude of the CSD bits

reset <= '0', '1' after 15 ns, '0' after 23 ns;

process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;


process(clk)
begin
    if reset = '1' then
        counter <= (others => '0');
    elsif rising_edge(clk) then
        counter <= counter -1;
    end if;
end process;


process(CSDs,CSDm)
variable b : integer;
begin
    b:=0;   
    for i in 0 to WL-1 loop
        if (CSDs(i) = '0' and CSDm(i) = '1') then
            b := b + 2**i;
        elsif (CSDs(i) = '1' and CSDm(i) = '1') then
            b := b - 2**i;
        end if;
    end loop;
    
    y <= b;   
     
end process;
            
    
end arch;