module Priority (HRQ , DACK , HLDA , DREQ , in_commandReg_3bits , in_requestReg_3bits , in_maskReg_4bits, RESET , clk ); 

/*****************inputs from internal Registers ****************/ 

/*         **in_commandReg_3bits Definations** 
 * in_commandReg_3bits[0] : 0--> Fixed_Priority         , 1--> Rotating_Priority
 * in_commandReg_3bits[1] : 0--> DREQ sense active low  , 1--> DREQ sense active High
 * in_commandReg_3bits[2] : 0--> DACK sense active low  , 1--> DACK sense active High
 */
input wire [2:0] in_commandReg_3bits ; 

/*         **in_requestReg_3bits Definations** 
 * in_requestReg_3bits[1:0] : 00:select Channel 0 ,  01:select Channel 1  , 10:select Channel 2  , 11:select Channel 3 
 * in_requestReg_3bits[2]   : 0--> ReSet Request bit , 1--> Set Request bit
 */
input wire [2:0] in_requestReg_3bits;

/*         **in_maskReg_4bits Definations** 
 * in_maskReg_4bits[0] : 0--> Clear Channel 0 mask bit  , 1--> Set Channel 0 mask bit
 * in_maskReg_4bits[1] : 0--> Clear Channel 1 mask bit  , 1--> Set Channel 1 mask bit
 * in_maskReg_4bits[2] : 0--> Clear Channel 2 mask bit  , 1--> Set Channel 2 mask bit
 * in_maskReg_4bits[3] : 0--> Clear Channel 3 mask bit  , 1--> Set Channel 3 mask bit
 */
input wire [3:0] in_maskReg_4bits ; 
input wire clk ;  
/*****************inputs from DMA pins ****************/ 
input wire [3:0] DREQ ; 
input wire HLDA ; 
input wire RESET ;
/*****************outputs of DMA pins ****************/ 
output reg HRQ ; 
output reg [3:0] DACK ; 
/******************** wires for Decoders and muxs********************/ 
wire [3:0] channel ; 

/*********************** Imlpmentation of DMA Priority ***********************/
initial begin  
end 

Decoder2to4 Decoder1 (channel[3:0] , in_requestReg_3bits[1:0] );

always @(posedge clk or posedge RESET) begin 

       /************** Beginning of Reset handling ***************/
    if(RESET) begin 
       HRQ <= 1'b0 ; 
// in_commandReg_3bits[2] : 0--> DACK sense active low  , 1--> DACK sense active High
       if (in_commandReg_3bits[2]) begin 
           DACK <= 4'b0000 ; 
       end  
       else begin 
           DACK <= 4'b1111 ;
       end // end of else 

    end // end of if(RESET)
/**************** End of Reset handling *****************/

