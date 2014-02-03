LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY draw_octant IS
  PORT(
    clk, resetx, draw, xbias,disable : IN  std_logic;
    xin, yin                 		 : IN  std_logic_vector(11 DOWNTO 0);
    done                       	     : OUT std_logic;
    x, y                  		     : OUT std_logic_vector(11 DOWNTO 0)
    );
END ENTITY draw_octant;

ARCHITECTURE comb OF draw_octant IS

  SIGNAL done1                    : std_logic;
  SIGNAL x1, y1                   : std_logic_vector(11 DOWNTO 0);
  SIGNAL xincr, yincr, xnew, ynew : std_logic_vector(11 DOWNTO 0);
  SIGNAL error                    : std_logic_vector(11 DOWNTO 0);
  SIGNAL err1, err2               : std_logic_vector(12 DOWNTO 0);

  ALIAS slv IS std_logic_vector;
  ALIAS usg  IS unsigned;
  ALIAS sgn IS signed;

BEGIN



  C1 : PROCESS(error, xincr, yincr, x1, y1, xnew, ynew, resetx, draw)

    VARIABLE err1_v, err2_v : std_logic_vector(12 DOWNTO 0);
    
  BEGIN
	--New Code Start
	
	
	--err1_v := slv(resize(sgn(error),13) + resize(sgn(yincr),13)); --Cast to signed and bit extend and back to slv
	
	err1_v := slv(sgn(resize(usg(error),13)) + sgn(resize(usg(yincr),13)));
	
	IF sgn(err1_v) < 0 THEN				--To create the absolute value
		--err1_v := slv(-1*sgn(err1_v));
		err1_v := slv(usg(NOT(err1_v))+"0000000000001"); --2's comp flip add1
	END IF;
	
	--err2_v := slv(resize(sgn(error),13) + resize(sgn(yincr),13) - resize(sgn(xincr),13)); --Cast to signed and bit extend
	err2_v := slv(sgn(resize(usg(error),13)) + sgn(resize(usg(yincr),13)) - sgn(resize(usg(xincr),13)));
	
	IF sgn(err2_v) < 0 THEN				-- To create absolute value
		--err2_v := -1*err2_v;
		err2_v := slv(usg(NOT(err2_v))+"0000000000001"); --2's complement flip add 1
	END IF;
	
	IF 	x1 = xnew AND
		y1 = ynew AND
		resetx = '0' AND
		draw = '0'THEN
			done1 <= '1';
			
	ELSE done1 <= '0';
	END IF;
	
	err1 <= err1_v;
	err2 <= err2_v;

		
	--New code end
  END PROCESS C1; 
	

  R1 : PROCESS
  BEGIN
  	--New code start
  	WAIT UNTIL clk'EVENT AND clk='1';

	-- Conditional assignment based on truth table inputs
  	IF 	disable = '0' AND
  		resetx = '1' THEN

  			error <= "000000000000";
  			x1 <= xin;
  			y1 <= yin;
  			xincr <= "000000000000";
  			yincr <= "000000000000";
  			xnew <= xin;
  			ynew <= yin;
  	END IF;   

  	IF 	disable = '0' AND
  		resetx = '0' AND
  		draw = '1' THEN

  			error <= "000000000000";
  			--x1 <= x1;
  			--y1 <= y1;
  			xincr <= slv(usg(xin) - usg(x1));
  			yincr <= slv(usg(yin) - usg(y1));
  			xnew <= xin;
  			ynew <= yin;
 	END IF; 
 	
 	IF 	disable = '0' AND
 		usg(err1) > usg(err2) AND
 		resetx = '0' AND
 		draw = '0' AND
 		done1 = '0' THEN
 		
 			error <= slv(sgn(error) + sgn(yincr) - sgn(xincr));
  			x1 <= slv(usg(x1) + "000000000001");
  			y1 <= slv(usg(y1) + "000000000001");
  	END IF;
  	
  	IF 	disable = '0' AND
 		usg(err1) < usg(err2) AND
 		resetx = '0' AND
 		draw = '0' AND
 		done1 = '0' THEN
 		
 			error <= slv(sgn(error) + sgn(yincr));
  			x1 <= slv(usg(x1) + "000000000001");
  			--y1 <= y1;
  	END IF;
  	
  	IF 	disable = '0' AND
 		usg(err1) = usg(err2) AND
 		xbias = '1' AND
 		resetx = '0' AND
 		draw = '0' AND
 		done1 = '0' THEN
 		 		
 			error <= slv(sgn(error) + sgn(yincr));
  			x1 <= slv(usg(x1) + "000000000001");
  			--y1 <= y1;
  	END IF;
  	
  	IF 	disable = '0' AND
 		usg(err1) = usg(err2) AND
 		xbias = '0' AND
 		resetx = '0' AND
 		draw = '0' AND
 		done1 = '0' THEN
 		
 			error <= slv( sgn(error) + sgn(yincr) - sgn(xincr));
  			x1 <= slv( usg(x1) + "000000000001");
  			y1 <= slv( usg(y1) + "000000000001");
  	END IF;
  	
  	
--  	IF 	disable = '0' AND
-- 		resetx = '0' AND
-- 		draw = '0' AND
-- 		done1 = '1' THEN
--
--  	END IF;
--	
--	IF 	disable = '1' THEN
--
--  	END IF;
	
  
  END PROCESS R1;

  	-- Assign Outputs
  	done <= done1;
  	x <= x1;
  	y <= y1;
  	
 END ARCHITECTURE comb;

