// Code your design here
`include "sr_cpu.svh"
`include "config.svh"
`include "sr_alu.sv"
`include "sr_decode.sv"
`include "sr_register_file.sv"
`include "instruction_rom.sv"
`include "sr_control.sv"

module tt_um_yuri_panchul_schoolriscv_cpu_with_fibonacci_program
(
    input  [7:0] ui_in,    // Dedicated inputs
    output [7:0] uo_out,   // Dedicated outputs
    input  [7:0] uio_in,   // IOs: Input path
    output [7:0] uio_out,  // IOs: Output path
    output [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input        ena,      // always 1 when the design is powered, so you can ignore it
    input        clk,      // clock
    input        rst_n     // reset_n - low to reset
);

    //------------------------------------------------------------------------

    wire rst = ~ rst_n;

    wire [3:0] pc;
    wire [3:0] reg_a0;

    wire pass, fail;

    soc i_soc (.*);

    //------------------------------------------------------------------------

    assign uo_out  = { 6'b0, fail, pass };
    assign uio_out = { pc, reg_a0 };

    assign uio_oe  = '1;

    wire _unused = & { ena, ui_in, uio_in, 1'b0 };

endmodule

module register_with_rst
(
    input               clk,
    input               rst,
    input        [31:0] d,
    output logic [31:0] q
);

    always_ff @ (posedge clk)
        if (rst)
            q <= '0;
        else
            q <= d;

endmodule

module sr_cpu
(
    input           clk,      // clock
    input           rst,      // reset

    output  [31:0]  imAddr,   // instruction memory address
    input   [31:0]  imData,   // instruction memory data

    input   [ 4:0]  regAddr,  // debug access reg address
    output  [31:0]  regData   // debug access reg data
);
    // control wires

    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    wire        wdSrc;
    wire  [2:0] aluControl;

    // instruction decode wires

    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;

    // program counter

    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 32'd4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;

    register_with_rst r_pc (clk, rst, pcNext, pc);

    // program memory access

    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;

    // instruction decode

    sr_decode id
    (
        .instr      ( instr       ),
        .cmdOp      ( cmdOp       ),
        .rd         ( rd          ),
        .cmdF3      ( cmdF3       ),
        .rs1        ( rs1         ),
        .rs2        ( rs2         ),
        .cmdF7      ( cmdF7       ),
        .immI       ( immI        ),
        .immB       ( immB        ),
        .immU       ( immU        )
    );

    // register file

    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sr_register_file rf
    (
        .clk        ( clk         ),
        .a0         ( regAddr     ),
        .a1         ( rs1         ),
        .a2         ( rs2         ),
        .a3         ( rd          ),
        .rd0        ( rd0         ),
        .rd1        ( rd1         ),
        .rd2        ( rd2         ),
        .wd3        ( wd3         ),
        .we3        ( regWrite    )
    );

    // alu

    wire [31:0] srcB = aluSrc ? immI : rd2;
    wire [31:0] aluResult;

    sr_alu alu
    (
        .srcA       ( rd1         ),
        .srcB       ( srcB        ),
        .oper       ( aluControl  ),
        .zero       ( aluZero     ),
        .result     ( aluResult   )
    );

    assign wd3 = wdSrc ? immU : aluResult;

    // control

    sr_control sm_control
    (
        .cmdOp      ( cmdOp       ),
        .cmdF3      ( cmdF3       ),
        .cmdF7      ( cmdF7       ),
        .aluZero    ( aluZero     ),
        .pcSrc      ( pcSrc       ),
        .regWrite   ( regWrite    ),
        .aluSrc     ( aluSrc      ),
        .wdSrc      ( wdSrc       ),
        .aluControl ( aluControl  )
    );

    // debug register access

    assign regData = (regAddr != '0) ? rd0 : pc;

endmodule

module soc
(
    input              clk,
    input              rst,

    output       [3:0] pc,
    output       [3:0] reg_a0,

    output logic       pass,
    output logic       fail
);

    //------------------------------------------------------------------------

    wire [ 4:0] regAddr;  // debug access reg address
    wire [31:0] regData;  // debug access reg data
    wire [31:0] imAddr;   // instruction memory address
    wire [31:0] imData;   // instruction memory data

    sr_cpu cpu
    (
        .clk     ( clk      ),
        .rst     ( rst      ),
        .regAddr ( regAddr  ),
        .regData ( regData  ),
        .imAddr  ( imAddr   ),
        .imData  ( imData   )
    );

    instruction_rom # (.SIZE (64)) rom
    (
        .a       ( imAddr   ),
        .rd      ( imData   )
    );

    //------------------------------------------------------------------------

    assign regAddr = 5'd10;  // a0

    assign pc     = imAddr  [3:0];
    assign reg_a0 = regData [3:0];

    //------------------------------------------------------------------------

    logic [7:0] cnt;

    always_ff @ (posedge clk)
        if (rst)
            cnt <= '0;
        else
            cnt <= cnt + 1'd1;

    //------------------------------------------------------------------------

    always_ff @ (posedge clk)
        if (rst)
            pass <= 1'b0;
        else if (regData == 32'h00213d05)
            pass <= 1'b1;

    always_ff @ (posedge clk)
        if (rst)
            fail <= 1'b0;
        else if (& cnt == 1'b1 & ~ pass)
            fail <= 1'b1;

endmodule
