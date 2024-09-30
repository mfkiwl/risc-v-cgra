//Mux 3_1 Test bench for output

`include "mux3_1.v"
module mux3_1Testbench;

reg      [31:0] in_1;
reg      [31:0] in_2;
reg      [31:0] in_3;
reg      [1:0]  sel;
wire     [31:0] data_out;

initial $dumpfile("mux3_1testbench.vcd");
initial $dumpvars(0, mux3_1Testbench);

mux2_1 m2_1(in_1, in_2, in_3, sel, data_out);

initial begin
    //These events must be in chronological order.
    # 5 in_1 = 84;
    # 5 in_2 = 132;
    # 5 in_3 = 28;
    # 5 sel = 0;
    # 5 in_1 = 158;
    # 5 in_2 = 12;
    # 5 in_3 = 147;
    # 5 sel = 1;
    # 5 in_1 = 39;
    # 5 in_2 = 471;
    # 5 in_3 = 36;
    # 5 sel = 2;
    # 5 $finish;
end
endmodule