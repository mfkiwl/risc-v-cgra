// Mux 2:1 Test bench

`include "mux2_1.v"
module mux2_1Testbench;

reg      [31:0] in_1;
reg      [31:0] in_2;
reg             sel;
wire     [31:0] data_out;


initial $dumpfile("mux2_1testbench.vcd");
initial $dumpvars(0, mux2_1Testbench);

mux2_1 m2_1(in_1, in_2, sel, data_out);

initial begin
    //These events must be in chronological order.
    # 5 in_1 = 31;
    # 5 in_2 = 127;
    # 5 sel = 0;
    # 5 in_1 = 61;
    # 5 in_2 = 187;
    # 5 sel = 1;
    # 5 $finish;
end
endmodule