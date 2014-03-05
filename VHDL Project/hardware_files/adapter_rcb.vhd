LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.project_pack.ALL;
USE work.rcb;

ENTITY adapter_rcb IS
	PORT(
		clk          : IN  std_logic;
		reset        : IN  std_logic;

		-- db connections
		dbb          : IN  db_2_rcb;
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
END adapter_rcb;

ARCHITECTURE rtl2 OF adapter_rcb IS
BEGIN
	a1 : ENTITY rcb
		PORT MAP(
			clk          => clk,
			reset        => reset,

			-- bus to DB
			x            => dbb.X,
			y            => dbb.Y,
			rcbcmd       => dbb.rcb_cmd,
			startcmd     => dbb.startcmd,
			dbb_delaycmd => dbb_delaycmd,
			dbb_rcbclear => dbb_rcbclear,

			-- VRAM
			vdin         => vdin,
			vdout        => vdout,
			vaddr        => vaddr,
			vwrite       => vwrite,

			-- vdp connection
			rcb_finish   => rcb_finish
		);

END rtl2;      