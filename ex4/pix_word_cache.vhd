
LIBRARY IEEE;
LIBRARY WORK;

USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;              
USE work.pix_cache_pak.ALL;

ENTITY pix_word_cache IS

    PORT(
        clk, wen_all, reset, pw  : IN std_logic;
        pixopin                 : IN pixop_t;
        pixnum                  : IN std_logic_vector(3 DOWNTO 0);

        store                   : OUT store_t;
        is_same                 : OUT std_logic
    );

END pix_word_cache;

ARCHITECTURE pwc of pix_word_cache IS

---------------Internal Wires--------------------

    SIGNAL din1, dout1      : pixop_t;
    SIGNAL store_ram        : store_t;

---------------Behavioural-------------------

    BEGIN

--------Combinatorial process handling change block in diagram
        Change: PROCESS(dout1, pixopin) 
        BEGIN
 
			IF pixopin = same THEN
				din1 <= dout1;

			ELSIF pixopin = black THEN
				din1 <= black;

			ELSIF pixopin = white THEN
				din1 <= white;

			ELSIF pixopin = invert THEN

				CASE dout1 IS
					WHEN same   => din1 <= invert;
					WHEN black  => din1 <= white;
					WHEN white  => din1 <= black;
					WHEN invert => din1 <= same;
					WHEN OTHERS => NULL;
						END CASE;
			ELSE
				null;
				
			END IF;


        END PROCESS Change;

--------Combinatorial ram read for pix_word_cache------------

        dout1 <= store_ram(to_integer(unsigned(pixnum))); --access ram location pixnum

--------Clocked ram write process for pix_word_cache-------------
        PWRITE: PROCESS
        BEGIN
            WAIT UNTIL clk'EVENT AND clk='1';

            -----wen_all or synch reset
            IF wen_all ='1' OR reset='1' THEN 
              store_ram <= (OTHERS => same);
            END IF;
            
            --if not a reset, verride the pixnum addr location if pw =1
            IF pw = '1' AND wen_all = '1' AND reset ='0' THEN 
              store_ram(to_integer(unsigned(pixnum))) <= pixopin;
            END IF;
            
            
            --if not a reset, single write 
            IF pw = '1' AND wen_all = '0' AND reset ='0' THEN 
              store_ram(to_integer(unsigned(pixnum))) <= din1;
            END IF;
            
        END PROCESS PWRITE;

--------Computing is_same output----------------------
        ALL_SAME: PROCESS(store_ram)
        BEGIN
            is_same <= '1'; --default case
            
            FOR i IN store_ram'RANGE LOOP   --if any of them arent, set to 0
                IF store_ram(i) /= same THEN 
                    is_same <= '0';
                END IF;
            END LOOP;

        END PROCESS ALL_SAME;


    store <= store_ram;  --write out to main memory

    END pwc;

