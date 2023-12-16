Class: ECE287

Authors: Keegan Alvis, Liam Fronk, Graeme Welsh

# Connect4 with AI
Description:

This project is a Connect 4 game playing against an AI. We did this by utilizing a FPGA board (DE2-115) and VGA files to implement our design onto a screen. The user uses the buttons to go through the coloumns they want to place their piece in, as well as dropping their piece in the coloumn. 


Background Information:

Connect4 is a very popular game from our childhood, with the whole idea behind it to connect 4 of your pieces in a row on a grid before your opponent can by taking turns dropping pieces. We wanted to take this game, and add a twist: implementing an AI. We had different ideas for our AI, a simple randomizer that can place a piece anywhere, or trying to input a minmax AI to smartly place pieces according to where the player has last played. We chose to make our grid a 6x7, giving us 138 total winning combinations (AI and player combined). Using the buttons, the user is able to select the coloumn they want to drop their piece in and presses another button to actually drop their piece. After their move is finished, the AI will then place its piece and the user will be up to play again. We used one of the switches to act as our reset switch, to turn the screen off then back on to restart the game once someone wins or the game ends in a draw (meaning the whole board is fully filled up without anyone obtaining one of the winning states). 


Verilog Files:

At first, we implemented the checkCellState, checkDiagonal, checkHorizontal, and checkVert files to check what blocks in the grid had pieces in them and to check for different win conditions. After playing around with the code however, we decided to scrap these and state all our win conditions in a loop.  Con4final.v is a module that contains all of the game logic for connect 4. It contains our Finite state machine that allows the game to function, the player move handling, and all of the win checks for the board.  It also contains the inputs and outputs for player moves, the board, and the VGA outputs.  The vga_adapter.v, vga_address_translator.v, and vga_controller.v are all responsible for outputting the connect 4 game onto the monitor via vga cable.  



Video Testing:

https://youtube.com/shorts/Sw712l3lS1Y?si=woICKOnuC0QyFRO1 


Citations/VGA Credits:

I would like to credit Sonny Grooms for lending us his VGA, which he got from Obed Amaning-Yeboah. I would also like to credit tahmid-haque (GitHub username) as we used his image file to create our grid. 


Project Design:

Turn-Based FSM Setup:
--
P1_MOVE:     The game starts on player 1's move. The FSM moves to CHECK_1_WIN once validMove goes high (see "Column Selecting" below).

CHECK_1_WIN: If win = 1, move to WIN1 (see "Win Coditions" below). Otherwise move to P2_MOVE.

WIN1:        End state if player 1 wins, remain here until reset.

P2_MOVE:     The FSM moves to CHECK_2_WIN once validMove goes high (see "Column Selecting" below).

CHECK_2_WIN: If win = 2, move to WIN2 (see "Win Coditions" below). Otherwise move to CHECK_DRAW.

WIN2:        End state if player 2 wins, remain here until reset.

CHECK_DRAW:  Go to DRAW if drawn = 1 (only necessary after P2_MOVE). Otherwise move to P1_MOVE.

DRAW:        End state if players draw, remain here until reset.
--
Column Selecting:  
Each column is an adjacent state in an FSM. The FSM moves to the next state (column) when direction goes high. When moveChosen goes high in any column, the col#Capacity is checked to make sure the column isn't full. validMove goes high if the column has open spaces, initiating drop logic and moving the main FSM to the next state.

Drop Logic: 
The current column # is added to the product of the lowest open row (col#Capacity) * 6. This gives the location of the cell in the
gameboard which has been chosen, whose value will be update to 1 or 2 depending on the current player's move.
  
Win Conditions:
Each player has 69 possible ways to win the game, creating a total of 138 wins on the board. The main module is constantly checking
all 138 wins, using a 4-input AND gate to check if four squares are connected verticall, horizontally or diagonally.
The "win" variable is set to 1 or 2 if player 1 or 2 wins, respectively.


