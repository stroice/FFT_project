library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CORDIC is
  generic(PIPELINE : character := 'I';--GEN(P) -- 'I'=I/O, 'S'=Stages, 'F'=Fully
          N : integer range 13 to 52 := 16);--GEN(N)
  port(clk : in std_logic; -- not used if NO_PIPELINE
       x,y : in signed(N-1 downto 0); -- arbitrary fraction point
       alpha : in signed(N-1 downto 0); -- alpha in [-.5, .5), corresponding to an entire rotate.
       XD,YD : out signed(N-1 downto 0));
end entity;

architecture rtl of CORDIC is
  constant IO_PIPELINE : boolean := PIPELINE='I' or PIPELINE='F';
  constant DO_PIPELINE : boolean := PIPELINE='S' or PIPELINE='F';
  -- Stage S=1: Trivial rotations. Angle unit = rot (2pi rad/rot, 1 rot/360 deg).
  -- Stage S=2..6: CORDIC. 2^(S-1) +- 1j. Angle unit = rot.
  -- Stage S=7: Convert angle to rad.
  -- Stage S=8..10: CORDIC. 2^(S-2) +- 1j. Angle unit = rad. Just pick bits from angle.
  
  -- Each CORDIC stage rotate in positive or negative direction.
  -- A negative direction is implemented as a swap of x and y on input and output.
  -- The conditional output swap is moved to the next stage, to be merged with the
  --   conditional input swap of that stage. Two swaps = no swap.
  
  --type Ts is array (natural range <>) of signed(N-1 downto 0);
  type Ts is array (1 to 10) of signed(N-1 downto 0);
  type TuL is array (natural range <>) of unsigned(51 downto 0);
  type Tn is array (natural range <>) of natural;
  
  -- *is = *os from previous stage, conditionally pipelined.
  signal xis,xos,yis,yos,ais,aos : Ts;
  signal swapis,swapos : std_logic_vector(1 to 10); -- swap control signal.
  -- 0.000betas(S) = atan(2^-(S-1)) / (2pi) rot.
  constant betas : TuL(2 to 6) := (
    X"972028ECEF980", -- S=2, atan(2^-1)*2^55. Unit=rot
    X"4FD9C2DAF71CC", -- S=3, atan(2^-2)*2^55. Unit=rot
    X"28888EA0EEECD", -- S=4, atan(2^-3)*2^55. Unit=rot
    X"14586A1872C4E", -- S=5, atan(2^-4)*2^55. Unit=rot
    X"0A2EBF0AC8231");-- S=6, atan(2^-5)*2^55. Unit=rot
  -- S=2: A=2+1j. arg(A^13.5)~0. 1/13.5 = 0.0738 = 0.0001001011100100000...
  constant skipMSBs : Tn(2 to 7) := (2,2,3,4,5,6);
