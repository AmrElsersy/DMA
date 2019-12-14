//counts is the no of words you want to transfer
module temporary(Data,clk,counts);
inout [7:0] Data;
reg [7:0] temp;
reg [7:0] data_out;
input clk,counts;

assign Data  = (!counts) ? data_out : 8'bz; //data pins will work as output

always @(posedge clk)
begin
	if(counts) begin temp <= Data; end
	else if (!counts) begin data_out <= temp; end
end
endmodule 

module tbtemp();
reg clk,counts;
wire [7:0] Data;
reg [7:0] data_reg;
temporary temp(Data,clk,counts);

assign Data = (counts)? data_reg: 8'bz;
always begin #5 clk=~clk; end

initial begin
clk=1'b0;

//writing data
data_reg = 8'b1;
counts=1;
#50;
data_reg = 8'b10101111;
counts=1;
#20;

//reading data
counts=0;
#20;

end
endmodule
