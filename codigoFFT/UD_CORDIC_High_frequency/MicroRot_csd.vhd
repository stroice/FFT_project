library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MicroRot_csd is
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
end MicroRot_csd;

architecture arch of MicroRot_csd is

component RMCM_st1_csd is
    generic(
        WL: integer:= 8);
	port(
	    reset: in  std_logic;
	    clk:   in  std_logic;
	  	xin:   in  signed(WL-1 downto 0); -- input signal  
	  	s0:    in  std_logic;  -- control signal s_0
	  	s1:    in  std_logic;  -- control signal s_1
	  	xC:    out signed(WL-1+9 downto 0);  -- x times C      (C,S) = (296,0) or (260,142) or (160,249)
	  	xS:    out signed(WL-1+9 downto 0));  -- x times S
end component;

component RMCM_st2_csd is
    generic(
        WL: integer:= 8);
	port(
	    reset:  in  std_logic;
	    clk:    in  std_logic;
	  	xin:    in  signed(WL-1 downto 0); -- input signal  
	  	s2:     in  std_logic;  -- control signal s_2
	  	s3:     in  std_logic;  -- control signal s_3
	  	xC:     out signed(WL-1+8 downto 0);  -- x times C      (C,S) = (129,0) or (128,16) or (125,32)
	  	xS:     out signed(WL-1+5 downto 0));  -- x times S
end component;

component RMCM_sti_csd is
    generic(
        WL: integer:= 8;
        i: integer:= 3); -- stage. Can take values from 3 to n
	port(
	--    clk:   in std_logic;
	  	xin:   in  signed(WL-1 downto 0); -- input signal  
	  	s2im1: in  std_logic;  -- control signal s_{2i-1}
	  	s2im2: in  std_logic;  -- control signal s_{2i-2}
	  	xC:    out signed(WL-1+(2*i-1) downto 0);  -- x times C      (C,S) = (2^{2i-1},0) or (2^{2i-1},1) or (2^{2i-1},2)
	  	xS:    out signed(WL-1+1 downto 0));  -- x times S
end component;

begin

stage1: if st = 1 generate

signal xC, xS, yC, yS: signed(WL-1+9 downto 0);
signal X, Y: signed(WL-1+9 downto 0); 

begin

RMCM1real: RMCM_st1_csd
    generic map(
        WL => WL)
	port map(
	    reset => reset,
	    clk => clk,
	  	xin => xin,  -- input signal  
	  	s0  => si,   -- control signal s_0
	  	s1  => si1,  -- control signal s_1
	  	xC  => xC,   -- x times C      (C,S) = (296,0) or (260,142) or (160,249)
	  	xS  => xS);  -- x times S


RMCM1imag: RMCM_st1_csd
    generic map(
        WL => WL)
	port map(
	    reset => reset,
	    clk => clk,
	  	xin => yin,  -- input signal  
	  	s0  => si,   -- control signal s_0
	  	s1  => si1,  -- control signal s_1
	  	xC  => yC,   -- y times C      (C,S) = (296,0) or (260,142) or (160,249)
	  	xS  => yS);  -- y times S

-- Calculate the rotation
X <= xC - yS;
Y <= yC + xS;

-- Truncate and register the outputs
process(reset, clk)
begin
    if reset = '1' then
        xout <= (others => '0');
        yout <= (others => '0');
    elsif rising_edge(clk) then
        xout <= X(WL-1+9 downto 9);
        yout <= Y(WL-1+9 downto 9);
    end if;
end process;

end generate;

stage2: if st = 2 generate

signal xC, yC: signed(WL-1+8 downto 0);
signal xS, yS: signed(WL-1+5 downto 0);
signal X, Y:   signed(WL-1+8 downto 0);

begin

