module computer_arch();
reg clk,CS,Reset;
/* **********wires********** */
wire [7:0] Data_Bus;
wire [3:0] DREQ,DACK;
wire [15:0] Address_Bus;
wire MEMWR,HLDA,HRQ,TReady,IReady,EOP,AEN,IOR,IOW,IOflag,CPU_Event;
reg [31:0] first_1 = 600 , last_1 = 632  , first_2=633,last_2=665 ; 
/* **********wires********** */
initial begin
clk = 0 ; 
CS = 0;
Reset = 0;
end


MIPS processor(Data_Bus,Address_Bus,MEMWR,IReady , TReady ,clk , HRQ , HLDA, IOW, IOR, CS);

DMA dma(EOP,Reset,CS,IReady,TReady,clk,AEN,MEMWR,IOR,IOW,DREQ,HLDA,HRQ,DACK,Address_Bus,Data_Bus,IOflag);

IO keyboard(Data_Bus ,clk,Address_Bus ,IReady,TReady,DREQ[2] , DACK[2] ,CPU_Event, IOflag , MEMWR,first_2,last_2);
IO printer(Data_Bus ,clk,Address_Bus ,IReady,TReady,DREQ[2] , DACK[2] ,CPU_Event, IOflag , MEMWR,first_1,last_1);

RAM ram(Data_Bus,Address_Bus,MEMWR,IReady,TReady,clk);


always begin #50 clk = ~clk; end

endmodule

module computer_arch_memtomem(clk,CS,Reset,HLDA);

input clk,CS,Reset,HLDA;

/* **********wires********** */

wire [7:0] Data_Bus;
wire [3:0] DREQ,DACK;
wire [15:0] Address_Bus;
wire MEMWR,HLDA,HRQ,TReady,IReady,EOP,AEN,IOR,IOW,IOflag,CS,Reset;

/* **********wires********** */

//MIPS processor(Data_Bus,Address_Bus,MEMWR,IReady,TReady,clk,HRQ,HLDA);

DMA dma(EOP,Reset,CS,IReady,TReady,clk,AEN,MEMWR,IOR,IOW,DREQ,HLDA,HRQ,DACK,Address_Bus,Data_Bus,IOflag);

RAM ram(Data_Bus,Address_Bus,MEMWR,IReady,TReady,clk);

endmodule

module tb_mem2mem();
reg clk = 0;
reg CS,Reset,HLDA;
initial begin
clk <= 0 ; 
CS <= 0;
Reset <= 0;
HLDA <= 1;
end

always begin #50 clk = ~clk; end


computer_arch_memtomem comp(clk,CS,Reset,HLDA);

endmodule 
