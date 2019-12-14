//*****NOTE******
//in case IOR, IOW these are inputs to the big module of all modules, to select wether I will read from A0-A3 and check which address of my registers in the DMA or will I work A0-A3 as output
module timingcontrol(wrflag,memread,memwrite,cs,clk,ready,HLDA,AEN,reset);
input cs,clk,ready,HLDA,reset,wrflag; //wrflag is a flag indicates wether the IO device will read or write
reg write;
output reg memread,memwrite,AEN;

always @(wrflag) //not used now
write <= wrflag;

always @(posedge clk)
begin
if (!cs) begin 
if (!reset)begin

 if (HLDA) begin AEN <=1; end
 else if (!HLDA) begin AEN <=0; end

 if (!ready) begin
   if (wrflag) begin
     memread <= 0;
     memwrite <=1;
   end
   else if (wrflag ==0) begin
      memread <=1;
      memwrite <=0;
     end
 end

 else if(ready) begin
 memread<=0;
 memwrite<=0;
 end
end


else if (reset) begin
 memread<=0;
 memwrite<=0;
 AEN<=0;
end

end
end

always @(negedge clk)
begin
memread<=0;
memwrite<=0;
end

endmodule 

module tbtiming();
reg cs,reset,clk;
reg wrflag;
reg ready;
reg HLDA;
wire memread,memwrite;
wire AEN;
timingcontrol my(wrflag,memread,memwrite,cs,clk,ready,HLDA,AEN,reset);
always begin #5 clk=~clk; end
initial begin
clk=1'b0;
cs=1'b0;
wrflag=1'b1;
ready=1'b1;
HLDA=1'b1;
reset= 1'b0;
$monitor("memread: %b memwr: %b ready: %b wrflag: %b AEN: %b",memread,memwrite,ready,wrflag,AEN);
end
endmodule 