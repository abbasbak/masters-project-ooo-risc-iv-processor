
module Decode2 (
  input logic clk,
  input logic [31:0] firstinstruction,
  input logic [31:0] secondinstruction,
  output logic [6:0] opcode1,
  output logic [6:0] opcode2,
  output logic [4:0] rs1_1,
  output logic [4:0] rs1_2,
  output logic [4:0] rs2_1,
  output logic [4:0] rs2_2,
  output logic [4:0] rd_1,
  output logic [4:0] rd_2,
  output logic regWrite1,
  output logic regWrite2,
  output logic [2:0] aluOp1,
  output logic [2:0] aluOp2,
  output logic aluSrc1,
  output logic aluSrc2,
  output logic memWrite1,
  output logic memWrite2,
  output logic memRead1,
  output logic memRead2,
  output logic memtoReg1,
  output logic memtoReg2,
  output logic signed [31:0] imm1,
  output logic signed [31:0] imm2
);

  static logic [2:0] funct3_1, funct3_2;
  static logic [6:0] funct7_1, funct7_2;

logic [6:0] firstopcode1;
logic [6:0] firstopcode2;
logic [2:0] firstfunct3_1;
logic [2:0] firstfunct3_2;
logic [6:0] firstfunct7_1;
logic [6:0] firstfunct7_2;

always_ff @(posedge clk) begin
    firstopcode1 <= firstinstruction[6:0];
    firstopcode2 <= secondinstruction[6:0];
    firstfunct3_1 <= firstinstruction[14:12];
    firstfunct3_2 <= secondinstruction[14:12];
    firstfunct7_1 <= firstinstruction[31:25];
    firstfunct7_2 <= secondinstruction[31:25];
end

always_ff @(posedge clk) begin
    //$display("firstinstruction = %b, secondinstruction = %b", firstinstruction, secondinstruction);
    //$display("opcode1 = %b, opcode2 = %b",opcode1, opcode2);

    opcode1 = firstopcode1;
    opcode2 = firstopcode2;
    funct3_1 = firstfunct3_1;
    funct3_2 = firstfunct3_2;
    funct7_1 =firstfunct7_1;
    funct7_2 = firstfunct7_2;

    // Decode logic for the first instruction
    case (firstinstruction[6:0])
      7'b0010011: begin // ADDI and ANDI
        rs1_1 <= firstinstruction[19:15];
	rs2_1 <= 0;
        rd_1 <= firstinstruction[11:7];
        imm1 <= {{20{firstinstruction[31]}}, firstinstruction[31:20]}; 
        regWrite1 <= 1;
	//$display("funct3_1 = %b",funct3_1);

