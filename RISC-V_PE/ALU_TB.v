// ALU testbench

// Test bench for instruction decoder

`include "ALU.v"

`timescale 1ns / 1ps

module tb_alu;

    // Parameters
    reg        clk;
    reg [31:0] A;
    reg [31:0] B;
    reg [4:0] ALU_Sel;
    wire [31:0] ALU_Out;
    wire Zero;
    wire ALUcomplete;

    initial $dumpfile("alutestbench.vcd");
    initial $dumpvars(0, tb_alu);

    // Instantiate the ALU module
    alu uut (
        .clk(clk),
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .Zero(Zero),
        .ALUcomplete(ALUcomplete)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test procedure
    initial begin
        // Monitor outputs
        $monitor("Time: %0dns | A: %h | B: %h | ALU_Sel: %b | ALU_Out: %b | Zero: %b | Complete: %b", 
                 $time, A, B, ALU_Sel, ALU_Out, Zero, ALUcomplete);

        // Test case 1: Addition
        A = 32'h00000005; 
        B = 32'h00000003; 
        ALU_Sel = 5'b00000; // Addition
        #10;

        // Test case 2: Subtraction
        A = 32'h00000005; 
        B = 32'h00000003; 
        ALU_Sel = 5'b00001; // Subtraction
        #10;

        // Test case 3: Multiplication
        A = 32'h00000002; 
        B = 32'h00000003; 
        ALU_Sel = 5'b00010; // Multiplication
        #10;

        // Test case 4: Division
        A = 32'h00000006; 
        B = 32'h00000002; 
        ALU_Sel = 5'b00011; // Division
        #10;

        // Test case 5: Logical Shift Left
        A = 32'h00000001; 
        B = 32'h00000000; 
        ALU_Sel = 5'b00100; // Shift left
        #10;

        // Test case 6: Logical Shift Right
        A = 32'h00000002; 
        B = 32'h00000000; 
        ALU_Sel = 5'b00101; // Shift right
        #10;

        // Test case 7: Rotate Left
        A = 32'h80000000; 
        B = 32'h00000000; 
        ALU_Sel = 5'b00110; // Rotate left
        #10;

        // Test case 8: Rotate Right
        A = 32'h80000000; 
        B = 32'h00000000; 
        ALU_Sel = 5'b00111; // Rotate right
        #10;

        // Test case 9: Logical AND
        A = 32'hF0F0F0F0;
        B = 32'h0F0F0F0F;
        ALU_Sel = 5'b01000; // AND operation
        #10;

        // Test case 10: Logical OR
        A = 32'hF0F0F0F0;
        B = 32'h0F0F0F0F;
        ALU_Sel = 5'b01001; // OR operation
        #10;

         // Test case 11: Logical XOR
         A = 32'hF0F0F0F0;
         B = 32'h0F0F0F0F;
         ALU_Sel = 5'b01010; // XOR operation
         #10;

         // Test case 12: Logical NOR
         A = 32'hF0F0F0F0;
         B = 32'h0F0F0F0F;
         ALU_Sel = 5'b01011; // NOR operation
         #10;

         // Test case 13: Logical NAND
         A = 32'hF0F0F0F0;
         B = 32'h0F0F0F0F;
         ALU_Sel = 5'b01100; // NAND operation
         #10;

         // Test case 14: Set on Less Than Unsigned (SLTU)
         A = 32'd5;
         B = 32'd10;
         ALU_Sel = 5'b01101; // SLTU operation
         #10;

         // Test case 15: Set on Less Than (Signed)
         A = -5;
         B = -10;
         ALU_Sel = 5'b01110; // SLT operation
         #10;

         // Test case for SRA (Shift Right Arithmetic)
         A = 32'b11111111000000000000000000100101;
         B = 4;
         ALU_Sel = 5'b01111; // SRA operation
         #10;

         // Test case for take byte sign extended
         A = 32'b10111111001111011101011010110101;
         B = 32'b0;
         ALU_Sel = 5'b10000; // byte sign extended
         #10;

         // Test case for take half word sign extended
         A = 32'b10111111001111011101011010110101;
         B = 32'b0;
         ALU_Sel = 5'b10001; // half word sign extended
         #10;

         // Test case for take byte unsigned
         A = 32'b10111111001111011101011010110101;
         B = 32'b0;
         ALU_Sel = 5'b10010; // byte unsigned
         #10;

         // Test case for take half word unsigned
         A = 32'b10111111001111011101011010110101;
         B = 32'b0;
         ALU_Sel = 5'b10011; // byte unsigned
         #10;

         $finish;
    end

endmodule