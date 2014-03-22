clear1
IF current addrX < bottomLeft(maxX) THEN
nextWord = getRamAddr(x+1,y)
nextstate = clear2
ELSIF current addr_y < bottomLeft(maxY) THEN
nextWord = getRamAddr(xmin,y+1)
nextstate = clear2
ELSE
        DONE
        nextstate = s_idle
 
---> tell ramFSM nextWord
 
clear2
 
 
For x in 0 to 3 Loop
        for y in 0 to 3 Loop
        bitNum := getRambit(x,y)
        IF inClearRange(prev_cmd, curr_cmd, x,y) = '1' THEN
                CASE color IS
                        WHEN "01" => cleared_px(bitNum) <= '0';
                        WHEN "10" => cleared_px(bitNum) <= '1';
                        WHEN "11" => cleared_px(bitNum) <= not vdout(bitNum);
                        WHEN others => NULL; assert false severity failure;
                END CASE
 
        ELSE
                cleared_px(bitnum) <= vdout(bitNum);
        END IF;
        END Loop;
END Loop;
nextstate =clear3;
 
inClearRange(prev_cmd, curr_cmd,x,y){
       
        VARIABLE x0,x1,y0,y1;
        VARIABLE xmax,ymax,xmin,ymin;
        VARIABLE inRange;
 
        x0 := toint(prev_cmd.x);
        y0 := toint(prev_cmd.y);
        x1 := toint(curr_cmd.x);
        y1 := curr_cmd.y;
 
        IF x0 <= x1 THEN
                xmin := x0;
                xmax := x1;
        ELSE
                xmin := x1;
                xmax := x0;
        END IF;
 
        IF y0 <= y1 THEN
                ymin := y0;
                ymay := y1;
        ELSE
                ymin := y1;
                ymay := y0;
        END IF;

        x = x + addrX;
        y = y + addrY;
 
        IF x >= xmin AND x <= xmax AND
                y >= ymin AND y <= ymax THEN
                inrange := '1' ;
        ELSE
                inrange := '0';
 
        return inrange;
}
 
clear3
vwrite=1;
goback to clear1