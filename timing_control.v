//*****NOTE******
//IOR and IOW shall be a flag to the address pins that they will work as input
module timingcontrol(wrflag,MEMWR,cs,clk,HLDA,AEN,reset,IReady,TReady,IOR,IOW,IOflag); //IOflag for data is out from IO device

input cs,clk,HLDA,reset,wrflag;            //wrflag is a flag indicates wether the IO device will read or write
reg write;
output reg AEN;
inout TReady, IReady,MEMWR;        //IOW and IOR always input to the DMA but they are defined as inout because the are on the control bus
input IOR,IOW,IOflag;
reg iready,tready,memwr;

assign IReady = (HLDA)? iready: 1'bz;                           //when the DMA is a master
assign TReady = ((!IOR) || (!IOW))? tready :1'bz ;                         //When the DMA is a target and called by address from the processor
assign MEMWR = (HLDA)? memwr :1'bz ;                            

always @(posedge clk or posedge reset)  
begin
if (!cs) begin 
if (!reset)begin

   if (HLDA) begin AEN <=1; end
   else if (!HLDA) begin AEN <=0; end

   if (wrflag) begin
     memwr <=1;
        if (IOflag)begin
           iready <=1;
            @(posedge TReady);   //waiting for ack from memo
            iready<=0;
         end
     
   end
   else if (wrflag ==0) begin
      memwr <=0;
      iready<=1;
      @(posedge TReady); //waiting for memo to finish
      iready<=0;
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