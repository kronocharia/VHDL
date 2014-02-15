LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY invert IS
	GENERIC(vsize: INTEGER :=12);
	PORT(	c: IN std_logic;
			a: IN std_logic_vector(vsize-1 DOWNTO 0);
			b: OUT std_logic(vsize-1 DOWNTO 0)
	);
END ENTITY invert;

ARCHITECTURE comb OF invert IS
	--SIGNAL a_i,b_i;
	--SIGNAL c_i;
BEGIN
	C1:PROCESS(c,a)
	BEGIN
		b <= a;
		IF 	c = '1' THEN
			b <= NOT(a);
		END IF;
	END PROCESS C1;

END ARCHITECTURE comb;
--------------------------
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


ENTITY swap IS
	GENERIC(vsize: INTEGER :=12);
	PORT(	xin,yin: IN std_logic_vector(vsize-1 DOWNTO 0);
			xout,yout: OUT std_logic_vector(vsize-1 DOWNTO 0);
			c: IN std_logic
	);
END ENTITY swap;

ARCHITECTURE comb OF swap IS
BEGIN 
	C1:PROCESS(c,xin,yin)
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
	SIGNAL x

BEGIN
	RD:PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT AND clk='1' AND disable='0';
		negx_i <= negx;
		negy_i <= negy;
		swapxy_i <= swapxy;
	END PROCESS RD;

	C1:PROCESS(xbias, xin, yin, swapxy, negx, negy)
	BEGIN
		SWAP1: ENTITY swap GENERIC MAP(vsize) PORT MAP( swapxy => c ,xin => , yin =>,  );
		INVERT1: ENTITY invert GENERIC MAP(vsize) PORT MAP(negx =>c,);
		INVERT2: ENTITY invert GENERIC MAP(vsize) PORT MAP(negy =>c);
		DRAW1: ENTITY draw_octant GENERIC MAP(vsize) PORT MAP()
		INVERT3: ENTITY invert GENERIC MAP(vsize) PORT MAP(negx =>c);
		INVERT4: ENTITY invert GENERIC MAP(vsize) PORT MAP(negy =>c);
		SWAP2: ENTITY swap GENERIC MAP(vsize) PORT MAP(swapxy =>c);

	
		
	END PROCESS C1;

END ARCHITECTURE comb;

