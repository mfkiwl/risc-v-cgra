`include BusArbiter.v
`include BusInterface.v
`include ProcessingElement.v
`include DataRegs.v

module local_bus (
    input clk,
    input reset,
    input [31:0] address [3:0],   // Addresses from the 4 PEs. 
    //PE inputs
    //input [3:0] mem_read,         // Read signals from the 4 PEs to global mem
    //input [3:0] mem_write,        // Write signals from the 4 PEs to global mem
    input [3:0] rd_write,         // write signal to local mem
    input [3:0] read_en,          // read signal to local mem
    input [3:0] reg_select,       // reg select signals for local mem read
    input [31:0] PCout [3:0],     // Program counter for local program memory
    input [31:0] result_in [3:0], // Data to be written by the PEs (result_out signal)
    input [4:0] rs1Out [3:0],     // Select signal for mux coming from PE
    input [4:0] rs2Out [3:0],     // Select signal for mux coming from PE
    input [4:0] rdOut [3:0],      // Select signal for demux coming from PE
    //LocalMem inputs
    input [31:0] data_out1,
    input [31:0] data_out2,       // Data coming from local registers
    //Instruction mem inputs
    input [31:0] instructions [3:0], //Four instructions read from instruction memory to load into PEs
    output [31:0] Amux_in [3:0],  // Data read from local memory to the PEs to mux A
    output [31:0] Bmux_in [3:0],  // Data read from local memory to the PEs to mux B
    output [31:0] instruction [3:0], // Instruction sent to each PE
    output [31:0] PC_in [3:0],    // Program counter
    output [3:0] mem_ack,
    output [3:0] data_Ready
);

    wire [3:0] bus_req;           // Request signals from PEs
    wire [3:0] grant;             // Grant signals from arbiter
    wire [3:0] mem_read;          // Global read signal wired to cluster output
    wire [3:0] mem_write;         // Global write signal wired to cluster output

    // Arbiter for managing bus contention
    bus_arbiter arbiter (
        .clk(clk),
        .reset(reset),
        .req(bus_req),
        .grant(grant)
    );

    // Local Memory System
    register_system local_memory (
        .clk(clk),
        .reset(reset),
        .selRD(grant[0]?rdOut[0]:grant[1]?rdOut[1]:grant[2]?rdOut[2]:grant[3]:rdOut[3]:5'b0),        // Selects which reg to store into
        .selRS1(grant[0]?rs1Out[0]:grant[1]?rs1Out[1]:grant[2]?rs1Out[2]:grant[3]:rs1Out[3]:5'b0),   // Selects which reg to read from
        .selRS2(grant[0]?rs2Out[0]:grant[1]?rs2Out[1]:grant[2]?rs2Out[2]:grant[3]:rs2Out[3]:5'b0),   // Selects which reg to read from
        .data_in(result_in[grant]),   // Data to write
        .rdwrite(rdWrite[grant]),  // Write enable
        .read_en(read_en[grant]),   // Read enable
        .data_out1(Amux_in[grant]),   // Output data read from registers
        .data_out2(Bmux_in[grant])    // Optional second output read from registers
    );

    // Connect each PE to the bus interface
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : bus_interface
            bus_interface iface (
                .clk(clk),
                .reset(reset),
                .address(address[i]),
                .result_in(result_in[i]),
                .mem_read(mem_read[i]),
                .mem_write(mem_write[i]),
                .rdWrite(rd_write[i]),
                .read_en(read_en[i]),
                .reg_select(reg_select[i]),
                .PCout(PCout[i]),
                .mess_Reg(mess_Reg[i]),
                .grant(grant[i]),
                .Amux(Amux_in[i]),
                .Bmux(Bmux_in[i]),
                .instruction(instruction[i]),
                .PCin(PCin[i]),
                .mem_ack(mem_ack[i]),
                .data_Ready(data_Ready[i]),
                .bus_request(bus_req[i])
            );
        end
    endgenerate
endmodule
