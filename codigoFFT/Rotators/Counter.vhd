
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity COUNTER is
  generic (
    WIDTH     : integer := 8
    );
  port (
    account   : out STD_LOGIC_VECTOR (WIDTH-1  downto 0);
    start    : in  STD_LOGIC;
    rst      : in  STD_LOGIC;
    clk      : in  STD_LOGIC
    );
end COUNTER;

architecture Behavioral of COUNTER is
  signal i_account : std_logic_vector (WIDTH-1 downto 0);
begin

  account <= i_account;

  process (rst, clk)
  begin
    if rst='1' then
      i_account <= (others => '0');
    elsif clk='1' and clk'event then
      if start='1' then
        i_account <= (others => '0');
      else
        i_account <= i_account + '1';
      end if;
    end if;
  end process;
end Behavioral;