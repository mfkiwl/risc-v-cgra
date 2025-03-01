`include "ProcessingElement.v"

module test_processing_element;

// Testbench signals
reg clk;
reg [31:0] PCin;
reg [31:0] instruction;
reg mem_ack;
reg data_Ready;
reg [31:0] AmuxIn;
reg [31:0] BmuxIn;
wire [31:0] mem_address;
wire reg_select;
wire mem_read;
wire [31:0] messReg;
wire [4:0] rs1Out;
wire [4:0] rs2Out;
wire [4:0] rdOut;
wire rdWrite;
wire mem_write;
wire [31:0] result_out;
wire [31:0] PCout;

// Instantiate the processing element module
processing_element uut (
    .clk(clk),
    .PCin(PCin),
    .instruction(instruction),
    .mem_ack(mem_ack),
    .data_Ready(data_Ready),
    .AmuxIn(AmuxIn),
    .BmuxIn(BmuxIn),
    .mem_address(mem_address),
    .reg_select(reg_select),
    .mem_read(mem_read),
    .messReg(messReg),
    .rs1Out(rs1Out),
    .rs2Out(rs2Out),
    .rdOut(rdOut),
    .rdWrite(rdWrite),
    .mem_write(mem_write),
    .result_out(result_out),
    .PCout(PCout)
);

// Generate clock signal
initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock with a period of 10 time units
end

// Initialize and apply test vectors
initial begin
    // Initialize inputs
    PCin = 32'b0;
    instruction = 32'b0;
    mem_ack = 0;
    data_Ready = 0;
    AmuxIn = 32'b0;
    BmuxIn = 32'b0;

    // Apply a test case
    #10;
    PCin = 32'h00000001; // Program counter input
    instruction = 32'h00000013; // Example instruction
    mem_ack = 1; // Memory acknowledgment signal
    data_Ready = 1; // Data ready signal
    AmuxIn = 32'h00000002; // Data from bus to be loaded into A mux
    BmuxIn = 32'h00000003; // Data from bus to be loaded into B mux

    // Wait for some time to observe outputs
    #50;

    // End the simulation
    $finish;
end

endmodule
