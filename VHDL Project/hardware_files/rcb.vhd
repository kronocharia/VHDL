------------------------------main entity---------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.project_pack.ALL;
USE WORK.pix_cache_pak.ALL;
USE WORK.helper_funcs.ALL;
USE WORK.ram_fsm;
USE WORK.pix_word_cache;

ENTITY rcb IS
    GENERIC(    vsize : INTEGER := 6;
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

-- return the RamWord address as a 8 bit vector
    FUNCTION getRamWord( x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector IS
      
      VARIABLE xVal, yVal       : integer;
      VARIABLE wordAddress      : std_logic_vector(7 DOWNTO 0);
    BEGIN
        
        xVal := to_integer(unsigned(x(VSIZE-1 DOWNTO 2)));
        yVal := to_integer(unsigned(y(VSIZE-1 DOWNTO 2)));

        wordAddress := std_logic_vector(to_unsigned(xVal+ 16*yVal,8));

        RETURN wordAddress;
    END;

    -- return the ramBit addr as a 4bit address vector
    FUNCTION getRamBit(  x : std_logic_vector(vsize-1 DOWNTO 0); y :std_logic_vector(vsize-1 DOWNTO 0)) RETURN std_logic_vector IS
      
      VARIABLE xVal, yVal   : integer;
      VARIABLE bitAddress   : std_logic_vector(3 DOWNTO 0);

    BEGIN
        
        xVal := to_integer(unsigned(x(1 DOWNTO 0)));
        yVal := to_integer(unsigned(y(1 DOWNTO 0)));

        bitAddress := std_logic_vector(to_unsigned(xVal + 4*yVal,4));

        RETURN bitAddress;
    END;



---------------Internal Wires--------------------


--For interfacing with ram block
    SIGNAL ram_start, ram_delay, ram_vwrite, ram_done           : std_logic;
    SIGNAL ram_addr, ram_addr_del                               : std_logic_vector(7 DOWNTO 0);
    SIGNAL ram_data_del                               : std_logic_vector(15 DOWNTO 0);

--For interfacing with pixel cache
    SIGNAL pxcache_wen_all, pxcache_pw                          : std_logic;
    SIGNAL pxcache_is_same                                      : std_logic;
    SIGNAL pxcache_pixopin                                      : pixop_t;
    SIGNAL pxcache_pixnum                                       : std_logic_vector(3 DOWNTO 0);
    SIGNAL pxcache_store,pxcache_store_buf                      : store_t;

--
--VSIZE is 6 ish...
    
    SIGNAL prev_dbb_bus                                         :db_2_rcb;

--RCB state machine signals
    TYPE state_type IS (s_error,s_idle,s_draw, s_clear, s_flush);-- s_waitram);
    SIGNAL state, next_state , prev_state         : state_type; --, prev_2state 

--draw_px process signals
    SIGNAL curr_vram_word,prev_vram_word             : std_logic_vector(7 DOWNTO 0);
    SIGNAL change_curr_word                                     : std_logic;

--trigger the cache flush
    SIGNAL pxcache_stash                                        : std_logic;
--waiting for ram_fsm to complete
    SIGNAL vram_done,vram_really_done                           : std_logic;
    SIGNAL reset_idle_count,idle_counter_trig                   : std_logic;

    --hardcoded width to handle N up to 256
    SIGNAL idle_counter                                         : std_logic_vector(7 DOWNTO 0);
    CONSTANT one_vector                                         : std_logic_vector(7 DOWNTO 0) := "00000001";
    -- CONSTANT cache_init                                         : store_t := "00000000000000000000000000000000";
   

BEGIN

---------------------state transition matrix----------------------- 

    state_transition: PROCESS(state,dbb_bus, curr_vram_word,next_state, vram_done,idle_counter,
                                 prev_state,prev_vram_word,reset,pxcache_is_same,vram_really_done) 
    --idle counter variable declared in package
    variable prevState: std_logic_vector(1 DOWNTO 0);  
    variable concatDraw: std_logic_vector(2 DOWNTO 0);                  
    variable concatFlush: std_logic_vector(3 DOWNTO 0); 
    variable concatIdle: std_logic_vector(1 DOWNTO 0);
    variable inRange: std_logic;
  
    BEGIN

        next_state <= s_error;  --default to error state

        idle_counter_trig <= '0';  --disable
            
        pxcache_pixopin <= same;   --dont care
        pxcache_pixnum <= "0000";  --dont care
        pxcache_wen_all <= '0';    --disable
        pxcache_pw <='0';          --disable
        pxcache_stash <= '0';      --disable
        change_curr_word <='0';    --disable
        --vram_waddr <= getRamWord(dbb_bus.X, dbb_bus.Y); --stay same
        --IF (reset = '1') THEN
         --   ram_addr <= "00000000";
        --ELSE 
            ram_addr <= prev_vram_word; --dont care
        --END IF;

        ram_start <='0';            --disable       
        
        --dbb_delaycmd <='1'; --always busy unless in idle state
        
        --transitions 
        CASE state IS
            WHEN s_idle =>  --report "State = Idle" severity note;
           -- dbb_delaycmd <= '0';

                concatIdle := dbb_bus.startcmd & dbb_bus.rcb_cmd(2);

                CASE concatIdle IS
                    WHEN "10" => --ready and draw
                        --dbb_delaycmd <= '1';

                        reset_idle_count <= '1';   --disable
                        next_state <= s_draw; --report "Received Start cmd and draw" severity note;
                    
                    WHEN "11" => --ready and clear
                       -- dbb_delaycmd <= '1';

                        reset_idle_count <= '1';   --disable
                        next_state <= s_clear;-- report "Received Start cmd and clear" severity note;
                    
                    WHEN others => --Idle
                       -- dbb_delaycmd <= '1';
                        IF (to_integer(unsigned(idle_counter)) = N) THEN
                            reset_idle_count <= '1'; -- report "Beginning idle flush" severity note; ---<<<<
                            pxcache_stash <= '1';       --ENABLE!! <<<<<
                            --change_curr_word <='1';     --ENABLE!! <<<<<

                            next_state <= s_flush;      --time to flush <<<<
                        
                        ELSE                            --increase idleCount

                            reset_idle_count <= '0';   --disable
                            idle_counter_trig <= '1';  --  report "Going back to idle" severity note; --<<<< 
                           -- dbb_delaycmd <='0'; --always busy unless in idle state
                            next_state <= s_idle; END IF; --RETURN TO IDLE <<<<<
                END CASE;


                        --instruction decode        
                        -- RCB CMD
                        -- 000 move
                        -- 001 draw white           '-01' if white
                        -- 010 draw black           '-10' if black
                        -- 011 draw invert          '-11' if invert
                        -- 100 unused               '0--' if draw
                        -- 101 clear white          '1--' if clear
                        -- 110 clear black          '000' if move
                        -- 111 clear invert         


            WHEN s_draw =>  

                reset_idle_count <= '1';  
                --report "State = draw" severity note;
               -- assert false report "breakpoint in when s_draw" severity failure;
                
                IF ( getRamWord(dbb_bus.X, dbb_bus.Y) = curr_vram_word ) THEN      
                    inRange := '1';
                ELSE
                    inRange := '0';
                END IF;
                concatDraw := inRange & dbb_bus.rcb_cmd(1 DOWNTO 0); --|inrange|pxopin|

                CASE concatDraw IS 
                    WHEN "101" | "110" | "111" => --draw single 
                        
                        pxcache_pixopin <= pixop_t(dbb_bus.rcb_cmd(1 DOWNTO 0)); --SET VALUE <<<<<
                        pxcache_pixnum <= getRamBit(dbb_bus.X, dbb_bus.Y);    --SET VALUE <<<<<
                        pxcache_pw <='1';   --enable the px cache for writing singl --SET VALUE <<<<<

                       -- dbb_delaycmd <='0';
                        next_state <= s_idle;       --RETURN TO IDLE <<<<< 
 
                    WHEN "100" => --movepen
                      --  dbb_delaycmd <='0';
                        next_state <= s_idle;           --RETURN TO IDLE <<<<<
                        

                    WHEN "000"| "001" | "010" | "011" => --out of range draw single or move
   
                        pxcache_stash <= '1';             --load new word <<<<<
                        --change_curr_word <='1';           --ENABLE!!      <<<<<

                        next_state <= s_flush;            --ENABLE FLUSH <<<<<
                        --next_state <= s_waitram;

                    WHEN others => next_state <= s_error; 
                    assert false report "ERROR in rcb, when concatDraw " severity failure;

                END CASE;
              

            --WHEN s_waitram => next_state <= s_flush; 
           --reset_idle_count <= '1'; 

            WHEN s_clear => next_state <=s_idle; --to be implemented later

                reset_idle_count <= '1';   --disable

            WHEN s_flush => 

            reset_idle_count <= '1';   --disable
            change_curr_word <='1';
               CASE prev_state IS
                    WHEN s_idle => prevState := "00";
                    WHEN s_draw => prevState := "01";
                    WHEN s_clear => prevState := "10";
                    WHEN s_error => prevState := "11"; --to remove synth warnings
                    WHEN s_flush => prevState := "11";  --to remove synth warnings
                    --WHEN others => prevState := "11"; --not used
                END CASE;

                IF vram_done = '0' AND prev_state = s_flush THEN
                    
                    next_state <= s_flush; --loop here till done <<<< not actuaLLY USED

                -- ELSIF vram_done ='0' AND prev_state = s_draw THEN
                --     next_state <= s_flush;
                ELSE
                    concatFlush := prevState & dbb_bus.rcb_cmd(1 DOWNTO 0); --|inrange|pxopin|
                    
                    --assert false report "oord raw " severity failure;
                    CASE concatFlush IS
                        WHEN "0000" | "0001" | "0010" | "0011" | "0100" => --its an idle flush or out of range move (last pattern)

                            pxcache_wen_all <= '1';  --pseudo reset cache <<<<<
                            ram_start <='1';            --ENABLE RAM!! <<<<

                            --dbb_delaycmd <= '0';
                            next_state <= s_idle;       --and go back to IDLE<<<<
                           

                        WHEN "0101" | "0110" | "0111" => --out of range draw
                            pxcache_pixopin <= pixop_t(dbb_bus.rcb_cmd(1 DOWNTO 0)); --SET VALUE <<<<<
                            pxcache_pixnum <= getRamBit(dbb_bus.X, dbb_bus.Y); --<<<<
                            pxcache_wen_all <= '1';      --ENABLE CACHE CLEAR <<<<<
                            pxcache_pw <='1';            --ENABLE SINGLE WRITE <<<<
                            ram_start <='1';             --ENABLE VRAM WRITE
                            --dbb_delaycmd <= '0';
                            next_state <= s_idle;        --and go back to IDLE
                          
                        WHEN "1001" | "1010" | "1011" => --its a clear of some colour 
                            next_state <= s_idle;

                        WHEN others => next_state <= s_error;    
                        assert false report "ERROR in rcb, state_transition - when s_flush " severity failure;     
                    END CASE;
                END IF;

            WHEN s_error => 

                    reset_idle_count <= '1';   --disable
                    assert false report "Congrats, you're in the error state, fix me" ;
                    next_state <= s_error; -- only reset moves state to idle

                    
            WHEN others => 

                    reset_idle_count <= '1';   --disable
                    assert false report "RCB Unspecified FSM transition " severity failure;
                    next_state <= s_error;

        END CASE;


        IF (reset=  '1') THEN
            dbb_delaycmd <= '0';
        -- ELSIF (next_state = s_draw OR state = s_draw OR state = s_flush OR next_state = s_draw) THEN
        ELSIF   ((next_state = s_draw) OR 
                --(next_state = s_waitram) OR
                (next_state = s_flush) OR 
                (next_state = s_clear)) THEN
            dbb_delaycmd <= '1';
        ELSE
            dbb_delaycmd <= '0'; END IF;


       ---------rcb finish------------
        IF reset = '1' THEN
            rcb_finish <='0';

        ELSIF (next_state = s_idle AND vram_really_done = '1') THEN
            rcb_finish <= pxcache_is_same;
            --rcb_finish <= '1';
        ELSE 
            rcb_finish <= '0';
        END IF;

    END PROCESS state_transition;
-------------------------------------------------------------------------------

----------------------------fsm_clocked_process--------------------------------
    fsm_clocked_process: PROCESS
    BEGIN
        WAIT UNTIL clk'EVENT AND clk = '1';

            -------previous command--------
            prev_dbb_bus <= dbb_bus;
            -------------------------------          
            ---------store states----------          
            --prev_2state <= prev_state;
            prev_state <= state;
            state <= next_state;

         

            ------------reset---------------
            IF reset = '1' THEN
                state <= s_idle;
                prev_state <= s_idle;
            END IF;

            -----------idle counter-------

            IF (idle_counter_trig ='1' AND reset = '0') THEN
                idle_counter  <= std_logic_vector(unsigned(unsigned(one_vector)+ unsigned(idle_counter)));
            END IF;

            IF (reset = '1' OR reset_idle_count ='1') THEN
                idle_counter <= "00000000";
            END IF;

            ------------pxcache_stored_value-----
            IF pxcache_stash = '1' THEN
               pxcache_store_buf <= pxcache_store;
            END IF;
            
            IF (reset = '1') THEN
                --pxcache_store_buf <= pxcache_store;
                pxcache_store_buf <= (OTHERS => same);
                --FOR i IN pxcache_store_buf'RANGE LOOP
                --    pxcache_store_buf(i) <= same;
                --END LOOP;
            
            END IF;

            -----current and previous word addresses----
            IF (change_curr_word='1' AND reset ='0') THEN 
                prev_vram_word <= curr_vram_word;
                curr_vram_word <= getRamWord(prev_dbb_bus.X, prev_dbb_bus.Y); 
            END IF;

            IF (reset = '1') THEN
            curr_vram_word <= "00000000";
            prev_vram_word <= "00000000";

            END IF;



    END PROCESS fsm_clocked_process;


---------------------------------------------------------------------------------
---------------------------- structural -----------------------------------------
ram_state_machine: ENTITY ram_fsm PORT MAP(

    --inputs std_logic    "entity port => external signal"
    clk      => clk,
    reset    => reset,
    start    => ram_start,

    --input std_logic_vector
    addr     => ram_addr,
    data     => vdout,
    cache_d  => pxcache_store_buf,


    --output std_logic
    delay    => ram_delay,  
    vwrite   => ram_vwrite,
    done     => vram_done,
    really_done => vram_really_done,

    --output std_logc_vector
    addr_del => ram_addr_del,
    data_del => ram_data_del
    );

px_cache: ENTITY pix_word_cache PORT MAP(

    --inputs std_logic
    clk     => clk,
    wen_all => pxcache_wen_all, 
    reset   => reset,
    pw      => pxcache_pw,

    --inputs pixop_t
    pixopin => pxcache_pixopin,

    --inputs std_logic_vector(3 DOWNTO 0)
    pixnum  => pxcache_pixnum,


    --outputs store_t
    store   => pxcache_store,

    --outputs std_logic
    is_same => pxcache_is_same

    );

------------------external connections and signal stuff----------------------

vdin <= ram_data_del;
vaddr <= ram_addr_del; --joining external ram to the ram interface fsm
--ram_data <= vdout; --joins vram output to ram data in
vwrite <= ram_vwrite;

--clear not implemented yet
dbb_rcbclear <= '0';


END rtl1;