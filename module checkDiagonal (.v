module checkDiagonal (
    input row,
    input column,
    output [2:0]win;
)
if(column <= 4 && gameBoard[row][column] == 2'b01 
    && gameBoard[row+1][column+1] == 2'b01
    && gameBoard[row+2][column+2] == 2'b01
    && gameBoard[row+3][column+3] == 2'b01) {

    }
if(column >= 4 && gameBoard[row][column] == 2'b01 
    && gameBoard[row+1][column-1] == 2'b01
    && gameBoard[row+2][column-2] == 2'b01
    && gameBoard[row+3][column-3] == 2'b01){
    }
    if(column <= 4 && gameBoard[row][column] == 2'b10
    && gameBoard[row+1][column+1] == 2'b10
    && gameBoard[row+2][column+2] == 2'b10
    && gameBoard[row+3][column+3] == 2'b10) {
        
    }
if(column >= 4 && gameBoard[row][column] == 2'b10
    && gameBoard[row+1][column-1] == 2'b10
    && gameBoard[row+2][column-2] == 2'b10
    && gameBoard[row+3][column-3] == 2'b10){

    }
endmodule