if (firstinstruction[14:12] == 3'b000) begin
aluOp1 <= 3'b000; // ADDI 
            aluSrc1 <= 0;
end

if (firstinstruction[14:12] == 3'b111) begin
aluOp1 <= 3'b111; // ANDI 
            aluSrc1 <= 0;
end

        memWrite1 <= 0;
        memRead1 <= 0;
        memtoReg1 <= 0;
      end

      7'b0110011: begin // ADD, SUB, AND, XOR, SRA
        rs1_1 <= firstinstruction[19:15];
        rs2_1 <= firstinstruction[24:20];
        rd_1 <= firstinstruction[11:7];
        regWrite1 <= 1;
        imm1 <= 0;

if (firstinstruction[14:12] == 3'b000) begin
if (firstinstruction[31:25] == 7'b0000000) begin
aluOp1 <= 3'b000; // ADD 
            	aluSrc1 <= 0;
end
if (firstinstruction[31:25] == 7'b0100000) begin
aluOp1 <= 3'b001; // SUB 
            	aluSrc1 <= 0;
end
end

if (firstinstruction[14:12] == 3'b100) begin
  aluOp1 <= 3'b100; // XOR 
            aluSrc1 <= 0;
end

if (firstinstruction[14:12] == 3'b101) begin
  aluOp1 <= 3'b101; // SRA 
            aluSrc1 <= 0;
end
        memWrite1 <= 0;
        memRead1 <= 0;
        memtoReg1 <= 0;
      end

      7'b0100011: begin // SW
        rs1_1 <= firstinstruction[19:15];
        rs2_1 <= firstinstruction[24:20];
	rd_1 <= 0;
        imm2 <= {secondinstruction[31:25], secondinstruction[11:7]};
        regWrite1 <= 0;
        aluOp1 <= 3'b000;
        aluSrc1 <= 1;
        memWrite1 <= 1;
        memRead1 <= 0;
        memtoReg1 <= 0;
      end

	7'b0000011: begin // LW
        rs1_1 <= firstinstruction[19:15];
	rs2_1 <= 0;
        rd_1 <= firstinstruction[11:7];
        imm1 <= {{20{firstinstruction[31]}}, firstinstruction[31:20]}; 
        regWrite1 <= 1;
        aluOp1 <= 3'b000; 
        aluSrc1 <= 1;
        memWrite1 <= 0;
        memRead1 <= 1;
        memtoReg1 <= 1;
      end

      default: begin
        rs1_1 <= 5'bxxxxx; 
        rs2_1 <= 5'bxxxxx;
        rd_1 <= 5'bxxxxx; 
        regWrite1 <= 1'bx; 
        aluOp1 <= 3'bxxx; 
        aluSrc1 <= 1'bx;
        memWrite1 <= 1'bx; 
        memRead1 <= 1'bx; 
        memtoReg1 <= 1'bx;
	imm1 <= 1'bx;
        // $display("Debug: Unknown opcode detected for instruction 1");
      end
    endcase


 // Decode logic for the second instruction
    case (secondinstruction[6:0])
      7'b0010011: begin // ADDI and ANDI
        rs1_2 <= secondinstruction[19:15];
	rs2_2 <= 0;
        rd_2 <= secondinstruction[11:7];
        imm2 <= {{20{secondinstruction[31]}}, secondinstruction[31:20]}; 
        regWrite2 <= 1;

	if (secondinstruction[14:12] == 3'b000) begin
	aluOp2 <= 3'b000; // ADDI 
            aluSrc2 <= 0;
	end

	if (secondinstruction[14:12] == 3'b111) begin
	aluOp2 <= 3'b111; // ANDI 
            aluSrc2 <= 0;
	end

        memWrite2 <= 0;
        memRead2 <= 0;
        memtoReg2 <= 0;
      end

      7'b0110011: begin // ADD, SUB, XOR, SRA
        rs1_2 <= secondinstruction[19:15];
        rs2_2 <= secondinstruction[24:20];
        rd_2 <= secondinstruction[11:7];
        regWrite2 <= 1;
        imm2 <= 0;

if (secondinstruction[14:12] == 3'b000) begin
if (secondinstruction[31:25] == 7'b0000000) begin
aluOp2 <= 3'b000; // ADD 
            	aluSrc2 <= 0;
end
if (secondinstruction[31:25] == 7'b0100000) begin
aluOp2 <= 3'b001; // SUB 
            	aluSrc2 <= 0;
end
end

if (secondinstruction[14:12] == 3'b100) begin
  aluOp2 <= 3'b100; // XOR 
            aluSrc1 <= 0;
end

if (secondinstruction[14:12] == 3'b101) begin
  aluOp2 <= 3'b101; // SRA 
            aluSrc2 <= 0;
end

        memWrite2 <= 0;
        memRead2 <= 0;
        memtoReg2 <= 0;
      end

      7'b0100011: begin // SW
        rs1_2 <= secondinstruction[19:15];
        rs2_2 <= secondinstruction[24:20];
	rd_2 <= 0;
        imm2 <= {secondinstruction[31:25], secondinstruction[11:7]};
        regWrite2 <= 0;
        aluOp2 <= 3'b000; 
        aluSrc2 <= 1;
        memWrite2 <= 1;
        memRead2 <= 0;
        memtoReg2 <= 0;
      end


	7'b0000011: begin // LW
        rs1_2 <= secondinstruction[19:15];
	rs2_2 <= 0;
        rd_2 <= secondinstruction[11:7];
        imm2 <= {{20{secondinstruction[31]}}, secondinstruction[31:20]}; 
        regWrite2 <= 1;
        aluOp2 <= 3'b000; 
        aluSrc2 <= 1;
        memWrite2 <= 0;
        memRead2 <= 1;
        memtoReg2 <= 1;
      end

      default: begin
        rs1_2 <= 5'bxxxxx; 
        rs2_2 <= 5'bxxxxx; 
        rd_2 <= 5'bxxxxx; 
        regWrite2 <= 1'bx; 
        aluOp2 <= 3'bxxx; 
        aluSrc2 <= 1'bx; 
        memWrite2 <= 1'bx;
        memRead2 <= 1'bx; 
        memtoReg2 <= 1'bx; 
	imm2 <= 1'bx;
        //$display("Debug: Unknown opcode detected for instruction 2");
      end
    endcase

    // Additional debug information if needed

    $display("Debug: rd_1=%0d, rs1_1=%0d, rs2_1=%0d, imm_1=%d", rd_1, rs1_1, rs2_1, imm1);
    $display("Debug: regWrite_1=%0b, aluOp_1=%0b, aluSrc_1=%0b", regWrite1, aluOp1, aluSrc1);
    $display("Debug: memWrite_1=%0b, memRead_1=%0b, memtoReg_1=%0b", memWrite1, memRead1, memtoReg1);

    $display("Debug: rd_2=%0d, rs1_2=%0d, rs2_2=%0d, imm_2=%d", rd_2, rs1_2, rs2_2, imm2);
    $display("Debug: regWrite_2=%0b, aluOp_2=%0b, aluSrc_2=%0b", regWrite2, aluOp2, aluSrc2);
    $display("Debug: memWrite_2=%0b, memRead_2=%0b, memtoReg_2=%0b", memWrite2, memRead2, memtoReg2);

end
endmodule
