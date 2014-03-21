LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.project_pack.ALL;
USE work.db;

ENTITY adapter_db IS
	PORT(
		clk          : IN  std_logic;
		reset        : IN  std_logic;

		-- host processor connections
		hdb          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		dav          : IN  STD_LOGIC;
		hdb_busy     : OUT STD_LOGIC;

		-- rcb connections
		dbb          : OUT db_2_rcb;
		dbb_delaycmd : IN  STD_LOGIC;
		dbb_rcbclear : IN  STD_LOGIC;

		-- vdp connection
		db_finish    : OUT STD_LOGIC
	);
END adapter_db;

ARCHITECTURE rtl0 OF adapter_db IS
BEGIN
	d1 : ENTITY db
		PORT MAP(
			clk          => clk,        -- universal clock from Host processor
			reset        => reset,      -- reset signal from Host Processor

			-- host processor connections
			hdb          => hdb,
			dav          => dav,
			hdb_busy     => hdb_busy,

			-- bus to RCB
			dbb_bus(5 downto 0) => dbb.X,
			dbb_bus(11 downto 6)  => dbb.Y,
			dbb_bus(14 downto 12)=> dbb.rcb_cmd,
			dbb_bus(15)          => dbb.startcmd,
			dbb_delaycmd => dbb_delaycmd,
			dbb_rcbclear => dbb_rcbclear,

			-- vdp connection
			db_finish    => db_finish
		);

END rtl0;      