`include "BusArbiter.v"

`timescale 1ns / 1ps

module tb_bus_arbiter;

    // Testbench signals
    reg clk;
    reg reset;
    reg [3:0] req;         // Request signals from PEs
    wire [3:0] grant;      // Grant signals from arbiter

    // Instantiate the arbiter module
    bus_arbiter uut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .grant(grant)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period = 10 time units
    end

    // Testbench logic
    initial begin
        // Dump waveform for debugging
        $dumpfile("tb_bus_arbiter.vcd");
        $dumpvars(0, tb_bus_arbiter);

        // Monitor outputs
        $monitor("Time: %0dns | grant: %b", 
                 $time, grant);


        // Initialize signals
        reset = 1;
        req = 4'b0000; // No requests initially
        #10 reset = 0; // Release reset

        // Test Case 1: Single PE requests (PE 0)
        #10 req = 4'b0001; // PE 0 requests access
        #10 req = 4'b0000; // Clear request

        // Test Case 2: Multiple requests (PE 1 and PE 3)
        #10 req = 4'b1010; // PE 1 and PE 3 request access

        // Test Case 3: Sequential requests
        #10 req = 4'b0100; // PE 2 requests access
        #10 req = 4'b0010; // PE 1 requests access

        // Test Case 4: All PEs request access
        #10 req = 4'b1111; // All PEs request access

        // Test Case 5: No requests
        #10 req = 4'b0000; // No PEs request access

        // Test Case 6: Persistent request (PE 0 keeps requesting access)
        #10 req = 4'b0001; // PE 0 requests access again
        #50 req = 4'b0000; // Clear request

        // End simulation
        #10 $finish;
    end

endmodule
