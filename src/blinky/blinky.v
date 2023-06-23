module blinky(
    input CLK,
    input RST,
    output LED,
    input RXD,
    output TXD
);

    reg [25:0] counter;

    assign LED = counter[23];
    assign TXD = 1'b0;

    initial begin
        counter = 0;
    end

    always @(posedge CLK)
    begin
        counter <= counter + 1;
    end

endmodule