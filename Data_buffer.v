module DATA_buffer(Data_bus_ex ,out_dataBuffer , in_dataBuffer , TReady,CS,IOR,IOW,MEMRW,MemToMem,RESET , clk);

inout [7:0] Data_bus_ex;

input [7:0] in_dataBuffer ; 
input clk , RESET , TReady ,CS,IOR,IOW,MEMRW,MemToMem ; 

output reg [7:0] out_dataBuffer ; 

reg [7:0] Data_bus;

assign Data_bus_ex = (TReady && ((!CS)&&(!IOR)) ) ? in_dataBuffer : (MemToMem&&MEMRW) ? Data_bus : 8'hzz ; 

always @(posedge clk or RESET)
begin
	if(RESET)
	  begin 
		Data_bus <= 0 ; 
	  end 
	else 
	 begin 
		
			if(((!CS)&&(!IOW)))
			out_dataBuffer <= Data_bus_ex ; 
			
			else if(MemToMem&&(!MEMRW))
			begin
			 Data_bus<= Data_bus_ex;
			end
		
	 end
end

endmodule
