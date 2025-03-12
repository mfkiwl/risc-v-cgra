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

    #10; //First case lh
    $display ("Start of load half word case");
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

    #30;
    //Expected result: 11111111111111111_1000000010100101
    if (result_out == 32'b11111111111111111000000010100101) 
    begin
        $display ("Result as expected");
    end

    #10;
    // Initialize inputs
    PCin = 32'b0;
    instruction = 32'b0;
    mem_ack = 0;
    data_Ready = 0;
    AmuxIn = 32'b0;
    BmuxIn = 32'b0;
    reset = 1;

    #10; //Second case lb
    $display ("Start of load byte case");
    reset = 0;
    PCin = 32'h00000002; // Program counter input
    instruction = 32'b000000100011_01011_000_10111_0000011; //Immidiate = 35, rs1 = 11, rd = 23, funct3 = 000, op = 3
    mem_ack = 0; // Memory acknowledgment signal
    data_Ready = 0; // Data ready signal
    AmuxIn = 32'b00000000000000000000000000100101; // Data from bus to be loaded into A mux for address calculation. Value 35
    BmuxIn = 32'b0; // Data from bus to be loaded into B mux

    #10;
    data_Ready = 1;

    #10;
    AmuxIn = 32'b00000000000000001000000010100101; // Data from bus to be loaded into A mux from address calculated. 
    mem_ack = 1;

    #30;
    //Expected result: 111111111111111111111111_10100101
    if (result_out == 32'b11111111111111111111111110100101) 
    begin
        $display ("Result as expected");
    end

    #10;
    // Initialize inputs
    PCin = 32'b0;
    instruction = 32'b0;
    mem_ack = 0;
    data_Ready = 0;
    AmuxIn = 32'b0;
    BmuxIn = 32'b0;
    reset = 1;

    #10; //Third case lb
    $display ("Start of load word case");
    reset = 0;
    PCin = 32'h00000003; // Program counter input
    instruction = 32'b000000100011_01011_010_10111_0000011; //Immidiate = 35, rs1 = 11, rd = 23, funct3 = 010, op = 3
    mem_ack = 0; // Memory acknowledgment signal
    data_Ready = 0; // Data ready signal
    AmuxIn = 32'b00000000000000000000000000100101; // Data from bus to be loaded into A mux for address calculation. Value 35
    BmuxIn = 32'b0; // Data from bus to be loaded into B mux

    #10;
    data_Ready = 1;

    #10;
    AmuxIn = 32'b10100010110000001000000010100101; // Data from bus to be loaded into A mux from address calculated. 
    mem_ack = 1;

    #30;
    //Expected result: b10100010110000001000000010100101
    if (result_out == 32'b10100010110000001000000010100101) 
    begin
        $display ("Result as expected");
    end

    #10;
    // Initialize inputs
    PCin = 32'b0;
    instruction = 32'b0;
    mem_ack = 0;
    data_Ready = 0;
    AmuxIn = 32'b0;
    BmuxIn = 32'b0;
    reset = 1;

    #10; //Fourth case ALU imm
    $display ("Start of ALU with immidiate value AND case");
    reset = 0;
    PCin = 32'h00000004; // Program counter input
    instruction = 32'b000000100011_01011_111_10111_0010011; //Immidiate = 35, rs1 = 11, rd = 23, funct3 = 010, op = 19
    mem_ack = 0; // Memory acknowledgment signal
    data_Ready = 0; // Data ready signal
    AmuxIn = 32'b00000000000000000000000000100101; // Data from bus to be loaded into A mux for address calculation. Value 35
    BmuxIn = 32'b0; // Data from bus to be loaded into B mux

    #10;
    data_Ready = 1;

    #10;
    AmuxIn = 32'b10100010110000001000000010100101; // Data from bus to be loaded into A mux from address calculated. 
    mem_ack = 1;

    #30;
    //Expected result: b00000000000000000000000000100001
    if (result_out == 32'b00000000000000000000000000100001) 
    begin
        $display ("Result as expected");
    end

    #10;
    // Initialize inputs
    PCin = 32'b0;
    instruction = 32'b0;
    mem_ack = 0;
    data_Ready = 0;
    AmuxIn = 32'b0;
    BmuxIn = 32'b0;
    reset = 1;

    #10; //Fifth case ALU operands
    $display ("Start of ALU with register values SRA case");
    reset = 0;
    PCin = 32'h00000005; // Program counter input
    instruction = 32'b0100000_01100_01011_101_00001_0110011; //funct7 = 0100000, rs1 = 11, rd = 1, funct3 = 101, op = 51
    mem_ack = 0; // Memory acknowledgment signal
    data_Ready = 0; // Data ready signal
    AmuxIn = 32'b11111111000000000000000000100101; // Data from bus to be loaded into A mux  
    BmuxIn = 32'b00000000000000000000000000000100; // Data from bus to be loaded into B mux

    #10;
    data_Ready = 1;

    #50;
    //Expected result: 11111111111100000000000000000010
    if (result_out == 32'b11111111111100000000000000000010) 
    begin
        $display ("Result as expected");
    end

    // End the simulation
    $finish;
end

endmodule
