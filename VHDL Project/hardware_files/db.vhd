library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.project_pack.all;
use work.draw_any_octant;
use work.clearscreen;

entity db is
  generic(vsize : integer := 6);
  port(
    clk          : in  std_logic;
    reset        : in  std_logic;

    -- host processor connections
    hdb          : in  std_logic_vector(2*vsize+3 downto 0);
    dav          : in  std_logic;
    hdb_busy     : out std_logic;

    -- rcb connections
    dbb_bus      : out db_2_rcb;
    dbb_delaycmd : in  std_logic;
    dbb_rcbclear : in  std_logic;

    -- vdp connection
    db_finish    : out std_logic
    );
end db;

architecture rtl of db is
  signal dao_draw, dao_xbias, dao_done, dao_swap, dao_negx, dao_negy, dao_disable, dao_reset : std_logic;
  signal dao_xin, dao_yin, dao_xout, dao_yout: std_logic_vector(vsize-1 downto 0);
  signal penx, peny: std_logic_vector(vsize-1 downto 0);
  --signal previous_command : std_logic_vector(2*vsize+3 downto 0);
  
  signal cs_reset, cs_disable, cs_done, cs_draw: std_logic;
  signal cs_xout, cs_yout: std_logic_vector(vsize-1 downto 0);
  
  type state_t is (draw_reset, draw_start, draw_line, idle, clear_start, draw_clear);
  signal state, nstate : state_t;
  
  type opcode_t is array (1 downto 0) of std_logic;
  constant movepen_op      : opcode_t := "00";
  constant drawline_op     : opcode_t := "01";
  constant clearscreen_op  : opcode_t := "10";
  
  type pentype_t is array (1 downto 0) of std_logic;
  constant white  : pentype_t := "01";
  constant black  : pentype_t := "10";
  constant invert : pentype_t := "11";
  
  type command_t is record
    op   : opcode_t;
    x, y : std_logic_vector(vsize-1 downto 0);
    pen  : pentype_t;
  end record;
  signal command_in, command: command_t;