RMCM2real: RMCM_st2_csd
    generic map(
        WL => WL)
	port map(
	    reset => reset,
	    clk => clk,
	  	xin => xin, -- input signal  
	  	s2  => si,  -- control signal s_2
	  	s3  => si1, -- control signal s_3
	  	xC  => xC,  -- x times C      (C,S) = (129,0) or (128,16) or (125,32)
	  	xS  => xS); -- x times S

RMCM2imag: RMCM_st2_csd
    generic map(
        WL => WL)
	port map(
	    reset => reset,
	    clk => clk,
	  	xin => yin, -- input signal  
	  	s2  => si,  -- control signal s_2
	  	s3  => si1, -- control signal s_3
	  	xC  => yC,  -- y times C      (C,S) = (129,0) or (128,16) or (125,32)
	  	xS  => yS); -- y times S
	  		  	
-- Calculate the rotation
X <= xC - resize(yS,WL+8);
Y <= yC + resize(xS,WL+8);

-- Truncate and register the outputs
process(reset, clk)
begin
    if reset = '1' then
        xout <= (others => '0');
        yout <= (others => '0');    
    elsif rising_edge(clk) then
        xout <= X(WL-1+7 downto 7);  -- We used 8 extra bits because the scaling is 129. However, by considering the scaling of the previous stage, we can remove the MSB here
        yout <= Y(WL-1+7 downto 7);
    end if;
end process;	  	

end generate;

stagei: if st > 2 generate

signal xC, yC: signed(WL-1+(2*st-1) downto 0);
signal xS, yS: signed(WL-1+1 downto 0);
signal X, Y:   signed(WL-1+(2*st-1) downto 0);

begin

RMCMiReal: RMCM_sti_csd
    generic map(
        WL => WL,
        i  => st) -- stage. Can take values from 3 to n
	port map(
	--    clk   => clk,  
	  	xin   => xin, -- input signal  
	  	s2im1 => si1,  -- control signal s_{2i-1}
	  	s2im2 => si, -- control signal s_{2i-2}
	  	xC    => xC,  -- x times C      (C,S) = (2^{2i-1},0) or (2^{2i-1},1) or (2^{2i-1},2)
	  	xS    => xS); -- x times S

RMCMiImag: RMCM_sti_csd
    generic map(
        WL => WL,
        i  => st) -- stage. Can take values from 3 to n
	port map(
	 --   clk   => clk,
	  	xin   => yin, -- input signal  
	  	s2im1 => si1,  -- control signal s_{2i-1}
	  	s2im2 => si, -- control signal s_{2i-2}
	  	xC    => yC,  -- y times C      (C,S) = (2^{2i-1},0) or (2^{2i-1},1) or (2^{2i-1},2)
	  	xS    => yS); -- y times S

-- Calculate the rotation
X <= xC - resize(yS,WL+(2*st-1));
Y <= yC + resize(xS,WL+(2*st-1));

-- Truncate and register the outputs
process(reset, clk)
begin
    if reset = '1' then
        xout <= (others => '0');
        yout <= (others => '0');
    elsif rising_edge(clk) then
        xout <= X(WL-1+(2*st-1) downto (2*st-1));
        yout <= Y(WL-1+(2*st-1) downto (2*st-1));
    end if;
end process;

end generate;	

end arch;


-- Reconfigurable MCM for the first stage of the CSD UD CORDIC:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RMCM_st1_csd is
    generic(
        WL: integer:= 8);
	port(
	    reset: in  std_logic;
	    clk:   in  std_logic;
	  	xin:   in  signed(WL-1 downto 0); -- input signal  
	  	s0:    in  std_logic;  -- control signal s_0
	  	s1:    in  std_logic;  -- control signal s_1
	  	xC:    out signed(WL-1+9 downto 0);  -- x times C      (C,S) = (296,0) or (260,142) or (160,249)
	  	xS:    out signed(WL-1+9 downto 0));  -- x times S
end RMCM_st1_csd;

architecture arch of RMCM_st1_csd is

signal s0_reg, s1_reg: std_logic;

