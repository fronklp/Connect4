module con4FINAL (
		clk,
		rst,
		moveChosen,
		directionD, 
		VGA_CLK,   						//	VGA Clock 
 		VGA_HS,							//	VGA H_SYNC 
 		VGA_VS,							//	VGA V_SYNC 
 		VGA_BLANK_N,					//	VGA BLANK 
 		VGA_SYNC_N,						//	VGA SYNC 
 		VGA_R,   						//	VGA Red[9:0] 
 		VGA_G,	 						//	VGA Green[9:0] 
 		VGA_B   							//	VGA Blue[9:0] 
);
input clk,
		rst,
		moveChosen,
		directionD;
reg [2:0]S; // current state
reg [2:0]NS; // next state
reg [2:0]C; // current column
reg [2:0]NC; // next column
reg validMove; // turns high when the selected move is valid
reg win1; // turns high if player 1 wins
reg win2; // turns high if player 2 wins
reg drawFinal; // turns high if match is drawn
reg [2:0]selectedCol; // holds the currently selected column
reg [7:0]selectedCell;
reg [2:0]col0Cap, col1Cap, col2Cap, col3Cap, col4Cap, col5Cap, col6Cap; // column capacity
reg [1:0]gameBoard[41:0];
/* VGA */
reg [2:0]player_color;
wire [1:0]turn;
reg [7:0] cell_x; 
reg [6:0] cell_y; 
reg [8:0] i;

initial begin
    {col0Cap, col1Cap, col2Cap, col3Cap, col4Cap, col5Cap, col6Cap} = 3'b000; // init capacity as 0
end

/* helper module instantiations */ 


