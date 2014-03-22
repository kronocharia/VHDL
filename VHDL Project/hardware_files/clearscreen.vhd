library ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY clearscreen IS
  GENERIC(vsize: INTEGER := 6);
  PORT(
    clk, reset, draw, disable : IN  std_logic;
    xstart, ystart, xend, yend: IN  std_logic_vector(vsize-1 DOWNTO 0);
    done                      : OUT std_logic;
    xout, yout                : OUT std_logic_vector(vsize-1 DOWNTO 0)
    );
END ENTITY clearscreen;

architecture arch of clearscreen is
  signal currx, curry, nextx, nexty : std_logic_vector(vsize-1 downto 0);
begin
  next_pixel: process(currx, curry, xstart, xend, yend)
    variable xin, yin, xlo, xhi, yhi, v_nextx, v_nexty: integer;
  begin
    xin := to_integer(unsigned(currx)); 
    yin := to_integer(unsigned(curry));
    xlo := to_integer(unsigned(xstart));
    xhi := to_integer(unsigned(xend)); 
    yhi := to_integer(unsigned(yend));
    if xin + 1 <= xhi then
      v_nextx := xin + 1;
      v_nexty := yin;
      done <= '0';
    elsif yin + 1 <= yhi then
      v_nextx := xlo;
      v_nexty := yin + 1;
      done <= '0';
    else
      v_nextx := 0;
      v_nexty := 0;
      done <= '1';
    end if;
    nextx <= std_logic_vector(to_unsigned(v_nextx, vsize));
    nexty <= std_logic_vector(to_unsigned(v_nexty, vsize));
  end process next_pixel;
  
  clock_outputs: process
  begin
    wait until clk'event and clk = '1';
    if reset = '1' then
      currx <= std_logic_vector(to_unsigned(0, vsize));
      curry <= std_logic_vector(to_unsigned(0, vsize));
    elsif disable = '1' then
      null;
    elsif draw = '1' then
      currx <= xstart;
      curry <= ystart;
    else
      currx <= nextx;
      curry <= nexty;
    end if;
  end process clock_outputs;
  
  xout <= currx;
  yout <= curry;
end architecture arch;