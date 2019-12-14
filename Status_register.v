module STATUS_reg(clk,Status,address_in,IOR,IOW);

output [5:0] Status;

input [3:0] address_in;

input IOR,IOW,clk;

reg [7:0] status;

assign Status = (address_in == 8 && IOW == 1 && IOR == 0 && clk == 1) ? status : 6'bzzzzzz;

endmodule
