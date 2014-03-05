LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.project_pack.ALL;
USE WORK.ram_fsm.ALL;
USE WORK.pix_word_cache.ALL;

ENTITY rcb IS
	GENERIC(vsize : INTEGER := 6);
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
    SIGNAL ram_addr, ram_data, ram_addr_del, ram_data_del		: std_logic_vector;

--For interfacing with pixel cache
	SIGNAL pxcache_wen_all, pxcache_reset, pxcache_pw 			: std_logic;
	SIGNAL pxcache_is_same										: std_logic;
	SIGNAL pxcache_pixopin 										: pixop_t;
	SIGNAL pxcache_pixnum										: std_logic_vector(3 DOWNTO 0)
	SIGNAL pxcache_store										: store_t;



BEGIN


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



END rtl1;      