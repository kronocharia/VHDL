LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY invert IS
	GENERIC(vsize: NATURAL :=12);
	PORT(	a,c: IN std_logic;
			b: OUT std_logic
	);
END ENTITY invert;

ARCHITECTURE comb OF invert IS
	--SIGNAL a_i,b_i;
	--SIGNAL c_i;
BEGIN
	C1:PROCESS(c)
	BEGIN
		IF 	c = '1' THEN
			b <= NOT(a);
		END IF;
	END PROCESS C1;

END ARCHITECTURE comb;
--------------------------
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.invert, WORK.swap;

ENTITY swap IS
	GENERIC(vsize: NATURAL :=12);
	PORT(	xin,yin: IN std_logic_vector(vsize-1 DOWNTO 0);
			xout,yout: OUT std_logic_vector(vsize-1 DOWNTO 0);
			c: IN std_logic
	);
END ENTITY swap;

ARCHITECTURE comb OF swap IS
BEGIN 
	C1:PROCESS(c)
	BEGIN
		IF 	c = '1' THEN
			xout <= yin;
			yout <= xin;
		END IF;
	END PROCESS C1;
	
END ARCHITECTURE comb;
----------------------------
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

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
    swapxy, negx, negy       : IN  std_logic
    );
END ENTITY draw_any_octant;

ARCHITECTURE comb OF draw_any_octant IS

	SIGNAL clk_i,negx_i,negy_i,swapxy_i : std_logic_vector(vsize-1 DOWNTO 0) ;

BEGIN
	RD:PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT AND clk='1' AND disable='0';
		negx_i <= negx;
		negy_i <= negy;
		swapxy_i <= swapxy;
	END PROCESS RD;

	C1:PROCESS
	BEGIN
		SWAP1: swap GENERIC MAP(vsize) PORT MAP();
		INV1: invert GENERIC MAP(vsize) PORT MAP();
		INV2: invert GENERIC MAP(vsize) PORT MAP();
		
		INV3: invert GENERIC MAP(vsize) PORT MAP();
		INV4: invert GENERIC MAP(vsize) PORT MAP();
		SWAP2: swap GENERIC MAP(vsize) PORT MAP();
		
		
	END PROCESS C1;

END ARCHITECTURE comb;

