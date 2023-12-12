module checkHorizontal(
    input row,
    input column,
    output 1wins;
    output 2win;
    )
    if(gameBoard[row][column] == 2'b01 
    && gameBoard[row][column+1] == 2'b01
    && gameBoard[row][column+2] == 2'b01
    && gameBoard[row][column+3] == 2'b01){
        1wins = 1'b1;
        2wins = 1'b0;
    }
    if(
        gameBoard[row][column] == 2'b10
    && gameBoard[row][column+1] == 2'b10
    && gameBoard[row][column+2] == 2'b10
    && gameBoard[row][column+3] == 2'b10
    ) {
        1wins = 1'b0;
        2wins = 1'b1; 
    } 
endmodule
