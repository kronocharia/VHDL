LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- please insert appropriate entity (see tb instance for port names)

ENTITY ram_fsm IS

    PORT(
            clk, reset, start: IN std_logic;
            delay,vwrite: OUT std_logic;

            addr, data: IN std_logic_vector;
            addr_del, data_del: OUT std_logic_vector
    );


ARCHITECTURE synth OF ram_fsm IS
  TYPE   state_t IS (m3, m2, m1, mx);       --possible states
  SIGNAL state, nstate : state_t;           --current state and next state
BEGIN

----------------implements the state transition matrix-------------------

    STATE_PROC:                  --combinatorial 
    PROCESS(state, start, reset) 
    BEGIN
        nstate <= state;         --default value same as current state
        
        IF reset = '1' THEN      --reset signal 
            nstate <= mx;
        END IF; 

        CASE state IS
            WHEN mx =>  IF start ='1' THEN nstate <= m1; END IF;
            WHEN m1 => nstate <= m2;    --unconditional transition
            WHEN m2 => nstate <= m3;    --unconditioanl transition
            WHEN m3 =>  IF start = '1' THEN 
                            nstate <= m1;
                        ELSIF start ='0' THEN
                            nstate <= mx;
        END CASE;
    END PROCESS STATE_PROC;
--------------------------------------------------------------------------
 
---------------------------state register---------------------------------
    SS_PROC:                    
    PROCESS
    BEGIN
        WAIT UNTIL clk'EVENT AND clk = '1'
            state <= nstate;

    END PROCESS SS_PROC;
--------------------------------------------------------------------------

------------------addr & data delay registers-----------------------------

    DELAY_PROC:
    PROCESS
    BEGIN
        WAIT UNTIL CLK'EVENT AND clk ='0'
            addr_del <= addr;
            data_del <= data;

    END PROCESS DELAY_PROC;

-------------------------- outputs ---------------------------------------
    
    vwrite <= m3;

    delay <= (m1 OR m2) AND start;



END ARCHITECTURE synth;

