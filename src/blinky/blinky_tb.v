`timescale 1ns/100ps
module blinky_tb();
    reg  CLK;
    wire RST;
    wire LED;
    reg  RXD;
    wire TXD;

    blinky uut(
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

    initial
    begin            
        $dumpfile("wave.vcd");
        $dumpvars(0, blinky_tb);
        #100;
        $finish;
    end
endmodule   