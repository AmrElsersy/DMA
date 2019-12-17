module Read_buffer_current(current_in,current_out,clk,RESET,conc_flag_out);

input clk,RESET,conc_flag_out;

input [15:0] current_in;

output reg [7:0] current_out;

always @(posedge clk or RESET)
begin
if(RESET)
current_out <= 0;
else
	if(conc_flag_out == 0)
		current_out <= current_in[7:0];
	else if(conc_flag_out == 1)
		current_out <= current_in[15:8];
end

endmodule
