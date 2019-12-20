module DATA_buffer(Data_bus_ex ,out_dataBuffer , in_dataBuffer , TReady,CS,IOR,IOW,MEMRW,MemToMem,RESET , clk,flag_data_ready,Data_flag,IReady,HLDA);

inout [7:0] Data_bus_ex;

input [7:0] in_dataBuffer ; 
input clk , RESET , TReady ,CS,IOR,IOW,MEMRW,MemToMem ,Data_flag,IReady,HLDA; 

output reg [7:0] out_dataBuffer ; 
output flag_data_ready;

reg [7:0] Data_bus;

//assign Data_bus_ex = (Data_flag==1) ? temp : (TReady && ((!CS)&&(!IOR)) ) ? in_dataBuffer : 8'hzz ; 
assign Data_bus_ex = (HLDA===1 && TReady===1 && ((CS === 0)&&(IOR === 0)) ) ? in_dataBuffer :(Data_flag === 1 && MEMRW === 1 && MemToMem === 1) ? Data_bus : 8'hzz ; 

assign flag_data_ready = (Data_flag) ? 1 : 0;

always @(posedge clk or RESET ,Data_flag)
begin
	if(RESET)
	  begin 
		Data_bus <= 0 ; 
	  end 
	else 
	 begin 
		
			if(((!CS)&&(!IOW)))
			out_dataBuffer = Data_bus_ex ; 
			
			else if(MemToMem&&(!MEMRW))
			begin
			@(posedge IReady)
			 Data_bus = Data_bus_ex;
			end
		
	 end
end

endmodule
