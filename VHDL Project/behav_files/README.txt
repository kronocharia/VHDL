The entities in this directory are provides for testing purposes.

vdp_behav simulates a VDP, and can be used to test the testbench.

rcb_behav and db_behav can be used with your structural VDP 
(which should be written early on) to test each block separately 
from the other one. The missing block and be replaced by the 
behavioural equivalent here.

This allows each partner in a pair to test their own block before
the other block becomes available.