module IO (Data_Bus , Address_Bus ,IReady,TReady,clk   , DREQ , DACK , IOW , IOR , CPU_Event);

reg[7:0] Memory[0:31];

// ******* DMA ************
output reg DREQ;
input wire DACK;
input wire CPU_Event;
// ******* Bus ************
inout wire[7:0] Data_Bus;
inout wire[15:0] Address_Bus;
inout wire IOW , IOR , IReady , TReady ;
input wire clk;
// ******* Bus_Registers *********
reg tready ;
reg[7:0] data_bus ;
// ****** parameters ***********
parameter first = 1001 , last = 1032; integer i ;
// ******* Chip Select ******
wire CS; 
assign CS = ( Address_Bus >= first && Address_Bus <= last ) ;
// ******* Assign inout **********
assign TReady =  (CS)? tready : 'bz ;
assign Data_Bus = ( (IOR  && CS) || (DACK && IOR) )? data_bus : 'bz ;	

// ============ Normal CPU Read/Write ============
always@(posedge IReady)
begin
$display("IO_CS=%0d,DREQ=%d,DACK=%d",CS,DREQ,DACK);
if (CS && !DACK ) begin
	if (IOW) begin // write
		Memory[Address_Bus-first] = Data_Bus; // store the Data_Bus in the Address location in memory
		tready = 1;		// triger the slave ack
		@(negedge IReady);	// wait for ack of master 
		tready = 0;		// make TReady = 0 to know that bus operation is finished
		end
	else if ( IOR ) begin  // read
		data_bus = Memory[Address_Bus-first]; // put data in the Data_Bus 
		tready = 1;		// triger slave ack that indicates that data is ready on the bus
		@(negedge IReady);	// wait for master ack that indicates that he received the data
		tready = 0;		// operation is finished
		end
	$display("Address=%d,Data=%d,IOR=%d,IOW=%d",Address_Bus,Data_Bus,IOR,IOW);
end // if
end // always
// =================================================

// ============ DMA IO-to-Memory Transfer (Write Transfer ===================
always @(posedge DACK)
begin
	// IO to Memory Transfer (DMA Write Transfer)
	if(IOR) // IOR				// we need to make the IO Device puts the data in the data_bus without controlling the "TReady" Signal .. it is not a normal read operation
		begin				
 		data_bus = Memory[3] ;		// assign data_bus to Memory[0] . 0 can be any special index we choose to read from it always
	$display("Address=%d,Data=%d,IOR=%d,IOW=%d",Address_Bus,Data_Bus,IOR,IOW);

		@(posedge TReady);		// wait for TReady comming from Memory for Successfull Operation
		end

end
// ==========================================================================
// ****** CPU Trigger ****
always@(posedge CPU_Event)
begin DREQ = 1 ; end
// ****** INITIAL ********
initial
begin
tready = 0  ;
DREQ = 0;
for(i =0 ; i< 31 ; i = i+1) begin Memory[i] = 2*i; end
end

endmodule 


module tb_IO();

// ************ Clock *************
reg clk ;
// ************ RAM ***************
wire[7:0] Data_Bus;
wire[15:0] Address_Bus;
wire IOR , IOW , IReady , TReady ;
reg CPU_Event;

reg iready , tready , iow,ior;
reg [7:0] data ; 
reg [15:0 ] add ;
integer i ;

wire DREQ;
reg DACK ;

always begin #10 clk = ~clk; end
IO Keyboard(Data_Bus , Address_Bus ,IReady,TReady,clk   , DREQ , DACK , IOW , IOR , CPU_Event);

assign IReady 		= iready ; 
assign IOW 		= iow; 
assign IOR 		= ior; 
assign Address_Bus 	= add ;
assign Data_Bus 	= (IOW)? data : 'bz ; 

initial 
begin
#1
CPU_Event = 1 ;
@(posedge DREQ);
ior = 1; iow = 0;
add = 1003;

DACK = 1;
iready = 1;
//@(posedge TReady);
#2
$display("DataComming=%d",Data_Bus);
iready = 0;

end

endmodule 