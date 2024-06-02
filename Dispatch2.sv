
module Dispatch2 (
  input logic [5:0] src1_phys,
  input logic [5:0] src2_phys,
  input logic [5:0] dest_phys,
  input logic [5:0] src1_phys2,
  input logic [5:0] src2_phys2,
  input logic [5:0] dest_phys2,
  input wire clk,
  // signals from decode->rename->dispatch
  input logic [6:0] dispatchopcode1,
  input logic [6:0] opcode2,
  input logic regWrite1,
  input logic regWrite2,
  input logic [2:0] aluOp1,
  input logic [2:0] aluOp2,
  input logic aluSrc1,
  input logic aluSrc2,
  input logic memWrite1,
  input logic memWrite2,
  input logic memRead1,
  input logic memRead2,
  input logic memtoReg1,
  input logic memtoReg2,
  input logic signed [31:0] imm1,
  input logic signed [31:0] imm2,
  input logic decode_enable,  

  input logic ready_src1_instr,
  input logic ready_src2_instr,
  input logic ready_src1_instr2,
  input logic ready_src2_instr2,
  input logic [63:0] readyregs,
 
  output logic [84:0] rs_array[0:15],
  output logic [18:0] rob[0:15],
  output logic [15:0] complete_array = '{default:1'b0},
  input logic [5:0] overwrittendest_phys1,
  input logic [5:0] overwrittendest_phys2,

  input logic [4:0] destihold,
  input logic [4:0] destihold2,
  input logic [3:0] retire_rob [0:1],
  input logic [3:0] clear_rs [0:2]

);


logic [6:0] finopcode1;
logic [6:0] finopcode2;
logic finregWrite1;
logic finregWrite2;
logic [2:0] finaluOp1;
logic [2:0] finaluOp2;
logic finaluSrc1;
logic finaluSrc2;
logic finmemWrite1;
logic finmemWrite2;
logic finmemRead1;
logic finmemRead2;
logic finmemtoReg1;
logic finmemtoReg2;
logic signed [31:0] finimm1;
logic signed [31:0] finimm2;

// Buffer all the docode signals once so that they align with the correct renamed physical registers
  always_ff @(posedge clk) begin
  finregWrite1 <= regWrite1;
  finregWrite2 <= regWrite2;
  finaluOp1 <= aluOp1;
  finaluOp2 <= aluOp2;
  finaluSrc1 <= aluSrc1;
  finaluSrc2 <= aluSrc2;
  finmemWrite1 <= memWrite1;
  finmemWrite2 <= memWrite2;
  finmemRead1 <= memRead1;
  finmemRead2 <= memRead2;
  finmemtoReg1 <= memtoReg1;
  finmemtoReg2 <= memtoReg2;
  finimm1 <= imm1;
  finimm2 <= imm2;
end

  logic [6:0] finfinopcode1;
  logic [6:0] finfinopcode2;

always_ff @(posedge clk) begin
  finfinopcode1 <= finopcode1;
  finfinopcode2 <= finopcode2;
end


  logic [15:0] row_index = 0;
  logic [15:0] new_rs = 0;

  logic [9:0] clk_counter = 0;

  logic [1:0] funcunit1 = 2'b0;
  logic [1:0] funcunit2 = 2'b0;
  logic [5:0] ROBnumber1 = 0;
  logic [5:0] ROBnumber2 = 0; // 5'b1;



  logic newready_src1_instr;
  logic newready_src2_instr;
  logic newready_src1_instr2;
  logic newready_src2_instr2;

always_ff @(posedge clk) begin

    // Display the rs_array values (reservation station)
$display("Value at rs_array: %p", rs_array);
$display("Value at rs_array0: %b", rs_array[0]);
$display("Value at rs_array1: %b", rs_array[1]);
$display("Value at rs_array2: %b", rs_array[2]);
$display("Value at rs_array3: %b", rs_array[3]);
$display("Value at rs_array4: %b", rs_array[4]);
$display("Value at rs_array5: %b", rs_array[5]);
$display("Value at rs_array6: %b", rs_array[6]);
$display("Value at rs_array7: %b", rs_array[7]);
$display("Value at rs_array8: %b", rs_array[8]);
$display("Value at rs_array9: %b", rs_array[9]);
$display("Value at rs_array10: %b", rs_array[10]);
$display("Value at rs_array11: %b", rs_array[11]);
$display("Value at rs_array12: %b", rs_array[12]);
$display("Value at rs_array13: %b", rs_array[13]);
$display("Value at rs_array14: %b", rs_array[14]);
$display("Value at rs_array15: %b", rs_array[15]);
$display("Value at rs_array16: %b", rs_array[16]);

// Display the ROB (re-order buffer) values
$display("Value at ROB0: %b", rob[0]);
$display("Value at ROB1: %b", rob[1]);
$display("Value at ROB2: %b", rob[2]);
$display("Value at ROB3: %b", rob[3]);
$display("Value at ROB4: %b", rob[4]);
$display("Value at ROB5: %b", rob[5]);
$display("Value at ROB6: %b", rob[6]);
$display("Value at ROB7: %b", rob[7]);
$display("Value at ROB8: %b", rob[8]);
$display("Value at ROB9: %b", rob[9]);
$display("Value at ROB10: %b", rob[10]);
$display("Value at ROB11: %b", rob[11]);
$display("Value at ROB12: %b", rob[12]);

