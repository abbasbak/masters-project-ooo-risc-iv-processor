
module TopModule;

  reg clk;

  reg reset;

  InstructionInterface myInterface();

  DecodeInterface decodeInterface();

  RegisterRenamingInterface renamingInterface();

  DispatchingInterface dispatchinterface();

  FireInterface fireinterface();

  RetireInterface retireinterface();

  // Module instantiation of Fetch module
  Fetch2 myModule (
    .clk(clk),
    .firstinstruction(myInterface.firstinstruction),
    .secondinstruction(myInterface.secondinstruction)
  );

// Module instantiation of Decode module
 Decode2 decodeModule (
  .clk(clk),
  .firstinstruction(decodeInterface.firstinstruction),
  .secondinstruction(decodeInterface.secondinstruction),
  .opcode1(decodeInterface.opcode1),
  .rs1_1(decodeInterface.rs1_1),
  .rs2_1(decodeInterface.rs2_1),
  .rd_1(decodeInterface.rd_1),
  .regWrite1(decodeInterface.regWrite1),
  .aluOp1(decodeInterface.aluOp1),
  .aluSrc1(decodeInterface.aluSrc1),
  .memWrite1(decodeInterface.memWrite1),
  .memRead1(decodeInterface.memRead1),
  .memtoReg1(decodeInterface.memtoReg1),
  .imm1(decodeInterface.imm1),
  .opcode2(decodeInterface.opcode2),
  .rs1_2(decodeInterface.rs1_2),
  .rs2_2(decodeInterface.rs2_2),
  .rd_2(decodeInterface.rd_2),
  .regWrite2(decodeInterface.regWrite2),
  .aluOp2(decodeInterface.aluOp2),
  .aluSrc2(decodeInterface.aluSrc2),
  .memWrite2(decodeInterface.memWrite2),
  .memRead2(decodeInterface.memRead2),
  .memtoReg2(decodeInterface.memtoReg2),
  .imm2(decodeInterface.imm2)
);


