
PACKAGE ex4_data_pak IS
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
        swapxy,negx,negy: INTEGER; -- swap inputs for octant
    END RECORD;

    TYPE data_t IS ARRAY (natural RANGE <>) OF data_t_rec;

    CONSTANT data: data_t :=(

		(reset, 0, 0, 0, 0, 0, 1, 0, 0),
		(start, 0, 0, 1, 2, 0, 1, 0, 0),
		(drawing, 0, 0, 1, 2, 0, 1, 0, 0),
		(drawing, 0, 1, 1, 2, 0, 1, 0, 0),
		(done, 1, 2, 1, 2, 0, 1, 0, 0),
		(reset, 1, 2, 2, 3, 0, 1, 1, 1),
		(start, 2, 3, 0, 0, 0, 1, 1, 1),
		(drawing, 2, 3, 0, 0, 0, 1, 1, 1),
		(drawing, 1, 2, 0, 0, 0, 1, 1, 1),
		(drawing, 1, 1, 0, 0, 0, 1, 1, 1),
		(done, 0, 0, 0, 0, 0, 1, 1, 1),
		(reset, 0, 0, 9, 4, 0, 0, 1, 1),
		(start, 9, 4, 5, 3, 1, 0, 1, 1),
		(drawing, 9, 4, 5, 3, 1, 0, 1, 1),
		(drawing, 8, 4, 5, 3, 1, 0, 1, 1),
		(drawing, 7, 4, 5, 3, 1, 0, 1, 1),
		(drawing, 6, 3, 5, 3, 1, 0, 1, 1),
		(done, 5, 3, 5, 3, 1, 0, 1, 1)
	);
END PACKAGE ex4_data_pak;