signal x_16_1:     signed(WL-1+4 downto 0);
signal x_64_4:     signed(WL-1+6 downto 0);
signal x_65_5, x_65_5_reg:     signed(WL-1+7 downto 0);
signal x_40:       signed(WL-1+6 downto 0);
signal x_65_40:    signed(WL-1+7 downto 0);
signal x_260_160:  signed(WL-1+9 downto 0);

signal x_7:        signed(WL-1+3 downto 0);
signal x_14_m7, x_14_m7_reg:    signed(WL-1+4 downto 0);
signal x_40_14_m7: signed(WL-1+6 downto 0);

signal x_2_1, x_2_1_reg:      signed(WL-1+1 downto 0);
signal x_256_128:  signed(WL-1+8 downto 0); 

signal c: std_logic;  --- Carry
signal x_296_249_142_aux:  signed(WL-1+10 downto 0); 
signal x_296_249_142:      signed(WL-1+9 downto 0); 

signal x_296_260_160:  signed(WL-1+9 downto 0);
signal s0_replicated: signed(WL-1+9 downto 0);
signal x_0_142_249:    signed(WL-1+9 downto 0);


begin

process(reset, clk)
begin
    if reset = '1' then
        s0_reg <= '0';
        s1_reg <= '0';
    elsif rising_edge(clk) then
        s0_reg <= s0;
        s1_reg <= s1;
    end if;
end process;


x_16_1 <=  (xin & "0000") when s1 = '0' else resize(xin,WL+4); 
x_64_4 <=  x_16_1 & "00"; 
x_65_5 <=  resize(x_64_4,WL+7) + resize(xin,WL+7);

process(reset, clk)
begin
    if reset = '1' then
        x_65_5_reg <= (others => '0');
    elsif rising_edge(clk) then
        x_65_5_reg <= x_65_5;
    end if;
end process;    

x_40 <= x_65_5_reg(WL-1+3 downto 0) & "000";  -- Only the case of 5x needs to be scaled to create 40x.
x_65_40 <= x_65_5_reg when s1_reg = '0' else resize(x_40,WL+7);
x_260_160 <= x_65_40 & "00";

x_7 <= xin & "000" - resize(xin,WL+3);
x_14_m7 <= (x_7 & '0') when s1 = '0' else not (resize(x_7,WL+4));

process(reset, clk)
begin   
    if reset = '1' then
        x_14_m7_reg <= (others => '0');
    elsif rising_edge(clk) then
        x_14_m7_reg <= x_14_m7;
    end if;
end process;

x_40_14_m7 <= x_40 when s0_reg = '0' else resize(x_14_m7_reg,WL+6);

x_2_1 <= resize(xin,WL+1) when s1 = '0' else (xin & '0');

process(reset, clk)
begin   
    if reset = '1' then
        x_2_1_reg <= (others => '0');
    elsif rising_edge(clk) then
        x_2_1_reg <= x_2_1;
    end if;
end process;

x_256_128 <= x_2_1_reg & "0000000"; 

c <= s0_reg and s1_reg;
x_296_249_142_aux <= (resize(x_256_128,WL+9) & c) + (resize(x_40_14_m7,WL+9) & c); -- We sum in this way in order to add the carry in.
x_296_249_142 <= x_296_249_142_aux(WL-1+10 downto 1);

x_296_260_160 <= x_296_249_142 when s0_reg = '0' else resize((x_65_40 & "00"),WL+9); 
s0_replicated <= (others => s0_reg);
x_0_142_249 <= x_296_249_142 and s0_replicated;

process(reset, clk)
begin
    if reset = '1' then
        xC <= (others => '0');
        xS <= (others => '0');
    elsif rising_edge(clk) then
        xC <= x_296_260_160;
        xS <= x_0_142_249;
    end if;
end process;    

end arch;



