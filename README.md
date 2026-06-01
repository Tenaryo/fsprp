# Five-Stage Pipelined RISC-V Processor

A synthesizable 5-stage pipelined RISC-V (RV32I subset) processor written in Verilog, supporting 22 instructions. Simulated with Icarus Verilog.

## Architecture

Pipeline stages: **IF → ID → EX → MEM → WB**

### Hazard Handling (Lab 4)

- **Data forwarding**: ALU operands are forwarded from EX/MEM and MEM/WB stages to bypass register-file write latency. EX/MEM has priority over MEM/WB.
- **Load-use stall**: When a `lw`/`lb`/`lbu` instruction in EX is followed by a dependent instruction in ID, the pipeline inserts one bubble (stalls PC, preserves IF/ID, flushes ID/EX).
- **Control hazard**: Predict branch not-taken. On mispredict (branch actually taken), flush the instruction in IF. Branch/jal resolved in ID (1-cycle penalty), jalr resolved in EX (2-cycle penalty).

### No Hardware Handling Required

Stores do not need forwarding for the data operand: the forwarded `rs2` value is captured in EX/MEM and written to data memory from the MEM stage.

## Supported Instructions

| Category | Instructions |
|----------|-------------|
| R-type ALU | `add`, `sub`, `and`, `or`, `sll`, `srl`, `sra` |
| I-type ALU | `addi`, `andi`, `slli`, `srli` |
| Memory | `lw`, `sw`, `lb`, `lbu`, `sb` |
| Branch | `beq`, `bne`, `bge`, `blt` |
| Jump | `jal`, `jalr` |

## Dependencies

- [Icarus Verilog](http://iverilog.icarus.com/) (>= 11.0)
- [Surfer](https://surfer-project.org/) (optional, for waveform viewing)

## Build & Test

```bash
# Run the official test program (make sim)
make sim

# Run all per-instruction tests (22 tests)
make tests

# Run a single instruction test
make test_add

# View waveform
make wave

# Clean build artifacts
make clean
```

## Project Structure

```
├── sim1.v                             # Official testbench
├── Makefile
├── rtl/                               # RTL source
│   ├── five_stage_pipeline.v          # Top-level 5-stage pipeline
│   ├── pipeline_regs.v                # Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
│   ├── pc_reg.v                       # PC register with stall support
│   ├── inst_mem.v                     # Instruction memory (ROM)
│   ├── ctrl_unit.v                    # Control unit / decoder
│   ├── reg_file.v                     # Register file (32 × 32-bit)
│   ├── extend.v                       # Immediate generator (I/S/B/J/U types)
│   ├── alu.v                          # Arithmetic logic unit
│   └── data_mem.v                     # Data memory (128 bytes, byte/word access)
├── tests/                             # Test suite
│   ├── include/test_macros.vh         # Shared test macros (CHECK_EQ, PASS, FAIL)
│   ├── golden/sim1_expected.txt       # Golden output for sim1
│   └── test_*.v                       # Per-instruction tests (22 tests)
└── docs/                              # Documentation
    └── Lab3.pdf
```
