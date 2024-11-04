// Please paste this testbench code into testbench.sv and run when trying to see SRControlTestbench results OR change second line file in files.f to SRControlTestbench.sv
// Change the first line file in files.f to sr_control.sv

// SRControlTestbench.sv
`default_nettype none
`timescale 1ns / 1ps

module tb ();

  reg [6:0] cmdOp;
  reg [2:0] cmdF3;
  reg [6:0] cmdF7;
  reg aluZero;
  
  wire pcSrc;
  wire regWrite;
  wire aluSrc;
  wire wdSrc;
  wire [2:0] aluControl;
  
  sr_control CONTROL_UUT (
    .cmdOp(cmdOp),
    .cmdF3(cmdF3),
    .cmdF7(cmdF7),
    .aluZero(aluZero),
    .pcSrc(pcSrc),
    .regWrite(regWrite),
    .aluSrc(aluSrc),
    .wdSrc(wdSrc),
    .aluControl(aluControl)
  );
  
  covergroup cg_cmd with function sample(bit [6:0] cmdOp, bit [2:0] cmdF3, bit [6:0] cmdF7);
    cp_cmdOp: coverpoint cmdOp {
      bins all_cmdOp[] = {`RVOP_ADDI, `RVOP_BEQ, `RVOP_LUI, `RVOP_BNE, `RVOP_ADD, `RVOP_OR, `RVOP_SRL, `RVOP_SLTU, `RVOP_SUB};
    }
    cp_cmdF3: coverpoint cmdF3 {
      bins all_cmdF3[] = {`RVF3_ADDI, `RVF3_BEQ, `RVF3_BNE, `RVF3_ADD, `RVF3_OR, `RVF3_SRL, `RVF3_SLTU, `RVF3_SUB};
    }
    cp_cmdF7: coverpoint cmdF7 {
      bins all_cmdF7[] = {`RVF7_ADD, `RVF7_OR, `RVF7_SRL, `RVF7_SLTU, `RVF7_SUB};
    }
    cross cp_cmdOp, cp_cmdF3, cp_cmdF7;
  endgroup
  
  cg_cmd cg_c;
  
  class controlTest;
    rand bit [6:0] op, F7;
    rand bit [2:0] F3;
    rand bit zero;
    
    constraint opcodes{
      op inside {7'b0010011, 7'b1100011, 7'b0110111, 7'b0110011};
    }
    
    constraint function3{
      F3 dist {3'b000 :/ 10, 3'b001 :/ 10, 3'b110 :/ 10, 3'b101 :/ 10, 3'b011 :/ 10, [3'b000 : 3'b111] :/ 50};
    }
    
    constraint function7{
      F7 dist {7'b0000000 :/ 25, 7'b0100000 :/ 25, [7'b0000000 : 7'b1111111] :/ 50}; 
    }
  endclass
  
  task check_result(input bit expected_pcSrc, input bit expected_regWrite, input bit expected_aluSrc, input bit expected_wdSrc, input bit [2:0] expected_aluControl, string msg);
    if (pcSrc !== expected_pcSrc || regWrite !== expected_regWrite || aluSrc !== expected_aluSrc || wdSrc !== expected_wdSrc || aluControl !== expected_aluControl) begin
      $display("FAIL: %s. Expected: pcSrc=%0b, regWrite=%0b, aluSrc=%0b, wdSrc=%0b, aluControl=%0b; Actual: pcSrc=%0b, regWrite=%0b, aluSrc=%0b, wdSrc=%0b, aluControl=%0b", 
               msg, expected_pcSrc, expected_regWrite, expected_aluSrc, expected_wdSrc, expected_aluControl, pcSrc, regWrite, aluSrc, wdSrc, aluControl);
    end else begin
      $display("PASS: %s. Expected: pcSrc=%0b, regWrite=%0b, aluSrc=%0b, wdSrc=%0b, aluControl=%0b; Actual: pcSrc=%0b, regWrite=%0b, aluSrc=%0b, wdSrc=%0b, aluControl=%0b", 
               msg, expected_pcSrc, expected_regWrite, expected_aluSrc, expected_wdSrc, expected_aluControl, pcSrc, regWrite, aluSrc, wdSrc, aluControl);
    end
  endtask
  
  initial begin
    controlTest test = new();
    cg_c = new();
    
    
      // Randomized test cases
    repeat (500) begin
      assert(test.randomize()) else $error("Randomization Failed!");
     cmdOp = test.op;
     cmdF3 = test.F3;
     cmdF7 = test.F7;
     aluZero = $random;

     #10;
     cg_c.sample(cmdOp, cmdF3, cmdF7);
  end

    
    cg_c.stop();
    
    // Specific test cases
    // Test case 1: ADD instruction
    cmdOp = `RVOP_ADD; cmdF3 = `RVF3_ADD; cmdF7 = `RVF7_ADD; aluZero = 0;
    #10;
    check_result(0, 1, 0, 0, `ALU_ADD, "Checking ADD instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 2: OR instruction
    cmdOp = `RVOP_OR; cmdF3 = `RVF3_OR; cmdF7 = `RVF7_OR; aluZero = 0;
    #10;
    check_result(0, 1, 0, 0, `ALU_OR, "Checking OR instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 3: SRL instruction
    cmdOp = `RVOP_SRL; cmdF3 = `RVF3_SRL; cmdF7 = `RVF7_SRL; aluZero = 0;
    #10;
    check_result(0, 1, 0, 0, `ALU_SRL, "Checking SRL instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 4: SLTU instruction
    cmdOp = `RVOP_SLTU; cmdF3 = `RVF3_SLTU; cmdF7 = `RVF7_SLTU; aluZero = 0;
    #10;
    check_result(0, 1, 0, 0, `ALU_SLTU, "Checking SLTU instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 5: SUB instruction
    cmdOp = `RVOP_SUB; cmdF3 = `RVF3_SUB; cmdF7 = `RVF7_SUB; aluZero = 0;
    #10;
    check_result(0, 1, 0, 0, `ALU_SUB, "Checking SUB instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 6: ADDI instruction
    cmdOp = `RVOP_ADDI; cmdF3 = `RVF3_ADDI; cmdF7 = `RVF7_ANY; aluZero = 0;
    #10;
    check_result(0, 1, 1, 0, `ALU_ADD, "Checking ADDI instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 7: LUI instruction
    cmdOp = `RVOP_LUI; cmdF3 = `RVF3_ANY; cmdF7 = `RVF7_ANY; aluZero = 0;
    #10;
    check_result(0, 1, 0, 1, `ALU_ADD, "Checking LUI instruction");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 8: BEQ instruction (branch taken)
    cmdOp = `RVOP_BEQ; cmdF3 = `RVF3_BEQ; cmdF7 = `RVF7_ANY; aluZero = 1;
    #10;
    check_result(1, 0, 0, 0, `ALU_SUB, "Checking BEQ instruction (branch taken)");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 9: BEQ instruction (branch not taken)
    cmdOp = `RVOP_BEQ; cmdF3 = `RVF3_BEQ; cmdF7 = `RVF7_ANY; aluZero = 0;
    #10;
    check_result(0, 0, 0, 0, `ALU_SUB, "Checking BEQ instruction (branch not taken)");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 10: BNE instruction (branch taken)
    cmdOp = `RVOP_BNE; cmdF3 = `RVF3_BNE; cmdF7 = `RVF7_ANY; aluZero = 0;
    #10;
    check_result(1, 0, 0, 0, `ALU_SUB, "Checking BNE instruction (branch taken)");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    // Test case 11: BNE instruction (branch not taken)
    cmdOp = `RVOP_BNE; cmdF3 = `RVF3_BNE; cmdF7 = `RVF7_ANY; aluZero = 1;
    #10;
    check_result(0, 0, 0, 0, `ALU_SUB, "Checking BNE instruction (branch not taken)");
    cg_c.sample(cmdOp, cmdF3, cmdF7);
    
    $finish;
  end
  
    final begin
    $display("Overall Coverage = %0f", $get_coverage());
    $display("Command Coverage = %0f", cg_c.get_coverage());
  end

endmodule
