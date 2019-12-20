module write_buffer(clk,RESET, word_count, address, data_bus,conc_flag_out);

input clk ,RESET;
input [7:0] data_bus;
output reg [15:0] address, word_count;
output reg conc_flag_out;
//reg [15:0] address_conc , word_count_conc; 
reg flag ; // flag indicationg num of word    0: 1st half word      1: 2nd half word 


initial 
begin 
flag <= 0 ;
conc_flag_out <=0 ; 
end 


//assign address = (flag)? ((address_conc<<8)||address_conc) : (address_conc) ; 

always @ (posedge clk or posedge RESET )// data bus in the always 

	begin
             if(RESET) 
              begin 
                address<= 0  ;
                word_count <= 0 ; 
                flag <= 0 ; 
		conc_flag_out<=0 ; 
               end 
             else 
              begin 
		
                   if(flag == 0)
                     begin 
                        address <= data_bus;
	                word_count<= data_bus;
			conc_flag_out <=0 ; 
                        flag <= 1; 
		    end	
		    else if(flag == 1)
                     begin 
			address = ((address<<8)|data_bus);
	                word_count = ((word_count<<8)|{8'h00,data_bus});
                        conc_flag_out =1 ; 
                        flag =0 ; 
			end
              end   



	end



endmodule
