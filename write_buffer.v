module write_buffer(clk, word_count, address, data_bus);

input clk;
input [31:0] data_bus;
output reg [15:0] address, word_count;

always @ (posedge clk)

	begin

	address <= data_bus[15:0];
	word_count <= data_bus[31:16];

	end



endmodule
