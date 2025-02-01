// Test bench for instruction decoder


`timescale 1ns / 1ps
`include "decoder.v"

module tb_decoder;

    // Parameters
    reg [31:0] instruction;
    wire [6:0]  op;
    wire [1:0]  funct2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [4:0]  rs1; 
    wire [4:0]  rs2; 
    wire [4:0]  fs1; 
    wire [4:0]  fs2; 
    wire [4:0]  fs3; 
    wire [4:0]  rd;  
    wire [4:0]  fd; 
    wire [11:0] imm12; 
    wire [19:0] immhi;

    initial $dumpfile("decodertestbench.vcd");
    initial $dumpvars(0, tb_decoder);

    // Instantiate the decoder module
    decoder uut (
        .instruction(instruction),
        .op(op),
        .funct2(funct2),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .fs1(fs1),
        .fs2(fs2),
        .fs3(fs3),
        .rd(rd),
        .fd(fd),
        .imm12(imm12),
        .immhi(immhi)
    );

    // Test procedure
    initial begin
        // Monitor outputs
        $monitor("Time: %0dns | Instruction: %h | op: %d | funct2: %b | funct3: %b | funct7: %b | rs1: %b | rs2: %b | fs1: %b | fs2: %b | fs3: %b | rd: %b | fd: %b | imm12: %b | immhi: %b ", 
                 $time, instruction, op, funct2, funct3, funct7, rs1, rs2, fs1, fs2, fs3, rd, fd, imm12, immhi);

        // Test case 1: Case R instruction
        instruction = 32'b0000000_00010_00011_100_00001_0110011; //XOR
        #10;

        // Test case 2: Case J instruction
        instruction = 32'b00000000000010000011_00001_1101111; // Jump
        #10;

        // Test case 3: Case S instruction
        instruction = 32'b0000001_00010_00011_001_00001_0100011; // Store half
        #10;

        // Test case 4: Case B type
        instruction = 32'b0001000_00010_00011_100_00001_1100011; // Branch if less than
        #10;

        // Test case 5: Case I type with op 103
        instruction = 32'b000000001000_00011_000_00001_1100111; // Jump and link register
        #10;

        // Test case 5: Case I type with op 3
        instruction = 32'b000000001000_00011_001_00001_0000011; // Load half word
        #10;

        // Test case 5: Case I type with op 19
        instruction = 32'b000000001000_00011_010_00001_0010011; // Set less than immidiate
        #10;

        // Test case 5: Case U type with op 23
        instruction = 32'b00000000100000011010_00001_0010111; // Add upper imm to PC
        #10;

        // Test case 5: Case U type with op 55
        instruction = 32'b00000000100000011010_00001_0110111; // load upper immidiate
        #10;

         $finish;
    end

endmodule