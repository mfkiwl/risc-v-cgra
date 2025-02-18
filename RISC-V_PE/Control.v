// Control module

module controller (

// Input clock
input        clk,

// Input from ALU result and instruction decoder
input        ALU0,
input [6:0]  op,
input [1:0]  funct2,
input [2:0]  funct3,
input [6:0]  funct7,
input [4:0]  rs1,
input [4:0]  rs2,
input [4:0]  rd,
input [11:0] imm12,
input [19:0] immhi,
input        ALUcomplete, //Indicates end of ALUoperation

// Control signal inputs/outputs from bus
input  [31:0] PCin, //Program counter input
output reg [31:0] PCout, //Program counter output

// Results from previous operations to be used in opA and opB
// Might remove, using RISC-V registers as inputs for operands
input  [31:0] result_1,
input  [31:0] result_2,

// Signals for memory access operations
input        mem_ack,
input [31:0] mem_Message, //input received when load functions are called

// Selection signal outputs for the 3 MUX and the ALU
output reg [4:0] ALUsel,
output reg [1:0] Asel, //Can be rs1 from decoder, dataInput from bus or PC from bus
output reg       Bsel, //Can be rs2 from decoder or immvalue from controller
output reg [1:0] Osel, //Can be ALU result, opA register, or opB register

output reg [4:0] rdOut, // This is the address of the destination register
output reg rdWrite, //Indicates that output will be written to rd

output reg [31:0] messReg, // Result being sent to the bus. Might remove

//Register input values
// Might remove. Find how to wire the proper values
output reg [31:0] Aval,
output reg [31:0] Bval,

// Register enable signals
output reg       Aenable,
output reg       Benable,

// Output signals for read/write to memory
output reg        mem_read, // If mem_read is 1, value from the output of the PE is a memory address that must be read
output reg [31:0] mem_address, // might remove

output reg [31:0] immvalue //Value being wired to reg B mux
);

// Internal signals
reg [31:0] tempimmvalue = 0; //Fill with imm12 or immhi
reg [31:0] tempVal = 0;
reg [31:0] tempValA = 0; 
reg [31:0] tempValB = 0;

always @(posedge clk) 
begin
    //initialize values
    PCout <= 0;
    ALUsel <= 0;
    Asel <= 0;
    Bsel <= 0;
    Osel <= 0;
    rdOut <= 0;
    rdWrite <= 0;
    Aenable <= 0;
    Benable <= 0;
    mem_read <= 0;
    immvalue <= 0;


    case(op)
    7'b0000011: // Op code 3 is load operations
    begin
        Asel <= 00; // Select rs1 as A input
        if (imm12[11]==0)
        begin
            tempimmvalue = {20'b00000000000000000000, imm12};
        end
        else
        begin
            tempimmvalue = {20'b11111111111111111111, imm12};
        end
        immvalue <= tempimmvalue;
        Bsel <= 1; //Select immidiate value as B input
        // Enable registers to load value
        Aenable <= 1; 
        Benable <= 1;

        //Select ALU to add values
        ALUsel <= 5'b00000;

        //Select ALU result as output to send address
        Osel <= 00; 

        if (ALUcomplete)
        begin
            mem_read <= 1; //Send signal for memory read
            Aenable <= 0;
            Benable <= 0;
        end

        if (mem_ack) //After acknowledge signal has been received
        begin
            Aenable <= 1;
            Asel <= 01; //Select data from bus as A input
            case (funct3)
            3'b000: // Load byte sign extended
                begin
                ALUsel <= 5'b10000; // Select take byte sign extended from ALU
                Osel <= 00; //Select output from ALU
                end
            3'b001: // Load half word sign extended
                begin
                ALUsel <= 5'b10001; // Select take half word sign extended from ALU
                Osel <= 00; //Select output from ALU
                end
            3'b010: // Load word
                begin
                ALUsel <= 5'b10000; // Select take byte sign extended from ALU
                Osel <= 01; //Select register A as output
                end
            3'b100: // Load byte unsigned
                begin
                ALUsel <= 5'b10010; // Select take byte unsigned from ALU
                Osel <= 00; // Select output from ALU
                end
            3'b101: // Load half word unsigned
                begin
                ALUsel <= 5'b10011; // Select take byte unsigned from ALU
                Osel <= 00; // Select output from ALU
                end
            endcase
            rdOut <= rd; 
            rdWrite <= 1; //Send signal to write output value into rd register
            mem_read <= 0; //Reset the memory read signal
            PCout <= PCin + 1;
        end
    end
    endcase
end

endmodule


