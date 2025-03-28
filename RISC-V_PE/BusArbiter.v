module bus_arbiter (
    input clk,
    input reset,
    input [3:0] req,       // Request signals from the PEs. 
    output reg [3:0] grant // Grant signals for the PEs
);
    reg [1:0] current;     // Keeps track of which PE has the current priority. Scale for more PEs

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant <= 4'b0000;
            current <= 2'b00;
        end else begin
            case (current)
                2'b00: grant <= req[0] ? 4'b0001 : (req[1] ? 4'b0010 : (req[2] ? 4'b0100 : (req[3] ? 4'b1000 : 4'b0000)));
                2'b01: grant <= req[1] ? 4'b0010 : (req[2] ? 4'b0100 : (req[3] ? 4'b1000 : (req[0] ? 4'b0001 : 4'b0000)));
                2'b10: grant <= req[2] ? 4'b0100 : (req[3] ? 4'b1000 : (req[0] ? 4'b0001 : (req[1] ? 4'b0010 : 4'b0000)));
                2'b11: grant <= req[3] ? 4'b1000 : (req[0] ? 4'b0001 : (req[1] ? 4'b0010 : (req[2] ? 4'b0100 : 4'b0000)));
            endcase

            if (req[current]) begin
                current <= current + 1;
            end
        end
    end
endmodule
