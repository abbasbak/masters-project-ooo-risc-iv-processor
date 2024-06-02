
module Fire2 (
  input logic clk,
  input logic [84:0] rs_array [0:15],
  input logic [18:0] rob [0:15],
  output logic [31:0] physregisters [63:0]= '{default:32'h0},
  output logic [15:0] complete_array, // = '{default:1'b0},
  output logic [15:0] store_complete_array = '{default:1'b0},

  output logic [31:0] store_address,
  output logic [31:0] store_value,
  output logic [31:0] load_address,

  input logic [31:0] memory [0:1023],
  output logic [3:0] clear_rs [0:2]
);

reg [7:0] mem_actual [0:255];      // Temporary memory to store data

parameter NUM_PHYSICAL_REGISTERS = 64; // Adjust based on your architecture

logic src1_ready;
logic src2_ready;

logic [0:3] clearval;
logic fu3_src1;
logic fu3_src2;
logic fu3_dest;
logic fu3_imm;

logic all_units_busy;
logic fu1_busy;
logic fu2_busy;
logic fu3_busy;


logic [2:0] countfinal;

logic [64-1:0] regfreedfire = '0; 
logic [4:0] clearcount = 5'b0;

always_ff @(posedge clk) begin
complete_array = {default:1'b0};

// Display statemetns for physical register file
$display("Value at physregisters0: %b", physregisters[0]);
$display("Value at physregisters1: %b", physregisters[1]);
$display("Value at physregisters2: %b", physregisters[2]);
$display("Value at physregisters3: %b", physregisters[3]);
$display("Value at physregisters4: %b", physregisters[4]);
$display("Value at physregisters5: %b", physregisters[5]);
$display("Value at physregisters6: %b", physregisters[6]);
$display("Value at physregisters7: %b", physregisters[7]);
$display("Value at physregisters8: %b", physregisters[8]);
$display("Value at physregisters9: %b", physregisters[9]);
$display("Value at physregisters10: %b", physregisters[10]);
$display("Value at physregisters11: %b", physregisters[11]);
$display("Value at physregisters12: %b", physregisters[12]);
$display("Value at physregisters13: %b", physregisters[13]);
$display("Value at physregisters14: %b", physregisters[14]);

/*
// Display statemetns for important memory values
$display("memory[0]: %b", memory[0]);
$display("memory[16]: %b", memory[16]);
$display("memory[24]: %b", memory[24]);
*/

fu1_busy = 0;
fu2_busy = 0;
fu3_busy = 0;
countfinal = 0;
  all_units_busy = (fu1_busy && fu2_busy && fu3_busy);

  for (int i = 0; i < 16; i++) begin

 all_units_busy = (fu1_busy && fu2_busy && fu3_busy); 

if ((!all_units_busy)) begin

      src1_ready = rs_array[i][20];
      src2_ready = rs_array[i][27];

      if ((src1_ready && src2_ready) || ((regfreedfire[rs_array[i][19:14]] == 1'b1) && (regfreedfire[rs_array[i][26:21]] == 1'b1))) begin
	
	if (countfinal < 2'b10) begin

		if ((rs_array[i][7:1] == 7'b0010011) || (rs_array[i][7:1] == 7'b0110011)) begin
		
			// ADDI (I) type instructions
			if (rs_array[i][7:1] == 7'b0010011) begin
				//ADDI
				
				if(rs_array[i][31:29] == 3'b000) begin
					physregisters[rs_array[i][13:8]] <= physregisters[rs_array[i][19:14]] +  rs_array[i][67:36];
				
				end
				//ANDI
				if(rs_array[i][31:29] == 3'b111) begin
					physregisters[rs_array[i][13:8]] <= physregisters[rs_array[i][19:14]] &  rs_array[i][67:36];
				end
			end
			
			// ADD (R) type instructions
			if (rs_array[i][7:1] == 7'b0110011) begin
			//ADD
			if(rs_array[i][31:29] == 3'b000) begin
					physregisters[rs_array[i][13:8]] <= physregisters[rs_array[i][19:14]] +  physregisters[rs_array[i][26:21]];
				end
			//SUB
			if(rs_array[i][31:29] == 3'b001) begin
					physregisters[rs_array[i][13:8]] <= physregisters[rs_array[i][19:14]] -  physregisters[rs_array[i][26:21]];
					end
		
			//XOR
			if(rs_array[i][31:29] == 3'b100) begin
					physregisters[rs_array[i][13:8]] <= physregisters[rs_array[i][19:14]] ^  physregisters[rs_array[i][26:21]];
				end
			//SRA
			if(rs_array[i][31:29] == 3'b101) begin
					physregisters[rs_array[i][13:8]] <= physregisters[rs_array[i][19:14]] >>> physregisters[rs_array[i][26:21]];
				end

			end
if(countfinal == 0 ) begin 
clear_rs[0] = i;
end
if (countfinal == 1) begin
clear_rs[1] = i;
end

countfinal = countfinal + 1'b1;
regfreedfire[rs_array[i][13:8]] <= 1'b1;

complete_array[i] <= 1'b1;
		end
	
	fu1_busy = 1'b1;
	end


	// FU 3 for sw and lw instructions
	if (!fu3_busy) begin
		if (rs_array[i][7:1] == 7'b0100011 || rs_array[i][7:1] == 7'b0000011) begin
			// SW
			if(rs_array[i][7:1] == 7'b0100011) begin
			memory[physregisters[rs_array[i][19:14]] + rs_array[i][67:36]] <= physregisters[rs_array[i][26:21]];
			end
			//LW
			if(rs_array[i][7:1] == 7'b0000011) begin
     			 load_address <= physregisters[rs_array[i][19:14]] + rs_array[i][67:36];
			 physregisters[rs_array[i][13:8]] <= memory[physregisters[rs_array[i][19:14]] + rs_array[i][67:36]];
		
			end		
  clear_rs[2] = i;	
  fu3_busy = 1'b1;

  complete_array[i] <= 1'b1;
  store_complete_array[i] <= 1'b1;
  regfreedfire[rs_array[i][13:8]] <= 1'b1;
		end

	end
  
      end
    end
  end
end

endmodule