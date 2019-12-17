module Command_Register (out_commandWire , in_commandReg , Auto_Intialization , address , IOR , IOW ,RESET , EOP , clk ) ;

input wire clk , Auto_Intialization , RESET , EOP , IOR , IOW ; 
input wire [7:0]in_commandReg;
input wire [3:0] address ; 
output wire [7:0] out_commandWire ; 

reg [7:0] out_commandReg;

assign out_commandWire = out_commandReg;

initial
begin
	out_commandReg<= 8'b1100_0001 ; 
end

always @(posedge clk or RESET )
begin 
if(address == 8 && IOR == 1 && IOW == 0)begin 
    if (in_commandReg[2]==1'b1) begin
// Command register word for disable DMA controller, refer command word format 
     out_commandReg <= 0'b000_0100 ; 
   end 
  else
    out_commandReg <= in_commandReg; 
  end 

else
begin
if(RESET || (!EOP)) begin 
out_commandReg <= 8'b0000_0000 ; 
end 

else if (Auto_Intialization) begin 
/*Command register word to initialize DMA controller
 * D7:DACK active high 
 * D6:DREQ active high 
 * D5:extended write selection 
 * D4:Fixed priority 
 * D3:normal timing 
 * D2:DMA Controller enable 
 * D1:Channel-0 address hold disables
 * D0:Memory-to-memory enables
 */
out_commandReg <= 8'b1100_0001 ; // 0xC1
end // end of else if


end

end  // end of always 
endmodule 
