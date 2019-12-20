module RAM(Data_Bus , Address_Bus , Control ,IReady,TReady,clk);

reg[7:0] Memory[0:600];
wire myBus; // boolean wire to check if the address bus belongs to my memory space to know that tha master talks to that device
// ******* Bus ************
inout wire[7:0] Data_Bus;
inout wire[15:0] Address_Bus;
inout wire Control , IReady , TReady ;
input wire clk;
// ******* Bus_Registers *********
reg tready ;
reg[7:0] data_bus ;
// ****** parameters ***********
parameter first = 16 , last = 599;
integer i ;
// ******* Assign inout **********
assign myBus = ( Address_Bus >= first && Address_Bus <= last ) ;
assign TReady =  (myBus)? tready : 'bz ;			// slave can change the TReady wire in the bus if the address enables this module
assign Data_Bus = ( !Control  && myBus )? data_bus : 'bz ;	// slave have access on Data_Bus in read operation && address belongs to him 

always@(posedge IReady)
begin
$display("myBus=%0d",myBus);
if (myBus ) begin
	if (Control == 1) begin // write
		Memory[Address_Bus-first] = Data_Bus; // store the Data_Bus in the Address location in memory
		tready = 1;		// triger the slave ack
		$write("tready=%0d  ",tready);
		@(negedge IReady);	// wait for ack of master 
		tready = 0;		// make TReady = 0 to know that bus operation is finished
		$write("tready=%0d  ",tready);
		$write("TReady=%0d Address=%0d,Data=%0d\n",TReady,Address_Bus,Data_Bus);	
		end 

	else if ( Control == 0 ) begin  // read
		data_bus = Memory[Address_Bus-first]; // put data in the Data_Bus 
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
for(i =0 ; i< 600 ; i = i+1) begin Memory[i] = i; end
end

endmodule
