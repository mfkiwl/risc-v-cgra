// Test bench for instruction decoder


`timescale 1ns / 1ps
`include "decoder.v"

module tb_decoder;

    // Parameters
    reg [31:0] instruction;
    wire [2:0] op;
    wire [1:0] prefix;
    wire [3:0] funct;
    wire [5:0] nalloc;
    wire endF;
    wire immab;
    wire [5:0] immlo;
    wire [25:0] immhi;
    wire [9:0] offset;
    wire [5:0] ta1;
    wire [5:0] ta2;
    wire [5:0] ta3;
    wire [5:0] ta4;
    wire [1:0] tt1;
    wire [1:0] tt2;
    wire [1:0] tt3;
    wire [1:0] tt4;

    initial $dumpfile("decodertestbench.vcd");
    initial $dumpvars(0, tb_decoder);

    // Instantiate the decoder module
    decoder uut (
        .instruction(instruction),
        .op(op),
        .prefix(prefix),
        .funct(funct),
        .nalloc(nalloc),
        .endF(endF),
        .immab(immab),
        .immlo(immlo),
        .immhi(immhi),
        .offset(offset),
        .ta1(ta1),
        .ta2(ta2),
        .ta3(ta3),
        .ta4(ta4),
        .tt1(tt1),
        .tt2(tt2),
        .tt3(tt3),
        .tt4(tt4)
    );

    // Test procedure
    initial begin
        // Monitor outputs
        $monitor("Time: %0dns | Instruction: %h | op: %b | prefix: %b | funct: %b | endF: %b | immab: %b | immlo: %h | immhi: %h | offset: %h | ta1: %h | ta2: %h | ta3: %h | ta4: %h | tt1: %b | tt2: %b | tt3: %b | tt4: %b", 
                 $time, instruction, op, prefix, funct, endF, immab, immlo, immhi, offset, ta1, ta2, ta3, ta4, tt1, tt2, tt3, tt4);

        // Test case 1: Case D instruction word
        //instruction = 32'b000_0001_0_010101_00_10_101010_11_111100; //ALU Case
        //#10;

        // Test case 2: Case D word lhu
        instruction = 32'b001_0101_1_110011_00_10_010101_11_000111; // Example instruction
        #10;

        // Test case 3: Case W word sw
        //instruction = 32'b010_0011_0_010101_00000000_1011001110; // Example instruction
        //#10;

        // Test case 4: Case T prefix
        //instruction = 32'b011_0000000000000_10_101010_11_111100; // Example instruction
        //#10;

        // Test case 5: Case I prefix
        //instruction = 32'b100_000_10101010101010101010101010; // Example instruction
        //#10;

        // Test case 6: Case fragment end/start
        //instruction = 32'b101_0_0000000000000000000000_110011;
        //#10;

        // Test case 7: Invalid opcode (default case)
        //instruction = 32'hFFFFFFFF; // Example invalid instruction
        //#10;

         $finish;
    end

endmodule