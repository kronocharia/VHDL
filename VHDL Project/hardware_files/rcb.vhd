LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.project_pack.ALL;
USE WORK.pix_cache_pak.ALL;
USE WORK.helper_funcs.ALL;
USE WORK.ram_fsm;
USE WORK.pix_word_cache;

ENTITY rcb IS
	GENERIC(	vsize : INTEGER := 6;
			 	N: INTEGER := 10);
	PORT(
		clk          : IN  std_logic;
		reset        : IN  std_logic;

		-- db connections
		dbb_bus      : IN db_2_rcb;   --this is what jake sends me
		dbb_delaycmd : OUT STD_LOGIC;
		dbb_rcbclear : OUT STD_LOGIC;

		-- vram connections
		vdout        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		vdin         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		vwrite       : OUT STD_LOGIC;
		vaddr        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

		-- vdp connection
		rcb_finish   : OUT STD_LOGIC
	);
END rcb;

--id probably need to decode all the rcb commands


ARCHITECTURE rtl1 OF rcb IS
---------------Internal Wires--------------------


--For interfacing with ram block
    SIGNAL ram_start, ram_delay, ram_vwrite						: std_logic;
    SIGNAL ram_addr, ram_addr_del								: std_logic_vector(7 DOWNTO 0);
    SIGNAL ram_data, ram_data_del								: std_logic_vector(15 DOWNTO 0);

--For interfacing with pixel cache
	SIGNAL pxcache_wen_all, pxcache_reset, pxcache_pw 			: std_logic;
	SIGNAL pxcache_is_same										: std_logic;
	SIGNAL pxcache_pixopin 										: pixop_t;
	SIGNAL pxcache_pixnum										: std_logic_vector(3 DOWNTO 0);
	SIGNAL pxcache_store										: store_t;

--
--VSIZE is 6 ish...


--RCB state machine signals
	TYPE state_type IS (s_error,s_idle, s_draw, s_clear);
	SIGNAL state, next_state									: state_type;
	SIGNAL idle_write,draw_flag,move_flag						: std_logic;

--draw_px process signals
	SIGNAL vram_waddr,curr_vram_word							: std_logic_vector(7 DOWNTO 0);
	SIGNAL change_curr_word										: std_logic;

BEGIN

--get new command
--if start cmd then... otherwise loop and wait for start
--after n waits, write cache to memory

--check if in cache range

--if ( curr_vram_word != getRamWord(dbb_bus.X, dbb_bus.Y) ) THEN
	--flush current contents into memory
		--pass curr_vram word to vaddr
		--pass current cache content to vdin
		--make vwrite high

	--pull new word from memory to cache
		--getRamWord(dbb...) to vaddr
		--vdout to pxcache
		--read

--feed in the addr to write to the cache
--pxcache_pixnum <= getRamBit(dbb_bus.X, dbb_bus.Y);

--write the new location as required
--if draw, then single pixel
--if clear then a massive square paint from current pen loc to specified location



---------------------state transition matrix----------------------- 

	state_transition: PROCESS(state, dbb_bus.startcmd)	--combinatorial
	VARIABLE idleCounter : INTEGER := 0; --idling loop counter to flush cache
	
	BEGIN

	
		next_state <= state; 	--default to current state

		--default output conditions
		idle_Write <= '0';

		--transitions
		CASE state IS
			WHEN s_idle => 	IF (dbb_bus.startcmd) THEN 
								--instruction decode
								
								-- RCB CMD
								-- 000 move
								-- 001 draw white			'-01' if white
								-- 010 draw black			'-10' if black
								-- 011 draw invert			'-11' if invert
								-- 100 unused				'0--' if draw
								-- 101 clear white			'1--' if clear
								-- 110 clear black			'000' if move
								-- 111 clear invert			

								IF (dbb_bus.rcb_cmd(2) = '0') THEN --draw command issued (or move)
									next_state <= s_draw;
								
								ELSIF (dbb_bus.rcb_cmd(2) = '1') THEN --clear command issued
									next_state <= s_clear;

								ELSE
									next_state <= s_error;
									
								END IF;

							ELSIF (idleCounter = N) THEN
								idle_write <= '1';
								--writeout the cache
								--probably no change so can use same?
								--set wen_all to 1
								--set pw to 0
								next_state <= s_idle;
							

							ELSIF (dbb_bus.startcmd ='0') THEN
								--increment loop counter
								idleCounter := idleCounter + 1;
								next_state <= s_idle;

							ELSE 
								next_state <= s_error;

							END IF;

			WHEN s_draw =>  IF (dbb_bus.rcb_cmd = "000") THEN
								move_flag <='1';
						    ELSE
						    	draw_flag <='1'; 	
							END IF;

							IF (draw_flag='1') THEN   --while drawing stay in draw state
								next_state <= s_draw;

							ELSIF (draw_flag='0') THEN --if finished draw go to idle state
								next_state <= s_idle;
							
							ELSE
								next_state <= s_error;
							END IF;


			
			WHEN s_clear => next_state <=s_idle; --to be implemented later

			WHEN s_error => next_state <= s_error; --reset moves state to idle

		END CASE;
	END PROCESS state_transition;
--------------------------------------------------------------------------
----------------------------state register--------------------------------
	state_reg: PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT AND clk = '1';
			state <= next_state;
		IF reset = '1' THEN
			state <= s_idle;
		END IF;
	END PROCESS state_reg;
-----------------------------------------------------------------------

-------register storing current word to detect if out of range--------------
	current_word_register: PROCESS 
	BEGIN
		WAIT UNTIL clk'EVENT AND clk ='1';
		IF (change_curr_word='1') THEN --enable for register
			curr_vram_word <= vram_waddr; --join this to one of the addresses
		END IF;
	END PROCESS current_word_register;		
------------------------------------------------------------------------------

	draw_px: PROCESS(state, draw_flag, move_flag)
	BEGIN
		pxcache_pw <='1';	--enable the px cache
		vram_waddr <= getRamWord(dbb_bus.X, dbb_bus.Y); 

		IF (unsigned(vram_waddr) = unsigned(curr_vram_word)) THEN
			--cachehit
			null;
		ELSE 
			--do ram flush IF vram not busy and update curr_addr register witn en
			--wen_all =1 , pw=1, move contents into second register
		END IF;
	END PROCESS draw_px;
---------------------------- structural -----------------------------------------
ram_state_machine: ENTITY WORK.ram_fsm PORT MAP(

	--inputs std_logic 	  "entity port => external signal"
	clk		 => clk,
	reset 	 => reset,
	start 	 => ram_start,

	--input std_logic_vector
	addr 	 => ram_addr,
	data 	 => ram_data,


	--output std_logic
	delay 	 => ram_delay,	
	vwrite 	 => ram_vwrite,

	--output std_logc_vector
	addr_del => ram_addr_del,
	data_del => ram_data_del
	);

px_cache: ENTITY WORK.pix_word_cache PORT MAP(

	--inputs std_logic
	clk		=> clk,
	wen_all => pxcache_wen_all, 
	reset	=> pxcache_reset,
	pw 		=> pxcache_pw,

	--inputs pixop_t
	pixopin	=> pxcache_pixopin,

	--inputs std_logic_vector(3 DOWNTO 0)
	pixnum	=> pxcache_pixnum,


	--outputs store_t
	store 	=> pxcache_store,

	--outputs std_logic
	is_same => pxcache_is_same

	);


vaddr <= ram_addr; --joining external ram to the ram interface fsm



--new_pxcache_store <= vdout; -- read in new memory 

dbb_rcbclear <= '0';


END rtl1;      