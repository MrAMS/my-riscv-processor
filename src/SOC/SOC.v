`default_nettype none
`include "Clock.v"
`include "Memory.v"
`include "Processor.v"
module SOC(
    input   wire        CLK,
    input   wire        RST,
    output  wire[7:0]   LED,
    input   RXD,
    output  TXD
);
    wire clk;
    wire resetn;

    wire [31:0] mem_addr;
    wire [31:0] mem_rdata;
    wire mem_rstrb;
    Memory RAM(
        .clk(clk),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb)
    );

    wire [31:0] x1;
    Processor CPU(
        .clk(clk),
        .resetn(resetn),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb),
        .x1(x1)
    );

    assign LED = x1[7:0];

    Clock #(
        `ifdef TEST_BENCH
        .DIV(1)
        `else
        .DIV(22)
        `endif
    )
    CK(
        .CLK(CLK),
        .RST(RST),
        .clk(clk),
        .resetn(resetn)
    );

    assign TXD = 1'b0;

endmodule