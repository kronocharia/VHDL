
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.pix_cache_pak.ALL;
USE WORK.pix_tb_pak.ALL;

PACKAGE ex4_data_pak IS
    TYPE cyc IS (   reset,  -- reset = '1'
                    start,  -- draw = '1', xin,yin are driven from xin,yin
                    done,   -- done output = 1
                    drawing -- reset,start,done = '0', xin, yin are undefined
                );

    TYPE data_t_rec IS
    RECORD
        rst,wen_all,pw: INTEGER;
        pixop:  pixop_tb_t;
        pixnum: INTEGER;
        is_same: INTEGER;
        store: pixop_tb_vec(0 TO 15);
    END RECORD;

    TYPE data_t IS ARRAY (natural RANGE <>) OF data_t_rec;

    CONSTANT data: data_t :=(
--                 INPUTS              ||           OUTPUTS
--  rst    wen_all  pw   pixop pixnum      is_same   store

	(1,     0,     0,     ':',     0,     1, "::::::::::::::::"),
	(0,     0,     0,     '*',     0,     1, "::::::::::::::::"),
	(0,     0,     1,     'B',     3,     1, "::::::::::::::::"),
	(0,     0,     1,     'W',     4,     0, ":::B::::::::::::"),
	(0,     0,     1,     '*',     5,     0, ":::BW:::::::::::"),
	(0,     0,     0,     '*',     5,     0, ":::BW*::::::::::"),
	(0,     0,     1,     '*',     3,     0, ":::BW*::::::::::"),
	(0,     0,     1,     '*',     4,     0, ":::WW*::::::::::"),
	(0,     0,     1,     '*',     5,     0, ":::WB*::::::::::"),
	(0,     1,     1,     'B',     0,     0, ":::WB:::::::::::"),
	(0,     1,     0,     ':',     0,     0, "B:::::::::::::::"),
	(0,     0,     0,     ':',     0,     1, "::::::::::::::::"),
	(0,     0,     0,     ':',     0,     1, "::::::::::::::::"),
	(0,     1,     0,     '*',     0,     1, "::::::::::::::::")
	);
END PACKAGE ex4_data_pak;
