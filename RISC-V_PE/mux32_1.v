module mux32_1 (
    input      [31:0] in_1,
    input      [31:0] in_2,
    input      [31:0] in_3,
    input      [31:0] in_4,
    input      [31:0] in_5,
    input      [31:0] in_6,
    input      [31:0] in_7,
    input      [31:0] in_8,
    input      [31:0] in_9,
    input      [31:0] in_10,
    input      [31:0] in_11,
    input      [31:0] in_12,
    input      [31:0] in_13,
    input      [31:0] in_14,
    input      [31:0] in_15,
    input      [31:0] in_16,
    input      [31:0] in_17,
    input      [31:0] in_18,
    input      [31:0] in_19,
    input      [31:0] in_20,
    input      [31:0] in_21,
    input      [31:0] in_22,
    input      [31:0] in_23,
    input      [31:0] in_24,
    input      [31:0] in_25,
    input      [31:0] in_26,
    input      [31:0] in_27,
    input      [31:0] in_28,
    input      [31:0] in_29,
    input      [31:0] in_30,
    input      [31:0] in_31,
    input      [31:0] in_32,
    input      [4:0]  selrs1,
    input      [4:0]  selrs2,
    input             reg_select,
    input             read_en,
    output reg [31:0] data_out1,
    output reg [31:0] data_out2
);
    always @(*) begin
        if (read_en == 1)
        begin
        case(selrs1)
            5'b00000: 
            begin
                data_out1 = in_1;
                $display("Data read at Reg 0: %h", in_1);
            end 
            5'b00001: data_out1 = in_2; 
            5'b00010: data_out1 = in_3; 
            5'b00011: data_out1 = in_4; 
            5'b00100: data_out1 = in_5; 
            5'b00101: data_out1 = in_6; 
            5'b00110: data_out1 = in_7; 
            5'b00111: data_out1 = in_8; 
            5'b01000: data_out1 = in_9; 
            5'b01001: data_out1 = in_10; 
            5'b01010: data_out1 = in_11; 
            5'b01011: data_out1 = in_12; 
            5'b01100: data_out1 = in_13; 
            5'b01101: data_out1 = in_14; 
            5'b01110: 
            begin
                data_out1 = in_15; 
                $display("Data read at Reg 14: %h", in_15);
            end
            5'b01111: data_out1 = in_16; 
            5'b10000: data_out1 = in_17; 
            5'b10001: data_out1 = in_18; 
            5'b10010: data_out1 = in_19; 
            5'b10011: data_out1 = in_20; 
            5'b10100: data_out1 = in_21; 
            5'b10101: data_out1 = in_22; 
            5'b10110: data_out1 = in_23; 
            5'b10111: data_out1 = in_24; 
            5'b11000: data_out1 = in_25; 
            5'b11001: data_out1 = in_26; 
            5'b11010: data_out1 = in_27; 
            5'b11011: data_out1 = in_28; 
            5'b11100: data_out1 = in_29; 
            5'b11101: data_out1 = in_30; 
            5'b11110: data_out1 = in_31; 
            5'b11111: data_out1 = in_32; 
            default: data_out1 = 32'b0; // Default case (optional)
        endcase
        if (reg_select == 1)
        begin
            case(selrs2)
                5'b00000: data_out2 = in_1; 
                5'b00001: data_out2 = in_2; 
                5'b00010: data_out2 = in_3; 
                5'b00011: data_out2 = in_4; 
                5'b00100: data_out2 = in_5; 
                5'b00101: data_out2 = in_6; 
                5'b00110: data_out2 = in_7; 
                5'b00111: data_out2 = in_8; 
                5'b01000: data_out2 = in_9; 
                5'b01001: data_out2 = in_10; 
                5'b01010: data_out2 = in_11; 
                5'b01011: data_out2 = in_12; 
                5'b01100: data_out2 = in_13; 
                5'b01101: data_out2 = in_14; 
                5'b01110: 
                begin
                    data_out2 = in_15; 
                    $display("Data read at Reg 14: %h", in_15);
                end
                5'b01111: data_out2 = in_16; 
                5'b10000: data_out2 = in_17; 
                5'b10001: data_out2 = in_18; 
                5'b10010: data_out2 = in_19; 
                5'b10011: data_out2 = in_20; 
                5'b10100: data_out2 = in_21; 
                5'b10101: data_out2 = in_22; 
                5'b10110: data_out2 = in_23; 
                5'b10111: data_out2 = in_24; 
                5'b11000: data_out2 = in_25; 
                5'b11001: data_out2 = in_26; 
                5'b11010: data_out2 = in_27; 
                5'b11011: data_out2 = in_28; 
                5'b11100: data_out2 = in_29; 
                5'b11101: data_out2 = in_30; 
                5'b11110: data_out2 = in_31; 
                5'b11111: data_out2 = in_32; 
                default: data_out2 = 32'b0; // Default case (optional)
            endcase
        end
        else
        begin
            data_out2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        end
        end

        else
        begin
            data_out1 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
            data_out2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        end
    end

endmodule