for (int x = 0; x < 2; x++) begin
rob[retire_rob[x]] = 19'b0000000000000000000;
end

end

  always_ff @(posedge clk) begin
    for (int x = 0; x < 3; x++) begin
     rs_array[clear_rs[x]] = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
  end

  always_ff @(posedge clk) begin
   clk_counter = clk_counter + 1'b1;
   newready_src1_instr = readyregs[src1_phys];
   newready_src2_instr = readyregs[src2_phys];
   newready_src1_instr2 = readyregs[src1_phys2];
   newready_src2_instr2 = readyregs[src2_phys2];

if (finaluOp1 !== 3'bxxx) begin
//$display("dispatchopcode1: %b", dispatchopcode1);
//$display("opcode2: %b", opcode2);
//$display("dest_phys: %b", dest_phys);
//$display("dest_phys2: %b", dest_phys2);

/*
$display("dispatch %0t: ready_src1_instr: %b", $time, newready_src1_instr);
$display("dispatch %0t: ready_src2_instr: %b", $time, newready_src2_instr);
$display("dispatch %0t: ready_src1_instr2: %b", $time, newready_src1_instr2);
$display("dispatch %0t: ready_src2_instr2: %b", $time, newready_src2_instr2);

$display("dispatch %0t: src1_phys: %b", $time, src1_phys);
$display("dispatch %0t: src2_phys: %b", $time, src2_phys);
$display("dispatch %0t: src1_phys2: %b", $time, src1_phys2);
$display("dispatch %0t: src2_phys2: %b", $time, src2_phys2);
$display("dispatch %0t: readyregs: %b", $time, readyregs);
*/


 //Code to reset row index if you get to the end of the reservation station
if (row_index == 4'b10000) begin
row_index = 4'b0000;
end

// Useful for debugging, places x between each separate element of reservation station
//rs_array[row_index] = {ROBnumber1,1'bx,funcunit1,1'bx,finimm1,1'bx,finmemtoReg1,1'bx,finmemRead1,1'bx,finmemWrite1,1'bx,finaluSrc1,1'bx,finaluOp1,1'bx,finregWrite1,1'bx, newready_src2_instr, 1'bx, src2_phys,1'bx,newready_src1_instr,1'bx,src1_phys,1'bx,dest_phys,1'bx,dispatchopcode1,1'b1};
     
//rs_array[row_index+1] = {ROBnumber2,1'bx,funcunit2,1'bx,finimm2,1'bx,finmemtoReg2,1'bx,finmemRead2,1'bx,finmemWrite2,1'bx,finaluSrc2,1'bx,finaluOp2,1'bx,finregWrite2,1'bx, newready_src2_instr2, 1'bx, src2_phys2,1'bx,newready_src1_instr2,1'bx,src1_phys2,1'bx,dest_phys2,1'bx,opcode2,1'b1};


rs_array[row_index] = {ROBnumber1,funcunit1,finimm1,finmemtoReg1,finmemRead1,finmemWrite1,finaluSrc1,finaluOp1,finregWrite1, newready_src2_instr,  src2_phys,newready_src1_instr,src1_phys,dest_phys,dispatchopcode1,1'b1};
  
rs_array[row_index+1] = {ROBnumber2,funcunit2,finimm2,finmemtoReg2,finmemRead2,finmemWrite2,finaluSrc2,finaluOp2,finregWrite2, newready_src2_instr2,  src2_phys2,newready_src1_instr2,src1_phys2,dest_phys2,opcode2,1'b1};

//rs_array[new_rs] = {ROBnumber1,1'bx,funcunit1,1'bx,finimm1,1'bx,finmemtoReg1,1'bx,finmemRead1,1'bx,finmemWrite1,1'bx,finaluSrc1,1'bx,finaluOp1,1'bx,finregWrite1,1'bx, newready_src2_instr, 1'bx, src2_phys,1'bx,newready_src1_instr,1'bx,src1_phys,1'bx,dest_phys,1'bx,dispatchopcode1,1'b1};
     
//rs_array[new_rs+ 1] = {ROBnumber2,1'bx,funcunit2,1'bx,finimm2,1'bx,finmemtoReg2,1'bx,finmemRead2,1'bx,finmemWrite2,1'bx,finaluSrc2,1'bx,finaluOp2,1'bx,finregWrite2,1'bx, newready_src2_instr2, 1'bx, src2_phys2,1'bx,newready_src1_instr2,1'bx,src1_phys2,1'bx,dest_phys2,1'bx,opcode2,1'b1};

rob[row_index] = {complete_array[row_index],destihold,overwrittendest_phys1,dest_phys,1'b1};

rob[row_index+1] = {complete_array[row_index+1'b1],destihold2,overwrittendest_phys2,dest_phys2,1'b1};

ROBnumber1 = ROBnumber1 + 1'b1;

ROBnumber2 = ROBnumber2 + 1'b1;

row_index = row_index + 2'b10;

end

end

endmodule

