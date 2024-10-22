// Control module

module controller (

// Input clock
input        clk,

// Input from ALU result and instruction decoder
input        ALU0,
input [2:0]  op,
input [1:0]  prefix,
input [3:0]  funct,
input [5:0]  nalloc,
input        endF,
input        immab,
input [5:0]  immlo,
input [25:0] immhi,
input [9:0]  offset,
input [5:0]  ta1,
input [5:0]  ta2,
input [5:0]  ta3,
input [5:0]  ta4,
input [1:0]  tt1,
input [1:0]  tt2,
input [1:0]  tt3,
input [1:0]  tt4,

// Control signal inputs from bus
input  [1:0] prefix_i,
input  [25:0] immhi_i,
input  [1:0]  tt3_i, 
input  [1:0]  tt4_i,
input  [5:0]  ta3_i,
input  [5:0]  ta4_i,

// Results from previous operations to be used in opA and opB
input  [31:0] result_1,
input  [31:0] result_2,
input  [1:0]  tt1_ctrl, //Defines if writing to opA or writing to opB
input  [1:0]  tt2_ctrl,

// Defines the address (ta) for the current instruction
input [5:0]  icounter_i, // Counter for instructions in the fragment instance. Current PE index

// Signals for memory access operations
input        mem_ack,
input [31:0] mem_Message, //input received when load functions are called
input [7:0][31:0] messages, //Array of 32 bit messages to receive from the 8 message registers. Should be modified to read from memory.

// Selection signal outputs for the 3 MUX and the ALU
output reg [3:0] ALUsel,
output reg      Asel,
output reg      Bsel,
output reg [1:0] Osel,

// Output signals when instruction is a prefix or to send the ta to perform the tt operation
output reg [1:0] prefix_o, // 00 no prefix 10 prefix I and 01 prefix T
output reg [25:0] immhi_o,
output reg [1:0]  tt1_o,
output reg [1:0]  tt2_o,
output reg [5:0]  ta1_o,
output reg [5:0]  ta2_o,
output reg [1:0]  tt3_o,
output reg [1:0]  tt4_o,
output reg [5:0]  ta3_o,
output reg [5:0]  ta4_o,
output reg        branch, // signal that defines that a branch is performed to instruction with ta1
output reg        oTerm, // signal to terminate current FI


output reg [31:0] messReg, // Result being sent to the bus
output reg [31:0] Aval,
output reg [31:0] Bval,

// Fragment start/end output signals
output reg [5:0] nalloc_o,
output reg       endAck,

// Register enable signals
output reg       Aenable,
output reg       Benable,
output reg       Renable,

// Output signals for read/write to memory
output reg        mem_read,
output reg [31:0] mem_address,

//Output signals for send operations
output reg [2:0] outMessInd,
output reg [25:0] out_sendFIA,

output reg       invoke_on,
output reg  [5:0] icounter_o
);

// Internal signals
reg [31:0] immvalue = 0;
reg [2:0] MessInd = 0; // Message index to reference one of the 8 message registers
reg [31:0] tempVal = 0;
reg [28:0] temp_address = 0; // Address for new FIA for invoke;
reg [2:0]  temp_RMI = 0;     // Return message index for new FIA for invoke;
reg [25:0] temp_sendFIA = 0; // FIA for send operation
reg [31:0] tempValA = 0;
reg [31:0] tempValB = 0;

