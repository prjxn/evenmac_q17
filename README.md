# Structural 8-bit Pipelined MAC Unit (Q1.7 Fixed-Point)

## Overview
A high-performance Verilog implementation of an 8-bit signed fixed-point Multiply-Accumulate (MAC) unit, designed with a focus on Structural RTL. The unit explicitly avoids high-level behavioral operators, instead utilizing explicit bit-level arithmetic structures for all computations.

Operation: Y = (A x B) + C

* Input Format: Q1.7 (8-bit signed)
* Output Format: Q1.7 (Rounded & Saturated)
* Internal Precision: 18-bit datapath to maintain accuracy and prevent intermediate overflow.


## Architecture
The MAC is implemented as a 3-stage pipelined datapath, optimized for high-frequency synthesis by balancing the logic depth between stages.

### 1. Stage 1: PP Gen & Operand Alignment (pp_gen)
* Modified Baugh-Wooley: Generates 8 partial products.
* Alignment: The 8-bit C input is sign-extended and left-shifted by 7 bits to align its binary point with the Q2.14 product of A x B.

### 2. Stage 2: Multi-Operand Reduction (csa_tree)
* CSA Tree: A Wallace-style Carry-Save Adder tree reduces 9 operands (8 PPs + Aligned C) down to a redundant Sum and Carry vector.
* Efficiency: Using CSA reduction minimizes the critical path to O(log N) gate delays compared to a linear adder chain.

### 3. Stage 3: Post-Processing (round_saturate)
* Final Addition: A Carry-Propagate Adder (CPA) converts the redundant vectors into a 18-bit binary sum.
* RNE Rounding: Implements Round-to-Nearest-Even logic using Guard and Sticky bits (OR-reduction of the lower 7 fractional bits) to eliminate statistical bias.
* Saturation: Detects overflow/underflow by comparing the "True Sign" against the MSBs of the accumulator, clipping the output to 0x7F or 0x80 respectively.

## Pipeline Specification

| Stage | Function | Hardware Structures |
| :--- | :--- | :--- |
| Stage 1 | Partial Product Gen | Inverter + Adder (for A_neg), Shifters |
| Stage 2 | CSA Reduction | Wallace Tree (3:2 Compressors) |
| Stage 3 | CPA & Rounding | 18-bit CPA, Sticky-bit Logic, Saturation Muxes |

* Latency: 3 Cycles
* Throughput: 1 Result/Cycle

## Features
* Zero Operator Inference: No "*" or "-" operators used; all arithmetic is performed via structural instantiation of adder_n.
* Glitch-Resistant: Fully registered boundaries at every stage.
* High Fidelity: RNE rounding provides superior accuracy over simple truncation for DSP applications.
* Handshake Protocol: Integrated valid_in/valid_out signals for easy integration into larger SoC fabrics.

## Verification
The design was verified using a bit-accurate Verilog testbench comparing the DUT against a golden reference model.

* Coverage: 1,000 test vectors (343 corner cases + 657 Pseudo-random).
* Checks: Verified latency-aligned valid_out and bit-exact RNE/Saturation results.
