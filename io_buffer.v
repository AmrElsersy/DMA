module IO_buffer(address_in,address_bus,clk,Reset,AEN,out_address,conc_flag_out,TReady,IReady,address_ready,MemToMem,HLDA);

input clk,Reset,AEN,conc_flag_out,TReady,IReady,MemToMem,HLDA;

input [15:0] address_in;

inout [15:0] address_bus;

output wire [3:0] out_address ; 

output reg address_ready;

reg [15:0] Address;

assign address_bus = (AEN) ? Address : 16'hzzzz;
assign out_address =  Address[3:0];
assign IReady = ( HLDA===1 && MemToMem===1 )? address_ready : 1'bz ; 


always @(posedge clk or Reset)
begin

if(Reset)
Address <= 0;

else
begin

	if(address_bus >= 0 && address_bus <= 7)
	begin

		if(conc_flag_out == 0)
			Address = address_bus;

		else if(conc_flag_out)
			Address = Address;

	end

	else if(address_bus >= 8 && address_bus <= 15)
	begin
	Address = address_bus;
	end
	
	else
	begin
	Address = address_in;
	address_ready = 1;
	@(posedge IReady)
	Address = address_in;
	address_ready = 0;
	end
end
end

endmodule