// Module instantiation of Rename module
  RegisterRenaming renamingModule (
    .clk(clk),
    .src1_instr(renamingInterface.src1_instr),
    .src2_instr(renamingInterface.src2_instr),
    .dest_instr(renamingInterface.dest_instr),
    .src1_instr2(renamingInterface.src1_instr2),
    .src2_instr2(renamingInterface.src2_instr2),
    .dest_instr2(renamingInterface.dest_instr2),
    .rename_enable(1'b1),
    .src1_phys(renamingInterface.src1_phys),
    .src2_phys(renamingInterface.src2_phys),
    .dest_phys(renamingInterface.dest_phys),
    .src1_phys2(renamingInterface.src1_phys2),
    .src2_phys2(renamingInterface.src2_phys2),
    .dest_phys2(renamingInterface.dest_phys2),
    .reset(reset),

  //  .outrenameopcode1(predispatchinterface.outrenameopcode1),
  //  .outrenameopcode2(predispatchinterface.outrenameopcode2),

    .renameopcode1(renamingInterface.renameopcode1),
    .renameopcode2(renamingInterface.renameopcode2),

    .ready_src1_instr(renamingInterface.ready_src1_instr),
    .ready_src2_instr(renamingInterface.ready_src2_instr),
    .ready_src1_instr2(renamingInterface.ready_src1_instr2),
    .ready_src2_instr2(renamingInterface.ready_src2_instr2),
    .readyregs(renamingInterface.readyregs),

    .overwrittendest_phys1(renamingInterface.overwrittendest_phys1),
    .overwrittendest_phys2(renamingInterface.overwrittendest_phys2),

    .destihold(renamingInterface.destihold),
    .destihold2(renamingInterface.destihold2),
    .free_regs(renamingInterface.free_regs)
  );

// Module instantiation of Dispatch module
  Dispatch2 dispatchModule (
    .clk(clk),
    .src1_phys(dispatchinterface.src1_phys),
    .src2_phys(dispatchinterface.src2_phys),
    .dest_phys(dispatchinterface.dest_phys),
    .src1_phys2(dispatchinterface.src1_phys2),
    .src2_phys2(dispatchinterface.src2_phys2),
    .dest_phys2(dispatchinterface.dest_phys2),

   // Signals that came from decode->rename->dispatch
  .dispatchopcode1(dispatchinterface.dispatchopcode1),
  .regWrite1(dispatchinterface.regWrite1),
  .aluOp1(dispatchinterface.aluOp1),
  .aluSrc1(dispatchinterface.aluSrc1),
  .memWrite1(dispatchinterface.memWrite1),
  .memRead1(dispatchinterface.memRead1),
  .memtoReg1(dispatchinterface.memtoReg1),
  .imm1(dispatchinterface.imm1),
  .decode_enable(1'b1),
  .opcode2(dispatchinterface.opcode2),
  .regWrite2(dispatchinterface.regWrite2),
  .aluOp2(dispatchinterface.aluOp2),
  .aluSrc2(dispatchinterface.aluSrc2),
  .memWrite2(dispatchinterface.memWrite2),
  .memRead2(dispatchinterface.memRead2),
  .memtoReg2(dispatchinterface.memtoReg2),
  .imm2(dispatchinterface.imm2),
  .rs_array(dispatchinterface.rs_array),
  .rob(dispatchinterface.rob),

  .ready_src1_instr(dispatchinterface.ready_src1_instr),
  .ready_src2_instr(dispatchinterface.ready_src2_instr),
  .ready_src1_instr2(dispatchinterface.ready_src1_instr2),
  .ready_src2_instr2(dispatchinterface.ready_src2_instr2),
  .readyregs(dispatchinterface.readyregs),

  .overwrittendest_phys1(dispatchinterface.overwrittendest_phys1),
  .overwrittendest_phys2(dispatchinterface.overwrittendest_phys2),

  .destihold(dispatchinterface.destihold),
  .destihold2(dispatchinterface.destihold2),
  .complete_array(dispatchinterface.complete_array),
  .retire_rob(dispatchinterface.retire_rob),

  .clear_rs(dispatchinterface.clear_rs)
  );

// Module instantiation of Fire module
Fire2 fireModule (
  .clk(clk),
  .rs_array(fireinterface.rs_array),
  .rob(fireinterface.rob),
  .physregisters(fireinterface.physregisters),
  .complete_array(fireinterface.complete_array),
  .store_address(fireinterface.store_address),
  .store_value(fireinterface.store_value),
  .load_address(fireinterface.load_address),
  .store_complete_array(fireinterface.store_complete_array),
  .memory(fireinterface.memory),
  .clear_rs(fireinterface.clear_rs)
  );

// Module instantiation of Retire module
Retire2 retireModule (
  .clk(clk),
  .rob(retireinterface.rob),
  .physregisters(retireinterface.physregisters),
  .complete_array(retireinterface.complete_array),
  .store_address(retireinterface.store_address),
  .store_value(retireinterface.store_value),
  .load_address(retireinterface.load_address),
  .store_complete_array(retireinterface.store_complete_array),
  .memory(retireinterface.memory),
  .retire_rob(retireinterface.retire_rob),
  .free_regs(retireinterface.free_regs)
  );


  // Connect the fetch output to the decode input
 always_comb begin
    decodeInterface.firstinstruction  = myInterface.firstinstruction;
    decodeInterface.secondinstruction = myInterface.secondinstruction;
  end;


// Connect the renaming output to the decode input
always_comb begin
  renamingInterface.src1_instr = decodeInterface.rs1_1;
  renamingInterface.src2_instr = decodeInterface.rs2_1;
  renamingInterface.dest_instr = decodeInterface.rd_1;

  renamingInterface.src1_instr2 = decodeInterface.rs1_2; 
  renamingInterface.src2_instr2 = decodeInterface.rs2_2;
  renamingInterface.dest_instr2 = decodeInterface.rd_2;

  // Pass through the items from Decode that
  // will eventually be used by dispatch
  renamingInterface.renameopcode1 = decodeInterface.opcode1;
  renamingInterface.regWrite1 = decodeInterface.regWrite1;
  renamingInterface.aluOp1 = decodeInterface.aluOp1;
  renamingInterface.aluSrc1 = decodeInterface.aluSrc1;
  renamingInterface.memWrite1 = decodeInterface.memWrite1;
  renamingInterface.memRead1 = decodeInterface.memRead1;
  renamingInterface.memtoReg1 = decodeInterface.memtoReg1;
  renamingInterface.imm1 = decodeInterface.imm1;

  renamingInterface.renameopcode2 = decodeInterface.opcode2;
  renamingInterface.regWrite2 = decodeInterface.regWrite2;
  renamingInterface.aluOp2 = decodeInterface.aluOp2;
  renamingInterface.aluSrc2 = decodeInterface.aluSrc2;
  renamingInterface.memWrite2 = decodeInterface.memWrite2;
  renamingInterface.memRead2 = decodeInterface.memRead2;
  renamingInterface.memtoReg2 = decodeInterface.memtoReg2;
  renamingInterface.imm2 = decodeInterface.imm2;

  renamingInterface.free_regs = retireinterface.free_regs;
end;


always_comb begin
  dispatchinterface.src1_phys  = renamingInterface.src1_phys;
  dispatchinterface.src2_phys = renamingInterface.src2_phys;
  dispatchinterface.dest_phys  = renamingInterface.dest_phys;
  dispatchinterface.src1_phys2 = renamingInterface.src1_phys2;
  dispatchinterface.src2_phys2  = renamingInterface.src2_phys2;
  dispatchinterface.dest_phys2 = renamingInterface.dest_phys2; 

  dispatchinterface.dispatchopcode1 = renamingInterface.renameopcode1;
  dispatchinterface.regWrite1 = renamingInterface.regWrite1;
  dispatchinterface.aluOp1 = renamingInterface.aluOp1;
  dispatchinterface.aluSrc1 = renamingInterface.aluSrc1;
  dispatchinterface.memWrite1 = renamingInterface.memWrite1;
  dispatchinterface.memRead1 = renamingInterface.memRead1;
  dispatchinterface.memtoReg1 = renamingInterface.memtoReg1;
  dispatchinterface.imm1 = renamingInterface.imm1;

  dispatchinterface.opcode2 = renamingInterface.renameopcode2;
  dispatchinterface.regWrite2 = renamingInterface.regWrite2;
  dispatchinterface.aluOp2 = renamingInterface.aluOp2;
  dispatchinterface.aluSrc2 = renamingInterface.aluSrc2;
  dispatchinterface.memWrite2 = renamingInterface.memWrite2;
  dispatchinterface.memRead2 = renamingInterface.memRead2;
  dispatchinterface.memtoReg2 = renamingInterface.memtoReg2;
  dispatchinterface.imm2 = renamingInterface.imm2;  

  dispatchinterface.ready_src1_instr = renamingInterface.ready_src1_instr;
  dispatchinterface.ready_src2_instr = renamingInterface.ready_src2_instr;
  dispatchinterface.ready_src1_instr2 = renamingInterface.ready_src1_instr2;
  dispatchinterface.ready_src2_instr2 = renamingInterface.ready_src2_instr2;
  dispatchinterface.readyregs = renamingInterface.readyregs;

  dispatchinterface.overwrittendest_phys1 = renamingInterface.overwrittendest_phys1;
  dispatchinterface.overwrittendest_phys2 = renamingInterface.overwrittendest_phys2;

  dispatchinterface.destihold = renamingInterface.destihold;
  dispatchinterface.destihold2 = renamingInterface.destihold2;
  
  dispatchinterface.retire_rob = retireinterface.retire_rob;

  dispatchinterface.clear_rs = fireinterface.clear_rs;
end;


always_comb begin
  fireinterface.rs_array = dispatchinterface.rs_array;
  fireinterface.rob = dispatchinterface.rob;
  fireinterface.complete_array = dispatchinterface.complete_array;
end;


always_comb begin
  retireinterface.rob = fireinterface.rob;
  retireinterface.physregisters = fireinterface.physregisters;
  retireinterface.complete_array = fireinterface.complete_array;  
  retireinterface.store_address = fireinterface.store_address;
  retireinterface.store_value = fireinterface.store_value;
  retireinterface.load_address = fireinterface.load_address;
  retireinterface.store_complete_array = fireinterface.store_complete_array;
  fireinterface.memory = retireinterface.memory;
end;

// Clock signal 
  always
  begin
    #5 clk = 1;
    #5 clk = 0;
  end

// Display for clock signal
/*
initial begin
  $display("Time %0t: clk = %b", $time, clk);
end
*/


  // Reset logic
  initial begin
    // Initialize reset at the beginning of simulation
    reset = 1'b1;
    #10 reset = 1'b0; // Unset reset after 10 time units
  end


// Display for positive clock edge
/*
 always_ff @(posedge clk) begin
    // Rotate the data_from_file array to get the next 4 values on each clock cycle
$display("Clock edge detected at time %0t", $time);
       
end
*/

endmodule