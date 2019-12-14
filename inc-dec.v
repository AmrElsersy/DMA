module inc_dec(clk,add_enable, add_strobe, add_in, address_out);
input clk, add_enable, add_strobe;
input [15:0] add_in;
output reg [15:0] address_out;

always @ (posedge clk)
	begin

	if(add_enable==1 & add_strobe==0)
		begin
			address_out[7:0] <= add_in[7:0];
			
		end

	if(add_enable==1 & add_strobe==1)
		begin
			address_out[15:8] <= add_in[15:8];
			
		end


	end

endmodule
