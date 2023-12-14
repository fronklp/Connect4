module randomizer (go, CLOCK_50, out);
    input go; 
    input CLOCK_50;
    output reg [2:0] o = 3'b000;
    always @ (posedge CLOCK_50)
    begin
        if (go)
            begin
                if (o == 3'b111)
                    o <= 3'b000;
                else 
                    o <= o + 1'b1;
            end
        out <= o;
    end
endmodule