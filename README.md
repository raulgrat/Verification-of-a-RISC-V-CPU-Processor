# Verification of RISC-V Processor Modules

## Project Overview

This project focuses on the development of a verification plan and testbenches for key components of a RISC-V processor, including the ALU, decoder, register file, and control logic. Using SystemVerilog, we conducted functional verification to ensure robust performance across both standard and edge-case scenarios. The verification process included randomized input generation, opcode constraints, and weighted distributions to achieve comprehensive functional coverage.

### Features

- **Functional Verification**: Developed testbenches targeting full functionality across critical modules.
- **Coverage Goals**: Aimed for 100% functional coverage on critical opcodes and register addresses.
- **Enhanced Methodology**: Employed pass/fail logic, edge-case handling, and manual output checks to validate expected results across modules.

### Tools Used

- **SystemVerilog**: For writing testbenches and implementing verification logic.
- **EDA Playground**: Platform used to run simulations and test the existing design.

## Credits

Credit regarding the design of the RISC-V processor goes to the original designers:

- **GitHub Repository**: [ddvca/tt08-schoolriscv-cpu-with-fibonacci-program](https://github.com/ddvca/tt08-schoolriscv-cpu-with-fibonacci-program)
- **Tiny Tapeout**: [tt08/tt_um_yuri_panchul_schoolriscv_cpu_with_fibonacci_program](https://tinytapeout.com/runs/tt08/tt_um_yuri_panchul_schoolriscv_cpu_with_fibonacci_program)

Group collaborators:

- [Francisco Soriano](https://github.com/Francisco-Soriano)
- [Raul Graterol](https://github.com/raulgrat)
- [Jack Get](https://github.com/jackgetgithub)


**Note**: This existing design was run on EDA Playground.

