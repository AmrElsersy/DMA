module temporary(Data,clk,mem2mem);
inout [7:0] Data;
reg [7:0] temp;
reg [7:0] data_out;
input clk,mem2mem;
reg flag ;

assign Data  = (mem2mem && flag) ? data_out : 8'bz;                    //data pins will work as output 

initial begin flag=0; end

always @(posedge clk)
begin
	if(!flag && mem2mem) begin temp <= Data; flag <= 1; end          //saves the data into the temp reg
	else if (flag && mem2mem) begin data_out <= temp; flag<=0; end   //output the data from the temp reg
end
endmodule 

module tbtemp();
reg clk,flag,mem2mem;
wire [7:0] Data;
reg [7:0] data_reg;
temporary temp(Data,clk,mem2mem);

assign Data = (mem2mem && !flag)? data_reg: 8'bz;
always begin #5 clk=~clk; end

initial begin
clk=1'b0;
mem2mem = 1'b1;

//writing data
data_reg = 8'b1;
flag=1'b0;
#10;


//reading data
//flag=1'b1;
//#10;

end
endmodule
