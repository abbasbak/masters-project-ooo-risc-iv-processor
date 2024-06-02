
module Fetch2 (
  input logic clk,
  output reg [31:0] firstinstruction,
  output reg [31:0] secondinstruction
);

  reg [63:0] data_from_file = 32'h0; 
  reg [7:0] mem [0:255];    
  reg clk1;

  // Logic to read values from text file (can change filepath if needed)
  initial begin
    $readmemh("C:/Users/abbas/OneDrive/Documents/quartusfiles/try1.txt", mem);

    // Display the contents of the memory after reading from the file
    $display("Memory contents after reading from file:");
    for (int i = 0; i <= 30; i = i + 1) begin
      $display("mem[%0d] = %h", i, mem[i]);
    end

  end

  int i = -8;
  
  always @(posedge clk) begin
    // Rotate the data_from_file array to get the next 4 values on each clock cycle
    $display("Clock edge detected at time %0t", $time);

    data_from_file <= {mem[i+7], mem[i+6],mem[i+5],mem[i+4],mem[i+3], mem[i+2],mem[i+1],mem[i]};

    i <= i + 8;

    firstinstruction  <= {mem[i], mem[i+1],mem[i+2],mem[i+3]};
    secondinstruction <= {mem[i+4], mem[i+5],mem[i+6],mem[i+7]};
   ////$display("data_from_file = %b",  data_from_file);
   ////$display("memory =%h,%h,%h,%h,%h,%h,%h,%h,", mem[i+7], mem[i+6],mem[i+5],mem[i+4],mem[i+3], mem[i+2],mem[i+1],mem[i]);
   ////$display("firstinstruction = %b, secondinstruction = %b", firstinstruction, secondinstruction);
   ////$display("i = %d",  i);
   $display("firstinstruction = %b, secondinstruction = %b", firstinstruction, secondinstruction);
  end

endmodule

