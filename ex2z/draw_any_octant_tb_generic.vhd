LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;               -- add unsigned, signed
USE work.ALL;
USE work.ex4_data_pak.ALL;

ENTITY draw_any_octant_tb IS
END draw_any_octant_tb;

ARCHITECTURE behav OF draw_any_octant_tb IS
	CONSTANT vsize : NATURAL := 12;

	SIGNAL clk_gen, clk, resetx_i   : std_logic;
	SIGNAL draw_i, xbias_i          : std_logic;
	SIGNAL done_i                   : std_logic;
	SIGNAL disable_i                : std_logic;
	SIGNAL xin_i, yin_i, x_i, y_i   : std_logic_vector(vsize - 1 DOWNTO 0);
	SIGNAL f_i                      : std_logic_vector(2 DOWNTO 0);
	SIGNAL z_i                      : std_logic_vector(15 DOWNTO 0);
	SIGNAL swapxy_i, negx_i, negy_i : std_logic;
	SIGNAL counter                  : integer;
	SIGNAL result                   : std_logic_vector(15 DOWNTO 0);
	SIGNAL result1                  : integer;

	FUNCTION to_sl(i : integer RANGE 0 TO 1) RETURN std_logic IS
		VARIABLE r : std_logic;
	BEGIN
		CASE i IS
			WHEN 0 => r := '0';
			WHEN 1 => r := '1';
		END CASE;
		RETURN r;
	END FUNCTION to_sl;

BEGIN
	dut : ENTITY draw_any_octant
		GENERIC MAP(vsize)
		PORT MAP(
			clk     => clk,
			resetx  => resetx_i,
			draw    => draw_i,
			done    => done_i,
			x       => x_i,
			y       => y_i,
			xin     => xin_i,
			yin     => yin_i,
			xbias   => xbias_i,
			swapxy  => swapxy_i,
			negx    => negx_i,
			negy    => negy_i,
			disable => disable_i);

	p1_clkgen : PROCESS
	BEGIN
		clk_gen <= '0';
		clk     <= '0';
		WAIT FOR 50 ns;
		clk_gen <= '1';
		clk     <= '1';
		IF disable_i = '1' THEN
			clk <= '0';
		END IF;
		WAIT FOR 50 ns;
	END PROCESS p1_clkgen;

	--for disable_i, count clock cycles
	p_count : PROCESS
	BEGIN
		WAIT UNTIL clk_gen'event AND clk_gen = '1';
		counter <= counter + 1;
	END PROCESS p_count;

	--mannually set which clock cycle you want disable_i to be high
	P_disable : PROCESS(counter)
	BEGIN
		disable_i <= '0';
		IF counter = 3 OR counter = 4 OR counter = 5 THEN
			disable_i <= '1';
		END IF;
	END PROCESS p_disable;

	p3_test : PROCESS
		VARIABLE xx, yy, dd, ddver : integer;
		VARIABLE rep               : string(1 TO 4);
		VARIABLE bad               : boolean;
		VARIABLE str               : string(1 TO 10);

	BEGIN
		-- set up known inputs for first cycle to reduce TB 'X' warnings
		resetx_i <= '1';
		draw_i   <= '0';
		xin_i    <= (OTHERS => '0');
		yin_i    <= (OTHERS => '0');

		WAIT UNTIL clk'event AND clk = '1'; -- reset everything
		WAIT UNTIL clk'event AND clk = '1'; -- another cycle to be safe.
		FOR n IN data'range LOOP
			resetx_i <= '0';
			draw_i   <= '0';
			xin_i    <= (OTHERS => 'X');
			yin_i    <= (OTHERS => 'X');
			CASE data(n).txt IS
				WHEN reset => resetx_i <= '1';
					str              := "startpoint";
				WHEN start => draw_i <= '1';
					str              := " endpoint ";
				WHEN OTHERS => NULL;
			END CASE;
			REPORT "Starting cycle :" & integer'image(n);
			IF data(n).txt = start OR data(n).txt = reset THEN
				xin_i <= std_logic_vector(to_unsigned(data(n).xin, vsize));
				yin_i <= std_logic_vector(to_unsigned(data(n).yin, vsize));
				REPORT "Drawing line through " & str & " (" & integer'image(data(n).xin) & "," & integer'image(data(n).yin) & ")";
			END IF;
			xbias_i  <= to_sl(data(n).xbias);
			swapxy_i <= to_sl(data(n).swapxy);
			negx_i   <= to_sl(data(n).negx);
			negy_i   <= to_sl(data(n).negy);
			WAIT UNTIL clk'event AND clk = '1';
			xx    := to_integer(unsigned(x_i));
			yy    := to_integer(unsigned(y_i));
			dd    := 0;
			ddver := 0;
			IF done_i = '1' THEN
				dd := 1;
			END IF;
			IF data(n).txt = done THEN
				ddver := 1;
			END IF;

			bad := (dd /= ddver) OR (xx /= data(n).x) OR (yy /= data(n).y);
			IF NOT bad THEN
				REPORT "Cycle " & integer'image(n) & " (" & cyc'image(data(n).txt) & ") " & ". X=" & integer'image(xx) & ", Y=" & integer'image(yy) & ", DONE=" & integer'image(dd) & " OK!";
			ELSE
				REPORT "Cycle " & integer'image(n) & " (" & cyc'image(data(n).txt) & ") " & ". X=" & integer'image(xx) & ", Y=" & integer'image(yy) & ", DONE=" & integer'image(dd) & "   +BAD++++++Wanted X=" & integer'image(data(n).x) & ". Y=" & integer'image(data(n).y) & ", DONE=" &
				integer'image(ddver) SEVERITY failure;
			END IF;

		END LOOP;                       -- n

		-- only way to stop Modelsim at end is using a failure assert
		-- this leads to a 'failure' message when everything is OK.
		--
		REPORT "All tests finished OK, terminating with failure ASSERT." SEVERITY failure;

	END PROCESS p3_test;

END behav;


