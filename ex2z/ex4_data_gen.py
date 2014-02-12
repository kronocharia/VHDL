# runs under python2.7.exe
# simple program to generate data for testing draw-octant.
# input its list of (X,Y) points. Octant must be ENE, so that increments
# in x & y direction are both non-negative, with x >= y.
# output is an array of VHDL data for the testbench which contains input
# stimulus & correct x,y output values.

# String containing VHDL prefix characters
pack_header = """
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
"""
true = 1
false = 0

lines = 0

# main function which outputs data
def draw(fname, point_list):
    global first_line
    first_line = true
    with open(fname,'w') as fp: # fp will be output file
        fp.write(pack_header)
        (x,y,b)=(0,0,0) # first cycle reset outputs are don't care
        for ((xs,ys),(xin,yin),b) in point_list: # loop over all lines to draw, starting at (0,0)
            print 'loop',xs,ys,x,y
            (negx,negy,swapxy)=(0,0,0)
            incrx = xin - xs
            if incrx < 0:
                incrx = -incrx
                negx = 1
            incry = yin - ys
            if incry < 0:
                incry = -incry
                negy = 1
            if abs(incry) > abs(incrx):
                (incry,incrx) = (incrx,incry)
                swapxy = 1
            swaps = (swapxy,negx,negy)
            output(fp,'reset',x,y,0,xs,ys,swaps) # reset cycle
            (x,y)=(xs,ys)
            error = 0
            if (incrx < 0 or incry < 0 or incry > incrx):
                print ("Error - wrong octant", point_list,(xs,ys),(xin,yin))
                exit()
            output(fp, 'start',x,y,b,xin,yin,swaps) #cycle with draw = '1'
            if x != xin or y != yin:
                output(fp,'drawing',x,y,b,xin,yin, swaps) # cycle after this when x,y don't change
            (xn,yn) = (xin,yin)
            while (x,y) != (xn,yn): # loop outputting data for one line
                print 'swapping', incrx, incry,x,y
                (x,y,b)= doswaps(swaps,(x,y,b))
                print (x,y)
                errx = abs(error + incry)
                errdiag = abs(error+incry-incrx)
                print x,y,error, errx,errdiag
                if  (errx > errdiag) or ((errx == errdiag) and (b == 0)):
                    (x, y)=(x+1, y+1)
                    error = error - incrx + incry
                elif (errx < errdiag) or ((errx == errdiag) and (b == 1)):
                    x = x + 1
                    error = error + incry
                (x,y,b) = doswaps(swaps,(x,y,b))
                # this outputs the next cycle's pixel coordinates etc
                output(fp, 'done' if (x,y)==(xn,yn) else 'drawing',x,y,b,xn,yn,swaps)
        fp.write("\n\t);\nEND PACKAGE ex4_data_pak;\n")
    print fname,'created.'

def doswaps((swapxy,negx,negy), (x,y,b)):
    if swapxy:
        (x,y) = (y,x)
        b = 1-b
    if negx:
        x = -x
    if negy:
        y = -y
    return (x,y,b)



def output(fp, text,x,y,xbias,xn,yn,swaps):
    global lines
    if lines > 0:
        sep = ',\n\t\t' # subsequent lines use , as separator
    else:
        sep = '\n\t\t'  # first line no comma
    lines = lines + 1
    if lines > 500:
        print "Warning - early termination after", lines, "cycles output"
        exit()
    # output one clock cycle of simulus & output test data
    # see data_t_rec for meaning of parameters
    s = sep+str((text,x,y,xn,yn,xbias,swaps[0],swaps[1],swaps[2]))
    # @type s str
    fp.write(s.replace("'", '')) # changes python strings to HNDL enum type names


draw('ex4_data_pak.vhd',[ ((0,0),(1,2),0), ((2,3),(0,0),0), ((9,4),(5,3),1)])


