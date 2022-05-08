library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctrl_csd is
	generic(	
		WL: integer:=8);		-- Word Length
	port(
	  	CSDs: in std_logic_vector(WL -1 downto 0);  -- Sign of the CSD bits
	  	CSDm: in std_logic_vector(WL -1 downto 0);  -- Magnitude of the CSD bits
	  	m: out std_logic_vector(WL/2 downto 0);
	  	s: out std_logic_vector(WL-1 downto 0));
end ctrl_csd;

architecture arch of ctrl_csd is

signal m_stage: std_logic_vector(WL/2-1 downto 0);

begin

process(CSDs, CSDm)
begin
    for i in 0 to WL/2-1 loop
        s(2*i) <= CSDm(WL-1-2*i) or CSDm(WL-2-2*i);
        s(2*i+1) <= not(CSDm(WL-2-2*i));
        m_stage(i) <= CSDs(WL-1-2*i) or CSDs(WL-2-2*i);
    end loop;
end process;

m <= (m_stage & '0') xor ('0' & m_stage);

end arch;