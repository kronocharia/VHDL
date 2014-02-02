LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;               -- add unsigned, signed
USE work.ALL;
USE work.ex1_data_pak.ALL;

ENTITY draw_octant_tb IS
END draw_octant_tb;

ARCHITECTURE behav OF draw_octant_tb IS
	SIGNAL clk_gen, clk, reset_i  : std_logic;
	SIGNAL draw_i, xbias_i        : std_logic;
	SIGNAL done_i                 : std_logic;
	SIGNAL disable_i              : std_logic;
	SIGNAL xin_i, yin_i, x_i, y_i : std_logic_vector(11 DOWNTO 0);
	SIGNAL f_i                    : std_logic_vector(2 DOWNTO 0);
	SIGNAL z_i                    : std_logic_vector(15 DOWNTO 0);

	SIGNAL counter : integer := 0;

	SIGNAL result  : std_logic_vector(15 DOWNTO 0);
	SIGNAL result1 : integer;

BEGIN
	dut : ENTITY draw_octant
		PORT MAP(
			clk     => clk_gen,
			resetx  => reset_i,
			draw    => draw_i,
			done    => done_i,
			x       => x_i,
			y       => y_i,
			xin     => xin_i,
			yin     => yin_i,
			xbias   => xbias_i,
			disable => disable_i);

	p1_clkgen : PROCESS
	BEGIN
		clk_gen <= '0';
		clk     <= '0';
		WAIT FOR 50 ns;
		clk_gen <= '1';
		clk     <= '1';
		-- when disable is high freeze testbench and do not check anything
		-- this correctly matches the DUT which should be frozen when disable is high
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

	BEGIN
		WAIT UNTIL clk'event AND clk = '1';
		FOR n IN data'range LOOP
			reset_i <= '0';
			draw_i  <= '0';
			xin_i   <= (OTHERS => 'X');
			yin_i   <= (OTHERS => 'X');
			CASE data(n).txt IS
				WHEN reset  => reset_i <= '1';
				WHEN start  => draw_i <= '1';
				WHEN OTHERS => NULL;
			END CASE;
			IF data(n).txt = reset THEN
				xin_i <= std_logic_vector(to_unsigned(data(n).xin, 12));
				yin_i <= std_logic_vector(to_unsigned(data(n).yin, 12));
				REPORT "Drawing line from (" & integer'image(data(n).xin) & "," & integer'image(data(n).yin) & ")";

			ELSIF data(n).txt = start THEN
				xin_i <= std_logic_vector(to_unsigned(data(n).xin, 12));
				yin_i <= std_logic_vector(to_unsigned(data(n).yin, 12));
				REPORT "Drawing line to (" & integer'image(data(n).xin) & "," & integer'image(data(n).yin) & ")";
				CASE data(n).xbias IS
					WHEN 1 => xbias_i <= '1';
						REPORT "xbias = 1";
					WHEN OTHERS => xbias_i <= '0';
						REPORT "xbias = 0";
				END CASE;
			END IF;

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
			rep := " OK!";
			IF (dd /= ddver OR xx /= data(n).x OR yy /= data(n).y) AND n /= 0 THEN
				rep := " BAD";
				REPORT "Wanted X=" & integer'image(data(n).x) & ". Y=" & integer'image(data(n).y) & ", DONE=" & integer'image(ddver) SEVERITY failure;
			END IF;

			REPORT "Cycle " & integer'image(n) & "  " & cyc'image(data(n).txt) & ". X=" & integer'image(xx) & ", Y=" & integer'image(yy) & ", DONE=" & integer'image(dd) & rep;

		END LOOP;                       -- n

		-- only way to stop Modelsim at end is using a failure assert
		-- this leads to a 'failure' message when everything is OK.
		--
		REPORT "All tests finished OK, terminating with failure ASSERT." SEVERITY failure;

	END PROCESS p3_test;

END behav;
