// MUX 3:1 para seleccion de entradas

module mux3_1(in_1, in_2, in_3, sel, data_out);

input      [31:0] in_1;
input      [31:0] in_2;
input      [31:0] in_3;
input      [1:0]  sel;
output     [31:0] data_out;

if(sel[1]==1)
{
    assign data_out = in_3;
}
else {
    assign data_out = sel[0] ? in_2 : in_1; 
}


endmodule