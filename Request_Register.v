module Request_Register (Request , Reset, CLK , IOR , Auto_Initialization, IOW, Address , DataBus,request_writed);

input Reset , Auto_Initialization , CLK ,IOR , IOW;
input wire [2:0] DataBus;
input wire [3:0] Address;
output reg [2:0] Request;

output reg request_writed;

/*initial
begin
Request <= 0;
end */

always@(Reset or Auto_Initialization)
	begin
		if( Reset || Auto_Initialization )
		Request <= 3'b0zz;
	end

always @(posedge CLK)
begin
	request_writed <= 1;
	if( (IOR == 1'b1) && (IOW == 1'b0) && (Address == 4'b1001) )
	begin
		Request <= DataBus;
	end
	else
		Request <=3'b000;

end

always @(negedge CLK)
begin
request_writed <= 0;
end

endmodule
