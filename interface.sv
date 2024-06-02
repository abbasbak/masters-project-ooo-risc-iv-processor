
interface InstructionInterface;
  logic  [31:0]  firstinstruction;
  logic  [31:0]  secondinstruction;
endinterface


interface DecodeInterface;
  // Signals related to the first instruction
  logic [31:0] firstinstruction;
  logic [6:0] opcode1;
  logic [4:0] rs1_1;
  logic [4:0] rs2_1;
  logic [4:0] rd_1;
  logic regWrite1;
  logic [2:0] aluOp1;
  logic aluSrc1;
  logic memWrite1;
  logic memRead1;
  logic memtoReg1;
  logic signed [31:0] imm1;

  // Signals related to the second instruction
  logic [31:0] secondinstruction;
  logic [6:0] opcode2;
  logic [4:0] rs1_2;
  logic [4:0] rs2_2;
  logic [4:0] rd_2;
  logic regWrite2;
  logic [2:0] aluOp2;
  logic aluSrc2;
  logic memWrite2;
  logic memRead2;
  logic memtoReg2;
  logic signed [31:0] imm2;
endinterface


interface RegisterRenamingInterface;
  logic [4:0] src1_instr;
  logic [4:0] src2_instr;
  logic [4:0] dest_instr;
  logic [4:0] src1_instr2;
  logic [4:0] src2_instr2;
  logic [4:0] dest_instr2;

  logic [5:0] src1_phys;
  logic [5:0] src2_phys;
  logic [5:0] dest_phys;
  logic [5:0] src1_phys2;
  logic [5:0] src2_phys2;
  logic [5:0] dest_phys2;

  // Pass in the extra items from decode that 
  // will be eventually needed by dispatch
  // (don't need the architectural registers since creating 
  // the physical registers in this stage)

  // Signals related to the first instruction
  logic [6:0] renameopcode1;
  logic regWrite1;
  logic [2:0] aluOp1;
  logic aluSrc1;
  logic memWrite1;
  logic memRead1;
  logic memtoReg1;
  logic signed [31:0] imm1;

  // Signals related to the second instruction
  logic [6:0] renameopcode2;
  logic regWrite2;
  logic [2:0] aluOp2;
  logic aluSrc2;
  logic memWrite2;
  logic memRead2;
  logic memtoReg2;
  logic signed [31:0] imm2;

  logic ready_src1_instr;
  logic ready_src2_instr;
  logic ready_src1_instr2;
  logic ready_src2_instr2;
  logic [63:0] readyregs;

  logic [5:0] overwrittendest_phys1;
  logic [5:0] overwrittendest_phys2;

  logic [4:0] destihold;
  logic [4:0] destihold2; 

  logic [5:0] free_regs [0:1]; 


endinterface

interface DispatchingInterface;
  logic [5:0] src1_phys;
  logic [5:0] src2_phys;
  logic [5:0] dest_phys;
  logic [5:0] src1_phys2;
  logic [5:0] src2_phys2;
  logic [5:0] dest_phys2;

  // Info that is coming in from decode->rename->dispatch

  // Signals related to the first instruction
  logic [6:0] dispatchopcode1;
  logic regWrite1;
  logic [2:0] aluOp1;
  logic aluSrc1;
  logic memWrite1;
  logic memRead1;
  logic memtoReg1;
  logic signed [31:0] imm1;

  // Signals related to the second instruction
  logic [6:0] opcode2;
  logic regWrite2;
  logic [2:0] aluOp2;
  logic aluSrc2;
  logic memWrite2;
  logic memRead2;
  logic memtoReg2;
  logic signed [31:0] imm2;
  logic [84:0] rs_array[0:15];
  logic [18:0] rob[0:15];

  logic ready_src1_instr;
  logic ready_src2_instr;
  logic ready_src1_instr2;
  logic ready_src2_instr2;
  logic [63:0] readyregs;

  logic [5:0] overwrittendest_phys1;
  logic [5:0] overwrittendest_phys2;

  logic [4:0] destihold;
  logic [4:0] destihold2;

  logic [15:0] complete_array;
  logic [3:0] retire_rob [0:1];
  logic [3:0] clear_rs [0:2];

endinterface

interface FireInterface;
  logic [84:0] rs_array[0:15];
  logic [18:0] rob[0:15];
  logic [31:0] physregisters [63:0];
  logic [15:0] complete_array;
  logic [31:0] store_address;
  logic [31:0] store_value;
  logic [31:0] load_address;
  logic [15:0] store_complete_array;
  logic [31:0] memory [0:1023];
  logic [3:0] clear_rs [0:2];
endinterface


interface RetireInterface;
  logic [18:0] rob[0:15];
  logic [31:0] physregisters [63:0];
  logic [31:0] regfile [0:31];
  logic [15:0] complete_array;
  logic [31:0] store_address;
  logic [31:0] store_value;
  logic [31:0] load_address;
  logic [15:0] store_complete_array;
  logic [31:0] memory [0:1023];
  logic [3:0] retire_rob [0:1];
  logic [5:0] free_regs [0:1];
endinterface

