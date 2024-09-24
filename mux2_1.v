// MUX 2:1 para seleccion de entradas

module mux2_1(in_1, in_2, sel, data_out);

input      [31:0] in_1;
input      [31:0] in_2;
input             sel;
output     [31:0] data_out;

assign data_out = sel ? in_2 : in_1; 

endmodule