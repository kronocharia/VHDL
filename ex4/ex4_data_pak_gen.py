# runs under python2.7.exe
# simple program to generate data for testing pixel_word_cache.
# input its list of (X,Y) points. Quadrant must be NE, so that increments
# in x & y direction are both non-negative.
# output is an array of VHDL data for the testbench which contains input
# stimulus & correct x,y output values.

# String containing VHDL prefix characters

import random

package_name = "ex4_data_pak"

package_uses = """
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.pix_cache_pak.ALL;
USE WORK.pix_tb_pak.ALL;

"""

pack_header = package_uses+"PACKAGE " + package_name + """ IS
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
"""
true = 1
false = 0

# main function which outputs data
def generate(fname, stimulus):
    global first_line
    first_line = true
    with open(fname,'w') as fp: # fp will be output file
        fp.write(pack_header)
        store = [':']*16
        for dat in stimulus: # loop once per cycle
            (rst,wen_all,pw,pixopin,pixnum) = dat
            lim = (1,1,1,['W','B','*',':'],15)
            check_dat(dat,lim)
            is_same = 1 if store == [':']*16 else 0
            print(dat, is_same)
            # output dat inputs, comb outputs, and old clocked outputs
            output(fp, dat, store, is_same)
            # change clocked outputs
            if rst or wen_all:
                store = [':']*16
            if pw and not rst:
                store[pixnum]=pix_change(pixopin,store[pixnum])
        fp.write("\n\t);\nEND PACKAGE "+package_name+";\n")
    print package_name, 'written to file', fname, '.'

def output(fp, dat, store, is_same):
    global first_line
    if first_line == false:
        sep = ',\n\t' # subsequent lines use , as separator
    else:
        first_line = false
        sep = '\n\t'  # first line no comma
    # output one clock cycle of simulus & output test data
    # see data_t_rec for meaning of parameters
    dat = dat+(is_same,)
    s = sep+str(dat).replace(",",",    ")
    #print store
    #print ''.join(store)
    s = s[:-1]+', '+repr(''.join(store)).replace("'",'"')+')'
    #print s
    fp.write(s)

def pix_change(pix,old):
    invert = {':':'*','W':'B','B':'W','*':':'}
    if pix == ':' : return old
    elif pix == '*' : return invert[old]
    elif pix == 'W': return 'W'
    elif pix == 'B': return 'B'
    else: exit()

def check_dat(dat,lim):
    for i in range(len(dat)):
        n = lim[i]
        if type(n) is type(int()):
            if dat[i] > n or dat[i] < 0:
                print('Bad data record, dat[' + str(i)+']='+str(dat[i])+
                    ', value should be in range 0 to', n)
                print 'dat=',dat
                exit()
        elif type(n) is type(list()):
            if dat[i] not in n:
                print('Bad data record, dat[' + str(i)+']='+str(dat[i])+
                    ', value should be one of', n)
                print 'dat=',dat
                exit()


def rand_stim(n):
    def rp(x): return (1 if  random.random() < x else 0)
    r4 = lambda: random.randrange(4)
    r16 = lambda: random.randrange(16)
    ret = [(1,0,0,':',0)]
    for x in range(n):
        ret.append((rp(0.01), rp(0.1),rp(0.5),':*BW'[r4()], r16()))
    return ret

#(rst,wen_all,pw,pixopin,pixnum)
stim =[
        (1, 0, 0, ':',  0),
        (0, 0, 0, '*',  0),
        (0, 0, 1, 'B',  3),
        (0, 0, 1, 'W',  4),
        (0, 0, 1, '*',  5),
        (0, 0, 0, '*',  5),
        (0, 0, 1, '*',  3),
        (0, 0, 1, '*',  4),
        (0, 0, 1, '*',  5),
        (0, 1, 1, 'B',  0),
        (0, 1, 0, ':',  0),
        (0, 0, 0, ':',  0),
        (0, 0, 0, ':',  0),
        (0, 1, 0, '*',  0)
]
print rand_stim(100)

generate('c:\\test-msim\\ex4\\ex4_data_pak.vhd',stim)
generate('c:\\test-msim\\ex4\\ex4_data_pak_rand2000.vhd',rand_stim(2000))


