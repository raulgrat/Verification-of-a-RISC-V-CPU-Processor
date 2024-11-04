// Please paste this testbench code into testbench.sv and run when trying to see RegisterFileTestbench results OR change second file in files.f to RegisterFileTestbench.sv
// Change the first line file in files.f to sr_register_file.sv

// RegisterFileTestbench.sv
`default_nettype none
`timescale 1ns / 1ps

module tb ();

  reg clk;
  reg [4:0] a0, a1, a2, a3;
  reg [31:0] wd3;
  reg we3;
  
  wire [31:0] rd0, rd1, rd2;
  
  sr_register_file RF_UUT (
    .clk(clk),
    .a0(a0),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .rd0(rd0),
    .rd1(rd1),
    .rd2(rd2),
    .wd3(wd3),
    .we3(we3)
  );
  
  covergroup cg_addr with function sample(bit [4:0] addr);
    cp_addr: coverpoint addr {
      bins all_addrs[] = {5'b00000, 5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, 5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101, 5'b01110, 5'b01111, 5'b10000, 5'b10001, 5'b10010, 5'b10011, 5'b10100, 5'b10101, 5'b10110, 5'b10111, 5'b11000, 5'b11001, 5'b11010, 5'b11011, 5'b11100, 5'b11101, 5'b11110, 5'b11111};
    }
  endgroup
  
  covergroup cg_cross with function sample(bit [4:0] addr, bit [31:0] data);
    cp_addr: coverpoint addr {
      bins all_addrs[] = {5'b00000, 5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, 5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101, 5'b01110, 5'b01111, 5'b10000, 5'b10001, 5'b10010, 5'b10011, 5'b10100, 5'b10101, 5'b10110, 5'b10111, 5'b11000, 5'b11001, 5'b11010, 5'b11011, 5'b11100, 5'b11101, 5'b11110, 5'b11111};
    }
    cp_data: coverpoint data {
      wildcard bins all_data = {32'h????????};
    }
    cross cp_addr, cp_data;
  endgroup
  
  class RegisterFileTest;
    rand bit [4:0] addr;
    rand bit [31:0] data;
  endclass
  
  task check_result(input bit[31:0] expected, input bit[31:0] actual, string msg);
    if (expected !== actual) begin
      $display("FAIL: %s. Expected: %0d, Actual: %0d", msg, expected, actual);
    end else begin
      $display("PASS: %s. Expected: %0d, Actual: %0d", msg, expected, actual);
    end
  endtask
  
  cg_addr cg_a0, cg_a1, cg_a2, cg_a3;
  cg_cross cg_c;
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    RegisterFileTest test = new();
    
    // Initialize covergroups
    cg_a0 = new();
    cg_a1 = new();
    cg_a2 = new();
    cg_a3 = new();
    cg_c = new();
    
    // Randomized test cases
    repeat (128) begin
      assert(test.randomize()) else $error("Randomization Failed!");
      a3 = test.addr;
      wd3 = test.data;
      we3 = 1'b1;
      
      #10;
      we3 = 1'b0;
      
      cg_a3.sample(a3);
      cg_c.sample(a3, wd3);
      
      #10;
      a0 = a3;
      #10;
      if (a0 == 5'b0) begin
        check_result(32'b0, rd0, "Checking read data from register 0");
      end else begin
        check_result(wd3, rd0, $sformatf("Checking read data from register %0d", a3));
      end
      
      cg_a0.sample(a0);
    end
    
    cg_a0.stop();
    cg_a1.stop();
    cg_a2.stop();
    cg_a3.stop();
    cg_c.stop();
    
    // Initialize inputs
    a0 = 5'b0; a1 = 5'b0; a2 = 5'b0; a3 = 5'b0;
    wd3 = 32'b0; we3 = 1'b0;
    
    // Specific test cases
    // Test case 1: Write to register 1 and read back
    a3 = 5'd1; wd3 = 32'hA5A5A5A5; we3 = 1'b1;
    #10; we3 = 1'b0;
    cg_a3.sample(a3); cg_c.sample(a3, wd3);
    #10; a0 = 5'd1;
    #10; check_result(32'hA5A5A5A5, rd0, "Checking Expected read data from register 1");
    cg_a0.sample(a0);
    
    // Test case 2: Write to register 2 and read back
    a3 = 5'd2; wd3 = 32'h5A5A5A5A; we3 = 1'b1;
    #10; we3 = 1'b0;
    cg_a3.sample(a3); cg_c.sample(a3, wd3);
    #10; a0 = 5'd2;
    #10; check_result(32'h5A5A5A5A, rd0, "Checking Expected read data from register 2");
    cg_a0.sample(a0);
    
    // Test case 3: Write to register 0 (should not change)
    a3 = 5'd0; wd3 = 32'hFFFFFFFF; we3 = 1'b1;
    #10; we3 = 1'b0;
    cg_a3.sample(a3); cg_c.sample(a3, wd3);
    #10; a0 = 5'd0;
    #10; check_result(32'b0, rd0, "Checking Expected read data from register 0");
    cg_a0.sample(a0);
    
    $finish;
  end
  
  final begin
    $display("Overall Coverage = %0f", $get_coverage());
    $display("Address Coverage a0 = %0f", cg_a0.get_coverage());
    $display("Address Coverage a1 = %0f", cg_a1.get_coverage());
    $display("Address Coverage a2 = %0f", cg_a2.get_coverage());
    $display("Address Coverage a3 = %0f", cg_a3.get_coverage());
    $display("Cross Coverage = %0f", cg_c.get_coverage());
  end

endmodule