/**************** begining of code in case of Non Reset  *****************/
else begin

   if (in_requestReg_3bits[2]) begin// 0--> RESET Request bit , 1--> SET Request bit
       HRQ <= 1'b1 ; 
       // in_commandReg_3bits[2] : 0--> DACK sense active low  , 1--> DACK sense active High
       if (in_commandReg_3bits[2]) begin 
       // case of active high 
          while (!HLDA) begin /// polling till the Ack is Recieved from CPU 
          end // end of while 
          DACK <= channel ; 
       end  
       else begin 
       // case of active high 
          while (!HLDA) begin /// polling till the Ack is Recieved from CPU 
          end // end of while 
          DACK <= ~channel ;
       end // end of else 

   end // end of requestReg condidtion 

   else begin // if there is NO SW Request from Request Reg

        case (in_commandReg_3bits[0]) // : 0--> Fixed_Priority  , 1--> Rotating_Priority)
          /*****************************Fixed_Priority Handler***************************/ 
               1'b0 : begin  // Fixed_Priority Handler : 
                      case (in_commandReg_3bits[2:1]) 
                      /*
                       * in_commandReg_3bits[1] : 0--> DREQ sense active low  , 1--> DREQ sense active High
                       * in_commandReg_3bits[2] : 0--> DACK sense active low  , 1--> DACK sense active High
                       */
                           2'b00 : // DREG and DACK are active low 
                                  begin 
                                        if( (!in_maskReg_4bits[0]) && (!DREQ[0]) )
                                           begin 
                                                  HRQ = 1'b1 ; 
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1100 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end 
                                        else if ( (!in_maskReg_4bits[1]) && (!DREQ[1]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1101 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end    
                                           end 
                                        else if ( (!in_maskReg_4bits[2]) && (!DREQ[2]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1011 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end   
                                           end 
                                        else if ( (!in_maskReg_4bits[3]) && (!DREQ[3]))
                                           begin 
                                                  HRQ <= 1'b1 ; 
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b0111 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end   
                                           end 
                                        else 
                                           begin 
                                                  HRQ <= 1'b0 ; 
                                                  DACK <= 4'b1111 ; 
                                           end 
                                   end // end of handling 2'b00 DREG and DACK active low case

                            2'b01 : // DREG is active high and DACK is active low 
                                  begin 
                                        if(  (!in_maskReg_4bits[0]) && (DREQ[0]) )
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1110 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end 
                                        else if ( (!in_maskReg_4bits[1]) && (DREQ[1]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1101 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end    
                                           end 
                                        else if ( (!in_maskReg_4bits[2]) && (DREQ[2]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1011 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end 
                                        else if ( (!in_maskReg_4bits[3]) && (DREQ[3]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b0111 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end
                                        else
                                           begin 
                                                  HRQ <= 1'b0 ;
                                                  DACK <= 4'b1111 ; 
                                           end  
                                   end // end of handling DREG and DACK active low case

                           2'b10 : // DREG is active low  and DACK are active high 
                                  begin 
                                        if(  (!in_maskReg_4bits[0]) && (!DREQ[0]) )
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b0001 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end 
                                        else if ( (!in_maskReg_4bits[1]) && (!DREQ[1]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b0010 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end 
                                        else if ( (!in_maskReg_4bits[2]) && (!DREQ[2]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b0100 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end  
                                           end 
                                        else if ( (!in_maskReg_4bits[3]) && (!DREQ[3]))
                                           begin 
                                                  HRQ <= 1'b1 ;
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                          DACK <= 4'b1000 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end   
                                           end 
                                        else
                                           begin 
                                                  HRQ <= 1'b0 ; 
                                                  DACK <= 4'b0000 ; 
                                           end  
                                   end // end of handling 2'b10

                           2'b11 : // DREG is active high and DACK are active high 
                                  begin 
                                        if(  (!in_maskReg_4bits[0]) && (DREQ[0]) )
                                           begin 
                                                  HRQ <= 1'b1 ; 
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                            DACK <= 4'b0001 ;  
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end                                                                                                      
                                           end 
                                        else if ( (!in_maskReg_4bits[1]) && (DREQ[1]))
                                           begin 
                                                  HRQ <= 1'b1 ; 
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                         DACK <= 4'b0010 ; 
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end                                                                                
                                           end 
                                        else if ( (!in_maskReg_4bits[2]) && (DREQ[2]))
                                           begin 
                                                  HRQ <= 1'b1 ; 
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                         DACK <= 4'b0100 ; 
                                                  end // end of HLDA condition
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end   
                                           end 
                                        else if ( (!in_maskReg_4bits[3]) && (DREQ[3]))
                                           begin 
                                                  HRQ <= 1'b1 ; 
                                                  if(HLDA) begin // wait till the Ack is Recieved from CPU 
                                                         DACK <= 4'b1000 ; 
                                                  end // end of HLDA condition 
                                                  else begin 
                                                        DACK <= 4'b0000 ; 
                                                  end 
                                           end 
                                        else
                                           begin 
                                                  HRQ <= 1'b0 ;
                                                  DACK <= 4'b0000 ; 
                                           end  
                                   end // end of handling 2'b10
                      endcase // end of 2'xx  DREQ and DACK
                   end // end of 1'b0 case     
        endcase

end // end of else 
end
end // end of always 



endmodule  
