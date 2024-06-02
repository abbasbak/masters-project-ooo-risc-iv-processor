
module Retire2 (
  input logic clk,
  input logic [18:0] rob [0:15],
  input logic [31:0] physregisters [63:0],
  output logic [31:0] regfile [0:31] = '{default:1'b0},
  input logic [15:0] complete_array,
  input logic [31:0] store_address,
  input logic [31:0] store_value,
  input logic [31:0] load_address,
  input logic [15:0] store_complete_array = '{default:1'b0},
  output logic [31:0] memory [0:1023],
  output logic [3:0] retire_rob [0:1],
  output logic [5:0] free_regs [0:1]
);

logic [3:0] val = 3'b0;
logic [15:0] checkcompleted = '0;
logic [15:0] storeloadcheckcompleted = '0;
logic [2:0] countretire = 2'b0;

  always_ff @(posedge clk) begin

val = 3'b000;

countretire = 2'b00;

for (int i = 0; i < 16; i++) begin

if (complete_array[i] == 1) begin

if ((checkcompleted[i] !== 1'b1) && (countretire < 2'b10) ) begin
 regfile[rob[i][17:13]] <= physregisters[rob[i][6:1]];

  retire_rob[val] <= i;

  free_regs[val] =  rob[i][12:7];

  val = val + 3'b001;
  checkcompleted[i] = 1'b1;
  countretire = countretire+2'b01;

end
end
end


for (int i = 0; i < 16; i++) begin

  if (store_complete_array[i] == 1) begin

	if (storeloadcheckcompleted[i] !== 1'b1) begin
 
 		storeloadcheckcompleted[i] <= 1'b1;
end
end
end

// Display statements for architectural register file
$display("Register File 0 (x0): %b", regfile[0]);
$display("Register File 1 (x1): %b", regfile[1]);
$display("Register File 2 (x2): %b", regfile[2]);
$display("Register File 3 (x3): %b", regfile[3]);
$display("Register File 4 (x4): %b", regfile[4]);
$display("Register File 5 (x5): %b", regfile[5]);
$display("Register File 6 (x6): %b", regfile[6]);
$display("Register File 7 (x7): %b", regfile[7]);
$display("Register File 8 (x8): %b", regfile[8]);
$display("Register File 9 (x9): %b", regfile[9]);
$display("Register File 10 (x10): %b", regfile[10]);
$display("Register File 11 (x11): %b", regfile[11]);
$display("Register File 12 (x12): %b", regfile[12]);


//$display("memory[0]: %b", memory[0]);
//$display("memory[16]: %b", memory[16]);
//$display("memory[24]: %b", memory[24]);

end

endmodule