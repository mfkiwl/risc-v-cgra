// Control module

module controller (Aval, Bval, Rval, messReg, ALUsel, Asel, Bsel, Osel, tt3_o, tt4_o. ta3_o, ta4_o, ctr_o, prefix_o, immhi_o, nalloc_o, icounter_o, endAck, icounter_i, opA, opB, pRes, op, prefix, funct, nalloc, endF, immab, immlo, immhi, offset, ta1, ta2, ta3, ta4, tt1, tt2, tt3, tt4, ALU0, prefix_i, immhi_i, tt3_i, tt4_i, ta3_i, ta4_i, ctr_i);

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
input  [1:0] prefix_i;
input  [25:0] immhi_i;
input  [1:0]  tt3_i;
input  [1:0]  tt4_i;
input  [5:0]  ta3_i;
input  [5:0]  ta4_i;
input [31:0] opA;
input [31:0] opB;
input [31:0] pRes;
input [6:0] icounter_i;

output reg [3:0] ALUsel;
output reg      Asel;
output reg     Bsel;
output reg [1:0] Osel;
//output       ctr_o;
output reg [1:0] prefix_o;
output reg [25:0] immhi_o;
output reg [1:0]  tt3_o;
output reg [1:0]  tt4_o;
output reg [5:0]  ta3_o;
output reg [5:0]  ta4_o;
output reg [31:0] messReg;
output reg [31:0] Aval;
output reg [31:0] Bval;
output reg [31:0] Rval;
output reg [6:0] nalloc_o;
output reg [6:0] icounter_o;
output reg       endAck;

reg [31:0] immvalue = 0;
reg [1:0] tt3_int;
reg [5:0] ta3_int;
reg [1:0] tt4_int;
reg [5:0] ta4_int;

always @(*) begin

// 00 no prefix
// 10 prefix I 
// 01 prefix T

    case(op)
    3'b000: // Op code 000 is ALU operation
        Asel = 0; // For ALU, performs operation over operand A and operand B (not offset and R)
        Bsel = 1;
        case(prefix_i)
            2'b00: //Did not come with a prefix
                immvalue = {26'b0,immlo};
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
                begin
                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aval = immvalue;
                        Bval = 0;
                    b'b1: //Assign immidiate value to regB
                        Aval = 0;
                        Bval = immvalue;
                endcase
            2'b01: // Comes with T prefix
                ta3_int = ta3_i;
                ta4_int = ta4_i;
                tt3_int = tt3_i;
                tt4_int = tt4_i;
        endcase

        case(tt1, tt2, tt3_i, tt4_i)
            2'b00: //branch on zero
                if (ALU0 && tt1== 2'b00)
                begin
                    //branch 
                end
                else if(ALU0 && (tt2 == 2'b00 || tt3_i == 2'b00 || tt4_i == 2'b00))
                    // no operation
                end
            2'b01: //branch unless zero
                if (!ALU0 && tt1 == 2'b01)
                begin
                    //branch 
                end
                else if(!ALU0 && (tt2 == 2'b01 || tt3_i == 2'b01 || tt4_i == 2'b01))
                    // no operation
                end
            2'b10: // write opA
                Aval = opA;
            2'b11: // write opB
                Bval = opB;
        endcase

                
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
    endcase

    3'b001: // OP code 001 includes receive, invoke and memory operations
        case(iDecoFUN)
        4'b0000: // recv
            //ALUSelection = 4'b1001;
        4'b0001: // lb
            //ALUSelection =  4'b1000;
        4'b0010: // lh
            //ALUSelection = 4'b1010;
        4'b0011: // lw
            //ALUSelection = 4'b0000;
        4'b0100: // lbu
            //ALUSelection = 4'b0001;
        4'b0101: // lhu
            //ALUSelection = 4'b1111;
        4'b0110: // invoke
            //ALUSelection = ;
        endcase
    3'b010: // OP code 010 includes send, terminate, sb, sh, sw
        case(iDecoFUN)
        4'b0000: // send
            //ALUSelection = 4'b1001;
        4'b0001: // sb
            //ALUSelection =  4'b1000;
        4'b0010: // sh
            //ALUSelection = 4'b1010;
        4'b0011: // sw
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
                icounter_o = nalloc;
            1: //End fragment 
                icounter_o = 0;
                endAck = 1;
        endcase

    endcase
end

endmodule


