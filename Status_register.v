module STATUS_reg(clk,Status,address_in,IOR,IOW);

output reg [5:0] Status;

input [3:0] address_in;

input IOR,IOW,clk;

reg [7:0] status;

always @(posedge clk)
begin
if(address_in == 8 && IOW == 1 && IOR == 0)
Status <= status;
end

endmodule
