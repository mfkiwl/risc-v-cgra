// ALU testbench

// Test bench for instruction decoder

`include "ALU.v"

`timescale 1ns / 1ps

module tb_alu;

    // Parameters
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALU_Sel;
    wire [31:0] ALU_Out;
    wire CarryOut;
    wire Zero;

    initial $dumpfile("alutestbench.vcd");
    initial $dumpvars(0, tb_alu);

    // Instantiate the ALU module
    alu uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .CarryOut(CarryOut),
        .Zero(Zero)
    );

    // Test procedure
    initial begin
        // Monitor outputs
        $monitor("Time: %0dns | A: %h | B: %h | ALU_Sel: %b | ALU_Out: %h | CarryOut: %b | Zero: %b", 
                 $time, A, B, ALU_Sel, ALU_Out, CarryOut, Zero);

        // Test case 1: Addition
        A = 32'h00000005; 
        B = 32'h00000003; 
        ALU_Sel = 4'b0000; // Addition
        #10;

        // Test case 2: Subtraction
        A = 32'h00000005; 
        B = 32'h00000003; 
        ALU_Sel = 4'b0001; // Subtraction
        #10;

        // Test case 3: Multiplication
        A = 32'h00000002; 
        B = 32'h00000003; 
        ALU_Sel = 4'b0010; // Multiplication
        #10;

        // Test case 4: Division
        A = 32'h00000006; 
        B = 32'h00000002; 
        ALU_Sel = 4'b0011; // Division
        #10;

        // Test case 5: Logical Shift Left
        A = 32'h00000001; 
        B = 32'h00000000; 
        ALU_Sel = 4'b0100; // Shift left
        #10;

        // Test case 6: Logical Shift Right
        A = 32'h00000002; 
        B = 32'h00000000; 
        ALU_Sel = 4'b0101; // Shift right
        #10;

        // Test case 7: Rotate Left
        A = 32'h80000000; 
        B = 32'h00000000; 
        ALU_Sel = 4'b0110; // Rotate left
        #10;

        // Test case 8: Rotate Right
        A = 32'h80000000; 
        B = 32'h00000000; 
        ALU_Sel = 4'b0111; // Rotate right
        #10;

        // Test case 9: Logical AND
        A = 32'hF0F0F0F0;
        B = 32'h0F0F0F0F;
        ALU_Sel = 4'b1000; // AND operation
        #10;

        // Test case 10: Logical OR
        A = 32'hF0F0F0F0;
        B = 32'h0F0F0F0F;
        ALU_Sel = 4'b1001; // OR operation
        #10;

         // Test case 11: Logical XOR
         A = 32'hF0F0F0F0;
         B = 32'h0F0F0F0F;
         ALU_Sel = 4'b1010; // XOR operation
         #10;

         // Test case 12: Logical NOR
         A = 32'hF0F0F0F0;
         B = 32'h0F0F0F0F;
         ALU_Sel = 4'b1011; // NOR operation
         #10;

         // Test case 13: Logical NAND
         A = 32'hF0F0F0F0;
         B = 32'h0F0F0F0F;
         ALU_Sel = 4'b1100; // NAND operation
         #10;

         // Test case 14: Set on Less Than Unsigned (SLTU)
         A = 32'd5;
         B = 32'd10;
         ALU_Sel = 4'b1101; // SLTU operation
         #10;

         // Test case 15: Set on Less Than (Signed)
         A = -5;
         B = -10;
         ALU_Sel = 4'b1110; // SLT operation
         #10;

         // Test case for SRA (Shift Right Arithmetic)
         A = -8;
         B = 'd2;
         ALU_Sel = 'b1111; // SRA operation
         #10;

         $finish;
    end

endmodule