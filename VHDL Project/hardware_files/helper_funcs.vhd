---------------------------------------------------------------------------------------------------
--------------------------------functions package-----------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.project_pack.ALL;
USE WORK.pix_cache_pak.ALL;
USE WORK.config_pack.ALL;

PACKAGE helper_funcs IS
    FUNCTION getRamWord(x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector;
    FUNCTION getRamBit( x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector;
END;


PACKAGE BODY helper_funcs IS
	
    -- return the RamWord address as a 8 bit vector
    FUNCTION getRamWord( x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector IS
      
      VARIABLE xVal, yVal       : integer;
      VARIABLE wordAddress      : std_logic_vector(7 DOWNTO 0);
    BEGIN
        
        xVal := to_integer(unsigned(x(VSIZE-1 DOWNTO 2)));
        yVal := to_integer(unsigned(y(VSIZE-1 DOWNTO 2)));

        wordAddress := std_logic_vector(to_unsigned(xVal+ 16*yVal,8));

        RETURN wordAddress;
    END;

    -- return the ramBit addr as a 4bit address vector
    FUNCTION getRamBit(  x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector IS
      
      VARIABLE xVal, yVal   : integer;
      VARIABLE bitAddress   : std_logic_vector(3 DOWNTO 0);

    BEGIN
        
        xVal := to_integer(unsigned(x(1 DOWNTO 0)));
        yVal := to_integer(unsigned(y(1 DOWNTO 0)));

        bitAddress := std_logic_vector(to_unsigned(xVal + 4*yVal,4));

        RETURN bitAddress;
    END;

END helper_funcs;
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------