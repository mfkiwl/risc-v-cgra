module bus_interface (
    input clk,
    input reset,
    //Inputs from PE
    input [31:0] mem_addressPE,  //mem_Address from PE for global memory
    input [31:0] result_inPE,    //result_out from PE
    input [31:0] PCoutPE,        //new program counter to be sent to the controller
    input [4:0] rs1OutPE,        //Select data from PE to be sent to local memory
    input [4:0] rs2OutPE,        //Select data from PE to be sent to local memory
    input [4:0] rdOutPE,         //Select data from PE to be sent to local memory
    input       reg_selectPE,    //Select signal for local memory (read 1 or 2 data)
    input       mem_readPE,      //Signal to read from global memory
    input       mem_writePE,     //Signal to write to global memory
    input       rd_writePE,      //Signal to write to local memory
    input       read_enPE,       //Signal to read from local memory

    //Outputs to the PE
    output reg [31:0] AmuxPE,    //Data being sent to A mux
    output reg [31:0] BmuxPE,    //Data being sent to B mux
    output reg        mem_ackPE, //Memory acknowledgment signal into the PE
    output reg        data_ReadyPE, //data_Ready signal into the PE

    //Signals to/from the bus
    output reg bus_request,    //Request signal sent to the arbiter
    input      grant,      //Grant signal from the arbiter
    output reg [31:0] mem_addressBus,  //mem_Address sent to bus for global memory
    output reg [31:0] result_outBus,   //result_out sent to bus
    output reg [31:0] PCoutBus,        //new program counter to be sent to the controller
    output reg [4:0] rs1OutBus,        //Select data from PE to be sent to local memory
    output reg [4:0] rs2OutBus,        //Select data from PE to be sent to local memory
    output reg [4:0] rdOutBus,         //Select data from PE to be sent to local memory
    output reg       reg_selectBus,    //Select signal for local memory (read 1 or 2 data)
    output reg       mem_readBus,      //Signal to read from global memory
    output reg       mem_writeBus,     //Signal to write to global memory
    output reg       rd_writeBus,      //Signal to write to local memory
    output reg       read_enBus,
    input [31:0] AmuxBus,    //Data being sent to A mux
    input [31:0] BmuxBus,    //Data being sent to B mux
    input        mem_ackBus, //Memory acknowledgment signal coming from the global memory
    input        data_ReadyBus, //register read complete
    input [31:0] memData,      //Data coming from global memory
);

    reg active; // Keep track of the bus request state

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bus_request <= 0;
            AmuxPE <= 0;
            BmuxPE <= 0;
            mem_ackPE <= 0;
            data_ReadyPE <= 0;
            mem_addressBus <= 0;
            result_outBus <= 0;
            PCoutBus <= 0;
            rs1OutBus <= 0;
            rs2OutBus <= 0;
            rdOutBus <= 0;
            reg_selectBus <= 0;
            mem_readBus <= 0;
            mem_writeBus <= 0;
            rd_writeBus <= 0;
            read_enBus <= 0;
            active <= 0;
        end else begin
            if ((mem_readPE || mem_writePE || rd_writePE || read_enPE) && !active) begin
                bus_request <= 1; // Request the bus
            end
            if (grant) begin
                PCoutBus <= PCoutPE;
                if (mem_writePE)
                begin
                    mem_addressBus <= mem_addressPE;
                    mem_writeBus <= mem_writePE;
                    result_outBus <= result_inPE;
                end
                if (mem_readPE)
                begin
                    mem_addressBus <= result_inPE; //Address is calculated from ALU
                    mem_readBus <= mem_readPE;
                end
                if (rd_writePE)
                begin 
                    rdOutBus <= rdOutPE; //Forward select for local memory write
                    rd_writeBus <= rd_writePE;
                    result_outBus <= result_inPE; //Result from ALU to be written in rd
                end
                if (read_enPE)
                begin
                    rs1OutBus <= rs1OutPE;
                    rs2OutBus <= rs2OutPE;
                    read_enBus <= read_enPE;
                    reg_selectBus <= reg_selectPE;
                end
                bus_request <= 0; // Clear the request once granted
                active <= 1;
            end
            if (active) begin
                if (mem_ackBus)
                begin
                    AmuxPE <= memData;
                    mem_ackPE <= mem_ackBus;
                end
                if (data_ReadyBus)
                begin
                    AmuxPE <= AmuxBus;
                    BmuxPE <= BmuxBus;
                    data_ReadyPE <= data_ReadyBus;
                end
                active <= 0;
                bus_request <= 0;

            end
        end
    end
endmodule
