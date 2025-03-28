`include "PEinterface.v"
`timescale 1ns / 1ps

module tb_PE_system;

    // Testbench signals
    reg clk;
    reg reset;
    reg grant;      // Grant signal from arbiter
    reg [31:0] PCinBus;    // Program counter sent to the PE
    reg [31:0] instructionBus; // Instruction loaded into the PE
    reg [31:0] AmuxBus;    // Data sent to A mux
    reg [31:0] BmuxBus;    // Data sent to B mux
    reg mem_ackBus;        // Memory acknowledgment signal from the bus
    reg data_ReadyBus;     // Register read complete signal
    reg [31:0] memData;    // Data from global memory
    reg instrWrite;        // Signal from controller to write instruction into PE

    // Outputs from the PE_system
    wire [31:0] mem_addressBus;  // Memory address sent to bus for global memory
    wire [31:0] result_outBus;   // Result output sent to bus
    wire [31:0] PCoutBus;        // New program counter to be sent to the controller
    wire [4:0] rs1OutBus;        // Local memory select signal for rs1
    wire [4:0] rs2OutBus;        // Local memory select signal for rs2
    wire [4:0] rdOutBus;         // Local memory select signal for rd
    wire reg_selectBus;          // Select signal for local memory read (1 or 2 data)
    wire mem_readBus;            // Signal to read from global memory
    wire mem_writeBus;           // Signal to write to global memory
    wire rd_writeBus;            // Signal to write to local memory
    wire read_enBus;             // Signal to read from local memory
    wire bus_request;            // Request signal sent to arbiter

    // Instantiate the PE_system
    PE_system uut (
        .clk(clk),
        .reset(reset),
        .grant(grant),
        .PCinBus(PCinBus),
        .instructionBus(instructionBus),
        .AmuxBus(AmuxBus),
        .BmuxBus(BmuxBus),
        .mem_ackBus(mem_ackBus),
        .data_ReadyBus(data_ReadyBus),
        .memData(memData),
        .instrWrite(instrWrite),
        .mem_addressBus(mem_addressBus),
        .result_outBus(result_outBus),
        .PCoutBus(PCoutBus),
        .rs1OutBus(rs1OutBus),
        .rs2OutBus(rs2OutBus),
        .rdOutBus(rdOutBus),
        .reg_selectBus(reg_selectBus),
        .mem_readBus(mem_readBus),
        .mem_writeBus(mem_writeBus),
        .rd_writeBus(rd_writeBus),
        .read_enBus(read_enBus),
        .bus_request(bus_request)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period = 10 time units
    end

    // Testbench logic
    initial begin
        // Dump waveform for debugging
        $dumpfile("tb_PE_system.vcd");
        $dumpvars(0, tb_PE_system);

        // Initialize signals
        reset = 1;
        grant = 0;
        PCinBus = 32'h00000000;
        instructionBus = 32'h00000000;
        AmuxBus = 32'h00000000;
        BmuxBus = 32'h00000000;
        mem_ackBus = 0;
        data_ReadyBus = 0;
        memData = 32'h00000000;
        instrWrite = 0;

        #10 reset = 0; // Release reset

        // Test Case 1: Instruction Write
        instructionBus = 32'h2BB81A3; // Load an instruction
        instrWrite = 1; // Trigger instruction write
        PCinBus = 32'h12345678; // Program counter update
        #10 instrWrite = 0; // Deassert instruction write

        // Test Case 2: Memory Write Request
        PCinBus = 32'h12345679; // Program counter update
        grant = 1; // Bus grants access
        instructionBus = 32'h2BB81A3;
        #10 // Clear memory write request
        grant = 0;

        // Test Case 3: Memory Read Request
        grant = 1; // Bus grants access
        memData = 32'h87654321; // Data from memory
        mem_ackBus = 1; // Acknowledge memory read
        #10  // Clear memory read request
        mem_ackBus = 0;
        grant = 0;

        // Test Case 4: Register Read
        AmuxBus = 32'h11111111; // Data for rs1
        BmuxBus = 32'h22222222; // Data for rs2
        data_ReadyBus = 1; // Data is ready
        #10 
        data_ReadyBus = 0;

        // Test Case 5: Bus Request
        grant = 1; // Bus grants access
        #10 
        grant = 0;

        // End simulation
        #50 $finish;
    end

endmodule
