// Test bench for the register module

`include "reg.v"
module RegisterTestbench;

reg         clock = 0;
reg         r_enable = 1;
reg  [31:0] value_in;
wire [31:0] value_out;

always #1 clock = !clock;

initial $dumpfile("registertestbench.vcd");
initial $dumpvars(0, RegisterTestbench);

Register r(clock, r_enable, value_in, value_out);

initial begin
    //These events must be in chronological order.
    # 5 value_in = 31;
    # 5 value_in = 127;
    # 5 enable = 0;
    # 5 value_in = 1023;
    # 5 $finish;
end
endmodule