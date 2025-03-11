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
reg        reset;
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
    .PCout(PCout),
    .reset(reset)
);

// Generate clock signal
initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock with a period of 10 time units
end

// Initialize and apply test vectors
initial begin
    // Monitor outputs
        $monitor("Time: %0dns | PCout: %d | mem_address: %b | reg_select: %b | mem_read: %b | mem_write: %b | messReg: %b | rs1: %b | rs2: %b | rd: %b | rd_Write: %b | result_out: %b", 
                 $time, PCout, mem_address, reg_select, mem_read, mem_write, messReg, rs1Out, rs2Out, rdOut, rdWrite, result_out);

    // Initialize inputs
    PCin = 32'b0;
    instruction = 32'b0;
    mem_ack = 0;
    data_Ready = 0;
    AmuxIn = 32'b0;
    BmuxIn = 32'b0;
    reset = 1;

    

    #10; //Second case lh
    reset = 0;
    PCin = 32'h00000001; // Program counter input
    instruction = 32'b000000100011_01011_001_10111_0000011; //Immidiate = 35, rs1 = 11, rd = 23, funct3 = 001, op = 3
    mem_ack = 0; // Memory acknowledgment signal
    data_Ready = 0; // Data ready signal
    AmuxIn = 32'b00000000000000000000000000100101; // Data from bus to be loaded into A mux for address calculation. Value 35
    BmuxIn = 32'b0; // Data from bus to be loaded into B mux

    #10;
    data_Ready = 1;

    #10;
    AmuxIn = 32'b00000000000000001000000010100101; // Data from bus to be loaded into A mux from address calculated. 
    mem_ack = 1;
    //Expected result: 11111111111111111_1000000010100101

    #50;


    // End the simulation
    $finish;
end

endmodule
