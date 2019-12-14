module IO_Buffer (CLK , Address, IO_Register);

input CLK;
inout wire [3:0] Address;
output reg IO_Register;

always @(posedge CLK)
	begin
		IO_Register <= Address;
	end

endmodule