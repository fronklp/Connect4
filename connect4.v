module connect4 (
    input clk,
    input rst,
);
reg [2:0]S; // current state
reg [2:0]NS; // next state
reg validMove; // turns high when the selected move is valid
reg 1wins; // turns high if player 1 wins
reg 2wins; // turns high if player 2 wins
reg drawFinal; // turns high if match is drawn

/* IDEAS TO IMPLEMENT:
~Give each column a count to determine which cell to drop into
~

*/

/* parameters to represent the states */
parameter   P1_MOVE = 3'b000;
            CHECK_1_WIN = 3'b001;
            WIN1 = 3'b010;
            P2_MOVE = 3'b011;
            CHECK_2_WIN = 3'b100;
            WIN2 = 3'b101;
            CHECK_DRAW = 3'b110;
            DRAW = 3'b111;

/* S update always block */
always @(posedge clk or negedge rst)
begin
    if(rst == 1'b0)
        S <= P1_MOVE;
    else
        S <= NS;
end

/* NS transitions always block */
always @(*)
begin
    case(S)
        P1_MOVE: begin
            if(validMove == 1'b1)
                NS = CHECK_1_WIN;
            else   
                NS = P1_MOVE;
        end
        CHECK_1_WIN:    begin
            if(1wins)
                NS = WIN1;
            else
                NS = P2_MOVE;
        end
        WIN1:   NS = WIN1;
        P2_MOVE: begin
            if(validMove == 1'b1)
                NS = CHECK_2_WIN;
            else   
                NS = P2_MOVE;
        end
        CHECK_2_WIN:    begin
            if(2wins)
                NS = WIN2;
            else   
                NS = CHECK_DRAW;
        end
        CHECK_DRAW: begin
            if(drawFinal)
                NS = DRAW;
            else   
                NS = P1_MOVE;
        end
        DRAW:   NS = DRAW;

end

/* clocked control signals always block */
always @(posedge clk or negedge rst)
begin

end

endmodule