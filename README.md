Class: ECE287

Authors: Keegan Alvis, Liam Fronk, Graeme Welsh

# Connect4 with AI
Description:

This project is a Connect 4 game playing against an AI. We did this by utilizing a FPGA board (DE2-115) and VGA files to implement our design onto a screen. The user uses the buttons to go through the coloumns they want to place their piece in, as well as dropping their piece in the coloumn. 


Background Information:

Connect4 is a very popular game from our childhood, with the whole idea behind it to connect 4 of your pieces in a row on a grid before your opponent can by taking turns dropping pieces. We wanted to take this game, and add a twist: implementing an AI. We had different ideas for our AI, a simple randomizer that can place a piece anywhere, or trying to input a minmax AI to smartly place pieces according to where the player has last played. We chose to make our grid a 6x7, giving us 138 total winning combinations (AI and player combined). Using the buttons, the user is able to select the coloumn they want to drop their piece in and presses another button to actually drop their piece. After their move is finished, the AI will then place its piece and the user will be up to play again. We used one of the switches to act as our reset switch, to turn the screen off then back on to restart the game once someone wins or the game ends in a draw (meaning the whole board is fully filled up without anyone obtaining one of the winning states). 




Citations/VGA Credits:

I would like to credit Sonny Grooms for lending us his VGA, which he got from Obed Amaning-Yeboah. I would also like to credit tahmid-haque (GitHub username) as we used his image file to create our grid. 
