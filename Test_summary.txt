# 8-Bit ALU — Directed Simulation Results

Simulator: Questa/ModelSim  
Testbench: tb_directed.sv

## Test Summary
- Directed test cases: 10
- PASS: 11 (including asynchronous reset test)
- FAIL: 0
- Overall Result: PASS

## Tested Scenarios
- ADD: normal operation, carry, signed overflow
- SUB: equal operands, borrow
- CMP: equal operands
- AND: zero result
- SHL: shifted-out carry
- MUL: maximum unsigned operands
- Reserved opcode: E
- Asynchronous reset during transaction

Note: This is the initial directed regression. It does not represent exhaustive verification of all opcodes or corner cases.
