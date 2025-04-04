// Control module

module controller (

// Input clock
input        clk,

// Input from ALU result and instruction decoder
input        reset,
input        ALU0,
input [6:0]  op,
input [2:0]  funct3,
input [6:0]  funct7,
input [4:0]  rs1,
input [4:0]  rs2,
input [4:0]  rd,
input [11:0] imm12,
input [19:0] immhi,
input        ALUcomplete, //Indicates end of ALUoperation
input [31:0] ALURes, //ALU Result input to controller
input        decodeComplete, //Signal from decoder that signals are ready

// Control signal inputs/outputs from bus
input  [31:0] PCin, //Program counter input
output reg [31:0] PCout, //Program counter output

// Input from bus when data from register is ready
input       dataReady,

// Signals for memory access operations
input        mem_ack,

// Signals to bus with register addresses
output reg [4:0] rs1Out,
output reg [4:0] rs2Out,
output reg       read_en,  //Enable signal to read rs1 or rs2 values from the registers

// Selection signal outputs for the 3 MUX and the ALU
output reg [4:0] ALUsel,
output reg [1:0] Asel, //Can be rs1 from decoder, dataInput from bus or PC from bus
output reg [1:0] Bsel, //Can be rs2 from decoder, dataInput from bus or immvalue from controller
output reg [1:0] Osel, //Can be ALU result, opA register, or opB register

output reg [4:0] rdOut, // This is the address of the destination register
output reg rdWrite, //Indicates that output will be written to rd

// Register enable signals
output reg       Aenable,
output reg       Benable,
output reg       IRenable,
output reg       reg_reset, //Reset signal for registers

// Output signals for read/write to memory
output reg        mem_read, // If mem_read is 1, value from the output of the PE is a memory address that must be read
output reg        mem_write, //Indicates to bus that value in output must be written to indicated address
output reg [31:0] mem_address, // used for store operations. Stores in memory
output reg        reg_select, // Selects rs1 or rs2 when reading from register

output reg [31:0] immvalue, //Value being wired to reg B mux
output reg        execution_complete //Indicates end of processing
);

// Internal signals
reg [31:0] tempimmvalue = 0; //Fill with imm12 or immhi
reg [31:0] tempAddress = 0; //For store operations
reg dataReady_sync;
reg ALUcomplete_sync;
reg ALURes_sync;


// Function definition 
    function [31:0] sign_extend;
        input [11:0] imm;
        begin
            sign_extend = (imm[11] == 0) ? {20'b0, imm} : {20'b11111111111111111111, imm};
        end
    endfunction

    // Task definition 
    task complete_operation(input [1:0] Oselection, input [4:0] dest_reg);
        begin
            Osel <= Oselection;
            rdOut <= dest_reg;
            rdWrite <= 1;
            execution_complete <= 1;
        end
    endtask

initial begin
    PCout = 0;
    ALUsel = 5'b00000;
    immvalue = 0;
    rdWrite = 0;
    mem_read = 0;
    mem_write = 0;
    reg_reset = 0;
    Aenable = 0;
    Benable = 0;
    IRenable = 0;
    Asel = 2'b00;
    Bsel = 2'b00;
    Osel = 2'b00;
    dataReady_sync = 0;
    ALUcomplete_sync = 0;
    ALURes_sync = 0;
    tempAddress = 0;
    read_en = 0;
    execution_complete = 0;
    //req = 0;
end

