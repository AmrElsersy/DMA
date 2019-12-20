module IO (Data_Bus ,clk,Address_Bus ,IReady,TReady,DREQ , DACK ,CPU_Event, IOflag , Control , first ,last);

reg [7:0] Memory [0:31];
input wire[31:0] first,last;
// ******* DMA ************
output reg DREQ,IOflag;
input wire DACK;
input wire CPU_Event;
// ******* Bus ************
inout wire[7:0] Data_Bus;
inout wire[15:0] Address_Bus;
inout wire Control;
input wire clk;
inout IReady,TReady;
// ******* Bus_Registers *********
reg tready ;
reg [7:0] data_bus ;
// ****** parameters ***********
integer i ;
// ******* Chip Select ******
wire CS; 

// ******* Assign inout **********
assign CS = (Address_Bus>= first && Address_Bus <= last) ;
assign Data_Bus = (CS && Control === 0)? data_bus : 'bz ;	
assign TReady = (CS === 1) ? tready : 'bz;
// ============ Normal CPU Read/Write ============
always@(posedge IReady)
begin
$display("IO_CS=%0d,DREQ=%d,DACK=%d",CS,DREQ,DACK);
if (CS) begin
	if (Control === 1) begin // write
		Memory[Address_Bus-first] = Data_Bus; // store the Data_Bus in the Address location in memory
		tready = 1;		// triger the slave ack
		@(negedge IReady);	// wait for ack of master 
		tready = 0;		// make TReady = 0 to know that bus operation is finished
		end
	else if ( Control === 0 ) begin  // read
		data_bus = Memory[Address_Bus-first]; // put data in the Data_Bus 
		tready = 1;		// triger slave ack that indicates that data is ready on the bus
		@(negedge IReady);	// wait for master ack that indicates that he received the data
		tready = 0;		// operation is finished
		end
end // if
end  // always 
// =================================================

// ============ DMA IO-to-Memory Transfer (Write Transfer ===================
always @(posedge DACK)
begin
	// IO to Memory Transfer (DMA Write Transfer)
data_bus = Memory[0] ;		// assign data_bus to Memory[0] . 0 can be any special index we choose to read from it always
IOflag = 1;
@(posedge clk);
data_bus = Memory[1] ;
IOflag = 1;
//$display("Address=%d,Data=%d,IOR=%d,IOW=%d",Address_Bus,Data_Bus,IOR,IOW);
@(negedge DACK);		// wait for TReady comming from Memory for Successfull Operation
IOflag = 0;
end
// ==========================================================================
// ****** CPU Trigger ****
always@(posedge CPU_Event)
begin DREQ = 1 ; end

always@(negedge CPU_Event)
begin DREQ = 0 ; end
// ****** INITIAL ********
initial
begin
tready = 0  ;
DREQ = 0;
for(i =0 ; i< 31 ; i = i+1) begin Memory[i] = 2*i; end
end

endmodule 


