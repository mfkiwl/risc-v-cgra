// Control module

module controller (mem_address, mem_read, mem_write, Aenable, Benable, Aval, Bval, Rval, messReg, ALUsel, Asel, Bsel, Osel, tt3_o, tt4_o. ta3_o, ta4_o, prefix_o, immhi_o, nalloc_o, icounter_o, endAck, icounter_i, opA, opB, pRes, op, prefix, funct, nalloc, endF, immab, immlo, immhi, offset, ta1, ta2, ta3, ta4, tt1, tt2, tt3, tt4, ALU0, messages, prefix_i, immhi_i, tt3_i, tt4_i, ta3_i, ta4_i, clk, mem_Message, mem_ack);

// Input clock
input        clk;

// Input from ALU result and instruction decoder
input        ALU0;
input [2:0]  op;
input [1:0]  prefix;
input [3:0]  funct;
input [6:0]  nalloc;
input        endF;
input        immab;
input [5:0]  immlo;
input [25:0] immhi;
input [9:0]  offset;
input [5:0]  ta1;
input [5:0]  ta2;
input [5:0]  ta3;
input [5:0]  ta4;
input [1:0]  tt1;
input [1:0]  tt2;
input [1:0]  tt3;
input [1:0]  tt4;

//input        ctr_i;

// Control signal inputs from bus
input  [1:0] prefix_i;
input  [25:0] immhi_i;
input  [1:0]  tt3_i; 
input  [1:0]  tt4_i;
input  [5:0]  ta3_i;
input  [5:0]  ta4_i;
input         branch_i; // ToDo determine what happens when there is a branch

// Results from previous operations to be used in opA and opB
input  [31:0] result_1;
input  [31:0] result_2;
input  [1:0]  tt1_ctrl; //Defines if writing to opA or writing to opB
input  [1:0]  tt2_ctrl;

// Check if need to remove
input [31:0] opA;
input [31:0] opB;
input [31:0] pRes; // previous result

// Defines the address (ta) for the current instruction
input [6:0]  icounter_i; // Counter for instructions in the fragment instance

// Signals for memory access operations
input        mem_ack;
input [31:0] mem_Message; //input received when load functions are called
input [7:0][31:0] messages; //Array of 32 bit messages to receive from the 8 message registers. Should be modified to read from memory.

// Selection signal outputs for the 3 MUX and the ALU
output reg [3:0] ALUsel;
output reg      Asel;
output reg      Bsel;
output reg [1:0] Osel;

//output       ctr_o; //Output control signal

// Output signals when instruction is a prefix or to send the ta to perform the tt operation
output reg [1:0] prefix_o; // 00 no prefix 10 prefix I and 01 prefix T
output reg [25:0] immhi_o;
output reg [1:0]  tt1_o;
output reg [1:0]  tt2_o;
output reg [5:0]  ta1_o;
output reg [5:0]  ta2_o;
output reg [1:0]  tt3_o;
output reg [1:0]  tt4_o;
output reg [5:0]  ta3_o;
output reg [5:0]  ta4_o;
output reg        branch; // signal that defines that a branch is performed to instruction with ta1


output reg [31:0] messReg; // Result being sent to the bus
output reg [31:0] Aval;
output reg [31:0] Bval;
output reg [31:0] Rval;

// Fragment start/end output signals
output reg [6:0] nalloc_o;
output reg       endAck;

// Register enable signals
output reg       Aenable;
output reg       Benable;
output reg       Renable;

// Output signals for read/write to memory
output reg       mem_read;
output reg       mem_write;
output reg       mem_address;

output reg       invoke_on;

// Internal signals
wire [31:0] immvalue = 0;
wire [1:0] tt3_int;
wire [5:0] ta3_int;
wire [1:0] tt4_int;
wire [5:0] ta4_int;
wire [2:0] MessInd; // Message index to reference one of the 8 message registers
wire [31:0] tempVal = 0;
wire [28:0] temp_address; // Address for new FIA for invoke;
wire [2:0]  temp_RMI;     // Return message index for new FIA for invoke;