always @(posedge clk or posedge reset) 
begin
    if (reset)
    begin
        //initialize values
        PCout <= 0;
        ALUsel <= 5'b11111;
        Asel <= 2'b00;
        Bsel <= 2'b00;
        Osel <= 2'b00;
        rdOut <= 0;
        rdWrite <= 0;
        Aenable <= 0;
        Benable <= 0;
        reg_reset <= 1;
        mem_read <= 0;
        immvalue <= 0;
        rs1Out <= 0;
        rs2Out <= 0;
        reg_select <= 0;
        mem_write <= 0;
        dataReady_sync <= 0;
        ALUcomplete_sync <= 0;
        ALURes_sync <= 0;
        mem_address <= 0;
        tempAddress <= 0;
        read_en <= 0;
        execution_complete <= 0;
        //req = 0;
    
        reg_reset <= 0;
        IRenable <= 1;
    end
    else
    begin
        dataReady_sync <= dataReady;
        ALUcomplete_sync <= ALUcomplete;
        ALURes_sync <= ALURes;

    case(op)
    7'b0000011: // Op code 3 is load operations
    begin
        rdOut <= 0;
        rdWrite <= 0;
        mem_read <= 0;
        Aenable <= 0;
        Benable <= 0;
        //req <= 0;
        PCout <= PCin; // By default, retain the same PC value
        execution_complete <= 0;

        rs1Out <= rs1;
        reg_select <= 0; //Selects only rs1 value to pull
        read_en <= 1;
        if (dataReady_sync)
        begin
            read_en <= 0;
            Asel <= 2'b01; // Select data from bus as A input
            //immvalue <= (imm12[11] == 0) ? {20'b0, imm12} : {20'b11111111111111111111, imm12};
            immvalue <= sign_extend(imm12);
            Bsel <= 2'b10; //Select immidiate value as B input
            Aenable <= 1;
            Benable <= 1;

            //Select ALU to add values
            ALUsel <= 5'b00000;

            //Select ALU result as output to send address
            Osel <= 2'b00; 

            if (ALUcomplete_sync)
            begin
                mem_read <= 1; //Send signal for memory read
                Aenable <= 0;
                Benable <= 0;

                if (mem_ack) //After acknowledge signal has been received
                begin
                    mem_read <= 0;
                    Aenable <= 1;
                    Asel <= 2'b01; //Select data from bus as A input
                    case (funct3)
                    3'b000: // Load byte sign extended
                        begin
                        ALUsel <= 5'b10000; // Select take byte sign extended from ALU
                        Osel <= 2'b00; //Select output from ALU
                        end
                    3'b001: // Load half word sign extended
                        begin
                        ALUsel <= 5'b10001; // Select take half word sign extended from ALU
                        Osel <= 2'b00; //Select output from ALU
                        end
                    3'b010: // Load word
                        begin
                        Osel <= 2'b01; //Select register A as output
                        end
                    3'b100: // Load byte unsigned
                        begin
                        ALUsel <= 5'b10010; // Select take byte unsigned from ALU
                        Osel <= 2'b00; // Select output from ALU
                        end
                    3'b101: // Load half word unsigned
                        begin
                        ALUsel <= 5'b10011; // Select take byte unsigned from ALU
                        Osel <= 2'b00; // Select output from ALU
                        end
                    endcase
                    rdOut <= rd; 
                    rdWrite <= 1; //Send signal to write output value into rd register
                    execution_complete <= 1;
                    //req <= 1;
                end
            end     
        end           
    end

    7'b0010011: //Op code 19 is ALU operations on immidiate values
    begin
        rdOut <= 0;
        rdWrite <= 0;
        mem_read <= 0;
        Aenable <= 0;
        Benable <= 0;
        rs1Out <= rs1;
        reg_select <= 0;
        read_en <= 1;
        reg_reset <= 0;
        //req <= 0;
        dataReady_sync <= dataReady;

        if (dataReady_sync)
        begin
            read_en <= 0;
            Asel <= 2'b01; //Select data comming from bus
            tempimmvalue = sign_extend(imm12);
            Bsel <= 2'b10; //Select immidiate value as B input
            // Enable registers to load value
            Aenable <= 1; 
            Benable <= 1;

            case(funct3)
            3'b000: //Add immidiate
            begin
                //Select ALU to add values
                ALUsel <= 5'b00000;
                immvalue <= tempimmvalue;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b001: //Shift left
            begin
                immvalue <= {27'b000000000000000000000000000, imm12[4:0]};
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b00100;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                   complete_operation(2'b00,rd);
                   //req <= 1;
                end
            end

            3'b010: //Set less than Immediate
            begin
                immvalue <= tempimmvalue;
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01110;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b011: //Set less imm than unsigned
            begin
                immvalue <= tempimmvalue;
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01101;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b100: //XOR
            begin
                immvalue <= tempimmvalue;
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01010;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b101: //Shift right logical or arithmetic
            begin
                immvalue <= {27'b000000000000000000000000000, imm12[4:0]};
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                case(tempimmvalue[11:5])
                7'b0000000: //Logical shift right
                begin
                    ALUsel <= 5'b00101;
                end
                7'b0100000: //Arithmetic shift right
                begin
                    ALUsel <= 5'b01111;
                end
                endcase

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b110: //OR
            begin
                immvalue <= tempimmvalue;
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01001;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b111: //AND
            begin
                immvalue <= tempimmvalue;
                Bsel <= 2'b10;
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01000;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end
            endcase
        end    
    end

    7'b0110011: //Code 51 is ALU operations on two values comming from registers
    begin
        rdOut <= 0;
        rdWrite <= 0;
        Aenable <= 0;
        Benable <= 0;
        PCout <= PCin; // By default, retain the same PC value
        //req <= 0;
        rs1Out <= rs1;
        rs2Out <= rs2;
        reg_select <= 1;
        read_en <= 1;
        reg_reset <= 0;
        execution_complete <= 0;

        if (dataReady_sync)
        begin
            read_en <= 0;
            Asel <= 2'b01; //Select data comming from bus
            Bsel <= 2'b01; //Select data comming from bus 
            // Enable registers to load value
            Aenable <= 1; 
            Benable <= 1;

            case(funct3)
            3'b000: //Add, substract, multiply
            begin
                if (funct7 == 7'b0000000) begin
                    ALUsel <= 5'b00000; // Add
                end else if (funct7 == 7'b0100000) begin
                    ALUsel <= 5'b00001; // Subtract
                end else if (funct7 == 7'b0000001) begin
                    ALUsel <= 5'b00010; //multiply
                end

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00, rd);
                    //req <= 1;
                end

            end

            3'b001: //Shift left logical
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b00100;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b010: //Set less than
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01110;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b011: //Set less than unsigned
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01101;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b100: //XOR
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01010;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b101: //Shift right logical or arithmetic
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                case(funct7)
                7'b0000000: //Logical shift right
                begin
                    ALUsel <= 5'b00101;
                end
                7'b0100000: //Arithmetic shift right
                begin
                    ALUsel <= 5'b01111;
                end
                endcase

                if (ALUcomplete_sync)
                begin
                    Osel <= 2'b00;
                    rdOut <= rd;
                    rdWrite <= 1;
                    execution_complete <= 1;
                    //complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end

            3'b110: //OR
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01001;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00, rd);
                    //req <= 1;
                end
            end

            3'b111: //AND
            begin
                // Enable registers to load value
                Aenable <= 1; 
                Benable <= 1;

                ALUsel <= 5'b01000;

                if (ALUcomplete_sync)
                begin
                    //Osel <= 2'b00;
                    //rdOut <= rd;
                    //rdWrite <= 1;
                    complete_operation(2'b00,rd);
                    //req <= 1;
                end
            end
            endcase
        end

    end

    7'b0110111: //Code 55 is Load upper immidiate word
    begin
        rdOut <= 0;
        rdWrite <= 0;
        Aenable <= 0;
        Benable <= 0;
        PCout <= PCin; // By default, retain the same PC value
        execution_complete <= 0;
        //req <= 0;

        reg_reset <= 0;
        tempimmvalue = {immhi, 12'b000000000000};
        immvalue <= tempimmvalue;
        Bsel <= 2'b10; //Select immidiate value as B input
        // Enable registers to load value
        Benable <= 1;

        //Select B register as output to send address
        Osel <= 2'b10; 

        mem_read <= 1; //Send signal for memory read

        if (mem_ack) //After acknowledge signal has been received
        begin
            Aenable <= 1;
            Benable <= 0;
            Asel <= 2'b01; //Select data from bus as A input
            Osel <= 2'b01; //Select register A as output
            rdOut <= rd; 
            rdWrite <= 1; //Send signal to write output value into rd register
            mem_read <= 0; //Reset the memory read signal
            execution_complete <= 1;
            //req <= 1;
        end
    end

    7'b0100011: //Code 35 is store operations
    begin
        rdOut <= 0;
        rdWrite <= 0;
        Aenable <= 0;
        Benable <= 0;
        PCout <= PCin; // By default, retain the same PC value
        execution_complete <= 0;
        //req <= 0;
        Osel <= 0;
        reg_reset <= 1;
        reg_reset <= 0;
        rs1Out <= rs1;
        reg_select <= 0; //Selects data only from rs1 to pull 
        read_en <= 1;
        Asel = 2'b01; //Select data from bus
        Bsel <= 2'b10; //Select immidiate value as B input
        immvalue <= sign_extend(imm12);

        if (!dataReady_sync && tempAddress == 0)
        begin
            ALUsel <= 5'b11111;
        end

        if (dataReady_sync && tempAddress == 0)
        begin
            read_en <= 0;
            // Enable registers to load value
            Aenable <= 1; 
            Benable <= 1;

            //Select ALU to add values
            ALUsel <= 5'b00000;

            if (ALUcomplete_sync)
            begin
                tempAddress <= ALURes;
            end

        end

        else if (!dataReady_sync && tempAddress !=0)
        begin
            ALUsel <= 5'b11111;
            Aenable <= 1;
            rs2Out <= rs2;
            read_en <= 1;
            reg_select <= 1; //Selects register rs2 to pull data from
            Asel <= 2'b01; //Select data from bus
        end

        else if (dataReady_sync && tempAddress != 0)
        begin
            read_en <= 0;
            case(funct3)
            3'b000: //Store byte
                begin
                    ALUsel = 5'b10010; //Take only lower byte of rs2 value
                    Osel = 2'b00; //Select output from ALU
                end 

            3'b001: //Store half word
                begin
                    ALUsel = 5'b10011; //Take lower half word of rs2 value
                    Osel = 2'b00; //Select output from ALU
                end
                    
            3'b010: //Store word
                begin
                    ALUsel = 5'b10100;
                    Osel = 2'b00; //Select output from ALU
                end
            endcase

            if (ALUcomplete_sync)
            begin
                mem_address <= tempAddress; //Use the calculated destination address to store the value
                mem_write <= 1; //Indicates that value at output will be stored at mem_address
                execution_complete <= 1;
                //req <= 1;
            end
        end
    end

    7'b1100011: //Case 99 is branch operations
    begin
        rdOut <= 0;
        rdWrite <= 0;
        Aenable <= 0;
        Benable <= 0;
        PCout <= PCin; // By default, retain the same PC value
        execution_complete <= 0;
        //req <= 0;
        Osel <= 0;
        reg_reset <= 1;
        reg_reset <= 0;
        rs1Out <= rs1;
        rs2Out <= rs2;
        reg_select <= 1; //Selects both registers to pull
        read_en <= 1;
        Asel = 2'b01; //Select data from bus
        Bsel <= 2'b01; //Select data from bus
        tempimmvalue = sign_extend(imm12);
        immvalue <= {tempimmvalue[30:0], 1'b0};

        Aenable <= 1;
        Benable <= 1;

        if (dataReady_sync)
        begin
            Aenable <= 1;
            Benable <= 1;

            ALUsel <= 5'b00110;

            if (ALUcomplete_sync && tempAddress == 0)
            begin
                ALUsel = 5'b11111;
                case (funct3)
                3'b000: //Case if =
                begin
                    if (ALURes == 32'b00000000000000000000000000000001)
                    begin
                        Asel <= 2'b10; //Select program counter
                        Bsel <= 2'b10; //Select imm value
                        Aenable <= 1;
                        Benable <= 1;
                        ALUsel <= 5'b00000; //Select add
                        tempAddress <= 32'b00000000000000000000000000000001;
                    end
                end
                3'b001: //Case if !=
                begin
                    if (ALURes == 32'b00000000000000000000000000000000)
                    begin
                        Asel <= 2'b10; //Select program counter
                        Bsel <= 2'b10; //Select imm value
                        Aenable <= 1;
                        Benable <= 1;
                        ALUsel <= 5'b00000; //Select add
                        tempAddress <= 32'b00000000000000000000000000000001;
                    end
                end
                endcase
            end
        end
        if (!dataReady_sync && ALUcomplete_sync && tempAddress != 0)
        begin
            PCout <= ALURes;
            execution_complete <= 1;
            //req <= 1;
            Aenable <= 0;
            Benable <= 0;
        end
    end

    7'b1101111: // Op 111 is jump and link
    begin
        rdOut <= 0;
        rdWrite <= 0;
        Aenable <= 0;
        Benable <= 0;
        PCout <= PCin; // By default, retain the same PC value
        execution_complete <= 0;
        //req <= 0;
        //Osel <= 0;
        reg_reset <= 1;
        reg_reset <= 0;
        Asel = 2'b10; //Select PC
        Bsel <= 2'b10; //Select immvalue
        tempimmvalue = (immhi[19] == 0) ? {12'b0, immhi} : {12'b111111111111, immhi};
        immvalue <= {tempimmvalue[30:0], 1'b0};

        Aenable <= 1;
        Benable <= 1;


        if (dataReady_sync)
        begin
            ALUsel = 5'b00000;
            

            if (ALUcomplete_sync)
            begin
                PCout <= ALURes;
                execution_complete <= 1;
                //req <= 1;
                rdOut <= rd;
                rdWrite <= 1;
                Osel = 2'b01; //Select A reg (PCin) as output *ommiting for now the + 4
                //ALUsel = 5'b11111;
                //Aenable <= 0;
                //Benable <= 0;
            end
        end   
    end

    endcase
    IRenable <= 0;
    end
end
endmodule




