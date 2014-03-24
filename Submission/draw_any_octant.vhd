LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.ALL;

ENTITY draw_any_octant IS

  -- swapxy negx  negy  octant
  --  0      0      0     ENE
  --  1      0      0     NNE
  --  1      1      0     NNW
  --  0      1      0     WNW
  --  0      1      1     WSW
  --  1      1      1     SSW
  --  1      0      1     SSE
  --  0      0      1     ESE

  -- swapxy: x & y swap round on inputs & outputs
  -- negx:   invert bits of x on inputs & outputs
  -- negy:   invert bits of y on inputs & outputs

  -- xbias always give bias in x axis direction, so swapxy must invert xbias
  GENERIC(
    vsize: INTEGER := 12
  );
  
  PORT(
    clk, resetx, draw, xbias : IN  std_logic;
    xin, yin                 : IN  std_logic_vector(vsize-1 DOWNTO 0);
    done                     : OUT std_logic;
    x, y                     : OUT std_logic_vector(vsize-1 DOWNTO 0);
    swapxy, negx, negy       : IN  std_logic;
    disable                  : IN  std_logic
    );
END ENTITY draw_any_octant;

ARCHITECTURE comb OF draw_any_octant IS

SIGNAL xi1, xi2, xo1, xo2, yi1, yi2, yo1, yo2: std_logic_vector(vsize-1 DOWNTO 0);
SIGNAL negx_out, negy_out, swapxy_out, xbias_in: std_logic;

BEGIN


swap_in: PROCESS(xin, yin, swapxy)--Swap inputs
BEGIN
  xi1 <= xin;
  yi1 <= yin;
  IF swapxy = '1' THEN
    xi1 <= yin;
    yi1 <= xin;
  END IF;
END PROCESS swap_in;

invertx_in: PROCESS(xi1, negx)--Invert x input
BEGIN
  xi2 <= xi1;
  IF negx = '1' THEN
    xi2 <= not xi1;
  END IF;
END PROCESS invertx_in;

inverty_in: PROCESS(yi1, negy)--Invert y input
BEGIN
  yi2 <= yi1;
  IF negy = '1' THEN
    yi2 <= not yi1;
  END IF;
END PROCESS inverty_in;

swap_out: PROCESS(xo2, yo2, swapxy_out)--Swap outputs
BEGIN
  x <= xo2;
  y <= yo2;
  IF swapxy_out = '1' THEN
    x <= yo2;
    y <= xo2;
  END IF;
END PROCESS swap_out;

invertx_out: PROCESS(xo1, negx_out)--Invert x output
BEGIN
  xo2 <= xo1;
  IF negx_out = '1' THEN
    xo2 <= not xo1;
  END IF;
END PROCESS invertx_out;

inverty_out: PROCESS(yo1, negy_out)--Invert y output
BEGIN
  yo2 <= yo1;
  IF negy_out = '1' THEN
    yo2 <= not yo1;
  END IF;
END PROCESS inverty_out;

delay: PROCESS
BEGIN
  WAIT UNTIL clk'EVENT and clk = '1';
  IF disable = '0' THEN
    negx_out <= negx;
    negy_out <= negy;
    swapxy_out <= swapxy;
  END IF;
END PROCESS delay;

xbias_in <= xbias xor swapxy;

d1: ENTITY draw_octant GENERIC MAP(vsize) PORT MAP(
    xin => xi2,
    yin => yi2,
    clk => clk,
    disable => disable,
    xbias => xbias_in,
    x => xo1,
    y => yo1,
    resetx => resetx,
    draw => draw,
    done => done
    );

END ARCHITECTURE comb;