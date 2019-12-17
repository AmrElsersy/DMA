module ReadWrite_buffer(clk,AEN,IOW,IOR,address_in_4,TC,MEMWR,add_inc_dec,autoinitialization,ch_select,address_WB,word_WB,base_address,base_word,CURRENT_address,Read_buffer,conc_flag_out,IOflag,mem2mem,flag_mem);

/*  (clock) is used to to make the current address in th register for each channel synchronous

    (autoinitialization) bit in mode register is to make the current address and word count equal the base
    to restart the transfer 	

    (add_inc_dec) bit in mode register to select if the address will increase or decrease for
    example if the base address 0xab00 and the word count 100 , it will go 0xab01 or aaff and so on
     
	*/

input clk,autoinitialization,add_inc_dec,MEMWR,IOR,IOW,AEN,conc_flag_out,IOflag,mem2mem;
input [3:0] address_in_4;

/*    ch_select is an input know which channel is requested   
	*/

input [1:0] ch_select;

/*    (base_address) is the initial(first address that will be data read or write to memory 
      (address_WB) is the address where the processor initailize(program) the address of the channel
      (base_word) is the number of transfers that io device will preform
	*/

input [15:0] address_WB,word_WB,base_address,base_word;

/*    (CURRENT_address) is the address which point to the current location of the memory to be read or write
      (CURRENT_word) is the number of word that the device will read or write from memory
	*/

output reg [15:0] CURRENT_address,Read_buffer;

/*    TC signal to be stored in status register
	*/
output reg TC;

/*    Array of 4 channel address and word count to hold the current address and count during the transfer
	*/

reg [15:0] current_address [0:3];
reg [15:0] current_word [0:3];

output reg flag_mem = 0;

reg [1:0] hold = 0;

// teminate the process
//assign TC = (current_word[ch_select] == 0) ? 1 : 0;

initial
begin
current_address[0] <= 16'h0064;
current_word[0] <= 10;
current_address[1] <= 16'h012c;
current_word[1] <= 10;
end

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
if(AEN)
begin
if(hold == 3)
begin
hold = 0;
end
if(hold == 1)
begin
hold = hold + 1;
end
// if number of current words equal zero it will teminate the process 
// and the address will be on the bus when control signal become not floating ( connected to the bus)
if(current_word[ch_select] > 0 && IOflag == 1)
begin
// always decrement the word numbers and update the table
current_word[ch_select] <= current_word[ch_select] - 1;
//if the address is decremented 
if(add_inc_dec == 1)
begin
current_address[ch_select] <= current_address[ch_select] - 4;
CURRENT_address <= current_address[ch_select];
end

//if the address is incremented 
else if(add_inc_dec == 0)
begin
current_address[ch_select] <= current_address[ch_select] + 4;
CURRENT_address <= current_address[ch_select];
end

end

else if(current_word[flag_mem] > 0 && mem2mem == 1 && (hold == 0||hold == 2))
begin
hold <= hold + 1 ;
if(flag_mem == 0)
begin

// always decrement the word numbers and update the table
current_word[flag_mem] <= current_word[flag_mem] - 1;
flag_mem <= 1;
//if the address is decremented 
if(add_inc_dec == 1)
begin
current_address[flag_mem] <= current_address[flag_mem] - 4;
CURRENT_address <= current_address[flag_mem];
end

//if the address is incremented 
else if(add_inc_dec == 0)
begin
current_address[flag_mem] <= current_address[flag_mem] + 4;
CURRENT_address <= current_address[flag_mem];
end

end

else if(flag_mem == 1)
begin

// always decrement the word numbers and update the table
current_word[flag_mem] <= current_word[flag_mem] - 1;
flag_mem <= 0;
//if the address is decremented 
if(add_inc_dec == 1)
begin
current_address[flag_mem] <= current_address[flag_mem] - 4;
CURRENT_address <= current_address[flag_mem];
end

//if the address is incremented 
else if(add_inc_dec == 0)
begin
current_address[flag_mem] <= current_address[flag_mem] + 4;
CURRENT_address <= current_address[flag_mem];
end

end

end

else if(current_word[ch_select] == 0) 
begin
TC<=1 ; 
end 

end

end

always @(posedge clk)
begin

if(address_in_4 == 0 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_address[0] <= address_WB;
else if(address_in_4 == 0 && IOW == 1 && IOR == 0)
Read_buffer <= current_address[0];
else if(address_in_4 == 1 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_word[0] <= word_WB;
else if(address_in_4 == 1 && IOW == 1 && IOR == 0)
Read_buffer <= current_word[0];

else if(address_in_4 == 2 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_address[1] <= address_WB;
else if(address_in_4 == 2 && IOW == 1 && IOR == 0)
Read_buffer <= current_address[1];
else if(address_in_4 == 3 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_word[1] <= word_WB;
else if(address_in_4 == 3 && IOW == 1 && IOR == 0)
Read_buffer <= current_word[1];


else if(address_in_4 == 4 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_address[2] <= address_WB;
else if(address_in_4 == 4 && IOW == 1 && IOR == 0)
Read_buffer <= current_address[2];
else if(address_in_4 == 5 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_word[2] <= word_WB;
else if(address_in_4 == 5 && IOW == 1 && IOR == 0)
Read_buffer <= current_word[2];

else if(address_in_4 == 6 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_address[3] <= address_WB;
else if(address_in_4 == 6 && IOW == 1 && IOR == 0)
Read_buffer <= current_address[3];
else if(address_in_4 == 7 && IOW == 0 && IOR == 1 && conc_flag_out == 1)
current_word[3] <= word_WB;
else if(address_in_4 == 7 && IOW == 1 && IOR == 0)
Read_buffer <= current_word[3];

end
endmodule
