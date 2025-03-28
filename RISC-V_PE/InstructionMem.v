module instruction_memory (
    input clk,
    input [3:0] read_enable,          // Read enable signals for 4 PEs
    input [127:0] PC,            // Flattened 4 × 32-bit Program counter
    output reg [127:0] instruction    // Flattened 4 × 32-bit instruction bus
);
    // Memory array to store instructions
    reg [31:0] memory_array [0:255]; // 256 instructions, 32 bits wide

    // Initialize the instruction memory (optional for simulation)
    initial begin
        $readmemh("instructions.hex", memory_array); // Load instructions from a file
    end

    // Fetch instructions for each PE
    always @(posedge clk) begin
        if (read_enable[0])
            instruction[31:0] <= memory_array[PC[31:0]]; // PE 0
        else
            instruction[31:0] <= 32'b0;

        if (read_enable[1])
            instruction[63:32] <= memory_array[PC[63:32]]; // PE 1
        else
            instruction[63:32] <= 32'b0;

        if (read_enable[2])
            instruction[95:64] <= memory_array[PC[95:64]]; // PE 2
        else
            instruction[95:64] <= 32'b0;

        if (read_enable[3])
            instruction[127:96] <= memory_array[PC[127:96]]; // PE 3
        else
            instruction[127:96] <= 32'b0;
    end
endmodule
