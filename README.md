Class: ECE287

Authors: Keegan Alvis, Liam Fronk, Graeme Welsh

# Connect4 with AI
Game/Problem Description:

This project is a Connect 4 game created to play against an AI in verilog. We created our design utilizing an FPGA board (DE2-115) and VGA files to implement our design onto a monitor. The user uses the FPGA inputs to choose the coloumn they want to place their piece in. Once they place their piece, win conditions are checked. If no win conditions are met, the opponent's move will automatically be chosen by the AI. Win conditions are once again checked and the turn is sent back to the user.

Background Information:

Connect 4 is a very popular game from our childhood, with the whole idea behind it being to connect 4 of your pieces in a row on a grid before your opponent can by taking turns dropping pieces. We wanted to take this game, and add a twist: implementing an AI. We had different ideas for our AI, a simple randomizer that can place a piece anywhere, or trying to input a minmax AI to smartly place pieces according to where the player has last played. We chose to make our grid a 6x7, giving us 138 total winning combinations (AI and player combined).

Project Design
--
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


Column Selecting:  
Each column is an adjacent state in an FSM. The FSM moves to the next state (column) when direction goes high. When moveChosen goes high in any column, the col#Capacity is checked to make sure the column isn't full. validMove goes high if the column has open spaces, initiating drop logic and moving the main FSM to the next state.

Drop Logic: 
The current column # is added to the product of the lowest open row (col#Capacity) * 6. This gives the location of the cell in the
gameboard which has been chosen, whose value will be update to 1 or 2 depending on the current player's move.
  
Win Conditions:
Each player has 69 possible ways to win the game, creating a total of 138 wins on the board. The main module is constantly checking
all 138 wins, using a 4-input AND gate to check if four squares are connected verticall, horizontally or diagonally.
The "win" variable is set to 1 or 2 if player 1 or 2 wins, respectively.

VGA
--
As stated previously, our VGA was borrowed by Obed Amaning-Yeboah. We used the VGA by instantiating it in the main module and used the FPGA pinouts to give inputs to the VGA. 

Conclusion and Final Results
--
Our final product fell far short of the intended function. The project can successfully connect to the VGA and display the initially selected column. Once the direction button is pressed to move to the next column, the column FSM is rapidly traversed and the VGA displays all columns to be selected at the same time. 

To fix this issue, the Column Selecting FSM must be modified to have an idling state which waits until the direction button goes back low. A functioning debouncer must also be implemented to keep the signal steady.

Once this issue is resolved, cell selection must be sequentially transmitted to the VGA in order to display the proper drop logic. To do so, sequentially change the VGA inputs cell_x and cell_y to transmit the selected cell's coordinates to the VGA.
We also recommend the implementation of a more sophisticated AI to improve the gaming experience. 

Video Testing:
--
https://youtube.com/shorts/Sw712l3lS1Y?si=woICKOnuC0QyFRO1 

Citations/VGA Credits:
--
We would like to credit Sonny Grooms for lending us his VGA, which he got from Obed Amaning-Yeboah. We would also like to credit tahmid-haque (GitHub username) as we used his image file to create our grid. 

