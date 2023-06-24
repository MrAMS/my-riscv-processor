`include "Clock.v"
module SOC(
    input   wire        CLK,
    input   wire        RST,
    output  reg[7:0]    LED,
    input   RXD,
    output  TXD
);
    wire clk;
    wire resetn;
    Clock #(.DIV(22))
    CK(
        .CLK(CLK),
        .RST(RST),
        .clk(clk),
        .resetn(resetn)
    );
    reg [7:0] MEM [0:7];
    integer i;
    initial begin
        MEM[0]  = 7'b0000001;
        for (i=1;i<=7;i=i+1) begin
            MEM[i] = (MEM[i-1] << 1);
        end
        PC = 0;
        LED = 0;
    end
    reg [4:0] PC;
    always @(posedge clk) begin
        LED <= MEM[PC];
        PC <= (!resetn || PC==7) ? 0 : (PC+1);
    end
    assign TXD = 1'b0;

endmodule