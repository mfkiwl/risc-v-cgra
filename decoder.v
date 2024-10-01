// Instruction decoder module

module decoder (op, prefix, nalloc, endF, funct, immab, immlo, immhi, ta1, ta2, ta3, ta4, tt1, tt2, tt3, tt4, offset, instruction);

input  [31:0] instruction;
output reg [2:0]  op;
output reg [1:0]  prefix;
output reg [3:0]  funct;
output reg [6:0]  nalloc;
output reg        endF;
output reg        immab;
output reg [5:0]  immlo;
output reg [25:0] immhi;
output reg [9:0]  offset;
output reg [5:0]  ta1;
output reg [5:0]  ta2;
output reg [5:0]  ta3;
output reg [5:0]  ta4;
output reg [1:0]  tt1;
output reg [1:0]  tt2;
output reg [1:0]  tt3;
output reg [1:0]  tt4;

always @(*) begin
    // Extract opcode
    op = instruction [31:29];

    //Default values for outputs
    prefix = 2'b00;
    funct = 4'b0000;
    immab = 1'b0;
    immlo = 6'b000000;
    immhi = 26'b00000000000000000000000000;
    ta1 = 6'b000000;
    ta2 = 6'b000000;
    ta3 = 6'b000000;
    ta4 = 6'b000000;
    tt1 = 2'b00;
    tt2 = 2'b00;
    tt3 = 2'b00;
    tt4 = 2'b00;
    nalloc = 7'b0000000;
    endF = 1'b0;

    case (op)
        3'b000 , 3'b001: //Case D instruction word
            begin
                funct = instruction[28:25];
                immab = instruction[24];
                immlo = instruction [23:18];
                ta1 = instruction [5:0];
                tt1 = instruction [7:6];
                ta2 = instruction [13:8];
                tt2 = instruction [15:14];
            end

        3'b010: //Case W instruction word
            begin
                funct = instruction[28:25];
                immab = instruction[24];
                immlo = instruction [23:18];
                offset = instruction [9:0];
            end

        3'b011: // Case T prefix
            begin
                ta3 = instruction [5:0];
                tt3 = instruction [7:6];
                ta4 = instruction [13:8];
                tt4 = instruction [15:14];
                prefix = 2'b01;
            end

        3'b100: // Case I prefix
            begin
                immhi = instruction [25:0];
                prefix = 2'b10;
            end

        3'b101: // Case fragment end/start
            begin
                endF = instruction[28];
                nalloc = instruction[6:0];
            end
        default: 
            begin
                $display ("This code does not correspond to any valid operation");
            end
    endcase

    end

    endmodule






