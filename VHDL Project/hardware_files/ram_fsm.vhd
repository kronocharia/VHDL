LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.pix_cache_pak.ALL;

-- please insert appropriate entity (see tb instance for port names)

ENTITY ram_fsm IS

    PORT(
            clk, reset, start: IN std_logic;
            delay,vwrite,done: OUT std_logic;

            addr : IN std_logic_vector;
            data : IN std_logic_vector(15 DOWNTO 0); --changedd from unbounded to hardcoded size
            cache_d : IN store_t;
            addr_del, data_del: OUT std_logic_vector
    );
END ram_fsm;

ARCHITECTURE synth OF ram_fsm IS
  TYPE   state_t IS (m3, m2, m1, mx);       --possible states
  SIGNAL state, nstate : state_t;           --current state and next state
  SIGNAL data_merged: std_logic_vector(15 DOWNTO 0);
BEGIN

----------------implements merge of cache changes and vram data---------

    MERGE_PROC:
    PROCESS(cache_d,data)
    BEGIN  
    FOR i IN cache_d'RANGE LOOP
        
        data_merged(i) <= data(i);
        
        --IF (TRUE) THEN
        CASE cache_d(i) IS
            WHEN same   => data_merged(i) <= data(i);
            WHEN white  => data_merged(i) <= '0';
            WHEN black  => data_merged(i) <= '1';
            WHEN invert => data_merged(i) <= NOT data(i);
            WHEN OTHERS => NULL;
        END CASE;
       -- END IF;
        
    END LOOP;
    END PROCESS MERGE_PROC;


------------------------------------------------------------------------

----------------implements the state transition matrix-------------------

    STATE_PROC:                  --combinatorial 
    PROCESS(state, start) 
    BEGIN
        nstate <= state;         --default value same as current state
        
       

		vwrite <='0';
		delay <='0';
		
        CASE state IS
            WHEN mx => 
                      	IF start ='1' THEN nstate <= m1; END IF;
            
            WHEN m1 => 
                       IF start ='1' THEN delay <='1'; END IF;
     					              nstate <= m2;    --unconditional transition
            
            WHEN m2 => 	
                        IF start ='1' THEN delay <='1'; END IF;
            			         nstate <= m3;    --unconditioanl transition
            
            WHEN m3 =>  vwrite <= '1'; 
            			IF start = '1' THEN 
                            nstate <= m1;
                        ELSIF start ='0' THEN
                           nstate <= mx; END IF;
                           --nstate <= m4; END IF;
            --WHEN m4 => nstate <=mx;              
        END CASE;
        
        
    END PROCESS STATE_PROC;
--------------------------------------------------------------------------
  DONE_SIGNAL: 
  PROCESS --(nstate)
  BEGIN
    WAIT UNTIL clk'EVENT AND clk = '1';
    --sets the done signal
        CASE nstate IS
            WHEN mx => done <= '1';
            WHEN m1 => done <= '1';
            WHEN m2 => done <= '0';
            WHEN m3 => done <= '0';
            --WHEN m4 => done <= '0';
        END CASE;
  END PROCESS DONE_SIGNAL;
---------------------------state register---------------------------------
    SS_PROC:                    
    PROCESS
    BEGIN
        WAIT UNTIL clk'EVENT AND clk = '1';
                        
            state <= nstate;
		IF reset = '1' THEN      --reset signal 
            state <= mx;
        END IF; 

    END PROCESS SS_PROC;
--------------------------------------------------------------------------

------------------addr & data delay registers-----------------------------

    DELAY_PROC:
    PROCESS
    BEGIN
        WAIT UNTIL CLK'EVENT AND clk ='0';
            addr_del <= addr;
            data_del <= data_merged;

    END PROCESS DELAY_PROC;




END ARCHITECTURE synth;
