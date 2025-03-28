module cgra_bus_system (
    input clk,
    input reset,
    input [3:0] mem_read,         // Read signals from the PEs
    input [3:0] mem_write,        // Write signals from the PEs
    input [31:0] address [3:0],   // Addresses from each PE
    input [31:0] write_data [3:0],// Write data from each PE
    output [31:0] read_data [3:0] // Read data to each PE
);
    wire [3:0] bus_req;           // Bus request signals
    wire [3:0] grant;             // Grant signals from the arbiter
    wire [31:0] shared_read_data; // Data from shared memory

    // Instantiate arbiter
    bus_arbiter arbiter (
        .clk(clk),
        .reset(reset),
        .req(bus_req),
        .grant(grant)
    );

    // Instantiate shared memory
    shared_memory memory (
        .clk(clk),
        .address(address[grant]),
        .write_data(write_data[grant]),
        .mem_read(|mem_read & grant),
        .mem_write(|mem_write & grant),
        .read_data(shared_read_data)
    );

    // Instantiate bus interfaces
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : bus_interfaces
            bus_interface iface (
                .clk(clk),
                .reset(reset),
                .address(address[i]),
                .write_data(write_data[i]),
                .mem_read(mem_read[i]),
                .mem_write(mem_write[i]),
                .grant(grant[i]),
                .read_data(read_data[i]),
                .bus_request(bus_req[i])
            );
        end
    endgenerate
endmodule
