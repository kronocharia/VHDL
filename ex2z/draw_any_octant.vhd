LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY invert IS
	GENERIC(vsize: INTEGER :=12);
	PORT(	c: IN std_logic;
			a: IN std_logic_vector(vsize-1 DOWNTO 0);
			b: OUT std_logic_vector(vsize-1 DOWNTO 0)
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
		xout <= xin;
		yout <= yin;
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
USE WORK.ALL;

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
    clk, resetx, draw, xbias,disable : IN  std_logic;
    xin, yin                 : IN  std_logic_vector(vsize-1 DOWNTO 0);
    done                     : OUT std_logic;
    x, y                     : OUT std_logic_vector(vsize-1 DOWNTO 0);
    swapxy, negx, negy       : IN  std_logic
    );
END ENTITY draw_any_octant;

ARCHITECTURE comb OF draw_any_octant IS

	SIGNAL clk_i,negx_i,negy_i,swapxy_i,xbias_i : std_logic ;
	SIGNAL x1,x2,x3,x4,y1,y2,y3,y4 : std_logic_vector(vsize-1 DOWNTO 0);

BEGIN
	RD:PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT AND clk='1' AND disable='0';
		negx_i <= negx;
		negy_i <= negy;
		swapxy_i <= swapxy;
	END PROCESS RD;


		SWAP1: ENTITY swap GENERIC MAP(vsize) PORT MAP(
			c => swapxy , xin => xin, yin =>yin, xout =>x1, yout=>y1 
			);
		
		INVERTX1: ENTITY invert GENERIC MAP(vsize) PORT MAP(c => negx, a =>x1, b=>x2);
		INVERTY1: ENTITY invert GENERIC MAP(vsize) PORT MAP(c =>negy, a=>y1, b=>y2);
		
		xbias_i <= xbias XOR swapxy; 
		
		DRAW1: ENTITY WORK.draw_octant GENERIC MAP(vsize) PORT MAP( 
			clk => clk, 
			resetx=> resetx, 
			draw=> draw,
			xbias=> xbias_i, 
			disable=> disable, 
			xin => x2, 
			yin =>y2, 
			done => done, 
			x=>x3, 
			y=>y3

			);
		INVERTX2: ENTITY invert GENERIC MAP(vsize) PORT MAP(c =>negx_i, a=>x3, b=>x4 );
		INVERTY2: ENTITY invert GENERIC MAP(vsize) PORT MAP(c =>negy_i, a=>y3, b=>y4 );
		SWAP2: ENTITY swap GENERIC MAP(vsize) PORT MAP(
			c=> swapxy_i, xin=>x4, yin=>y4, xout=>x, yout=>y
			);

END ARCHITECTURE comb;

