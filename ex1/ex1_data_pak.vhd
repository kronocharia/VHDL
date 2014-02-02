
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

		(reset, 0, 0, 2, 3, 0),
		(start, 2, 3, 5, 3, 0),
		(drawing, 2, 3, 5, 3, 0),
		(drawing, 3, 3, 5, 3, 0),
		(drawing, 4, 3, 5, 3, 0),
		(done, 5, 3, 5, 3, 0),
		(reset, 5, 3, 5, 3, 0),
		(start, 5, 3, 9, 4, 1),
		(drawing, 5, 3, 9, 4, 1),
		(drawing, 6, 3, 9, 4, 1),
		(drawing, 7, 3, 9, 4, 1),
		(drawing, 8, 4, 9, 4, 1),
		(done, 9, 4, 9, 4, 1)
	);
END PACKAGE ex1_data_pak;
