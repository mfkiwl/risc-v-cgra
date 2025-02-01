// Procesing element top module
`include "Control.v"
`include "decoder.v"
`include "ALU.v"
`include "mux2_1.v"
`include "mux3_1.v"
`include "reg.v"

module processing_element (
    input clk,
    input reset,
    input [31:0] instruction,  // Input instruction             
    input mem_ack,             // Memory acknowledgment signal from bus
    input [31:0] mem_Message,  // Data received from memory
    input [7:0][31:0] messages,// Array of Messages coming from memory
    input prefix_i,            // Input indicating if instruction has a prefix
    input [25:0] immhi_i,      // Value of higher bits of immidiate value coming from prefix
    input [1:0] tt3_i,         // Value of tt3 coming from prefix
    input [1:0] tt4_i,         // Value of tt4 coming from prefix
    input [5:0] ta3_i,         // Value of ta3 coming from prefix
    input [5:0] ta4_i,         // Value of ta4 coming from prefix
    input [31:0] result1,      // Previous result1 to control unit
    input [31:0] result2,      // Previous result2 to control unit
    input [1:0] tt1_ctrl,      // Type of operation for result1
    input [1:0] tt2_ctrl,      // Type of operation for result2
    input [5:0] i_counter_i,   // Operation number ID or counter
    output [31:0] mem_address, // Address for memory operations
    output mem_read,           // Memory read signal     
    output [31:0] messReg,     // Register for message data
    ouput         invoke_on,   // Signal for when invoke is called
    output        branch,      // Signal for when there is a branch
    output        oTerm,       // Output for termination of FI
    output [5:0]  nalloc_o,    // Number of instructions when fragment starts
    output [2:0]  outMessInd,  // Message index when performing invoke
    output [5:0]  i_counter_o, // Final count of operation counter
    output [1:0]  prefix_o,    // When instruction is a prefix
    output [1:0]  tt1_o,       // When instruction is a prefix
    output [1:0]  tt2_o,       // When instruction is a prefix
    output [1:0]  tt3_o,       // When instruction is a prefix
    output [1:0]  tt4_o,       // When instruction is a prefix
    output [5:0]  ta1_o,       // When instruction is a prefix
    output [5:0]  ta2_o,       // When instruction is a prefix
    output [5:0]  ta3_o,       // When instruction is a prefix
    output [5:0]  ta4_o,       // When instruction is a prefix
    output [25:0] out_sendFIA, // FIA for invoke 
    output        endAck      // End FI acknowledge
);



    // Internal signals
    wire [2:0] op;                 // Opcode from instruction
    wire [3:0] funct;              // Function code from instruction
    wire [5:0] nalloc;             // Number of allocations in fragment
    wire endF;                     // End flag for fragment
    wire immab;                    // Immediate address bit
    wire [5:0] immlo;              // Immediate lower bits
    wire [25:0] immhi;             // Immediate higher bits
    wire [9:0] offset;             // Offset for memory operations
    wire [5:0] ta1, ta2, ta3, ta4; // Target addresses from instruction
    wire [1:0] tt1, tt2, tt3, tt4; // Target types from instruction
    wire       ALU0; // ALU result zero flag

    wire [31:0] Aval;          // Operand A value from register or immediate
    wire [31:0] Bval;          // Operand B value from register or immediate
    wire [3:0] ALUsel;         // ALU operation select signal
    wire Asel, Bsel;           // MUX select signals for operands
    wire [1:0] Osel;           // MUX select signal for output

    wire       Aenable;      // Enables A register
    wire       Benable;      // Enables B register
    wire       Renable;      // Enables R register
    wire       reset;

    wire [31:0] opAmux;         // Signal from register output of A to mux
    wire [31:0] opBmux;         // Signal from register output of B to mux
    wire [31:0] opAmux2;        // Signal from register output of R to mux

    wire [31:0] muxAout;        // Signal output from MUX
    wire [31:0] muxBout;        // Signal output from MUX
    wire [31:0] AluRes;         // Signal output from ALU into Output mux


    // Instantiate the controller module
    controller ctrl (
        .clk(clk),
        .ALU0(ALU0),
        .op(op),
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
        .messReg(messReg),
        .reset(reset)    
   );

   // Instantiate the register module A
    Register regA (
       .clk(clk),
       .reset(reset),
       .r_enable(Aenable), 
       .data_in(Aval), 
       .data_out(opAmux), 
   );

   Register regB (
    .clk(clk),
    .reset(reset),
    .r_enable(Benable), 
    .data_in(Bval), 
    .data_out(opBmux), 
   );

   Register regR (
    .clk(clk),
    .reset(reset),
    .r_enable(Renable), 
    .data_in(result_1), 
    .data_out(opAmux2), 
   );  


   // Instantiate ALU module
   ALU alu (
       .A(muxAout), 
       .B(muxBout), 
       .ALUsel(ALUsel), 
       .ALU_Out(AluRes),  // Output result from ALU operation.
       .Zero(ALU0)
   );

   // Instantiate MUXes 
   mux2_1 muxA (
       .in_1(opAmux), 
       .in_2(opAmux2), 
       .sel(Asel), 
       .data_out(muxAout)  // Output to be used as operand A.
   );

   mux2_1 muxB (
       .in_1(offset), 
       .in_2(opBmux), 
       .sel(Bsel), 
       .data_out(muxBout)  // Output to be used as operand B.
   );

   mux3_1 muxOut (
       .in_1(opAmux), 
       .in_2(opBmux), 
       .in_3(AluRes), 
       .sel(Osel),  // Example selection logic based on end flag and prefix.
       .data_out(messReg)  // Output message register.
   );

endmodule