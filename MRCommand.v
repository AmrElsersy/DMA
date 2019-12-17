/* Mask register module is a register accessed as a whole to set or clear the 4 channels
   by a single command and outputs a 4-bit register to priority block
   
   0=======> enable the channel
   1=======> disable the channel

   All channels are unmaksed initially 

   This register un masks all channels when an autoinitialize singal is written to logic 1
   and disables (masks) all channels when resest signal is written to logic 1

   If the mask register is addressed ========> A3 A2 A1 A0 = 1 1 1 1 &
   IOR = 1 & IOW = 1 & ChipSelect = 0 as IOW&IOR are active low  
   
   Each posedge of a clock the  4-bit register output are changed by either last value of  
   the register if the register isn't addressed or by a new masking values for channels 
   if the register is addressed
   
*/

module Mask_Register(maskedChannels,CLK,IOR,IOW,address_in,autoInitalization,reset,accessAllCommand);


input wire reset,autoInitalization;
input wire CLK;
input wire IOR,IOW;
input wire [3:0] address_in;

input wire [3:0] accessAllCommand;
output reg [3:0] maskedChannels;


initial 
begin
maskedChannels = 4'b0000;
end


always @(reset)
begin
if(reset)
maskedChannels <= 4'b1111;
end


always @(posedge CLK)
begin
     if (address_in== 4'b1111 && IOW== 1'b0 && IOR== 1'b1)
        begin 
                maskedChannels <= accessAllCommand ;
        end 
    else if (autoInitalization)
         begin 
                maskedChannels <=  4'b0000; 
         end 
end

endmodule

