//*****NOTE******
//IOR and IOW shall be a flag to the address pins that they will work as input
module timingcontrol(wrflag,MEMWR,cs,clk,HLDA,AEN,reset,IReady,TReady,IOR,IOW,Address_Bus);

input cs,clk,HLDA,reset,wrflag;            //wrflag is a flag indicates wether the IO device will read or write
reg write;
output reg AEN;
inout TReady, IReady,IOR,IOW,MEMWR;         //IOW and IOR always input to the DMA but they are defined as inout because the are on the control bus
inout [15:0] Address_Bus;
reg [15:0] address;
reg iready,tready,memwr;
wire myBus;
parameter first = 32 , last = 48;           //address of Registers inside the DMA


assign myBus = (Address_Bus >= first && Address_Bus <= last);   //check if the DMA called by the processor
assign Address_Bus= (HLDA)? address: 'bz;                       //when the DMA is a master and takes the address bus
assign IReady = (HLDA)? iready: 1'bz;                           //when the DMA is a master
assign TReady = (myBus)? tready :1'bz ;                         //When the DMA is a target and called by address from the processor
assign MEMWR = (HLDA)? memwr :1'bz ;                            

always @(posedge clk or posedge reset)  
begin
if (cs) begin 
if (!reset)begin

   if (HLDA) begin AEN <=1; end
   else if (!HLDA) begin AEN <=0; end

   if (wrflag) begin
     memwr <=1;
     iready <=1;
     @(posedge TReady);   //waiting for ack from memo
     iready<=0;
   end
   else if (wrflag ==0) begin
      memwr <=0;
      iready<=1;
      @(posedge TReady);
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
wire[15:0] Address_Bus;

timingcontrol my(wrflag,MEMWR,cs,clk,HLDA,AEN,reset,IReady,TReady,IOR,IOW,Address_Bus);

always begin #10 clk=~clk; end

assign TReady = tready ;  //tready is input to the DMA here



initial begin
clk=1'b0;
cs=1'b1;
wrflag=1'b0;
tready = 1'b1;
HLDA=1'b1;
reset= 1'b0;
$monitor(" memwr: %b  wrflag: %b AEN: %b",MEMWR,wrflag,AEN);
end
endmodule 