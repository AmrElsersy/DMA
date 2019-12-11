module RAM(Data_Bus , Address_Bus , Control ,IReady,TReady,clk);

reg[31:0] Memory[0:31];
wire myBus; // boolean wire to check if the address bus belongs to my memory space to know that tha master talks to that device
// ******* Bus ************
inout wire[31:0] Data_Bus;
inout wire[15:0] Address_Bus;
inout wire Control , IReady , TReady ;
input wire clk;
// ******* Bus_Registers *********
reg tready ;
reg[31:0] data_bus ;
// ****** parameters ***********
parameter first = 0 , last = 31;
integer i ;
// ******* Assign inout **********
assign myBus = ( Address_Bus >= first && Address_Bus <= last ) ;
assign TReady =  (myBus)? tready : 'bz ;			// slave can change the TReady wire in the bus if the address enables this module
assign Data_Bus = ( !Control  && myBus )? data_bus : 'bz ;	// slave have access on Data_Bus in read operation && address belongs to him 

always@(posedge IReady)
begin
$display("myBus=%0d",myBus);
if (Address_Bus >= first && Address_Bus <= last ) begin
	if (Control == 1) begin // write
		Memory[Address_Bus] = Data_Bus; // store the Data_Bus in the Address location in memory
		tready = 1;		// triger the slave ack
		$write("tready=%0d  ",tready);
		@(negedge IReady);	// wait for ack of master 
		tready = 0;		// make TReady = 0 to know that bus operation is finished
		$write("tready=%0d  ",tready);
		$write("TReady=%0d Address=%0d,Data=%0d\n",TReady,Address_Bus,Data_Bus);	
		end 

	else if ( Control == 0 ) begin  // read
		data_bus = Memory[Address_Bus]; // put data in the Data_Bus 
		$display(" &&&&&&&&&&&&& data_bus_read_ram=%0d",data_bus);
		tready = 1;		// triger slave ack that indicates that data is ready on the bus
		@(negedge IReady);	// wait for master ack that indicates that he received the data
		tready = 0;		// operation is finished
		end
end // if
end // always

// ****** INITIAL ********
initial
begin
tready = 0  ;
data_bus = 50 ;
for(i =0 ; i< 31 ; i = i+1) begin Memory[i] = 3*i; end
end

endmodule


module tb_RAM();
// ************ Clock *************
reg clk ;
// ************ RAM ***************
wire[31:0] Data_Bus;
wire[15:0] Address_Bus;
wire Control , IReady , TReady ;

reg iready , tready , control;
reg [31:0] data ; 
reg [15:0 ] add ;
integer i ;

always begin #10 clk = ~clk; end
RAM myRam(Data_Bus,Address_Bus,Control,IReady,TReady,clk);

assign IReady 		= iready ; 
assign Control 		= control; 
assign Address_Bus 	= add ;
assign Data_Bus 	= (Control)? data : 'bz ; 

// for just testing
always@ (posedge clk)
begin
control = 0; 
add = i ;
iready = 1;
@(posedge TReady);		// wait for Target ack
iready = 0;			// to indicate that the bus has no operation
$display ("Data_Busssss= %0d",Data_Bus);
i = i +1 ;
end

initial begin
#1 i = 0 ; clk = 0;
$monitor("Data_Bus=%0d,Address_Bus=%0d,Control=%0d",Data_Bus,Address_Bus,Control);
end // of initial

endmodule 