`default_nettype none
`include "Clock.v"
module SOC(
    input   wire        CLK,
    input   wire        RST,
    output  wire[7:0]   LED,
    input   RXD,
    output  TXD
);
    wire clk;
    wire resetn;
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
    reg [31:0] MEM [0:255];
    reg [31:0] PC;          // program counter
    reg [31:0] instr;       // current instruction
    `include "riscv_assembly.v"

    initial begin
        PC = 0;
        ADD(x0,x0,x0);
        ADD(x1,x0,x0);
        ADDI(x1,x1,1);
        ADDI(x1,x1,1);
        ADDI(x1,x1,1);
        ADDI(x1,x1,1);
        ADD(x2,x1,x0);
        ADD(x3,x1,x2);
        SRLI(x3,x3,3);
        SLLI(x3,x3,31);
        SRAI(x3,x3,5);
        SRLI(x1,x3,26);
        EBREAK();
    end

    reg [31:0] RegisterBank [0:31];
    `ifdef TEST_BENCH   
    integer i;
    initial begin
        for(i=0; i<32; ++i) begin
            RegisterBank[i] = 0;
        end
    end
    `endif  
    reg [31:0] rs1;
    reg [31:0] rs2;

    wire isALUreg  =  (instr[6:0] == 7'b0110011); // rd <- rs1 OP rs2   
    wire isALUimm  =  (instr[6:0] == 7'b0010011); // rd <- rs1 OP Iimm
    wire isBranch  =  (instr[6:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
    wire isJALR    =  (instr[6:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
    wire isJAL     =  (instr[6:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
    wire isAUIPC   =  (instr[6:0] == 7'b0010111); // rd <- PC + Uimm
    wire isLUI     =  (instr[6:0] == 7'b0110111); // rd <- Uimm   
    wire isLoad    =  (instr[6:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
    wire isStore   =  (instr[6:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
    wire isSYSTEM  =  (instr[6:0] == 7'b1110011); // special

    // R-type instruction format
    wire [4:0] rs1Id = instr[19:15];
    wire [4:0] rs2Id = instr[24:20];
    wire [4:0] rdId  = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    // immediate value
    wire [31:0] Uimm={    instr[31],   instr[30:12], {12{1'b0}}};
    wire [31:0] Iimm={{21{instr[31]}}, instr[30:20]};
    wire [31:0] Simm={{21{instr[31]}}, instr[30:25],instr[11:7]};
    wire [31:0] Bimm={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
    wire [31:0] Jimm={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

    // ALU
    wire [31:0] aluIn1 = rs1;
    wire [31:0] aluIn2 = isALUreg ? rs2 : Iimm;
    reg [31:0] aluOut;

    wire [31:0] writeBackData;
    wire writeBackEn;
    assign writeBackData = aluOut; 
    assign writeBackEn = (state == EXECUTE && (isALUreg || isALUimm)); 

    wire [4:0] shamt = isALUreg ? rs2[4:0] : instr[24:20]; // shift amount
    
    always @(*) begin // combinatorial block
        case(funct3)
            // SUB <- funct[7]==1 && instr[5]==1(ALUimm don't have SUB)
            3'b000: aluOut = (funct7[5] & instr[5]) ? (aluIn1-aluIn2) : (aluIn1+aluIn2);
            // left shift
            3'b001: aluOut = aluIn1 << shamt;
            // 	signed comparison (<)
            3'b010: aluOut = ($signed(aluIn1) < $signed(aluIn2));
            // unsigned comparison (<)
            3'b011: aluOut = (aluIn1 < aluIn2);
            // XOR
            3'b100: aluOut = (aluIn1 ^ aluIn2);
            // logical right shift(0) or arithmetic right shift(1)
            3'b101: aluOut = funct7[5]? ($signed(aluIn1) >>> shamt) : (aluIn1 >> shamt); 
            // OR
            3'b110: aluOut = (aluIn1 | aluIn2);
            // AND
            3'b111: aluOut = (aluIn1 & aluIn2);	
        endcase
    end



    localparam FETCH_INSTR = 0;
    localparam FETCH_REGS  = 1;
    localparam EXECUTE     = 2;
    reg [1:0] state = FETCH_INSTR;

    always @(posedge clk) begin
        if(!resetn) begin
            PC <= 0;
            state <= FETCH_INSTR;
            instr <= 32'b0000000_00000_00000_000_00000_0110011; // NOP
        end else begin
            
            if(writeBackEn && rdId != 0) begin
                RegisterBank[rdId] <= writeBackData;
            end

            case(state)
                FETCH_INSTR: begin
                    instr <= MEM[PC[31:2]];
                    state <= FETCH_REGS;
                end
                FETCH_REGS: begin
                    rs1 <= RegisterBank[rs1Id];
                    rs2 <= RegisterBank[rs2Id];
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    if(!isSYSTEM) begin
                        PC <= PC + 4;
                    end
                    state <= FETCH_INSTR;	      
                end
            endcase

            `ifdef TEST_BENCH      
            if(isSYSTEM) $finish();
            `endif 
        end
    end

    
    assign LED = isSYSTEM ? 8'b1111_1111 : {PC[0],isALUreg,isALUimm,isLoad,isStore,3'b0};
    assign TXD = 1'b0;

    `ifdef TEST_BENCH  
    always @(posedge clk) begin
        $display("PC=%0d",PC);
        case (1'b1)
            isALUreg: $display(
                "ALUreg rd=%d rs1=%d rs2=%d funct3=%b",
                    rdId, rs1Id, rs2Id, funct3
            );
            isALUimm: $display(
                "ALUimm rd=%d rs1=%d imm=%0d funct3=%b",
                    rdId, rs1Id, Iimm, funct3
            );
            isBranch: $display("BRANCH");
            isJAL:    $display("JAL");
            isJALR:   $display("JALR");
            isAUIPC:  $display("AUIPC");
            isLUI:    $display("LUI");	
            isLoad:   $display("LOAD");
            isStore:  $display("STORE");
            isSYSTEM: $display("SYSTEM");
            default:  $display("UNKOWN");
        endcase 
    end
    `endif

endmodule