always @(*) begin

    case(op)
    3'b000: // Op code 000 is ALU operation
        Asel = 0; // For ALU, performs operation over operand A and operand B (not offset and R)
        Bsel = 1;

        case(prefix_i)
            2'b00: //Did not come with a prefix
                immvalue = {26'b0,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aval = immvalue;
                        Bval = 0;
                    b'b1: //Assign immidiate value to regB
                        Aval = 0;
                        Bval = immvalue;
                endcase

            2'b10: //Comes with prefix I 
                immvalue = {immhi,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aval = immvalue;
                        Bval = 0;
                    b'b1: //Assign immidiate value to regB
                        Aval = 0;
                        Bval = immvalue;
                endcase

            2'b01: // Comes with T prefix
            // The result of this instruction will be sent to ta3 and ta4 as well with tt3 and tt4 (write opA or write opB)
                ta3_o = ta3_i;
                ta4_o = ta4_i;
                tt3_o = tt3_i;
                tt4_o = tt4_i;
        endcase

        // Determine if previous results need to be written to opA or opB based on the target type being sent from previous operation
        case(tt1_ctrl)
            2'b10: // Write opA with result 1
                Aval = result_1;
            2:b11: // Write opB with result 1
                Bval = result_1;
        endcase

        case(tt2_ctrl)
            2'b10: // Write opA with result 2
                Aval = result_2;
            2:b11: // Write opB with result 2
                Bval = result_2;
        endcase

        // Now that input values to the ALU are defined, perform operation
        case(funct)
            4'b0000: // OR function
                ALUsel = 4'b1001;
            4'b0001: // AND function
                ALUsel =  4'b1000;
            4'b0010: // XOR function
                ALUsel = 4'b1010;
            4'b0011: // Addition
                ALUsel = 4'b0000;
            4'b0100: // Substraction
                ALUsel = 4'b0001;
            4'b0101: // set if less than function
                ALUsel = 4'b1111;
            4'b0110: // sltu function
                ALUsel = 4'b1101;
            4'b0111: // shift left sll
                ALUsel = 4'b0100;
            4'b1000: // shift right srl
                ALUsel = 4'b0101;
            4'b1001: // shift right arithmetic
                ALUsel = 4'b1111;
        endcase

        Osel = 2'b10; //Select ALU result as output

        // Check if branch on zero or branch unless zero is defined
        case(tt1)
            2'b00: // Branch on zero
                if (ALU0 == 0)
                    begin
                        ta1_o = ta1;
                        branch = 1;
                    end
                else
                    begin
                        branch = 0;
                    end    
                // else do nothing as the branch condition was not met 
            2'b01: // Branch unless zero
                if (ALU0 != 0)
                    begin
                        ta1_o = ta1;
                        branch = 1;
                    end
                else
                    begin
                        branch = 0;
                    end 
                // else do nothing as the branch condition was not met 
            2'b10: // Signal to write opA on ta1
                ta1_o = ta1;
                tt1_o = tt1;
            2'b11: // Signal to wtite opB on ta1
                ta1_o = ta1;
                tt1_o = tt1;
        endcase

        case(tt2): // Check if not 0 to send the signals to the bus
            2'b00: //Invalid
            2'b01:
                ta2_o = 0;
                tt2_o = 0;
            2'b10: // Defined to write opA or write opB on ta
            2'b01: 
                ta2_o = ta2;
                tt2_o = tt2;
        endcase


        case(tt3_i): // Check if not 0 to send the signals to the bus
            2'b00: //Invalid
            2'b01:
                ta3_o = 0;
                tt3_o = 0;
            2'b10: // Defined to write opA or write opB on ta
            2'b01: 
                ta3_o = ta3_i;
                tt3_o = tt3_i;
            default: // if signal was not defined since there was no prefix
                ta3_o = 0;
                tt3_o = 0;
        endcase

        case(tt4_i): // Check if not 0 to send the signals to the bus
            2'b00: //Invalid
            2'b01:
                ta4_o = 0;
                tt4_o = 0;
            2'b10: // Defined to write opA or write opB on ta
            2'b01: 
                ta4_o = ta4_i;
                tt4_o = tt4_i;
            default: 
                ta4_o = 0;
                tt4_o = 0;
        endcase
    endcase

    3'b001: // OP code 001 includes receive, invoke and memory operations
        Asel = 0; // In all cases, we will work with opA and opB instead of R or offset
        Bsel = 1;
        invoke_on = 0;

        case(prefix_i)
            2'b00: //Did not come with a prefix
                immvalue = {26'b0,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aval = immvalue;
                        Bval = 0;
                    b'b1: //Assign immidiate value to regB
                        Aval = 0;
                        Bval = immvalue;
                endcase

            2'b10: //Comes with prefix I 
                immvalue = {immhi,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aval = immvalue;
                        Bval = 0;
                    b'b1: //Assign immidiate value to regB
                        Aval = 0;
                        Bval = immvalue;
                endcase

            2'b01: // Comes with T prefix
            // The result of this instruction will be sent to ta3 and ta4 as well with tt3 and tt4 (write opA or write opB)
                ta3_o = ta3_i;
                ta4_o = ta4_i;
                tt3_o = tt3_i;
                tt4_o = tt4_i;
        endcase

         // Determine if previous results need to be written to opA or opB based on the target type being sent from previous operation
        case(tt1_ctrl)
            2'b10: // Write opA with result 1
                Aval = result_1;
            2:b11: // Write opB with result 1
                Bval = result_1;
        endcase

        case(tt2_ctrl)
            2'b10: // Write opA with result 2
                Aval = result_2;
            2:b11: // Write opB with result 2
                Bval = result_2;
        endcase

        tempVal = Aval + Bval;

        case(funct)
        4'b0000: // recv
            MessInd = tempVal[2:0];
            messReg = messages[MessInd];

        4'b0001: // lb load byte function.  Loads a single byte into a 32 bit register, all upper bits are 1
            mem_read = 1;
            mem_address = tempVal;
            always @ (posedge mem_ack)
            begin
                if (mem_Message[31] == 1)
                begin 
                    messReg = {24'b1, mem_Message[7:0]} ;
                end
                else
                begin 
                    messReg = {24'b0, mem_Message[7:0]} ;
                end
                mem_read = 0;
            end

        4'b0010: // lh. Loads a half word (16 bits) into a 32 bit register, all upper bits are 1
            mem_read = 1;
            mem_address = tempVal;
            always @ (posedge mem_ack)
            begin
                if (mem_Message[31] == 1)
                begin
                    messReg = {16'b1, mem_Message[15:0]} ;
                end
                else
                begin
                    messReg = {16'b0, mem_Message[15:0]} ;
                end
                mem_read = 0;
            end
        4'b0011: // lw Loads a word (32 bits)
            mem_read = 1;
            mem_address = tempVal;
            always @ (posedge mem_ack)
            begin
                messReg = mem_Message[31:0] ;
                mem_read = 0;
            end
            
        4'b0100: // lbu Loads an unsigned byte into a 32 bit register, all upper bits are 0
            mem_read = 1;
            mem_address = tempVal;
            always @ (posedge mem_ack)
            begin
                messReg = {24'b0, mem_Message[7:0]} ;
                mem_read = 0;
            end
        4'b0101: // lhu Loads an unsigned half word (16 bits) into a 32 bit register, all upper bits are 0
            mem_read = 1;
            mem_address = tempVal;
            always @ (posedge mem_ack)
            begin
                messReg = {16'b0, mem_Message[15:0]} ;
                mem_read = 0;
            end
        4'b0110: // invoke
            temp_address = tempVal[31:3];
            temp_RMI = tempVal[2:0];
            messReg = {temp_address, temp_RMI} ;
            invoke_on = 1;
    endcase

    3'b010: // OP code 010 includes send, terminate, sb, sh, sw
        case(iDecoFUN)
        4'b0000: // send
            //ALUSelection = 4'b1001;
        4'b0001: // sb Sends a byte (8 bits)
            //ALUSelection =  4'b1000;
        4'b0010: // sh Sends a halfword (16 bits)
            //ALUSelection = 4'b1010;
        4'b0011: // sw Sends a word (32 bits)
            //ALUSelection = 4'b0000;
        4'b0100: // terminate
            //ALUSelection = 4'b0001;
        endcase

    3'b011: // OP code 011 is used for T prefix
        prefix_o = 2'b10;
        ta3_o = ta3;
        tt3_o = tt3;
        ta4_o = ta4;
        tt4_o = tt4;
    3'b100: // OP code 100 is used for I prefix
        prefix = 2'b01;
        immhi_o = immhi;
    3'b101: // OP code 101 is used for fragment start and end markers
        case (endF)
            0: //Start fragment
                nalloc_o = nalloc;
            1: //End fragment 
                endAck = 1;
        endcase
    endcase
end

endmodule


