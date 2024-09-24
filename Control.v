// Control module

module Controller (ALUsel, Asel, Bsel, Osel, ctr_o, iDecoOP, iDecoFUN, ALU0, ctr_i);

input  [2:0] iDecoOP;
input  [3:0] iDecoFUN;
input        ALU0;
input        ctr_i;
output [3:0] ALUsel;
output       Asel;
output       Bsel;
output [1:0] Osel;
output       ctr_o;

reg [3:0] ALUselection;
reg       Aselection;
reg       Bselection;
reg [1:0] Oselection;
assign ALUsel = ALUSelection;
assign Asel = Aselection;
assign Bsel = Bselection;
assign Osel = Oselection;

begin
    case(iDecoOP)
    3'b000: // Op code 000 is ALU operation
        case(iDecoFUN)
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
    3'b100: // OP code 100 is used for I prefix
    3'b101: // OP code 101 is used for fragment start and end markers




