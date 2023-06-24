module SOC(
    input CLK,
    input RST,
    output LED,
    input RXD,
    output TXD
);
    wire clk;
    wire resetn;
    Clock #(.DIV(23))
    CK(
        .CLK(CLK),
        .RST(RST),
        .clk(clk),
        .resetn(resetn)
    );

    assign LED = clk;
    assign TXD = 1'b0;

endmodule