
LIBRARY IEEE;
LIBRARY WORK;

USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;              
USE work.pix_cache_pak.ALL;

ENTITY pix_word_cache IS

    PORT(
        clk, wen_all, reset pw  : IN std_logic;
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
    SIGNAL wen_all, wen1    : std_logic;
    SIGNAL addr1            : std_logic_vector(3 DOWNTO 0);


---------------Behavioural-------------------

    BEGIN

--------Combinatorial process handling change block in diagram
        Change: PROCESS(wen_all, dout1, pixopin) 
        BEGIN
            IF wen_all = '0' THEN
                
                IF pixopin = same THEN
                    din1 <= dout1;
                END IF;

                IF pixopin = black THEN
                    din1 <= black;
                END IF;

                IF pixopin = white THEN
                    din1 <= white;
                END IF;

                IF pixopin = invert THEN

                    CASE dout1 IS
                        WHEN same   => din1 <= invert;
                        WHEN black  => din1 <= white;
                        WHEN white  => din1 <= black;
                        WHEN invert => din1 <= same;
                        WHEN OTHERS => NULL;
                    END CASE;
                END IF;
            END IF;

        END PROCESS Change;

--------Combinatorial ram read process for pix_word_cache------------
        PREAD: PROCESS(pixnum,store_ram)
        BEGIN
            dout1 <= store_ram(to_integer(unsigned(pixnum))); -- access ram location pixnum
        END PROCESS PREAD;


--------Clocked ram write process for pix_word_cache-------------
        PWRITE: PROCESS
        BEGIN
            WAIT UNTIL clk'EVENT AND clk='1';
            
            IF wen_all ='1' THEN
                store_ram <= (OTHERS => same);
            END IF;

            IF pw = '1' THEN
                store_ram(to_integer(unsigned(pixnum))) <= pixopin;
            END IF;

            IF reset = '1' THEN --synchr reset
                store_ram <= (OTHERS => same);
            END IF;

        END PROCESS PWRITE;

--------Computing is_same output----------------------
        ALL_SAME: PROCESS(store_ram)
        BEGIN
            is_same = '1'; --default case
            
            FOR i IN store_ram'RANGE LOOP   --if any of them arent, set to 0
                IF store_ram(i) /= same THEN 
                    is_same <= '0';
                END IF;
            END LOOP;

        END PROCESS ALL_SAME;


    store <= store_ram;  --write out to main memory

    END pwc;


