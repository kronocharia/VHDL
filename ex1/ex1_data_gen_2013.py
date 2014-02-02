# runs under python2.7.exe
# simple program to generate data for testing draw-octant.
# input its list of (X,Y) points. Octant must be ENE, so that increments
# in x & y direction are both non-negative, with x >= y.
# output is an array of VHDL data for the testbench which contains input
# stimulus & correct x,y output values.

# String containing VHDL prefix characters
pack_header = """
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
"""
true = 1
false = 0

# main function which outputs data
def draw(fname, point_list):
    global first_line
    first_line = true
    with open(fname,'w') as fp: # fp will be output file
        fp.write(pack_header)
        point_list = point_list[1:]
        (x,y,b)=(0,0,0) # first cycle reset outputs are don't care
        for ((xs,ys),(xin,yin),b) in point_list: # loop over all lines to draw, starting at (0,0)
            output(fp,'reset',x,y,0,xs,ys) # reset cycle
                      
            (x,y)=(xs,ys)
            error = 0
            incrx = xin - x
            incry = yin - y
			
            if (incrx == 0 and incry == 0):
                output(fp, 'done' ,xin,yin,b,xin,yin)
            else:
		
                if (incrx < 0 or incry < 0 or incry > incrx):
                    print ("Error - wrong octant", point_list,(xs,ys),(xin,yin))
                    exit()
                output(fp, 'start',x,y,b,xin,yin) #cycle with draw = '1'
                if x != xin or y != yin:
                    output(fp,'drawing',x,y,b,xin,yin) # cycle after this when x,y don't change
                (xn,yn) = (xin,yin)
                
                while (x,y) != (xn,yn): # loop outputting data for one line
                    errx = abs(error + incry)
                    errdiag = abs(error+incry-incrx)
                    if  (errx > errdiag) or ((errx == errdiag) and (b == 0)):
                        (x, y)=(x+1, y+1)
                        error = error - incrx + incry
                    elif (errx < errdiag) or ((errx == errdiag) and (b == 1)):
                        x = x + 1
                        error = error + incry
                    # this outputs the next cycle's pixel coordinates etc
                    output(fp, 'done' if (x,y)==(xn,yn) else 'drawing',x,y,b,xn,yn)                   
                    
                
        fp.write("\n\t);\nEND PACKAGE ex1_data_pak;\n")
    print fname,'created.'

def output(fp, text,x,y,xbias,xn,yn):
    global first_line
    if first_line == false:
        sep = ',\n\t\t' # subsequent lines use , as separator
    else:
        first_line = false
        sep = '\n\t\t'  # first line no comma
    # output one clock cycle of simulus & output test data
    # see data_t_rec for meaning of parameters
    s = sep+str((text,x,y,xn,yn,xbias))
    # @type s str
    fp.write(s.replace("'", '')) # changes python strings to HNDL enum type names


draw('ex1_data_pak.vhd',[ ((0,0),(1,2),0),       # can't be used, as yincr > xincr
                          ((2,3),(5,3),0),       # yincr = 0, xincr > yincr
                          ((5,3),(9,4),1),       # xincr > yincr
                          #((10,5),(12,7),0),     #1 xincr = yincr != 0
                          #((11,6),(11,6),0),     #2 xincr = yincr =0
                          #((0,0),(4095,0),0),    #3 maximum xincr
                          #((0,0),(4095,4095),0), #4 maximum xin,yin
                          #((0,0),(2048,2048),0), #5 test with 2048 = b1000,0000,0000 
                          #((0,0),(2048,0),0),    #6 
                          #((0,0),(2048,30),0),   #7
                          #((0,0),(4000,1),0),    # random test   
                          #((35,89),(3900,800),0) # random test
                          ])


