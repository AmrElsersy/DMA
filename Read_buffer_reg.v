module READ_buffer_base(clk,IOR,IOW, address_in , base_address , base_word , base_address_out,base_word_out, ch_select,conc_flag_out,myBus,processor_write_done);

input clk,IOR,IOW,conc_flag_out,myBus;

input [1:0] ch_select;

input [3:0] address_in;

input [15:0] base_address,base_word;

output wire [15:0] base_address_out,base_word_out;

output reg processor_write_done;

reg [15:0] base_address_reg [0:3];
reg [15:0] base_word_reg [0:3];

assign base_address_out = base_address_reg[ch_select];
assign base_word_out = base_word_reg[ch_select];

initial
begin
base_address_reg[0] <= 16'h0064;
base_word_reg[0] <= 10;
base_address_reg[1] <= 16'h012c;
base_word_reg[1] <= 10;
base_address_reg[2] <= 16'h190;
base_word_reg[2] <= 2;
end

always @ (posedge clk)
begin
processor_write_done = 1;

if(IOR == 1 && IOW == 0)
begin 
	case(address_in)
	0:base_address_reg[0] = base_address;
	1:base_word_reg[0] = base_word;
	2:base_address_reg[1] = base_address;
	3:base_word_reg[1] = base_word;
	4:base_address_reg[2] = base_address;
	5:base_word_reg[2] = base_word;
	6:base_address_reg[3] = base_address;
	7:base_word_reg[3] = base_word;
	endcase
	
end 

/*
if(address_in == 0 && IOR == 1 && IOW == 0)
base_address_reg[0] = base_address;

else if(address_in == 1 && IOR == 1 && IOW == 0 )
base_word_reg[0] = base_word;

else if(address_in == 2 && IOR == 1 && IOW == 0)
base_address_reg[1] = base_address;

else if(address_in == 3 && IOR == 1 && IOW == 0)
base_word_reg[1] = base_word;

else if(address_in == 4 && IOR == 1 && IOW == 0 )
base_address_reg[2] = base_address;

else if(address_in == 5 && IOR == 1 && IOW == 0 )
base_word_reg[2] = base_word;

else if((address_in == 6) && IOR == 1 && IOW == 0)
base_address_reg[3] = base_address;

else if( (address_in == 7 )&& IOR == 1 && IOW == 0)
base_word_reg[3] = base_word;

*/
end

always @(negedge clk)
begin
processor_write_done = 0;
end

endmodule