// VGA OUTS
 	output			VGA_CLK;   				//	VGA Clock 
 	output			VGA_HS;					//	VGA H_SYNC 
 	output			VGA_VS;					//	VGA V_SYNC 
 	output			VGA_BLANK_N;				//	VGA BLANK 
 	output			VGA_SYNC_N;				//	VGA SYNC 
 	output	[9:0]	VGA_R;   				//	VGA Red[9:0] 
 	output	[9:0]	VGA_G;	 				//	VGA Green[9:0] 
 	output	[9:0]	VGA_B;   				//	VGA Blue[9:0] 

	wire [7:0] x; 
 	wire [6:0] y; 
 	reg writeEn; 
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(rst),
			.clock(clk),
			.colour(player_color),
			.x(cell_x),
			.y(cell_y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";		
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black1.mif";
		
		debouncer DEB(clk, rst, directionD, direction);
/* parameters to represent the states */
parameter   P1_MOVE = 3'b000,
            CHECK_1_WIN = 3'b001,
            WIN1 = 3'b010,
            P2_MOVE = 3'b011,
            CHECK_2_WIN = 3'b100,
            WIN2 = 3'b101,
            CHECK_DRAW = 3'b110,
            DRAW = 3'b111;

parameter   C_0 = 3'b000,
            C_1 = 3'b001,
            C_2 = 3'b010,
            C_3 = 3'b011,
            C_4 = 3'b100,
            C_5 = 3'b101,
            C_6 = 3'b110;

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
        P1_MOVE: begin // once a valid move is selected, the next state will be win check 1
            if(validMove == 1'b1)
                NS = CHECK_1_WIN;
            else   
                NS = P1_MOVE;
        end
        CHECK_1_WIN:    begin // either 1 wins is true, or move to player 2's move
            if(win1 == 1'b1)
                NS = WIN1;
            else
                NS = P2_MOVE;
        end
        WIN1:   NS = WIN1; // remains in win state until reset
        P2_MOVE: begin // once a valid move is selected, the next state will be win check 2
            if(validMove == 2'b01)
                NS = CHECK_2_WIN;
            else   
                NS = P2_MOVE;
        end
        CHECK_2_WIN:    begin // either 2 wins is true, or move to check for a draw
            if(win2)
                NS = WIN2;
            else   
                NS = CHECK_DRAW;
        end
        CHECK_DRAW: begin // either drawFinal is true, or move to player 1's move
            if(drawFinal)
                NS = DRAW;
            else   
                NS = P1_MOVE;
        end
        DRAW:   NS = DRAW; // remains in draw state until reset
    endcase

end

/* C update always block */
always @(posedge clk or negedge rst)
begin
    if(rst == 1'b0)
        C <= C_0;
    else
        C <= NC;
end

/* NC transitions always block */
always @(*)
begin
    case(C)
        C_0:    begin
            if(direction == 1'b0)
                NC = C_1;
            else
                NC = C_0;
        end
        C_1:    begin
            if(direction == 1'b0)
                NC = C_2;
            else
                NC = C_1;
        end
        C_2:    begin
            if(direction == 1'b0)
                NC = C_3;
            else
                NC = C_2;
        end
        C_3:    begin
            if(direction == 1'b0)
                NC = C_4;
            else
                NC = C_3;
        end
        C_4:    begin
            if(direction == 1'b0)
                NC = C_5;
            else
                NC = C_4;
        end
        C_5:    begin
            if(direction == 1'b0)
                NC = C_6;
            else
                NC = C_5;
        end
        C_6:    begin
            if(direction == 1'b0)
                NC = C_0;
            else
                NC = C_6;
        end
    endcase
end


/* changes the selected column variable based on the column state*/
always @(posedge clk or negedge rst)
begin
    case(C)
        C_0:    begin
            selectedCol <= 3'b000;
        end
        C_1:    begin
            selectedCol <= 3'b001;
        end
        C_2:    begin
            selectedCol <= 3'b010;
        end
        C_3:    begin
            selectedCol <= 3'b011;
        end
        C_4:    begin
            selectedCol <= 3'b100;
        end
        C_5:    begin
            selectedCol <= 3'b101;
        end
        C_6:    begin
            selectedCol <= 3'b110;
        end

    endcase
end

/* Column VGA */
always@(posedge clk or negedge rst)
begin
	case(selectedCol)
		3'b000:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd32;
			cell_y <= 8'd20;
		end
		3'b001:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd48;
			cell_y <= 8'd20;
		end
		3'b010:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd64;
			cell_y <= 8'd20;
		end
		3'b011:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd80;
			cell_y <= 8'd20;
		end
		3'b100:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd96;
			cell_y <= 8'd20;
		end
		3'b101:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd112;
			cell_y <= 8'd20;
		end
		3'b110:	begin
			writeEn <= 1'b1;
			cell_x <= 8'd128;
			cell_y <= 8'd20;
		end
	endcase
end

/* clocked control signals always block */
always @(posedge clk or negedge rst)
begin
    case(S)
        P1_MOVE:    begin
            if(moveChosen == 1'b0)
                case(selectedCol) // for the selected column, check if it's full or add at proper row
                    1'd0:   if(col0Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 0 + (col0Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col0Cap <= col0Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd1:   if(col1Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 1 + (col1Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col1Cap <= col1Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd2:   if(col2Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 2 + (col2Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col2Cap <= col2Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd3:   if(col3Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 3 + (col3Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col3Cap <= col3Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd0:   if(col4Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 4 + (col4Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col4Cap <= col4Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd5:   if(col5Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 5 + (col5Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col5Cap <= col5Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd6:   if(col6Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 6 + (col6Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b01;
                                col6Cap <= col6Cap + 1;
                                validMove <= 1'b1;
                            end
                endcase
        end
        CHECK_1_WIN:    begin
            validMove <= 1'b0;

        end
        WIN1:   begin // game over screen: 1 wins
            
        end
        P2_MOVE:    begin
            if(moveChosen == 1'b0)
                case(selectedCol) // for the selected column, check if it's full or add at proper row
                    1'd0:   if(col0Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 0 + (col0Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col0Cap <= col0Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd1:   if(col0Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 1 + (col1Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col1Cap <= col1Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd2:   if(col2Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 2 + (col2Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col2Cap <= col2Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd3:   if(col3Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 3 + (col3Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col3Cap <= col3Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd0:   if(col4Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 4 + (col4Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col4Cap <= col4Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd5:   if(col5Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 5 + (col5Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col5Cap <= col5Cap + 1;
                                validMove <= 1'b1;
                            end
                    1'd6:   if(col6Cap >= 1'd6)
                                validMove <= 1'b0;
                            else    begin
                                selectedCell <= 6 + (col6Cap * 2'd7);
                                gameBoard[selectedCell] <= 2'b10;
                                col6Cap <= col6Cap + 1;
                                validMove <= 1'b1;
                            end
                endcase
        end
        CHECK_2_WIN:    begin
            validMove <= 1'b0;
					
        end
        WIN2:   begin // game over screen: 2 wins
            
        end
        CHECK_DRAW: begin
            
        end
        DRAW:   begin // game over screen: draw
            
        end
	 endcase
end

always@(*)
begin
	/* Player 1 Check */
	// All Vertical Wins
	if((gameBoard[0] && gameBoard[7] && gameBoard[14] && gameBoard[21]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[28] && gameBoard[7] && gameBoard[14] && gameBoard[21]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[28] && gameBoard[35] && gameBoard[14] && gameBoard[21]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[1] && gameBoard[8] && gameBoard[15] && gameBoard[22]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[29] && gameBoard[8] && gameBoard[15] && gameBoard[22]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[29] && gameBoard[36] && gameBoard[15] && gameBoard[22]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[2] && gameBoard[9] && gameBoard[16] && gameBoard[23]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[30] && gameBoard[9] && gameBoard[16] && gameBoard[23]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[30] && gameBoard[37] && gameBoard[16] && gameBoard[23]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[3] && gameBoard[10] && gameBoard[17] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[31] && gameBoard[10] && gameBoard[17] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[31] && gameBoard[38] && gameBoard[17] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[4] && gameBoard[11] && gameBoard[18] && gameBoard[25]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[32] && gameBoard[11] && gameBoard[18] && gameBoard[25]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[32] && gameBoard[39] && gameBoard[18] && gameBoard[25]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[5] && gameBoard[12] && gameBoard[19] && gameBoard[26]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[33] && gameBoard[12] && gameBoard[19] && gameBoard[26]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[33] && gameBoard[40] && gameBoard[19] && gameBoard[26]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[6] && gameBoard[13] && gameBoard[20] && gameBoard[27]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[34] && gameBoard[13] && gameBoard[20] && gameBoard[27]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[34] && gameBoard[41] && gameBoard[20] && gameBoard[27]) == 2'b01)
		win1 = 1'b1;
	// All Horizontal Wins
	if((gameBoard[0] && gameBoard[1] && gameBoard[2] && gameBoard[3]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[4] && gameBoard[1] && gameBoard[2] && gameBoard[3]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[4] && gameBoard[5] && gameBoard[2] && gameBoard[3]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[4] && gameBoard[5] && gameBoard[6] && gameBoard[3]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[7] && gameBoard[8] && gameBoard[9] && gameBoard[10]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[11] && gameBoard[8] && gameBoard[9] && gameBoard[10]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[11] && gameBoard[12] && gameBoard[9] && gameBoard[10]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[11] && gameBoard[12] && gameBoard[13] && gameBoard[10]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[14] && gameBoard[15] && gameBoard[16] && gameBoard[17]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[18] && gameBoard[15] && gameBoard[16] && gameBoard[17]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[18] && gameBoard[19] && gameBoard[16] && gameBoard[17]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[18] && gameBoard[19] && gameBoard[20] && gameBoard[17]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[21] && gameBoard[22] && gameBoard[23] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[25] && gameBoard[22] && gameBoard[23] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[25] && gameBoard[26] && gameBoard[23] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[25] && gameBoard[26] && gameBoard[27] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[28] && gameBoard[29] && gameBoard[30] && gameBoard[31]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[32] && gameBoard[29] && gameBoard[30] && gameBoard[31]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[32] && gameBoard[33] && gameBoard[30] && gameBoard[31]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[32] && gameBoard[33] && gameBoard[34] && gameBoard[31]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[35] && gameBoard[36] && gameBoard[37] && gameBoard[38]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[39] && gameBoard[36] && gameBoard[37] && gameBoard[38]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[39] && gameBoard[40] && gameBoard[37] && gameBoard[38]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[39] && gameBoard[40] && gameBoard[41] && gameBoard[38]) == 2'b01)
		win1 = 1'b1;
	// All diagonal wins
	if((gameBoard[0] && gameBoard[8] && gameBoard[16] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[1] && gameBoard[9] && gameBoard[17] && gameBoard[25]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[2] && gameBoard[10] && gameBoard[18] && gameBoard[26]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[3] && gameBoard[11] && gameBoard[19] && gameBoard[27]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[3] && gameBoard[9] && gameBoard[15] && gameBoard[21]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[4] && gameBoard[10] && gameBoard[16] && gameBoard[22]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[5] && gameBoard[11] && gameBoard[17] && gameBoard[23]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[6] && gameBoard[12] && gameBoard[18] && gameBoard[24]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[7] && gameBoard[15] && gameBoard[23] && gameBoard[31]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[8] && gameBoard[16] && gameBoard[24] && gameBoard[32]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[9] && gameBoard[17] && gameBoard[25] && gameBoard[33]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[10] && gameBoard[18] && gameBoard[26] && gameBoard[34]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[10] && gameBoard[16] && gameBoard[22] && gameBoard[28]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[11] && gameBoard[17] && gameBoard[23] && gameBoard[29]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[12] && gameBoard[18] && gameBoard[24] && gameBoard[30]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[13] && gameBoard[19] && gameBoard[25] && gameBoard[31]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[14] && gameBoard[22] && gameBoard[30] && gameBoard[38]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[15] && gameBoard[23] && gameBoard[31] && gameBoard[39]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[16] && gameBoard[24] && gameBoard[32] && gameBoard[40]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[17] && gameBoard[25] && gameBoard[33] && gameBoard[41]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[17] && gameBoard[23] && gameBoard[29] && gameBoard[35]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[18] && gameBoard[24] && gameBoard[30] && gameBoard[36]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[19] && gameBoard[25] && gameBoard[31] && gameBoard[37]) == 2'b01)
		win1 = 1'b1;
	if((gameBoard[20] && gameBoard[26] && gameBoard[32] && gameBoard[38]) == 2'b01)
		win1 = 1'b1;
		
	/* Player 2 Check */
	// All Vertical Wins
	if((gameBoard[0] && gameBoard[7] && gameBoard[14] && gameBoard[21]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[28] && gameBoard[7] && gameBoard[14] && gameBoard[21]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[28] && gameBoard[35] && gameBoard[14] && gameBoard[21]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[1] && gameBoard[8] && gameBoard[15] && gameBoard[22]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[29] && gameBoard[8] && gameBoard[15] && gameBoard[22]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[29] && gameBoard[36] && gameBoard[15] && gameBoard[22]) == 2'b01)
		win2 = 1'b1;
	if((gameBoard[2] && gameBoard[9] && gameBoard[16] && gameBoard[23]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[30] && gameBoard[9] && gameBoard[16] && gameBoard[23]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[30] && gameBoard[37] && gameBoard[16] && gameBoard[23]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[3] && gameBoard[10] && gameBoard[17] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[31] && gameBoard[10] && gameBoard[17] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[31] && gameBoard[38] && gameBoard[17] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[4] && gameBoard[11] && gameBoard[18] && gameBoard[25]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[32] && gameBoard[11] && gameBoard[18] && gameBoard[25]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[32] && gameBoard[39] && gameBoard[18] && gameBoard[25]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[5] && gameBoard[12] && gameBoard[19] && gameBoard[26]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[33] && gameBoard[12] && gameBoard[19] && gameBoard[26]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[33] && gameBoard[40] && gameBoard[19] && gameBoard[26]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[6] && gameBoard[13] && gameBoard[20] && gameBoard[27]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[34] && gameBoard[13] && gameBoard[20] && gameBoard[27]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[34] && gameBoard[41] && gameBoard[20] && gameBoard[27]) == 2'b10)
		win2 = 1'b1;
	// All Horizontal Wins
	if((gameBoard[0] && gameBoard[1] && gameBoard[2] && gameBoard[3]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[4] && gameBoard[1] && gameBoard[2] && gameBoard[3]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[4] && gameBoard[5] && gameBoard[2] && gameBoard[3]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[4] && gameBoard[5] && gameBoard[6] && gameBoard[3]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[7] && gameBoard[8] && gameBoard[9] && gameBoard[10]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[11] && gameBoard[8] && gameBoard[9] && gameBoard[10]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[11] && gameBoard[12] && gameBoard[9] && gameBoard[10]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[11] && gameBoard[12] && gameBoard[13] && gameBoard[10]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[14] && gameBoard[15] && gameBoard[16] && gameBoard[17]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[18] && gameBoard[15] && gameBoard[16] && gameBoard[17]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[18] && gameBoard[19] && gameBoard[16] && gameBoard[17]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[18] && gameBoard[19] && gameBoard[20] && gameBoard[17]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[21] && gameBoard[22] && gameBoard[23] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[25] && gameBoard[22] && gameBoard[23] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[25] && gameBoard[26] && gameBoard[23] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[25] && gameBoard[26] && gameBoard[27] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[28] && gameBoard[29] && gameBoard[30] && gameBoard[31]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[32] && gameBoard[29] && gameBoard[30] && gameBoard[31]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[32] && gameBoard[33] && gameBoard[30] && gameBoard[31]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[32] && gameBoard[33] && gameBoard[34] && gameBoard[31]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[35] && gameBoard[36] && gameBoard[37] && gameBoard[38]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[39] && gameBoard[36] && gameBoard[37] && gameBoard[38]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[39] && gameBoard[40] && gameBoard[37] && gameBoard[38]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[39] && gameBoard[40] && gameBoard[41] && gameBoard[38]) == 2'b10)
		win2 = 1'b1;
	// All diagonal wins
	if((gameBoard[0] && gameBoard[8] && gameBoard[16] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[1] && gameBoard[9] && gameBoard[17] && gameBoard[25]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[2] && gameBoard[10] && gameBoard[18] && gameBoard[26]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[3] && gameBoard[11] && gameBoard[19] && gameBoard[27]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[3] && gameBoard[9] && gameBoard[15] && gameBoard[21]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[4] && gameBoard[10] && gameBoard[16] && gameBoard[22]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[5] && gameBoard[11] && gameBoard[17] && gameBoard[23]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[6] && gameBoard[12] && gameBoard[18] && gameBoard[24]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[7] && gameBoard[15] && gameBoard[23] && gameBoard[31]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[8] && gameBoard[16] && gameBoard[24] && gameBoard[32]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[9] && gameBoard[17] && gameBoard[25] && gameBoard[33]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[10] && gameBoard[18] && gameBoard[26] && gameBoard[34]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[10] && gameBoard[16] && gameBoard[22] && gameBoard[28]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[11] && gameBoard[17] && gameBoard[23] && gameBoard[29]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[12] && gameBoard[18] && gameBoard[24] && gameBoard[30]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[13] && gameBoard[19] && gameBoard[25] && gameBoard[31]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[14] && gameBoard[22] && gameBoard[30] && gameBoard[38]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[15] && gameBoard[23] && gameBoard[31] && gameBoard[39]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[16] && gameBoard[24] && gameBoard[32] && gameBoard[40]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[17] && gameBoard[25] && gameBoard[33] && gameBoard[41]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[17] && gameBoard[23] && gameBoard[29] && gameBoard[35]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[18] && gameBoard[24] && gameBoard[30] && gameBoard[36]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[19] && gameBoard[25] && gameBoard[31] && gameBoard[37]) == 2'b10)
		win2 = 1'b1;
	if((gameBoard[20] && gameBoard[26] && gameBoard[32] && gameBoard[38]) == 2'b10)
		win2 = 1'b1;
end

endmodule

