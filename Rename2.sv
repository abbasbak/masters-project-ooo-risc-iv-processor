
module RegisterRenaming (
  input wire [4:0] src1_instr,    // Source register 1 from instruction 1
  input wire [4:0] src2_instr,    // Source register 2 from instruction 1
  input wire [4:0] dest_instr,    // Destination register from instruction 1
  input wire [4:0] src1_instr2,   // Source register 1 from instruction 2
  input wire [4:0] src2_instr2,   // Source register 2 from instruction 2
  input wire [4:0] dest_instr2,   // Destination register from instruction 2
  input wire rename_enable,       // Enable register renaming
  input wire clk,                  // Clock signal
  input wire reset,                // Reset signal
  output logic [5:0] src1_phys,    // Physical register for source 1 in instruction 1
  output logic [5:0] src2_phys,    // Physical register for source 2 in instruction 1
  output logic [5:0] dest_phys,    // Physical register for destination in instruction 1
  output logic [5:0] src1_phys2,   // Physical register for source 1 in instruction 2
  output logic [5:0] src2_phys2,   // Physical register for source 2 in instruction 2
  output logic [5:0] dest_phys2,    // Physical register for destination in instruction 2

  output logic [4:0] destihold,
  output logic [4:0] destihold2,  
  input wire [6:0] renameopcode1,
  input wire [6:0] renameopcode2,
  input logic [5:0] free_regs [0:1],
  output logic ready_src1_instr,
  output logic ready_src2_instr,
  output logic ready_src1_instr2,
  output logic ready_src2_instr2,
  output logic [63:0] readyregs = '1,
  output logic [5:0] overwrittendest_phys1, 
  output logic [5:0] overwrittendest_phys2 

);
 
    logic [6:0] intopcode1;
    logic [6:0] intopcode2;

    parameter NUM_PHYSICAL_REGISTERS = 64; 

    logic [5:0] rat [NUM_PHYSICAL_REGISTERS-1:0]; // Register Alias Table
    logic [NUM_PHYSICAL_REGISTERS-1:0] free_pool; // Free pool (for physical registers)

    // Function that finds the position of the first '0' in a free pool,
    // which signifies the first free physical register (excluding p0, which is reserved as the value 0)
    function int find_first_zero(logic [NUM_PHYSICAL_REGISTERS-1:0] value);
        int result;

 	for (int i = 1; i < NUM_PHYSICAL_REGISTERS; i++) begin
            if (value[i] == 0) begin
                result = i;
		////$display("result: ", result);
                break;
            end
        end
        return result;
    endfunction

  always_ff @(posedge clk) begin
for (int x = 0; x < 2; x++) begin
free_pool[free_regs[x]] = 1'b0;
end
end

    // Register renaming
    always_ff @(posedge clk or posedge reset) begin
        //$display("reset: ", reset);
        overwrittendest_phys1 = 5'b00000;
        overwrittendest_phys2 = 5'b00000;


            // Source register renaming logic for instruction 1

            src1_phys <= (src1_instr != 5'b00000) ? rat[src1_instr] : 5'b0;
            src2_phys <= (src2_instr != 5'b00000) ? rat[src2_instr] : 5'b0;
            // Display messages for source register renaming in instruction 1
           //// $display("Clock %0t: Source Register1 %0d renamed to Physical Register %0d for Instruction 1", $time, src1_instr, src1_phys);
           //// $display("Clock %0t: Source Register2 %0d renamed to Physical Register %0d for Instruction 1", $time, src2_instr, src2_phys);
        
		// Source register renaming logic for instruction 2
            src1_phys2 <= (src1_instr2 != 5'b00000) ? rat[src1_instr2] : 5'b0;
            src2_phys2 <= (src2_instr2 != 5'b00000) ? rat[src2_instr2] : 5'b0;

	// Check to see if the source registers for instruction 1 are ready or not
 	  ready_src1_instr <= readyregs[src1_phys];
  	  ready_src2_instr <= readyregs[src2_phys];
          ready_src1_instr2 <= readyregs[src1_phys2];
          ready_src2_instr2 <= readyregs[src2_phys2];

        if (reset) begin
            //$display("entered1: ", reset);
            // Reset logic (initialize RAT and free pool)
            for (int i = 0; i < NUM_PHYSICAL_REGISTERS; i++) begin
                rat[i] <= 5'b0;
            end
            free_pool <= 5'b0; // Initialize free pool to all 0's
            dest_phys <= 5'b0; // Assign a default value to dest_phys
        end else if (rename_enable) begin
            //$display("entered2: ", reset);
            // Register renaming logic
            if (dest_instr != 5'b0000) begin
                // Destination register is not x0
                //$display("entered3: ", reset);

                dest_phys = find_first_zero(free_pool); 

		////$display("find_first_zero: ", find_first_zero(free_pool));

		//$display("VALUE AT rat[dest_instr]: %b", rat[dest_instr]);
		overwrittendest_phys1 <= rat[dest_instr];

 		destihold <= dest_instr;

                rat[dest_instr] = dest_phys; 
		////$display("dest_instr: ", dest_instr);
                //free_pool = free_pool | (64'b1  << dest_phys); // Mark the physical register as in use
		free_pool[dest_phys] = 1;

		readyregs[dest_phys] = 0;
                ////$display("Clock %0t: Register %0d renamed to Physical Register %0d for Instruction 1", $time, dest_instr, dest_phys);
		end else begin
                dest_phys <= 5'b00000; 
		destihold <= dest_instr;

            end
		 if (dest_instr2 != 5'b0000) begin
	
		dest_phys2 = find_first_zero(free_pool); 
		////$display("find_first_zero: ", find_first_zero(free_pool));

		overwrittendest_phys2 <= rat[dest_instr2];
		
		destihold2 <= dest_instr2;

                rat[dest_instr2] = dest_phys2;
		////$display("dest_instr: ", dest_instr2);
                //free_pool = free_pool | (64'b1  << dest_phys); 
		free_pool[dest_phys2] = 1;
       
		readyregs[dest_phys2] = 0;
                ////$display("Clock %0t: Register %0d renamed to Physical Register %0d for Instruction 2", $time, dest_instr2, dest_phys2);
 		
	end else begin
                dest_phys2 <= 5'b00000; 
                destihold2 <= dest_instr2;
            end
      
	end


	//$display("VALUE AT overwrittendest_phys1: %b", overwrittendest_phys1);
	//$display("VALUE AT overwrittendest_phys2: %b", overwrittendest_phys2);

        // Display the entire RAT
        $display("Clock %0t: Register Alias Table (RAT): %p", $time, rat);

        // Display the free pool
        $display("Clock %0t: Free Pool: %b", $time, free_pool);

	/*
	$display("Clock %0t: readyregs: %b", $time, readyregs);
	$display("Clock %0t: ready_src1_instr: %b", $time, ready_src1_instr);
	$display("Clock %0t: ready_src2_instr: %b", $time, ready_src2_instr);
	$display("Clock %0t: ready_src1_instr2: %b", $time, ready_src1_instr2);
	$display("Clock %0t: ready_src2_instr2: %b", $time, ready_src2_instr2);
	*/
    end

endmodule

