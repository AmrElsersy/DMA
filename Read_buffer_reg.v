module READ_buffer_base(clk,IOR,IOW, address_in , base_address , base_word , base_address_out,base_word_out, ch_select,conc_flag_out);

input clk,IOR,IOW,conc_flag_out;

input [1:0] ch_select;

input [3:0] address_in;

input [15:0] base_address,base_word;

output wire [15:0] base_address_out,base_word_out;

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
end

always @ (posedge clk)
begin

if(conc_flag_out)
begin

if(address_in == 0 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_address_reg[0] <= base_address;

else if(address_in == 1 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_word_reg[0] <= base_word;

else if(address_in == 2 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_address_reg[1] <= base_address;

else if(address_in == 3 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_word_reg[1] <= base_word;

else if(address_in == 4 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_address_reg[2] <= base_address;

else if(address_in == 5 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_word_reg[2] <= base_word;

else if(address_in == 6 && IOR == 1 && IOW == 0 && conc_flag_out == 1)
base_address_reg[3] <= base_address;

else if(address_in == 7 && IOR == 1 && IOW == 0)
base_word_reg[3] <= base_word;

end

end

endmodule
