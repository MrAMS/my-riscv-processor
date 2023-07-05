`timescale 1ns/100ps
`define TEST_BENCH
`define BENCH
`include "SOC.v"
module SOC_tb();
    reg         CLK;
    reg         RST;
    wire [7:0]  LED;
    reg         RXD;
    wire        TXD;

    SOC uut(
        .CLK(CLK),
        .RST(RST),
        .LED(LED),
        .RXD(RXD),
        .TXD(TXD)
    );

    initial begin
        CLK = 0;
        forever begin
            #1 CLK = ~CLK;
        end
    end

    initial begin
        RST = 1;
        #2
        RST = 0;
        #10
        RST = 1;
        #10
        RST = 0;
    end

    initial
    begin            
        $dumpfile("wave.vcd");
        $dumpvars(0, SOC_tb);
        #1000;
        $finish;
    end
endmodule   