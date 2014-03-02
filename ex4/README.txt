Testbench for pix_word_cache

Compile together:
pix_cache_pak
pix_word_cache (you must write this file, entity & architecture for ex4)
pix_tb_pak
ex4_data_pak OR ex4_data_pak_rand1000
pix_word_cache_tb

Note that the rand1000 package contains 1000 cycles of random sample stimulus, the ex4_data_pak contains a small number of a hoc tests for initial debugging.

Note that you can generate your own random sample tests from 
ex4_data4_pak_gen.py
This will run under python 2.7
The last few lines write out packages to given files, should be easy to modify
rand_stim creates the random samples - you can alter probabilities etc.