always @(*) 
begin
    oTerm <= 0; //Default to no termination
    branch <= 0; //Default to no branching

    case(op)
    3'b000: // Op code 000 is ALU operation
    begin
        Asel <= 1'b0; // For ALU, performs operation over operand A and operand B (not offset and R)
        Bsel <= 1'b1;
        icounter_o <= icounter_i + 1; 

        case(prefix_i)
            2'b00: //Did not come with a prefix
            begin
                immvalue <= {26'b0,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                Aval = (immab == 1'b1) ? 32'b0 : immvalue;
                Bval = (immab == 1'b1) ? immvalue : 32'b0;
            end

            2'b10: //Comes with prefix I 
            begin
                immvalue = {immhi,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                Aval = (immab == 1'b1) ? 32'b0 : immvalue;
                Bval = (immab == 1'b1) ? immvalue : 32'b0;
            end

            2'b01: // Comes with T prefix
            begin
            // The result of this instruction will be sent to ta3 and ta4 as well with tt3 and tt4 (write opA or write opB)
                ta3_o = ta3_i;
                ta4_o = ta4_i;
                tt3_o = tt3_i;
                tt4_o = tt4_i;
            end

            default:
            begin
                Aval = 32'bx; 
                Bval = 32'bx;
            end 
        endcase

        tempValA = Aval;
        tempValB = Bval;

        Aval = (tt1_ctrl == 2'b10) ? result_1 : ((tt2_ctrl == 2'b10) ? result_2 : tempValA);
        Bval = (tt1_ctrl == 2'b11) ? result_1 : ((tt2_ctrl == 2'b11) ? result_2 : tempValB);

        // Determine if previous results need to be written to opA or opB based on the target type being sent from previous operation
        //case(tt1_ctrl)
        //    2'b10: // Write opA with result 1
        //        Aval = result_1;
        //    2'b11: // Write opB with result 1
        //        Bval = result_1;
        //endcase

        //case(tt2_ctrl)
        //    2'b10: // Write opA with result 2
        //        Aval = result_2;
        //    2'b11: // Write opB with result 2
        //        Bval = result_2;
        //endcase

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
            begin
                if (ALU0 == 0)
                    begin
                        ta1_o = ta1;
                        branch = 1;
                        icounter_o = ta1; //Check
                    end
                else
                    begin
                        branch = 0;
                    end    
                // else do nothing as the branch condition was not met 
            end
            2'b01: // Branch unless zero
            begin
                if (ALU0 != 0)
                    begin
                        ta1_o = ta1;
                        branch = 1;
                        icounter_o = ta1;
                    end
                else
                    begin
                        branch = 0;
                    end 
                // else do nothing as the branch condition was not met 
            end
            2'b10: // Signal to write opA on ta1
            begin
                ta1_o = ta1;
                tt1_o = tt1;
            end
            2'b11: // Signal to wtite opB on ta1
            begin
                ta1_o = ta1;
                tt1_o = tt1;
            end
        endcase

        case(tt2) // Check if not 0 to send the signals to the bus
            2'b00: //Invalid
            begin
                ta2_o = 0;
                tt2_o = 0;
            end
            2'b01:
            begin
                ta2_o = 0;
                tt2_o = 0;
            end
            2'b10: // Defined to write opA or write opB on ta
            begin
                ta2_o = ta2;
                tt2_o = tt2;
            end
            2'b01: 
            begin
                ta2_o = ta2;
                tt2_o = tt2;
            end
        endcase


        case(tt3_i) // Check if not 0 to send the signals to the bus
            2'b00: //Invalid
            begin
                ta3_o = 0;
                tt3_o = 0;
            end
            2'b01:
            begin
                ta3_o = 0;
                tt3_o = 0;
            end
            2'b10: // Defined to write opA or write opB on ta
            begin
                ta3_o = ta3_i;
                tt3_o = tt3_i;
            end
            2'b01: 
            begin
                ta3_o = ta3_i;
                tt3_o = tt3_i;
            end
            default: // if signal was not defined since there was no prefix
            begin
                ta3_o = 0;
                tt3_o = 0;
            end
        endcase

        case(tt4_i) // Check if not 0 to send the signals to the bus
            2'b00: //Invalid
            begin
                ta4_o = 0;
                tt4_o = 0;
            end
            2'b01:
            begin
                ta4_o = 0;
                tt4_o = 0;
            end
            2'b10: // Defined to write opA or write opB on ta
            begin
                ta4_o = ta4_i;
                tt4_o = tt4_i;
            end
            2'b01: 
            begin
                ta4_o = ta4_i;
                tt4_o = tt4_i;
            end
            default: 
            begin
                ta4_o = 0;
                tt4_o = 0;
            end            
        endcase
    end

    3'b001: // OP code 001 includes receive, invoke and memory operations
    begin
        Asel = 1; // Will use the opR register for memory instructions
        Bsel = 1;
        invoke_on = 0;
        icounter_o = icounter_i + 1; 

        case(prefix_i)
            2'b00: //Did not come with a prefix
            begin
                immvalue = {26'b0,immlo};
                Renable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                Aval = (immab == 1'b1) ? 32'b0 : immvalue;
                Bval = (immab == 1'b1) ? immvalue : 32'b0;
            end

            2'b10: //Comes with prefix I 
            begin
                immvalue = {immhi,immlo};
                Renable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                Aval = (immab == 1'b1) ? 32'b0 : immvalue;
                Bval = (immab == 1'b1) ? immvalue : 32'b0;
            end

            2'b01: // Comes with T prefix
            begin
            // The result of this instruction will be sent to ta3 and ta4 as well with tt3 and tt4 (write opA or write opB)
                ta3_o = ta3_i;
                ta4_o = ta4_i;
                tt3_o = tt3_i;
                tt4_o = tt4_i;
            end
        endcase

        tempValA <= Aval;
        tempValB <= Bval;

         // Determine if previous results need to be written to opA or opB based on the target type being sent from previous operation
         Aval = (tt1_ctrl == 2'b10) ? result_1 : ((tt2_ctrl == 2'b10) ? result_2 : tempValA);
         Bval = (tt1_ctrl == 2'b11) ? result_1 : ((tt2_ctrl == 2'b11) ? result_2 : tempValB);
        
        //case(tt1_ctrl)
        //    2'b10: // Write opA with result 1
        //        Aval = result_1;
        //    2:b11: // Write opB with result 1
        //        Bval = result_1;
        //endcase

        //case(tt2_ctrl)
        //    2'b10: // Write opA with result 2
        //        Aval = result_2;
        //    2:b11: // Write opB with result 2
        //        Bval = result_2;
        //endcase

        tempVal = Aval + Bval;

        case(funct)
        4'b0000: // recv
        begin
            MessInd = tempVal[2:0];
            messReg = messages[MessInd];
        end

        4'b0001: // lb load byte function.  Loads a single byte into a 32 bit register, all upper bits are 1
        begin
            mem_read = 1;
            mem_address = tempVal;
            if(mem_ack)
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
        end

        4'b0010: // lh. Loads a half word (16 bits) into a 32 bit register, all upper bits are 1
        begin
            mem_read = 1;
            mem_address = tempVal;
            if(mem_ack)
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
        end
        4'b0011: // lw Loads a word (32 bits)
        begin
            mem_read = 1;
            mem_address = tempVal;
            if(mem_ack)
            begin
                messReg = mem_Message[31:0] ;
                mem_read = 0;
            end
        end
            
        4'b0100: // lbu Loads an unsigned byte into a 32 bit register, all upper bits are 0
        begin
            mem_read = 1;
            mem_address = tempVal;
            if(mem_ack)
            begin
                messReg = {24'b0, mem_Message[7:0]} ;
                mem_read = 0;
            end
        end
        4'b0101: // lhu Loads an unsigned half word (16 bits) into a 32 bit register, all upper bits are 0
        begin
            mem_read = 1;
            mem_address = tempVal;
            if(mem_ack)
            begin
                messReg = {16'b0, mem_Message[15:0]} ;
                mem_read = 0;
            end
        end
        4'b0110: // invoke
        begin
            temp_address = tempVal[31:3];
            temp_RMI = tempVal[2:0];
            messReg = {temp_address, temp_RMI} ;
            invoke_on = 1;
        end
        endcase
    end
    

    3'b010: // OP code 010 includes send, terminate, sb, sh, sw
    begin
        icounter_o = icounter_i + 1;
        Asel = 0; // Will use the opA register
        Bsel = 0; // Will use the offset value

        case(prefix_i)
            2'b00: //Did not come with a prefix
            begin
                immvalue = {26'b0,immlo};
                Aenable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                Aval = (immab == 1'b1) ? 32'b0 : immvalue;
                Bval = (immab == 1'b1) ? immvalue : 32'b0;
            end

            2'b10: //Comes with prefix I 
            begin
                immvalue = {immhi,immlo};
                Renable = 1;
                Benable = 1;
                // ta3 and ta4 are not defined
                ta3_o = 0;
                ta4_o = 0;

                Aval = (immab == 1'b1) ? 32'b0 : immvalue;
                Bval = (immab == 1'b1) ? immvalue : 32'b0;
            end

            2'b01: // Comes with T prefix
            begin
            // The result of this instruction will be sent to ta3 and ta4 as well with tt3 and tt4 (write opA or write opB)
                ta3_o = ta3_i;
                ta4_o = ta4_i;
                tt3_o = tt3_i;
                tt4_o = tt4_i;
            end
        endcase

        tempValA = Aval;
        tempValB = Bval;

        Aval = (tt1_ctrl == 2'b10) ? result_1 : ((tt2_ctrl == 2'b10) ? result_2 : tempValA);
        Bval = (tt1_ctrl == 2'b11) ? result_1 : ((tt2_ctrl == 2'b11) ? result_2 : tempValB);

         // Determine if previous results need to be written to opA or opB based on the target type being sent from previous operation
        //case(tt1_ctrl)
        //    2'b10: // Write opA with result 1
        //        Aval = result_1;
        //    2'b11: // Write opB with result 1
        //        Bval = result_1;
        //endcase

        //case(tt2_ctrl)
        //    2'b10: // Write opA with result 2
        //        Aval = result_2;
        //    2:b11: // Write opB with result 2
        //        Bval = result_2;
        //endcase

        tempVal = Aval + offset;

        case(funct)
        4'b0000: // send
        begin
            outMessInd = tempVal[2:0];
            out_sendFIA = tempVal[31:6];
            Osel = 2'b01; //Sends opB
        end

        4'b0001: // sb Sends a byte (8 bits)
        begin
            mem_address = tempVal;
            tempValB = Bval;
            Bval = {24'b0, tempValB[7:0]};
            Osel = 2'b01;
        end

        4'b0010: // sh Sends a halfword (16 bits)
        begin
            mem_address = tempVal;
            tempValB = Bval;
            Bval = {16'b0, tempValB[15:0]};
            Osel = 2'b01;
        end

        4'b0011: // sw Sends a word (32 bits)
        begin
            mem_address = tempVal;
            tempValB = Bval;
            Bval = tempValB;
            Osel = 2'b01;
        end

        4'b0100: // terminate
            oTerm = 1; //Signal to invalidate execution
        endcase
    end

    3'b011: // OP code 011 is used for T prefix
    begin
        icounter_o = icounter_i; 
        prefix_o = 2'b10;
        ta3_o = ta3;
        tt3_o = tt3;
        ta4_o = ta4;
        tt4_o = tt4;
    end
    3'b100: // OP code 100 is used for I prefix
    begin
        icounter_o = icounter_i + 1; 
        prefix_o = 2'b01;
        immhi_o = immhi;
    end
    3'b101: // OP code 101 is used for fragment start and end markers
    begin
        nalloc_o = endF ? 0 : nalloc;
        icounter_o = endF ? icounter_i : 0;
        endAck = endF ? 1:0;
    end
    endcase
end

endmodule


