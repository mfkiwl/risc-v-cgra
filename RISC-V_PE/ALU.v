//Modelo de la ALU de 32 bits para procesamiento de las funciones

module alu(
           input        clk, // clock input
           input [31:0] A,B,  // ALU 32-bit Inputs                 
           input [4:0] ALU_Sel,// ALU Selection
           output [31:0] ALU_Out, // ALU 32-bit Output
           output Zero, //Zero flag when ALU output is 0
           output complete //Indicates end of operation
    );
    integer i;
    reg [31:0] ALU_Result;
    reg zeroOut;
    wire [32:0] tmp;
    reg [31:0] y;
    assign ALU_Out = ALU_Result; // ALU out
    assign tmp = {1'b0,A} + {1'b0,B};
    assign Zero = zeroOut;
    always @(posedge clk)
    begin
        case(ALU_Sel)
        5'b00000: // Addition
           ALU_Result = A + B ; 
        5'b00001: // Subtraction
           ALU_Result = A - B ;
        5'b00010: // Multiplication
           ALU_Result = A * B;
        5'b00011: // Division
           if (B != 0 )
           begin
               ALU_Result = A/B;
           end
           else begin
               $display("We cannot divide by 0");
               ALU_Result = 32'hFFFFFFFF;
           end
        5'b00100: // Logical shift left
           ALU_Result = A<<1;
        5'b00101: // Logical shift right
           ALU_Result = A>>1;
        5'b00110: // Rotate left
           ALU_Result = {A[30:0],A[31]};
        5'b00111: // Rotate right
           ALU_Result = {A[0],A[31:1]};
        5'b01000: //  Logical and 
           ALU_Result = A & B;
        5'b01001: //  Logical or
           ALU_Result = A | B;
        5'b01010: //  Logical xor 
           ALU_Result = A ^ B;
        5'b01011: //  Logical nor
           ALU_Result = ~(A | B);
        5'b01100: // Logical nand 
           ALU_Result = ~(A & B);
        5'b01101: // SLTU
           ALU_Result = A < B;
        5'b01110: // Set on less than
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
           //ALU_Result = (A>B)?32'b1:32'b0 ;
        5'b01111: // SRA shift right arithmetic   
            begin
               y = A;
				   for (i = B; i > 0; i = i - 1) 
               begin
					   y = {y[31],y[31:1]};
				   end
				   ALU_Result = y;
            end
        5'b10000: //Take lower byte sign extended
            begin
               if (A[31]==1)
               begin
                  ALU_Result = {24'b111111111111111111111111, A[7:0]};
               end
               else
               begin
                  ALU_Result = {24'b0, A[7:0]};
               end
            end
        5'b10001: //Take lower half word sign extended
            begin
               if (A[31]==1)
               begin
                  ALU_Result = {16'b1111111111111111, A[15:0]};
               end
               else
               begin
                  ALU_Result = {16'b0, A[15:0]};
               end
            end
        5'b10010: //Take lower byte unsigned
            begin
               ALU_Result = {24'b0, A[7:0]};
            end
        5'b10011: //Take lower half word unsigned
            begin
               ALU_Result = {16'b0, A[15:0]};
            end  
          default: ALU_Result = A + B ; 
        endcase
    end

    always @(ALU_Result) begin
        zeroOut <= (ALU_Result == 0) ? 1 : 0; 
        complete <= 1;
    end

endmodule