-- top-level Vector Display Processor
-- this file is fully synthesisable
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE work.project_pack.ALL;
USE work.config_pack.ALL;

USE work.ALL;

ENTITY vdp IS
	PORT(
		clk      : IN  std_logic;
		reset    : IN  std_logic;
		-- bus from host
		hdb      : IN  STD_LOGIC_VECTOR(VSIZE * 2 + 3 DOWNTO 0);
		dav      : IN  STD_LOGIC;
		hdb_busy : OUT STD_LOGIC;

		-- bus to VRAM
		vdin     : OUT STD_LOGIC_VECTOR(RAM_WORD_SIZE - 1 DOWNTO 0);
		vdout    : IN  STD_LOGIC_VECTOR(RAM_WORD_SIZE - 1 DOWNTO 0);
		vaddr    : OUT STD_LOGIC_VECTOR; -- open port, exact size depends on VSIZE
		vwrite   : OUT STD_LOGIC;

		-- to testbench
		finish   : OUT std_logic
	);
END vdp;

ARCHITECTURE rtl OF vdp IS

--signals to connect db to rcb                   
SIGNAL dbb_i 								: db_2_rcb;
SIGNAL dbb_delaycmd_i, dbb_rcbclear_i		: std_logic;
SIGNAL dbb_finish_i, rcb_finish_i			: std_logic;


BEGIN
db: ENTITY db_behav PORT MAP(
	--entity port => external signal
	clk			 => clk ,
	reset		 => reset,
	--bus from host
	hdb 		 => hdb,
	dav 	 	 => dav,
	hdb_busy 	 => hdb_busy,
	--bus to RCB
	dbb 		 => dbb_i,
	dbb_delaycmd => dbb_delaycmd_i,
	dbb_rcbclear => dbb_rcbclear_i,
	--to testbench
	db_finish	 => dbb_finish_i
	);

rcb_mike: ENTITY rcb PORT MAP(

	clk				=>clk,
	reset			=>reset,

	--from db
	dbb_bus			=> dbb_i,
	dbb_delaycmd 	=> dbb_delaycmd_i,
	dbb_rcbclear 	=> dbb_rcbclear_i,

	--vram connections
	vdout			=> vdout,
	vdin			=> vdin,
	vwrite			=> vwrite,
	vaddr 			=> vaddr,

	--to vdp
	rcb_finish 		=> rcb_finish_i 


	);

finish <= rcb_finish_i AND dbb_finish_i;

END rtl;      


