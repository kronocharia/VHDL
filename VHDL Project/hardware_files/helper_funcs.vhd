---------------------------------------------------------------------------------------------------
--------------------------------functions package-----------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.project_pack.ALL;

PACKAGE helper_funcs IS
    FUNCTION getRamWord(x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic;
    FUNCTION getRamBit( x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic;
END;


PACKAGE BODY helper_funcs IS

    -- return the RamWord address as a 8 bit vector
    FUNCTION getRamWord( x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector IS
      
      VARIABLE xVal, yVal       : integer;
      VARIABLE wordAddress      : std_logic_vector(7 DOWNTO 0);
    BEGIN
        
        xVal := to_integer(x(VSIZE-1 DOWNTO 2));
        yVal := to_integer(y(VSIZE-1 DOWNTO 2));

        wordAddress := to_unsigned(xVal+ 16*yVal);

        RETURN wordAddress;
    END;

    -- return the ramBit addr as a 4bit address vector
    FUNCTION getRamBit(  x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector IS
      
      VARIABLE xVal, yVal   : integer
      VARIABLE bitAddress   : std_logic_vector(3 DOWNTO 0)

    BEGIN
        
        xVal := to_integer(x(1 DOWNTO 0));
        yVal := to_integer(y(1 DOWNTO 0));

        wordAddress := to_unsigned(xVal + 4*yVal);

        RETURN bitAddress;
    END;

END helper_funcs;
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------