`default_nettype none

`include "inc.h"

module u_xmit (
    input wire      sys_rst_l,                        //main sys reset 
                    xmitH,                          //active high -> uart clock with baudrate pulse starts the trasmit process
                    baud_xmit                       //baud rate for xmith
    input wire      [data_len-1 : 0]xmit_dataH,		//data to be sent, This data is sample when xmith high    			
    output wire     uart_XMIT_dataH,                //ouput asynchronous transmitter 
                    xmit_doneH,                     //when active high thhis indictes that the xmit_dataH has been fully transmitted
                    xmit_active	                    //indicates if the transmitter is actively transmitting a data
		);

	//state parameters
	parameter IDLE	= 0;
	parameter START	= 1;
	parameter SEND	= 2;
	parameter STOP	= 3;

	//state reg
	reg [1:0]CS;
	reg [1:0]NS;

	reg [data_len-1 : 0]data_ts;
	reg [$clog2(data_len)-1:0] count_ts;
	
	always@(posedge clk or posedge sys_rst_l)
		begin
			if(sys_rst_l)
				CS <= IDLE;
			else
				CS <= NS;
		end

	always@(posedge clk)
		begin
			case(CS)
				IDLE	:	begin
								if(xmit)
									begin
										NS = START;
										data_ts = xmit_dataH;
										count_ts = 'd0;
									end
								else
									NS = IDLE;
							end
				START	:	begin
								if(baud_xmit)
									begin	
										uart_XMIT_dataH = 0;
										NS = START;
									end
								else
									NS = START;
							end
				SEND	:	begin
								if(baud_xmit)
									begin	
										if(count_ts == data_len)
												NS = STOP;
										else
											begin
												uart_XMIT_dataH = data_ts[count_ts];
												count_ts = count_ts + 1;
												NS = START;
											end
									end
								else
									NS = SEND;
							end
				STOP	:	begin
								if(baud_xmit)
									begin	
										uart_XMIT_dataH = 1;
										NS = IDLE;
									end
								else
									NS = IDLE;
							end
				default	:	NS = IDLE;
			endcase
		end	
	
	assign xmit_doneH = (CS == IDLE)? 1 : 0;                     //when active high thhis indictes that the xmit_dataH has been fully transmitted
	assign xmit_active = (CS == IDLE)? 0 : 1;  	                    //indicates if the transmitter is actively transmitting a data
    
endmodule
