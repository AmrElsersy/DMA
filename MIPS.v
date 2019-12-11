`include "RAM.v"
module MIPS(Data_Bus,Address_Bus,Control,IReady , TReady ,clk , HOLD , HOLD_ACK);
// ******* DMA HOLD ************
input wire HOLD ;
output reg HOLD_ACK;
reg DONT_NEED_BUS ;
// ******* Bus Registers *******
reg[31:0] data_bus ;
reg[15 :0] address_bus ;
reg control , iready  ;
initial begin control = 0;   end
// ******* Bus ************
inout wire[31:0] Data_Bus;
inout wire[15:0] Address_Bus;
inout wire Control , IReady , TReady ;
input wire clk;
// ******* Assign inout **********
assign Data_Bus 	= (!HOLD_ACK && Control)? data_bus : 'bz ; 
assign Address_Bus	= (!HOLD_ACK)? address_bus : 'bz ;
assign Control 		= (!HOLD_ACK)? control : 'bz ;
assign IReady 		= (!HOLD_ACK)? iready : 'bz ;
// ******* Modules ********
reg[31:0] PC ;
reg[31:0] RegFile[0:31];
reg[31:0] InsMemory[0:1024];
// ******* variables ******
integer i ,file ,size, _ ;
reg[31:0] ins;
reg[5:0] operand , fun;
reg[4:0] rs_1 , rs_2 , rt ,shift;
reg[15:0] value_16_bit  ;

// ********** Main Flow ************
// blocking assignment 
always@(posedge clk)
begin
$display("ins=%0h,PC=%0d",ins,PC); 
if (PC > size-1 )
	$stop;
// Fetch
ins = InsMemory[PC];
PC  = PC +1;
// Control Unit
operand =  ins[31:26];
rs_1    =  ins[25:21];
rs_2  	=  ins[20:16];
rt    	=  ins[15:11]; 
shift 	=  ins[10:6];
fun   	=  ins[5:0] ;
value_16_bit = ins[15:0];
// ALU
if (operand == 0) // R-Format
begin 
	case(fun)
	0  : RegFile[rt] = RegFile[rs_1] << shift; // sll
	2  : RegFile[rt] = RegFile[rs_1] >> shift; // srl
	32 : RegFile[rt] = RegFile[rs_1] + RegFile[rs_2]; // add
	34 : RegFile[rt] = RegFile[rs_1] - RegFile[rs_2]; // sub
	36 : RegFile[rt] = RegFile[rs_1] & RegFile[rs_2]; // and 
	37 : RegFile[rt] = RegFile[rs_1] | RegFile[rs_2]; // or
	38 : RegFile[rt] = RegFile[rs_1] ^ RegFile[rs_2]; // xor
	39 : RegFile[rt] = ~(RegFile[rs_1] | RegFile[rs_2]); // nor
	endcase
	DONT_NEED_BUS = 1 ;
end
else if (operand == 8) begin // addi
	RegFile[rs_2] = RegFile[rs_1] + value_16_bit ; 
	DONT_NEED_BUS = 1 ; end

// ************ READ FROM BUS ********************
else if (operand == 60) // LW
begin
if(HOLD_ACK) begin @(negedge HOLD_ACK); end
$display("LW");
// LW $s0,100 ===== load the address 100 and store it in $s0
address_bus = value_16_bit;	 // master puts the address in the register to assign the inout Address_Bus 
control = 0;			 // read
iready = 1; 		  	 // master is ready
@(posedge TReady);		 // wait for Target ack
RegFile[rs_2] = Data_Bus;	 // when Target is Ready >> Read the Data_Bus
iready = 0;			 // to indicate that the bus has no operation(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS = 0; 		 // need it
end 
// ************* WRITE TO BUS *******************
else if (operand == 61)  // SW
begin
if(HOLD_ACK) begin @(negedge HOLD_ACK); end
$display("SW");
// SW $s0,100 ===== store the value of $s0 in address 100
address_bus = value_16_bit;	// master change the register to assign the inout address
data_bus = RegFile[rs_2];	// master change the register to assign the inout data
control  = 1; 			// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
end 

// ***** Print Register File ******
for (i = 0 ; i < 31; i = i+1) begin $write ("RegFile[%0d]=%0d .",i,RegFile[i]); end $write ("\n%0d\n",PC);

end // always

// ********* DMA HOLD ************
always@(posedge HOLD)
begin
if(!DONT_NEED_BUS)		  // condition to handle the state that hold is 1 and processor needs the bus
	@(posedge DONT_NEED_BUS); // wait for processor to finish his work on the bus
HOLD_ACK = 1;			  // ACK to DMA To start using the bus
end
always@(negedge HOLD)
begin
HOLD_ACK = 0;
end
// ******** initialization ***********
initial
begin
// pc
PC = 0;
// Instruction Memory
$readmemh("ins.txt",InsMemory);
// regFile
for(i =0 ; i < 32; i = i+1)
begin RegFile[i] = 0; end 
// ******** Size Calculation ******
size = 0;
file = $fopen("ins.txt","r");
// calculate size of instruction file
while (! $feof (file) ) begin _ = $fscanf (file,"%h",_); size = size +1; end $display ("SIZE === %d ",size);
// *********************************
HOLD_ACK = 0;
end // initial
endmodule

/******* Bus ********

********* Data_Bus : 32 ********* 
for data , can be accssed by anyone on the bus (master in write operation and slave in read operation)

********* Address_Bus : 16 bit *********		
for address , can be accessed by master only

********* Control : 1 bit *********		
for(read/write) , can be accessed by master only	

********* IReady : 1 bit  *********	
indication that the master finished(put data&address in write mode "or" put address in read mode)
can be accessed by Master only

******* TReady : 1 bit *********
indication that the slave finished(successfuly write in write mode "or" put data in read mode)
can be accessed by slave only

********************/

module tb_MIPS();
reg clk ;
wire[31:0] Data_Bus;
wire[15:0] Address_Bus;
wire Control , IReady , TReady;
reg HOLD ; wire HOLD_ACK;

RAM ram_ray2(Data_Bus,Address_Bus,Control,IReady,TReady,clk);
MIPS mips_ray2(Data_Bus,Address_Bus,Control,IReady,TReady,clk,HOLD,HOLD_ACK);

always begin #5 clk = ~clk; end
initial begin clk = 0 ; HOLD = 0 ; end
//initial begin $monitor("Data=%d,Add=%d,Control=%d,IReady=%d,TReady=%d",Data_Bus,Address_Bus,Control,IReady,TReady);end
// test HOLD
initial begin
#30
HOLD = 1;
#20
HOLD = 0;
end
endmodule
