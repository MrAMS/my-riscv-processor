module Clock(
    input   CLK,
    input   RST,
    output  clk,
    output  resetn
);
    parameter DIV=0;
    reg [DIV:0] counter = 0;
    always @(posedge CLK) begin
        counter <= counter + 1;
    end
    assign clk = counter[DIV];

endmodule