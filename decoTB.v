// Test bench for instruction decoder

`include "decoder.v"

module decoderTestbench;

reg [31:0]  instruction;
wire [2:0]  op;
wire [2:0]  prefix;
wire [3:0]  funct;
wire [6:0]  nalloc;
wire        endF;
wire        immab;
wire [5:0]  immlo;
wire [25:0] immhi;
wire [9:0]  offset;
wire [5:0]  ta1;
wire [5:0]  ta2;
wire [5:0]  ta3;
wire [5:0]  ta4;
wire [1:0]  tt1;
wire [1:0]  tt2;
wire [1:0]  tt3;
wire [1:0]  tt4;

initial $dumpfile("decodertestbench.vcd");
initial $dumpvars(0, decoderTestbench);

decoder deco(op, prefix, nalloc, endF, funct, immab, immlo, immhi, ta1, ta2, ta3, ta4, tt1, tt2, tt3, tt4, offset, instruction);

initial begin
    //These events must be in chronological order.
    # 5 instruction = 32'b000_0001_0_010101_00_10_101010_11_111100;
    # 5 instruction = 32'b001_0101_1_110011_00_10_0101_11_000111;
    # 5 instruction = 32'b010_0011_0_010101_00000000_1011001110;
    # 5 instruction = 32'b011_0000000000000_10_101010_11_111100;
    # 5 instruction = 32'b100_000_10101010101010101010101010;
    # 5 instruction = 32'b101_0_000000000000000000000_1110011;

end
endmodule