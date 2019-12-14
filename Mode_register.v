module MODE_reg(clk,Mode,address_in,IOR,IOW,ch_select);

inout [5:0] Mode;

input [3:0] address_in;
input [1:0] ch_select;
input IOR,IOW,clk;

reg [5:0] mode [0:3];

assign Mode = (clk == 1) ? mode[ch_select] : 6'bzzzzzz;

always @(posedge clk)
begin
if(address_in == 11 && IOW == 0 && IOR == 1)
begin
mode[ch_select] <= Mode;
end
end

endmodule
