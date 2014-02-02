-- advanced test 2
-- draw line from (11,6) to (11,6)
-- test for case where xincr = yincr = 0

PACKAGE ex1_data_pak IS
    TYPE cyc IS (   reset,  -- reset = '1'
                    start,  -- draw = '1', xin,yin are driven from xin,yin
                    done,   -- done output = 1
                    drawing -- reset,start,done = '0', xin, yin are undefined
                );

    TYPE data_t_rec IS
    RECORD
        txt: cyc; --see above definition
        x,y: INTEGER;   -- x,y are pixel coordinate outputs
        xin,yin: INTEGER; -- xn,yn are inputs xin, yin (0-4095)
        xbias: INTEGER; -- input xbias (1 or 0)
    END RECORD;

    TYPE data_t IS ARRAY (natural RANGE <>) OF data_t_rec;

    CONSTANT data: data_t :=(

		(reset, 0, 0, 11, 6, 0),
		(done, 11, 6, 11, 6, 0)
	);
END PACKAGE ex1_data_pak;
