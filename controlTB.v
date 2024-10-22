//Testbench for controller unit

`timescale 1ns / 1ps
`include "Control.v"

module tb_controller;

    // Parameters
    reg clk;
    reg ALU0;
    reg [2:0] op;
    reg [1:0] prefix;
    reg [3:0] funct;
    reg [5:0] nalloc;
    reg endF;
    reg immab;
    reg [5:0] immlo;
    reg [25:0] immhi;
    reg [9:0] offset;
    reg [5:0] ta1, ta2, ta3, ta4;
    reg [1:0] tt1, tt2, tt3, tt4;

    // Control signal inputs from bus
    reg [1:0] prefix_i;
    reg [25:0] immhi_i;
    reg [1:0] tt3_i; 
    reg [1:0] tt4_i;
    reg [5:0] ta3_i;
    reg [5:0] ta4_i;

    // Results from previous operations to be used in opA and opB
    reg [31:0] result_1;
    reg [31:0] result_2;

    //Defines if writing to opA or writing to opB
    reg  [1:0]  tt1_ctrl; 
    reg  [1:0]  tt2_ctrl;

    // Instruction counter
    reg [5:0] icounter_i;

    // Signals for memory access operations
    reg mem_ack;
    reg [31:0] mem_Message; 
    reg [7:0][31:0] messages; 

    // Outputs from the controller
    wire mem_read;
    wire [31:0] mem_address;

    wire [3:0] ALUsel;
    wire Asel, Bsel;
    wire [1:0] Osel;

    wire [31:0] Aval, Bval, messReg;

    // Output signals when instruction is a prefix or to send the ta to perform the tt operation
    wire [1:0] prefix_o; // 00 no prefix 10 prefix I and 01 prefix T
    wire [25:0] immhi_o;
    wire [1:0]  tt1_o;
    wire [1:0]  tt2_o;
    wire [5:0]  ta1_o;
    wire [5:0]  ta2_o;
    wire [1:0]  tt3_o;
    wire [1:0]  tt4_o;
    wire [5:0]  ta3_o;
    wire [5:0]  ta4_o;
    wire        branch; // signal that defines that a branch is performed to instruction with ta1
    wire        oTerm; // signal to terminate current FI

    // Fragment start/end output signals
    wire [5:0] nalloc_o;
    wire       endAck;

    // Register enable signals
    wire       Aenable;
    wire       Benable;
    wire       Renable;

    //Output signals for send operations
    wire [2:0] outMessInd;
    wire [25:0] out_sendFIA;

    wire       invoke_on;
    wire  [5:0] icounter_o;

    // Instantiate the controller module
    controller uut (
        .clk(clk),
        .ALU0(ALU0),
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
        .tt4(tt4),

        .prefix_i(prefix_i),
        .immhi_i(immhi_i),
        .tt3_i(tt3_i), 
        .tt4_i(tt4_i),
        .ta3_i(ta3_i),
        .ta4_i(ta4_i),

        .result_1(result_1),
        .result_2(result_2),

        .icounter_i(icounter_i),

        .tt1_ctrl(tt1_ctrl), 
        .tt2_ctrl(tt2_ctrl),

        .prefix_o(prefix_o),
        .immhi_o(immhi_o),
        .tt1_o(tt1_o),
        .tt2_o(tt2_o),
        .tt3_o(tt3_o),
        .tt4_o(tt4_o),
        .ta1_o(ta1_o),
        .ta2_o(ta2_o),
        .ta3_o(ta3_o),
        .ta4_o(ta4_o),

        .branch(branch),
        .oTerm(oTerm),

        .nalloc_o(nalloc_o),
        .endAck(endAck),

        .Aenable(Aenable),
        .Benable(Benable),
        .Renable(Renable),

        .outMessInd(outMessInd),
        .out_sendFIA(out_sendFIA),

        .invoke_on(invoke_on),
        .icounter_o(icounter_o),

        .mem_ack(mem_ack),
        .mem_Message(mem_Message), 
        .messages(messages),

        // Outputs
        .mem_read(mem_read),
        .mem_address(mem_address),

        // Control signals
        .ALUsel(ALUsel),
        .Asel(Asel),
        .Bsel(Bsel),
        .Osel(Osel),

        // Other outputs
        .Aval(Aval), 
        .Bval(Bval), 
        .messReg(messReg)
        
   );

   // Clock generation
   initial begin
       clk = 0;
       forever #5 clk = ~clk; // Toggle clock every 5 time units
   end

   // Test procedure
   initial begin
       // Initialize inputs
       ALU0 = 0; 
       op = 3'b000; 
       prefix = 2'b00; 
       funct = 4'b0000; 
       nalloc = 6'b000001; 
       endF = 0; 
       immab = 1'b0; 
       immlo = 6'b000001; 
       immhi = 26'b000000000000000000000001; 
       offset = 10'b0000000001; 
       ta1 = 6'b000001; 
       ta2 = 6'b000010; 
       ta3 = 6'b000011; 
       ta4 = 6'b000100; 
       tt1 = 2'b00; 
       tt2 = 2'b01; 
       tt3 = 2'b10; 
       tt4 = 2'b11;

       prefix_i = 2'b00;  
       immhi_i = 26'b000000000000000000000001;  
       tt3_i = 2'b00;  
       tt4_i = 2'b01;  
       ta3_i = 6'b000011;  
       ta4_i = 6'b000100;

       result_1 = 32'hA5A5A5A5;  
       result_2 = 32'h5A5A5A5A;

       icounter_i = 6'd0;

       mem_ack = 1'b0;  
       
       messages[0] = 32'hDEADBEEF; // Example message data

       // Test case for ALU operation (opcode == 000)
       #10 op = 3'b000; funct = 4'b0011; // Example ALU operation (Addition)
       
       #10 op = 3'b001; funct = 4'b0100; // Example memory operation (lb)
       
       #10 op = 3'b010; funct = 4'b1001; // Example send operation (sw)
       
       #10 op = 3'b101; endF = 1; // Fragment end operation

       #10 $finish; // End simulation
   end

endmodule