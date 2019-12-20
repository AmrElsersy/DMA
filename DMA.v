module DMA(EOP,Reset,CS,IReady,TReady,clk,AEN,MEMWR,IOR,IOW,DREQ,HLDA,HRQ,DACK,Address,Data,IOflag);

input CS,Reset,clk,HLDA,IOflag;

input [3:0] DREQ;

output HRQ,AEN;

output [3:0] DACK;

inout [15:0] Address;

inout [7:0] Data;

inout EOP,IReady,TReady,MEMWR,IOR,IOW;



/* ************** wires ****************** */
wire [7:0] command_out;
wire [3:0] mask_out;
wire [5:0] mode_out;
wire [7:0] temporary_reg;
wire [2:0] request_out;
wire [7:0] Data_buffer_out;
wire [7:0] Data_buffer_in;
wire [1:0] ch_select;
wire status_tc , conc_flag_out,flag_mem,Data_flag,flag_data_ready,address_ready,myBus,processor_write_done,command_writed,request_writed;
wire [15:0] address_WB,word_WB,base_address_out,base_word_out;
wire [3:0] out_address;
wire [15:0] Read_buffer;
wire [15:0] CURRENT_address;


/************* Registers*****************/ 
reg [7:0] status ; 


always @(posedge clk)
begin
status[ch_select] <= status_tc;
end

Priority priority(HRQ , DACK , HLDA , DREQ , {command_out[7:6],command_out[4]} , request_out , mask_out, ch_select ,Reset , clk,command_out[0] ,status_tc);

Command_Register com_reg(command_out , Data , mode_out[4] , Address[3:0] , IOR , IOW ,Reset , EOP , clk, command_writed) ;  

Mask_Register mask_reg(mask_out,clk,IOR,IOW,out_address,mode_out[4],Reset,Data_buffer_out[3:0]);

Request_Register req_reg(request_out , Reset, clk , IOR , mode_out[4], IOW, out_address , Data_buffer_out[2:0],request_writed);

MODE_reg mode_reg(clk,Data_buffer_out[7:2],Address[3:0],IOR,IOW,ch_select,mode_out,command_out[0],flag_mem);

ReadWrite_buffer readwrite_buf(clk,AEN,IOW,IOR,out_address,status_tc,MEMWR,mode_out[3],mode_out[2],ch_select,address_WB,word_WB,base_address_out,base_word_out,CURRENT_address,Read_buffer,conc_flag_out,IOflag,command_out[0],flag_mem,myBus);

IO_buffer io_address_buffer(CURRENT_address,Address,clk,Reset,AEN,out_address,conc_flag_out,TReady,IReady,address_ready,command_out[0],HLDA);

READ_buffer_base read_buf_base(clk,IOR,IOW, out_address , address_WB , word_WB , base_address_out,base_word_out, ch_select,conc_flag_out,myBus,processor_write_done);

write_buffer write_buf(clk,Reset, word_WB, address_WB, Data_buffer_out,conc_flag_out);

DATA_buffer data_buf(Data ,Data_buffer_out , Data_buffer_in , TReady,CS,IOR,IOW,MEMWR,command_out[0],Reset , clk,flag_data_ready,Data_flag,IReady,HLDA);

Read_buffer_current rf_current(Read_buffer,Data_buffer_in,clk,Reset,conc_flag_out);

timingcontrol tim_control(mode_out[0],MEMWR,CS,clk,HLDA,AEN,Reset,IReady,TReady,IOR,IOW,IOflag,command_out[0],Data_flag,flag_data_ready,address_ready,processor_write_done,myBus,command_writed,request_writed,Address,status_tc);

endmodule