-- Reconfigurable MCM for the second stage of the CSD UD CORDIC:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RMCM_st2_csd is
    generic(
        WL: integer:= 8);
	port(
	    reset: in  std_logic;
	    clk:   in  std_logic;
	  	xin:   in  signed(WL-1 downto 0); -- input signal  
	  	s2:    in  std_logic;  -- control signal s_2
	  	s3:    in  std_logic;  -- control signal s_3
	  	xC:    out signed(WL-1+8 downto 0);  -- x times C      (C,S) = (129,0) or (128,16) or (125,32)
	  	xS:    out signed(WL-1+5 downto 0));  -- x times S
end RMCM_st2_csd;

architecture arch of RMCM_st2_csd is

signal s2_replicated: signed (WL-1 downto 0);
signal s3_replicated: signed (WL-1 downto 0);

signal xin_reg: signed(WL-1 downto 0);
signal x_1_0_a:  signed (WL-1 downto 0);
signal x_1_0_b:  signed (WL-1 downto 0);
signal x_1_0_m3, x_1_0_m3_reg: signed (WL-1+2 downto 0);
signal x_129_128_125: signed (WL-1+8 downto 0);

signal x_1_0_c:   signed (WL-1 downto 0);
signal x_0_1_2:   signed (WL-1+1 downto 0);
signal x_0_16_32: signed (WL-1+5 downto 0);

begin

s2_replicated <= (others => s2);
s3_replicated <= (others => s3);

x_1_0_a <= xin and s3_replicated;
x_1_0_b <= x_1_0_a and s2_replicated;
x_1_0_m3 <= resize(x_1_0_a,WL+2) - (x_1_0_b & "00"); 

process(reset, clk)
begin
    if reset = '1' then
        x_1_0_m3_reg <= (others => '0');
        xin_reg <= (others => '0');
    elsif rising_edge(clk) then
        xin_reg <= xin;
        x_1_0_m3_reg <= x_1_0_m3;
    end if;
end process;

x_129_128_125 <= resize(xin_reg & "0000000",WL+8) + resize(x_1_0_m3_reg,WL+8);

x_1_0_c <= xin and s2_replicated;
x_0_1_2 <= resize(x_1_0_c, WL+1) when s3 = '0' else (x_1_0_c & '0');
x_0_16_32 <= (x_0_1_2 & "0000");


xC <= x_129_128_125;
--xS <= x_0_16_32;

process(reset, clk)
begin
    if reset = '1' then
        xS <= (others => '0');
    elsif rising_edge(clk) then
       --xC <= x_129_128_125;
       xS <= x_0_16_32;
    end if;
end process;        

end arch;


-- Reconfigurable MCM for the i-th stage, i=3,...,n, of the CSD UD CORDIC:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RMCM_sti_csd is
    generic(
        WL: integer:= 8;
        i: integer:= 3); -- stage. Can take values from 3 to n
	port(
	  --  clk:   in  std_logic;
	  	xin:   in  signed(WL-1 downto 0); -- input signal  
	  	s2im1: in  std_logic;  -- control signal s_{2i-1}
	  	s2im2: in  std_logic;  -- control signal s_{2i-2}
	  	xC:    out signed(WL-1+(2*i-1) downto 0);  -- x times C      (C,S) = (2^{2i-1},0) or (2^{2i-1},1) or (2^{2i-1},2)
	  	xS:    out signed(WL-1+1 downto 0));  -- x times S
end RMCM_sti_csd;

architecture arch of RMCM_sti_csd is

signal s2im2_replicated: signed (WL-1 downto 0);
signal x_1_0: signed(WL-1 downto 0);
signal x_0_1_2: signed(WL-1+1 downto 0);

begin

xC(WL-1+(2*i-1) downto (2*i-1)) <= xin;
xC((2*i-1)-1 downto 0) <= (others => '0');     

s2im2_replicated <= (others => s2im2);
x_1_0 <= xin and s2im2_replicated;
x_0_1_2 <= resize(x_1_0,WL+1) when s2im1 = '0' else (x_1_0 & '0');
xS <= x_0_1_2;



end arch;