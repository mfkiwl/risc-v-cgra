// Instruction decoder module

module decoder (op, prefix, nalloc, endF, funct, immab, immlo, immhi, ta1, ta2, ta3, ta4, tt1, tt2, tt3, tt4, offset, instruction);

input  [31:0] instruction;
output [2:0]  op;
output [2:0]  prefix;
output [3:0]  funct;
output [6:0]  nalloc;
output        endF;
output        immab;
output [5:0]  immlo;
output [25:0] immhi;
output [9:0]  offset;
output [5:0]  ta1;
output [5:0]  ta2;
output [5:0]  ta3;
output [5:0]  ta4;
output [1:0]  tt1;
output [1:0]  tt2;
output [1:0]  tt3;
output [1:0]  tt4;

reg [2:0] opCode = instruction [31:29];
assign op = opCode;
reg [1:0] hasprefix = 2'b00;

begin 
    case (opCode)
        3'b000 , 3'b001: //Case D instruction word
            begin
                reg [3:0] functCode = instruction[28:25];
                assign funct = functCode;
                reg immValab = instruction[24];
                assign immab = immValab;
                reg [5:0] immVallo = instruction [23:18];
                assign immlo = immVallo;
                reg [5:0] ta1Val = instruction [5:0];
                assign ta1 = ta1Val;
                reg [1:0] tt1Val = instruction [7:6];
                assign tt1 = tt1Val;
                reg [5:0] ta2Val = instruction [13:8];
                assign ta2 = ta2Val;
                reg [1:0] tt2Val = instruction [15:14];
                assign tt2 = tt2Val;
            end
        3'b101: //Case W instruction word
            begin
                reg [3:0] functCode = instruction[28:25];
                assign funct = functCode;
                reg immValab = instruction[24];
                assign immab = immValab;
                reg [5:0] immVallo = instruction [23:18];
                assign immlo = immVallo;
                reg [9:0] offsetVal = instruction [9:0];
                assign offset = offsetVal;
            end
        3'b011: // Case T prefix
            begin
                reg [5:0] ta3Val = instruction [5:0];
                assign ta3 = ta3Val;
                reg [1:0] tt3Val = instruction [7:6];
                assign tt3 = tt3Val;
                reg [5:0] ta4Val = instruction [13:8];
                assign ta4 = ta4Val;
                reg [1:0] tt4Val = instruction [15:14];
                assign tt4 = tt4Val;
                hasprefix = 2'b01; //Indicates that next instruction has a prefix and it is type T
                assign prefix = hasprefix;
            end
        3'b100: // Case I prefix
            begin
                reg [25:0] immhiVal = instruction [25:0];
                assign immhi = immhiVal;
                hasprefix = 2'b10; //Indicates that next instruction has a prefix and it is type I
                assign prefix = hasprefix;
            end
        3'b101: // Case fragment end/start
            begin
                reg endMark = instruction[28];
                assign endF = endMark;
                reg [6:0] nInstructions = instruction[6:0];
                assign nalloc = nInstructions;
            end
        default: 
    endcase