begin
  -- decoding command
  command_in.op  <= opcode_t(hdb(2*vsize+3 downto 2*vsize+2));
  command_in.x   <= hdb(2*vsize+1 downto vsize+2);
  command_in.y   <= hdb(vsize+1 downto 2);
  command_in.pen <= pentype_t(hdb(1 downto 0));
  
  dao: entity draw_any_octant generic map(vsize) port map(
    clk => clk,
    resetx => dao_reset,
    draw => dao_draw,
    xbias => dao_xbias, 
    xin => dao_xin,
    yin => dao_yin, 
    done => dao_done,
    x => dao_xout,
    y => dao_yout,
    swapxy => dao_swap,
    negx => dao_negx,
    negy => dao_negy,
    disable => dao_disable
    );
    
  cs: entity clearscreen generic map(vsize) port map(
    clk => clk,
    reset => cs_reset,
    draw => cs_draw,
    disable => cs_disable,
    xstart => penx,
    ystart => peny,
    xend => command.x,
    yend => command.y,
    done => cs_done,
    xout => cs_xout,
    yout => cs_yout
  );
  
  cs_reset <= reset;
  
  cs_inputs: process(state)
  begin
    if state = clear_start then
      cs_draw <= '1';
    else
      cs_draw <= '0';
    end if;
  end process cs_inputs;
    
  disable: process(state, dbb_delaycmd)
  begin
    -- disable dao when rcb not ready
    if state = draw_line and dbb_delaycmd = '1' then
      dao_disable <= '1';
    else
      dao_disable <= '0';
    end if;
    
    if state = draw_clear and dbb_delaycmd = '1' then
      cs_disable <= '1';
    else
      cs_disable <= '0';
    end if;
  end process disable;
  
  read_new_command: process
    constant reset_command: command_t := (
      op  => (others => '0'),
      x   => (others => '0'),
      y   => (others => '0'),
      pen => (others => '0')
      );
  begin
    wait until clk'event and clk='1';
    if state = idle and dav = '1' then
      command.op  <= opcode_t(hdb(2*vsize+3 downto 2*vsize+2));
      command.x   <= hdb(2*vsize+1 downto vsize+2);
      command.y   <= hdb(vsize+1 downto 2);
      command.pen <= pentype_t(hdb(1 downto 0));
    end if;
    if reset = '1' then
      command <= reset_command;
    end if;  
  end process read_new_command;

  block_host:process(state) --drives hdb_busy
  begin
    if state = idle then hdb_busy <= '0';
    else hdb_busy <= '1';
    end if;
  end process block_host;
  
  set_dao_inputs: process(command, state, penx, peny) -- drives negx, negy, swapxy,
                                          -- xin, yin, xbias, draw, reset
    variable dx: signed(vsize downto 0);
    variable dy: signed(vsize downto 0);
    variable v_swapxy, v_negx, v_negy: std_logic;
    --variable zero : std_logic_vector(vsize-1 downto 0) := (others =>'0');
  begin
    dx := signed(resize(unsigned(command.x), vsize+1)) - signed(resize(unsigned(penx), vsize+1));
    dy := signed(resize(unsigned(command.y), vsize+1)) - signed(resize(unsigned(peny), vsize+1));
    -- set swapxy if dx is closer to 0 than dy
    if abs(dx) < abs(dy) then
      v_swapxy := '1';
    else
      v_swapxy := '0';
    end if;
    -- set negx if dx is negative
    if (v_swapxy = '0' and dx < 0) or (v_swapxy = '1' and dy < 0) then
      v_negx := '1';
    else
      v_negx := '0';
    end if;
    -- set negy if dy is negative
    if (v_swapxy = '0' and dy < 0) or (v_swapxy = '1' and dx < 0) then
      v_negy := '1';
    else
      v_negy := '0';
    end if;
    -- set x and y inputs
    if state = draw_reset then
      dao_xin <= penx;
      dao_yin <= peny;
    else
      dao_xin <= command.x;
      dao_yin <= command.y;
    end if;
    --set draw input
    if state = draw_start then dao_draw <= '1';
    else dao_draw <= '0';
    end if;
    --set reset input
    if state = draw_reset then dao_reset <= '1';
    else dao_reset <= '0';
    end if;
    -- set xbias
    if (v_negx xor v_negy) = '0' then 
      dao_xbias <= '1';
    else
      dao_xbias <= '0';
    end if;
    dao_negx <= v_negx;
    dao_negy <= v_negy;
    dao_swap <= v_swapxy;
  end process set_dao_inputs;
  
  db_fsm_clocked: process
  begin
    wait until clk'event and clk='1';
    -- go to next state
    state <= nstate;
    if reset = '1' then state <= idle; end if;
  end process db_fsm_clocked;
  
  db_fsm_comb: process(state, command_in, dav, dao_done, cs_done, dbb_delaycmd) -- drives nstate
  begin
    case state is
      when idle =>
        if dav = '1' then
          --read command and decide which state to go to.
          case command_in.op is
            when movepen_op => null;
            when drawline_op => nstate <= draw_reset;
            when clearscreen_op => nstate <= clear_start;
            when others => nstate <= idle; --invalid command---do nothing
          end case;
        end if;
        
      when draw_reset =>
        nstate <= draw_start;
        
      when draw_start =>
        nstate <= draw_line;
        
      when draw_line =>
        if dao_done = '0' or dbb_delaycmd = '1' then
          nstate <= draw_line;
        else
          nstate <= idle;
        end if;
        
      when clear_start =>
        --if dbb_delaycmd = '0' then nstate <= clear_end; end if;
        nstate <= draw_clear;
        
      when draw_clear =>
        if cs_done = '0' or dbb_delaycmd = '1' then
          nstate <= draw_clear;
        else
          nstate <= idle;
        end if;
        
      --when clear_end =>
      --  if dbb_delaycmd = '0' then nstate <= idle; end if;
    end case;
  end process db_fsm_comb;

  send_rcb_inputs: process--(state, command, dao_xout, dao_yout, penx, peny) --drives dbb_bus
    constant default : std_logic_vector(vsize-1 downto 0) := (others =>'0');
  begin
    wait until clk'event and clk = '1';
    if dbb_delaycmd = '0' then
      -- encode operation
      case command.pen is
        when white => dbb_bus.rcb_cmd(1 downto 0) <= "01";
        when black => dbb_bus.rcb_cmd(1 downto 0) <= "10";
        when invert => dbb_bus.rcb_cmd(1 downto 0) <= "11";
        when others => dbb_bus.rcb_cmd <= "100"; -- invalid command
      end case;
      case command.op is
        when movepen_op => null;
        when drawline_op => dbb_bus.rcb_cmd(2) <= '0';
        when clearscreen_op => dbb_bus.rcb_cmd(2) <= '0';--'1';
        when others => dbb_bus.rcb_cmd <= "100"; -- invalid command
      end case;
    
      -- set other parameters
      case state is
        when draw_line =>
          dbb_bus.x <= dao_xout;
          dbb_bus.y <= dao_yout;
          dbb_bus.startcmd <= '1';
        when clear_start =>
          dbb_bus.rcb_cmd <= "000";
          dbb_bus.X <= penx;
          dbb_bus.Y <= peny;
          dbb_bus.startcmd <= '1';
        --when clear_end =>
        --  dbb_bus.X <= command.x;
        --  dbb_bus.Y <= command.y;
        --  dbb_bus.startcmd <= '1';
        when draw_clear =>
          dbb_bus.X <= cs_xout;
          dbb_bus.Y <= cs_yout;
          dbb_bus.startcmd <= '1';
        when others => --idle, draw_reset, draw_start have no output
          dbb_bus.X <= default;
          dbb_bus.Y <= default;
          dbb_bus.startcmd <= '0';
      end case;

      -- movepen
      if state = idle and dav = '1' and command_in.op = movepen_op then
        dbb_bus.rcb_cmd <= "000";
        dbb_bus.X <= command_in.x;
        dbb_bus.Y <= command_in.y;
        dbb_bus.startcmd <= '1';
      end if;
    end if;
  end process send_rcb_inputs;

  finished: process(state, dav) -- drives db_finish
  begin
    if state = idle and dav = '0' then db_finish <= '1';
    else db_finish <= '0';
    end if;
  end process finished;

  update_penpos: process -- drives penx, peny
  begin
    wait until clk'event and clk='1';
    if reset = '1' then
      penx <= (others => '0');
      peny <= (others => '0');
    elsif state = idle and dav = '1' and command_in.op = movepen_op then
      penx <= command_in.x;
      peny <= command_in.y;
    elsif state = draw_line and dao_done = '1' then
      penx <= command.x;
      peny <= command.y;
    elsif state = draw_clear and cs_done = '1' then
      penx <= command.x;
      peny <= command.y;
    end if;
  end process update_penpos;
end rtl;