begin
  
  -- The conditional pipeline:
  ifIOP_Gen: if IO_PIPELINE generate
    process(clk) begin if rising_edge(clk) then
      xis(1) <= x; yis(1) <= y; ais(1) <= alpha;
      if swapos(10) = '0' then
        XD <= xos(10);
        YD <= yos(10);
      else
        XD <= yos(10);
        YD <= xos(10);
      end if;
    end if; end process;
  end generate;
  ifNOIOP_Gen: if not IO_PIPELINE generate
    xis(1) <= x; yis(1) <= y; ais(1) <= alpha;
    XD <= xos(10) when swapos(10) = '0' else
          yos(10);
    YD <= yos(10) when swapos(10) = '0' else
          xos(10);
  end generate;
  ifP_Gen: if DO_PIPELINE generate
    process(clk) begin if rising_edge(clk) then
      xis(2 to 10) <= xos(1 to 9);
      yis(2 to 10) <= yos(1 to 9);
      ais(2 to 10) <= aos(1 to 9);
      swapis(2 to 10) <= swapos(1 to 9);
    end if; end process;
  end generate;
  ifNOP_Gen: if not DO_PIPELINE generate
    xis(2 to 10) <= xos(1 to 9);
    yis(2 to 10) <= yos(1 to 9);
    ais(2 to 10) <= aos(1 to 9);
    swapis(2 to 10) <= swapos(1 to 9);
  end generate;
  
  -- STAGE 1: Trivial rotation (angle unit in rot)
  S1 : block
    signal ai : signed(N-1 downto 0);
    signal beta : signed(1 downto 0);
  begin
    ai <= ais(1);
    beta <= ai(N-1 downto N-2) + ('0' & ai(N-3));
    swapos(1) <= '0' when beta = "00" else
                 '1' when beta = "01" else
                 '0' when beta = "10" else
                 '1';
    xos(1) <= xis(1) when beta = "00" else
              xis(1) when beta = "01" else
             -xis(1) when beta = "10" else
             -xis(1);
    yos(1) <= yis(1) when beta = "00" else
             -yis(1) when beta = "01" else
             -yis(1) when beta = "10" else
              yis(1);
    aos(1) <= (ai(N-1 downto N-2) - beta) & ai(N-3 downto 0);
    --aos(1) <= ais(1); -- 2 MSBs will anyway not be used.
  end block;
  
  -- State 2-6: CORDIC stages. 2^(S-1) + 1j. Angle unit in rot
  S26 : for S in 2 to 6 generate
    constant beta0 : signed(51 downto 0) := signed(betas(S));
    constant beta1 : signed(N-1 downto 0) := ("000" & beta0(51 downto 55-N)) + ("0"&beta0(54-N));
    constant skipMSB : natural := skipMSBs(S); -- how many MSBs of angle can be ignored?
    signal beta : signed(N-1 downto 0); -- +-arg(1 + j*2^-(S+1))
    signal neg_rot : std_logic;
    signal ai : signed(N-1 downto 0);
    signal xi,yi : signed(N-1 downto 0);
    signal xo,yo : signed((N-1)+(S-1) downto 0); -- N + log2(2^(S-1)) bits
  begin
    ai <= ais(S);
    neg_rot <= ai(N-1-skipMSB); -- 1: swap both input and output.
    swapos(S) <= neg_rot;
    beta <= -beta1 when neg_rot = '0' else
             beta1;
    -- the skip_MSB MSBs will be optimized away, since unused.
    aos(S) <= ai + beta;
    xi <= yis(S) when neg_rot = '1' xor swapis(S) = '1' else
          xis(S);
    yi <= xis(S) when neg_rot = '1' xor swapis(S) = '1' else
          yis(S);
    -- S=2: xyo = (2+1j)/2*xy as safe scaling.
    -- S>2: xyo = (2^(S-1) + 1j)*xy.
    -- xyos(S) = xyo / 2^(S-1).
    xo <= signed(xi(N-1) & xi) - yi(N-1 downto 1) when S = 2 else
          (xi & (S-2 downto 0=>'0')) - yi;
    yo <= signed(yi(N-1) & yi) + xi(N-1 downto 1) when S = 2 else
          (yi & (S-2 downto 0=>'0')) + xi;
    xos(S) <= xo(N-1+(S-1) downto S-1);
    yos(S) <= yo(N-1+(S-1) downto S-1);
  end generate;
  
  -- STAGE 7: Convert angle to rad instead of rot
  -- In short: a7o <= a7i * 2*pi
  -- 2*pi = 110.010010000111111011010101000100010000101101000110000...
  --      ~ 110.010010001
  -- 3 add, |eps| = .7*2^-18:
  --  * tmp = 16 + 1
  --  * ao = 128*tmp + 1024 + tmp = 3217
  --  ao*(1+eps) = 2*pi*2^9 = 3216.9909, |eps|= .7*2^-18
  S7 : block
    constant skipMSB : natural := skipMSBs(7); -- how many MSBs of angle can be ignored?
    constant N2 : natural := N-skipMSB;
    signal ai : signed(N2-1 downto 0); -- The used bits from 
    signal tmp : signed(N2+3 downto 0); -- 17 => N2 + 4 bits
    signal ao : signed(N2+10 downto 0); -- 3217 => N2 + 11 bits (range analysis ensures no overflow)
    -- ao : signed(N-6+10 downto 0)
  begin
    ai <= ais(7)(N2-1 downto 0);
    tmp <= (ai & "0000") + ai; -- 17
    ao <= (tmp & "0000000") + (ai & "0000000000") + tmp; -- 128*17 + 1024 + 17
    -- a7o <= ao * 2^-9.
    -- Only bits N+3-[8..10] = N2+[1..-1] from aos(7) are of interest. Round to those.
    aos(7)(N2+1 downto N2-1) <= ao(N2+1+9 downto N2-1+9);-- + ("0" & ao(N2-2+9));
    --aos(7)(N2+1 downto 0) <= ao(N2+10 downto 9); -- 3217 * 2^-9'
    xos(7) <= xis(7);
    yos(7) <= yis(7);
    swapos(7) <= swapis(7);
  end block;
  
  -- State 8-10: CORDIC stages. 2^(S-2) + 1j. Angle unit in rad
  S810 : for S in 8 to 10 generate
    signal neg_rot : std_logic;
    signal ai : signed(N-1 downto 0);
    signal xi,yi : signed(N-1 downto 0);
    signal xo,yo : signed(N-1+(S-2) downto 0);
  begin
    ai <= ais(S); -- S=6: range .11111#### - .00000####
    -- ai = b_5*-2^-5 + sum_{i=6..inf}(b_i*2^-i)
    --    = (1-2b_5)*2^-6 + sum_{i=6..inf}((2b_i-1)*2^-(i+1))
    -- I.e., 2^(S-2) + 1j belongs to b_{S-3} = ai(N+3-S)
    neg_rot <= ai(N+3-S) when S=8 else -- S=8: oposit sign.
           not ai(N+3-S);
    swapos(S) <= neg_rot;
    aos(S) <= ai; -- the skip_MSB MSBs will be optimized away, since unused.
    xi <= yis(S) when neg_rot = '1' xor swapis(S) = '1' else
          xis(S);
    yi <= xis(S) when neg_rot = '1' xor swapis(S) = '1' else
          yis(S);
    xo <= (xi & (S-3 downto 0 => '0')) - yi;
    yo <= (yi & (S-3 downto 0 => '0')) + xi;
    xos(S) <= xo(N-1+(S-2) downto S-2);
    yos(S) <= yo(N-1+(S-2) downto S-2);
  end generate;

end architecture;

