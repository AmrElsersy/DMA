module IO_buffer(address_in,address_bus,clk,Reset,AEN,out_address,conc_flag_out);

input clk,Reset,AEN,conc_flag_out;

input [15:0] address_in;

inout [15:0] address_bus;

output wire [3:0] out_address ; 

reg [15:0] Address;

assign address_bus = (AEN) ? Address : 16'hzzzz;
assign out_address =  Address[3:0];

always @(posedge clk or Reset)
begin

if(Reset)
Address <= 0;

else
begin

	if(address_bus >= 0 && address_bus <= 7)
	begin

		if(conc_flag_out)
			Address = address_bus;

		else if(conc_flag_out==0)
			Address = Address;

	end


	else
	Address = address_in;

end
end

endmodule
