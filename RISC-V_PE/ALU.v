//Modelo de la ALU de 32 bits para procesamiento de las funciones
`define DEBUG

module alu(
           input        clk,      // Clock input
           input [31:0] A, B,     // ALU 32-bit Inputs                 
           input [4:0]  ALU_Sel,  // ALU Selection
           output reg [31:0] ALU_Out, // ALU 32-bit Output
           output reg Zero,        // Zero flag when ALU output is 0
           output reg ALUcomplete  // Indicates end of operation
    );
    integer i;
    reg [31:0] y;
    wire [32:0] tmp;

    always @(posedge clk) begin
        ALUcomplete <= 0; // Indicates operation is in progress
        case (ALU_Sel)
            5'b00000: // Addition
               ALU_Out <= A + B; 
            5'b00001: // Subtraction
               ALU_Out <= A - B;
            5'b00010: // Multiplication
               ALU_Out <= A * B;
            5'b00011: // Division
               if (B != 0) begin
                   ALU_Out <= A / B;
               end else begin
                  `ifdef DEBUG
                     $display("Error: Division by zero at time %t", $time);
                  `endif
                  ALU_Out <= 32'hFFFFFFFF; // Default error value
               end
            5'b00100: // Logical shift left
               ALU_Out <= A << B;
            5'b00101: // Logical shift right
               ALU_Out <= A >> B;
            5'b00110: // Rotate left
               ALU_Out <= {A[30:0], A[31]};
            5'b00111: // Rotate right
               ALU_Out <= {A[0], A[31:1]};
            5'b01000: // Logical and 
               ALU_Out <= A & B;
            5'b01001: // Logical or
               ALU_Out <= A | B;
            5'b01010: // Logical xor 
               ALU_Out <= A ^ B;
            5'b01011: // Logical nor
               ALU_Out <= ~(A | B);
            5'b01100: // Logical nand 
               ALU_Out <= ~(A & B);
            5'b01101: // SLTU
               ALU_Out <= (A < B) ? 1 : 0;
            5'b01110: // Set on less than
                begin // SLT
                    if (A[31] != B[31]) begin
                        ALU_Out <= (A[31] > B[31]) ? 1 : 0;
                    end else begin
                        ALU_Out <= (A < B) ? 1 : 0;
                    end
                end
            5'b01111: // SRA shift right arithmetic   
                begin
                     y = A;
				         for (i = B; i > 0; i = i - 1) 
                     begin
					         y = {y[31],y[31:1]};
				         end
				         ALU_Out = y;
               end
            5'b10000: // Take lower byte sign extended
                begin
                   if (A[7] == 1) begin
                      ALU_Out <= {24'b111111111111111111111111, A[7:0]};
                   end else begin
                      ALU_Out <= {24'b0, A[7:0]};
                   end
                end
            5'b10001: // Take lower half word sign extended
                begin
                   if (A[15] == 1) begin
                      ALU_Out <= {16'b1111111111111111, A[15:0]};
                   end else begin
                      ALU_Out <= {16'b0, A[15:0]};
                   end
                end
            5'b10010: // Take lower byte unsigned
                begin
                   ALU_Out <= {24'b0, A[7:0]};
                end
            5'b10011: // Take lower half word unsigned
                begin
                   ALU_Out <= {16'b0, A[15:0]};
                end  
            default: ALU_Out <= A + B; 
        endcase

        Zero <= (ALU_Out == 0) ? 1 : 0;
        ALUcomplete <= 1; // Indicates operation completion
    end

endmodule
