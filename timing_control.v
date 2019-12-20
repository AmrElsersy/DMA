//*****NOTE******
//IOR and IOW shall be a flag to the address pins that they will work as input
module timingcontrol(wrflag,MEMWR,cs,clk,HLDA,AEN,reset,IReady,TReady,IOR,IOW,IOflag,mem2mem,Data_flag,flag_data_ready,address_ready,processor_write_done,myBus,command_writed,request_writed,address_bus,TC); //IOflag for data is out from IO device

input cs,clk,HLDA,reset,wrflag,mem2mem,flag_data_ready,address_ready,myBus,processor_write_done,command_writed,request_writed;            //wrflag is a flag indicates wether the IO device will read or write
input [15:0] address_bus;

reg write;
output reg AEN,Data_flag=1;

inout TReady, IReady,MEMWR;        //IOW and IOR always input to the DMA but they are defined as inout because the are on the control bus
input IOR,IOW,IOflag,TC;
reg iready,tready,memwr;

wire myBus;

assign myBus = (address_bus >= 0 && address_bus <= 15);
assign IReady = (HLDA===1 && mem2mem===0)? iready: 1'bz;                           //when the DMA is a master
assign TReady = ((IOR===0) || (IOW===0))? tready :1'bz ;                         //When the DMA is a target and called by address from the processor
assign MEMWR = (HLDA)? wrflag :1'bz ;      

initial 
begin   
AEN <= 0;
end                   

always@ (posedge TC)begin
AEN=0;
end


always @(posedge IReady or posedge reset or posedge wrflag)  
begin



if (!cs) begin 

   if(!IOW&&IOR)
   begin
   @(posedge processor_write_done , posedge command_writed , posedge request_writed);
   tready = 1;
   @(negedge IReady);
   tready = 0;
   end
	
if (!reset)begin

   if (HLDA) begin AEN <=1; end
   else if (!HLDA ) begin AEN <=0; end

   if (wrflag===1 && HLDA===1) begin
     
        if (IOflag)begin
            memwr = 1;
           iready = 1;
 	   @(posedge TReady);   //waiting for ack from memo
           iready = 0;
	end
   	else if(mem2mem&&Data_flag&&MEMWR)
	 begin
           
         Data_flag = 1;
	 @(posedge flag_data_ready);
           memwr = 1;
	 iready = 1;
 	   @(posedge TReady);   //waiting for ack from memo
           iready = 0;
	   Data_flag = 0;
         end
     
   end
   else if (wrflag ===0 && HLDA===1) begin
      
      @(posedge address_ready);
       memwr =0;
      iready=1;
      @(posedge TReady); //waiting for memo to finish
      iready=0;
     end
 
end


else if (reset) begin
 memwr<=1'bz;
 AEN<=0;
end

end
end


endmodule 

module tbtiming();
reg cs,reset,clk,wrflag,HLDA,iready,tready;
wire AEN,IReady,TReady,MEMWR;
reg IOflag;

timingcontrol my(wrflag,MEMWR,cs,clk,HLDA,AEN,reset,IReady,TReady,IOR,IOW,IOflag);

always begin #10 clk=~clk; end

assign TReady = tready ;  //tready is input to the DMA here



initial begin
clk=1'b0;
cs=1'b1;
wrflag=1'b0;
tready = 1'b1;
HLDA=1'b1;
reset= 1'b0;
IOflag= 1'b1;
$monitor(" memwr: %b  wrflag: %b AEN: %b",MEMWR,wrflag,AEN);
end
endmodule 