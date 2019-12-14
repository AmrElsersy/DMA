/* This module is the read buffer register that is interconnected with read/write buffer that carries CA & 
   CWC registers and interanl data bus

   Each posedge of a clock the output 16-bit registers are changed by the new value of CA & CWC registers

*/

module ReadBuffer_RW_Bus(RB_currentAddress_out, RB_currentWordCount_out, CLK, RB_currentAddress_in, RB_currentWordCount_in);

input wire CLK;
input wire [15:0] RB_currentAddress_in, RB_currentWordCount_in;

output reg [15:0] RB_currentAddress_out, RB_currentWordCount_out;

always @(posedge CLK)
begin
RB_currentAddress_out <= RB_currentAddress_in;
RB_currentWordCount_out <= RB_currentWordCount_in;
end

endmodule