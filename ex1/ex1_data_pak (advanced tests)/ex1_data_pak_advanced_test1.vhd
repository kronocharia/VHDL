-- advanced test 1
-- draw line from (10,5) to (12,7)
-- test for case where xincr = yincr != 0

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

		(reset, 0, 0, 10, 5, 0),
		(start, 10, 5, 12, 7, 0),
		(drawing, 10, 5, 12, 7, 0),
		(drawing, 11, 6, 12, 7, 0),
		(done, 12, 7, 12, 7, 0)
	);
END PACKAGE ex1_data_pak;
