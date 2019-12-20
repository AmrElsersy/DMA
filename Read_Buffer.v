module Read_Buffer(CLK, Word_Count, Address, Data_Bus);

input CLK;
input [15:0] Address, Word_Count;
output reg [31:0] Data_Bus;
always @(posedge CLK)
	begin
	Data_Bus = { Word_Count, Address };
	end

endmodule