LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;  -- add unsigned, signed
USE work.ALL;


ENTITY ram_fsm_wrapper is
PORT (
  clk, reset, start : IN  std_logic;
  delay, vwrite     : OUT std_logic;
  addr: IN std_logic_vector(7 DOWNTO 0);
  addr_del: OUT std_logic_vector(7 DOWNTO 0);
  data: IN std_logic_vector(3 DOWNTO 0);
  data_del: OUT std_logic_vector(3 DOWNTO 0)
  );

END ram_fsm_wrapper;



ARCHITECTURE wrapper OF ram_fsm_wrapper is

   
begin

   dut: ENTITY ram_fsm
      PORT MAP (
         clk => clk,
         reset=>reset,
         start => start,
         delay => delay,
         vwrite => vwrite,
         addr => addr,
         data => data,
         addr_del => addr_del,
         data_del => data_del
         );


   
END wrapper;


