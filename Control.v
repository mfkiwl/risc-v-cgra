// Control module

module controller (ALUsel, Asel, Bsel, Osel, Avalue, Bvalue, ctr_o, prefix_o, immhi_o, instruction, ALU0, prefix_i, immhi_i, ctr_i);

input  [31:0] instruction;
input        ALU0;
input        ctr_i;
input  [1:0] prefix_i;
input  [25:0] immhi_i;
output [3:0] ALUsel;
output       Asel;
output       Bsel;
output [1:0] Osel;
output       ctr_o;
output [1:0] prefix_o;
output [25:0] immhi_o;
output reg [31:0] Avalue;
output reg [31:0] Bvalue;

reg [2:0] op = instruction [31:29];

reg [3:0] ALUselection;
reg       Aselection;
reg       Bselection;
reg [1:0] Oselection;
assign ALUsel = ALUSelection;
assign Asel = Aselection;
assign Bsel = Bselection;
assign Osel = Oselection;

reg [3:0] fun;
reg       endMark;
reg [6:0] nalloc;
reg       immab;
reg [5:0] immlo;
reg [1:0] tt1;
reg [1:0] tt2;
reg [1:0] tt3;
reg [1:0] tt4;
reg [5:0] ta1;
reg [5:0] ta2;
reg [5:0] ta3;
reg [5:0] ta4;
reg [9:0] offset;
reg [25:0] immhi;

assign immhi_o = immhi;

reg [1:0] prefix; // Indicates that a prefix was selected and which one 
// 00 no prefix
// 01 prefix I 
// 10 prefix T
prefix = 2'b00;

reg [31:0] immvalue;

assing prefix_o = prefix;

begin
    case(op)
    3'b000: // Op code 000 is ALU operation
        fun = instruction [28:25];
        immab = instruction [24];
        immlo = instruction [23:18];
        tt2 = instruction [15:14];
        ta2 = instruction [13:8];
        tt1 = instruction [7:6];
        ta1 = instruction [5:0];
        begin
            case(prefix)
            2'b00: //Did not come with a prefix
                immvalue = [0, immlo];
                begin 
                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aselection = 0;
                        Bselection = 1;
                        assign Avalue = immvalue;
                        assign Bvalue = 0;
                    b'b1: //Assign immidiate value to regB
                        Aselection = 0;
                        Bselection = 1;
                        assign Avalue = 0;
                        assign Bvalue = immvalue;
                endcase
            2'b01: //Comes with prefix I 
                immvalue = [immhi,immlo];
                begin
                case(immab)
                    1'b0: //Assign immidiate value to regA
                        Aselection = 0;
                        Bselection = 1;
                        assign Avalue = immvalue;
                        assign Bvalue = 0;
                    b'b1: //Assign immidiate value to regB
                        Aselection = 0;
                        Bselection = 1;
                        assign Avalue = 0;
                        assign Bvalue = immvalue;
                endcase
            2'b10: // Comes with T prefix

            endcase

                
        case(fun)
        4'b0000: // OR function
            ALUSelection = 4'b1001;
        4'b0001: // AND function
            ALUSelection =  4'b1000;
        4'b0010: // XOR function
            ALUSelection = 4'b1010;
        4'b0011: // Addition
            ALUSelection = 4'b0000;
        4'b0100: // Substraction
            ALUSelection = 4'b0001;
        4'b0101: // set if less than function
            ALUSelection = 4'b1111;
        4'b0110: // sltu function
            ALUSelection = 4'b1101;
        4'b0111: // shift left sll
            ALUselection = 4'b0100;
        4'b1000: // shift right srl
            ALUSelection = 4'b0101;
        4'b1001: // shift right arithmetic
            ALUselection = 4'b1111;
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
        prefix = 2'b10;
        ta3 = instruction[5:0];
        tt3 = instruction[7:6];
        ta4 = instruction[13:8];
        tt4 = instruction[15:14];
    3'b100: // OP code 100 is used for I prefix
        prefix = 2'b01;
        immhi = instruction [25:0];
    3'b101: // OP code 101 is used for fragment start and end markers

endcase


