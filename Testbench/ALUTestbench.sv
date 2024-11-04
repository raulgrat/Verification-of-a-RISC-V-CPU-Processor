// Please paste this testbench code into testbench.sv and run when trying to see ALUtestbench results OR change second line file in files.f to ALUTestbench.sv
// Change the first line file in files.f to sr_alu.sv

// ALUTestbench.sv
`default_nettype none
`timescale 1ns / 1ps

module tb ();
	
  reg [31:0] srcA, srcB;
  reg [2:0] oper;
  
  wire zero;
  wire [31:0] result;
  
  sr_alu ALU_UUT(
    .srcA(srcA),
    .srcB(srcB),
    .oper(oper),
    .zero(zero),
    .result(result)
  );
  
  covergroup cg_cross with function sample(bit [2:0] oper, bit [31:0] srcA, bit [31:0] srcB);
    cp_oper: coverpoint oper{
      bins add = {3'b000};
      bins OR = {3'b001};
      bins SRL = {3'b010};
      bins SLTU = {3'b011};
      bins sub = {3'b100};
    }
    cp_srcA: coverpoint srcA{
      wildcard bins A = {32'h????????};
    }
    
    cp_srcB: coverpoint srcB{
      wildcard bins B = {32'h????????}; 
    }
    
    cross cp_oper, cp_srcA, cp_srcB;
  endgroup
  
class ALUTest;
  rand bit [31:0] srcA, srcB;
  rand bit [2:0] oper;
  
  constraint opcodes {
    oper inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100};
  }
endclass
  
task check_result(input bit[31:0] expected, input bit[31:0] actual, string msg);
	if (expected !== actual) begin
      $display("FAIL: %s. Expected: %0d, Actual: %0d", msg, expected, actual);
	end else begin
      $display("PASS: %s. Expected: %0d, Actual: %0d", msg, expected, actual);
	end
endtask

cg_cross cg_c;
    
  initial begin
    ALUTest test = new();
    
    // covergroups go under here
    cg_c = new();
    
    // change # of repeats to obtain more random test cases
    repeat (50) begin
      assert(test.randomize()) else $error("Randomization Failed!");
      srcA = test.srcA;
      srcB = test.srcB;
      oper = test.oper;
      
      #10;
      
      cg_c.sample(oper, srcA, srcB);
      
      $display("Inputs: A: %0d , B: %0d", srcA, srcB);
      if(oper == 3'b000) begin
        check_result(srcA + srcB, ALU_UUT.result, "Checking for Add case");
      end else if(oper == 3'b001) begin
        check_result(srcA | srcB, ALU_UUT.result, "Checking for OR case");
      end else if(oper == 3'b100) begin
        check_result(srcA - srcB, ALU_UUT.result, "Checking for Sub case");
      end else if(oper == 3'b010) begin
        check_result(srcA >> (srcB % 32), ALU_UUT.result, "Checking for SRL case");
      end else if(oper == 3'b011) begin
        check_result((srcA < srcB) ? 32'd1 : 32'd0, ALU_UUT.result, "Checking for SLTU case");
      end
      
    end
    
    cg_c.stop();
    
    // Expected Cases test
    srcA = 32'd10;
    srcB = 32'd15;
    oper = 3'b000;
   
    #5
    // Expected addition case
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    check_result(srcA + srcB, ALU_UUT.result, "Checking for Add case");
    
    srcA = 32'hFFFFFFFF;
    srcB = 32'd1;
    
    #5
    // Expected zero = 1 case for add
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    if(ALU_UUT.zero == 1)
      $display("Zero case passed for add");
    else
      $display("Zero case FAILED for add!");
    
    srcA = 32'h0F0F0F0F;
    srcB = 32'hF0F0F0F0;
    oper = 3'b001;
    
    #5
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    check_result(srcA | srcB, ALU_UUT.result, "Checking for OR case");
    
    srcA = 32'd0;
    srcB = 32'd0;
    
    #5
    // Expected zero = 1 case for OR
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    if(ALU_UUT.zero == 1)
      $display("Zero case passed for OR");
    else
      $display("Zero case FAILED for OR!");
    
    srcA = 32'd1;
    srcB = 32'd1;
    oper = 3'b010;
    
    #5
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    if(ALU_UUT.zero == 1)
      $display("Zero case passed for SRL");
    else
      $display("Zero case FAILED for SRL!");
    
    srcA = 32'd20;
    srcB = 32'd10;
    oper = 3'b011;
    
    #5
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    if(ALU_UUT.zero == 1)
      $display("Zero case passed for SLTU");
    else
      $display("Zero case FAILED for SLTU!");
    
    srcA = 32'd15;
    srcB = 32'd10;
    oper = 3'b100;
    
    #5
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    check_result(srcA - srcB, ALU_UUT.result, "Checking for Sub case");
    
    srcA = 32'd10;
    srcB = 32'd10;
    
    #5
    $display("Inputs: A: %0d , B: %0d, Result: %0d", srcA, srcB, ALU_UUT.result);
    if(ALU_UUT.zero == 1)
      $display("Zero case passed for Sub");
    else
      $display("Zero case FAILED for Sub!");
    
    
    $finish;
  end
  
final
  begin
    $display("Overall Coverage = %0f", $get_coverage());
    $display("Cross Coverage = %0f", cg_c.get_coverage());
  end
  
endmodule
