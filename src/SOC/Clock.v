module Clock(
    input   wire    CLK,
    input   wire    RST,
    output  wire    clk,
    output  reg     resetn
);
    parameter DIV=0;
    reg [DIV:0] counter = 0;
    always @(posedge CLK) begin
        counter <= counter + 1;
        resetn <= !RST;
    end
    assign clk = counter[DIV];

endmodule