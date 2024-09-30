//Modelo de la ALU de 32 bits para procesamiento de las funciones

module alu(
           input [31:0] A,B,  // ALU 32-bit Inputs                 
           input [3:0] ALU_Sel,// ALU Selection
           output [31:0] ALU_Out, // ALU 32-bit Output
           output CarryOut, // Carry Out Flag
           output Zero //Zero flag when ALU output is 0
    );
    integer i;
    reg [31:0] ALU_Result;
    reg zeroOut;
    wire [32:0] tmp;
    reg [31:0] y;
    assign ALU_Out = ALU_Result; // ALU out
    assign tmp = {1'b0,A} + {1'b0,B};
    assign CarryOut = tmp[32]; // Carryout flag
    assign Zero = zeroOut;
    always @(*)
    begin
        case(ALU_Sel)
        4'b0000: // Addition
           ALU_Result = A + B ; 
        4'b0001: // Subtraction
           ALU_Result = A - B ;
        4'b0010: // Multiplication
           ALU_Result = A * B;
        4'b0011: // Division
           if (B != 0 )
           begin
               ALU_Result = A/B;
           end
           else begin
               $display("We cannot divide by 0");
               ALU_Result = 32'hFFFFFFFF;
           end
        4'b0100: // Logical shift left
           ALU_Result = A<<1;
         4'b0101: // Logical shift right
           ALU_Result = A>>1;
         4'b0110: // Rotate left
           ALU_Result = {A[30:0],A[31]};
         4'b0111: // Rotate right
           ALU_Result = {A[0],A[31:1]};
          4'b1000: //  Logical and 
           ALU_Result = A & B;
          4'b1001: //  Logical or
           ALU_Result = A | B;
          4'b1010: //  Logical xor 
           ALU_Result = A ^ B;
          4'b1011: //  Logical nor
           ALU_Result = ~(A | B);
          4'b1100: // Logical nand 
           ALU_Result = ~(A & B);
          4'b1101: // SLTU
           ALU_Result = A < B;
          4'b1110: // Set on less than
             begin // SLT
				if (A[31] != B[31]) begin
					if (A[31] > B[31]) begin
						ALU_Result = 1;
					end else begin
						ALU_Result = 0;
					end
				end else begin
					if (A < B)
					begin
						ALU_Result = 1;
					end
					else
					begin
						ALU_Result = 0;
					end
				end
			end
           //ALU_Result = (A>B)?32'd1:32'd0 ;
          4'b1111: // SRA shift right arithmetic   
            y = A;
				for (i = B; i > 0; i = i - 1) begin
					y = {y[31],y[31:1]};
				end
				ALU_Result = y;
          default: ALU_Result = A + B ; 
        endcase
    end

    always @(ALU_Result) begin
        zeroOut <= (ALU_Result == 0) ? 1 : 0; 
    end

endmodule