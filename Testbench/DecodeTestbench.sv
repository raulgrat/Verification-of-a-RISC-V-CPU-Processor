// Please paste this testbench code into testbench.sv and run when trying to see DecodeTestbench results OR change second line file in files.f to DecodeTestbench.sv
// Change the first line file in files.f to sr_decode.sv

// DecodeTestbench.sv
`default_nettype none
`timescale 1ns / 1ps

module tb ();

  logic [31:0] instr;
  logic [ 6:0] cmdOp;
  logic [ 4:0] rd;
  logic [ 2:0] cmdF3;
  logic [ 4:0] rs1;
  logic [ 4:0] rs2;
  logic [ 6:0] cmdF7;
  logic [31:0] immI;
  logic [31:0] immB;
  logic [31:0] immU;

	sr_decode DUT (.instr(instr), .cmdOp(cmdOp), .rd(rd), .cmdF3(cmdF3), .rs1(rs1), .rs2(rs2), .cmdF7(cmdF7), .immI(immI), .immB(immB), .immU(immU));
  
	covergroup cg_decoder with function sample(bit [31:0] instr);
  
		cg_dec: coverpoint instr{
			wildcard bins X = {32'h????????};
		}
  
	endgroup
  
	class DECODER;
    
		rand bit [31:0] instr;
      
      constraint instr_constraints{
        instr[6:0] inside {7'b0010011, 7'b1100011, 7'b0110111, 7'b0110011};
      }
          
	endclass
  
  task check_result(input bit[6:0] expected, input bit[6:0] actual, string msg);
	if (expected !== actual) begin
      $display("FAIL: %s. Expected: %0d, Actual: %0d", msg, expected, actual);
	end else begin
      $display("PASS: %s. Expected: %0d, Actual: %0d", msg, expected, actual);
	end
endtask
  
cg_decoder cg_decoder_inst;
  
initial begin
    
	DECODER test = new();
    
    cg_decoder_inst = new();
    
    repeat (100) begin
      assert(test.randomize())
        else $error("Randomization Failed!");
          
      instr = test.instr;
      
      #10;
      	
      cg_decoder_inst.sample(instr);
      
      $display("Input OpCode: %0b", instr);
      check_result(instr[6:0], DUT.cmdOp, "Checking the Instruction OpCode");
      	     	
    end
    
    cg_decoder_inst.stop();
  	
  	// First expected test case with a negative immediate
  	instr = 32'hFFF32313;
  $display("I-Type Instruction: %0d", instr);
  	#5
  	if (DUT.cmdOp == 7'h13)
      $display("cmdOp is correct: %0d", DUT.cmdOp);
	else
      $display("cmdOp is incorrect: %0d", DUT.cmdOp);
  	
  	if(DUT.rd == 3'd6)
    	$display("rd is correct: %0d", DUT.cmdOp);
  	else
     	$display("cmdOP is incorrect: %0d", DUT.cmdOp);
  	
  	if(DUT.cmdF3 == 3'd2)
    	$display("cmdF3 is correct: %0d", DUT.cmdF3);
  	else
     	$display("cmdF3 is incorrect: %0d", DUT.cmdF3);
  	
  	if(DUT.rs1 == 3'd6)
      $display("rs1 is correct: %0d", DUT.rs1);
  	else
      $display("rs1 is incorrect: %0d", DUT.rs1);
  
  	if(DUT.immI == -1)
      $display("rs2 is correct: %0d", DUT.immI);
  	else
      $display("rs2 is incorrect: %0d", DUT.immI);
  	
  	$display("----------------------------------------");
  
  	// Second expected test case with Branch if equal with a small positive offset
   	instr =	32'h0020A063;
  $display("B-Type Instruction: %0d", instr);
  	#5
  	if (DUT.cmdOp == 7'h63)
    	$display("cmdOp is correct: %0d", DUT.cmdOp);
	else
    	$display("cmdOp is incorrect: %0d", DUT.cmdOp);
  	
  	if(DUT.cmdF3 == 3'd2)
    	$display("cmdF3 is correct: %0d", DUT.cmdF3);
  	else
     	$display("cmdF3 is incorrect: %0d", DUT.cmdF3);
  	
  	if(DUT.rs1 == 5'd1)
      $display("rs1 is correct: %0d", DUT.rs1);
  	else
      $display("rs1 is incorrect: %0d", DUT.rs1);
  
  	if(DUT.rs2 == 5'd2)
    	$display("rs2 is correct: %0d", DUT.rs2);
  	else
      $display("rs2 is incorrect: %0d", DUT.rs2);
  
  	if(DUT.immB == 32'b0)
    	$display("immB is correct: %0d", DUT.immB);
  	else
    	$display("immB is incorrect: %0d", DUT.immB);
  	
  	$display("----------------------------------------");
  	
   	// Third expected test case with Load upper immediate
  	instr = 32'h123450B7;
  $display("U-Type Instruction: %0d", instr);
  	#5
  	if (DUT.cmdOp == 7'h37)
    	$display("cmdOp is correct: %0d", DUT.cmdOp);
	else
    	$display("cmdOp is incorrect: %0d", DUT.cmdOp);
  	
  	if(DUT.rd == 5'd1)
      $display("cmdF3 is correct: %0d", DUT.rd);
  	else
      $display("cmdF3 is incorrect: %0d", DUT.rd);
  	
  	if(DUT.immU == 32'h12345000)
      $display("immU is correct: %0d", DUT.immU);
  	else
      $display("immU is incorrect: %0d", DUT.immU);
  
    $finish;
  end
  
final
	begin
      $display("Decoder Coverage = %0f", $get_coverage());
      $display("Decoder Coverpoint Coverage = %0f", cg_decoder_inst.get_coverage());
    end

endmodule
