-- Thomas Clarke 2013
-- draw-octant entity modified for variable size vectors
-- used in VHDL & Logic Synthesis Coursework

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY draw_octant IS
  GENERIC(vsize: INTEGER := 12);
  PORT(
    clk, resetx, draw, xbias, disable : IN  std_logic;
    xin, yin                 : IN  std_logic_vector(vsize-1 DOWNTO 0);
    done                     : OUT std_logic;
    x, y                     : OUT std_logic_vector(vsize-1 DOWNTO 0)
    );
END ENTITY draw_octant;

ARCHITECTURE comb OF draw_octant IS

  SIGNAL done1                    : std_logic; -- internal done
  SIGNAL x1, y1                   : unsigned(vsize-1 DOWNTO 0); -- internal x,y
  SIGNAL xincr, yincr, xnew       : unsigned(vsize-1 DOWNTO 0);
  -- note on vector sizes. err1,err2 must be one bit larger to preserve signed error info
  -- error is always adjusted to minimise absolute value of signed error and therefore 
  -- can never be larger than vsize bits even though also signed, 12 bits is enough
  SIGNAL error                    : signed(vsize-1 DOWNTO 0);
  SIGNAL err1, err2               : unsigned(vsize DOWNTO 0);

-- OPERATION
--
-- line drawing is initialted by asserting resetx and draw in successive cycles.
-- this loads the initial and final coordinates of the line to be drawn into
-- (x,y) and xnew,ynew0 respectively
-- drawing must be in ENE octant which implies xincr >= 0, yincr >= 0, xincr >= yincr
-- here xincr = x - xnew, yincr = y - ynew
--
-- Through the drawing process (x,y) represent a new point to be plotted on line each cycle.
-- error represents the signed
--
-- xbias determines whether line goes in x direction or xy direction when both directions have
-- equal offset from the true line.
--
-- done is asserted in the final cycle when x=xnew, y=ynew.

--NOTES ON DATA STRUCTURES
-- The basic data here is a (x,y) coordinate
-- it would make sense to use a record type for this:
-- TYPE coord IS RECORD x,y: std-logic_vector(vsize-1 DOWNTO 0) END RECORD;
-- then decalre internal datas tructures of type coord.
-- the result would be neater, and for example testing the end condition could 
-- be equality on records which works (like equality on arrays)


BEGIN
  -- assign to ports from internal signals
  x    <= std_logic_vector(x1);
  y    <= std_logic_vector(y1);
  done <= done1;

  C1 : PROCESS(error, xincr, yincr, x1, xnew, resetx, draw)
    
  BEGIN

    err1 <= unsigned(abs(resize(error, vsize+1) + signed(resize(yincr,vsize+1))));
    err2 <= unsigned(abs(resize(error, vsize+1) - signed(resize(unsigned(xincr - yincr),vsize+1))));

    done1 <= '0';
    IF x1 = xnew and resetx = '0' and draw = '0' THEN -- can only go right or diagonal, so when x is at end, finish.
      done1 <= '1';
    END IF;

  END PROCESS C1;

  R1 : PROCESS

  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF disable = '0' THEN
    IF resetx = '1' THEN
      x1    <= unsigned(xin);
      y1    <= unsigned(yin);
      xincr <= (OTHERS => '0');
      yincr <= (OTHERS => '0');
      xnew  <= unsigned(xin);
      error <= (OTHERS => '0');
      
    ELSIF draw = '1' THEN
      xincr <= unsigned(xin) - x1;
      yincr <= unsigned(yin) - y1;
      xnew  <= unsigned(xin);
      
    ELSIF done1 = '1' THEN
      NULL; -- do nothing more once line has finished until next resetx

	ELSE    -- draw new pixel
     
      IF err1 > err2 OR (err1 = err2 AND xbias = '0') THEN --check new pixel direction
        -- draw new pixel in diagonal direction
        y1    <= y1 + 1;
        x1    <= x1 + 1;
        error <= error + signed(yincr) - signed(xincr);
      ELSE
        -- draw new pixel in x direction
        x1    <= x1 + 1;
        error <= error + signed(yincr);
     
      END IF;

    END IF;

    END IF;
    
  END PROCESS R1;

END ARCHITECTURE comb;
