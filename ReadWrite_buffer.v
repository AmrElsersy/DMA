module ReadWrite_buffer(clk,TC,MEMR,MEMW,add_inc_dec,autoinitialization,ch_select,Temp_word_address,address_WB,base_address,base_word,CURRENT_address,CURRENT_word);

/*  (clock) is used to to make the current address in th register for each channel synchronous

    (autoinitialization) bit in mode register is to make the current address and word count equal the base
    to restart the transfer 	

    (add_inc_dec) bit in mode register to select if the address will increase or decrease for
    example if the base address 0xab00 and the word count 100 , it will go 0xab01 or aaff and so on
     
	*/

input clk,autoinitialization,add_inc_dec,MEMW,MEMR;

/*    Temp_word_address is 
	*/

inout [15:0] Temp_word_address;

/*    ch_select is an input from mode register to know which channel is requested   
	*/

input [1:0] ch_select;

/*    (base_address) is the initial(first address that will be data read or write to memory 
      (address_WB) is the address where the processor initailize(program) the address of the channel
      (base_word) is the number of transfers that io device will preform
	*/

input [15:0] address_WB,base_address,base_word;

/*    (CURRENT_address) is the address which point to the current location of the memory to be read or write
      (CURRENT_word) is the number of word that the device will read or write from memory
	*/

output reg [15:0] CURRENT_address,CURRENT_word;

/*    TC signal to be stored in status register
	*/
output TC;

/*    Array of 4 channel address and word count to hold the current address and count during the transfer
	*/

reg [15:0] current_address [0:3];
reg [15:0] current_word [0:3];

// teminate the process
assign TC = (current_word[ch_select] == 0) ? 1 : 0;


/*    this block to restore the initial value of the address and count
	*/

always @ (autoinitialization)
begin 
if(autoinitialization)
begin
current_address[ch_select] <= base_address;
current_word[ch_select] <= base_word;
end
end

/*    this block to increment or decrement the address and decrement the word every clock cycle
	*/

always @ (posedge clk)
begin 
// if number of current words equal zero it will teminate the process 
// and the address will be on the bus when control signal become not floating ( connected to the bus)
if((MEMR == 1 || MEMW == 1) && current_word[ch_select] > 0)
begin
// always decrement the word numbers and update the table
current_word[ch_select] <= current_word[ch_select] - 1;
CURRENT_word <= current_word[ch_select];
//if the address is decremented 
if(add_inc_dec == 1)
begin
current_address[ch_select] <= current_address[ch_select - 4];
CURRENT_address <= current_address[ch_select - 4];
end
//if the address is incremented 
else if(add_inc_dec == 0)
begin
current_address[ch_select] <= current_address[ch_select + 4];
CURRENT_address <= current_address[ch_select + 4];
end
end
end

endmodule
