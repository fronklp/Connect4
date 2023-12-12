module checkCellState(
    input [1:0] gameBoard[5:0][6:0],
    input [2:0] row,
    input [2:0] column, 
    output reg empty,
    output reg player1,
    output reg player2,
);
always@(*) begin 
    case(gameBoard[row][column])
        2'b00: begin 
            empty = 1'b1;
            player1 = 1'b0;
            player2 = 1'b0;
        end
        2'b01: begin 
           empty = 1'b0;
            player1 = 1'b1;
            player2 = 1'b0; 
        end;
        2'b10: begin 
            empty = 1'b0;
            player1 = 1'b0;
            player2 = 1'b1;
        end 
    endcase
end
endmodule