`default_nettype none

`include "inc.h"

module u_xmit (
    input wire      sys_rst,                        //main sys reset 
                    xmitH,                          //active high -> uart clock with baudrate pulse starts the trasmit process
                    baud_xmit                       //baud rate for xmith
    input wire      [data_len-1 : 0]xmit_dataH,		//data to be sent, This data is sample when xmith high    			
    output reg      uart_XMIT_dataH,                //ouput asynchronous transmitter 
                    xmit_doneH,                     //when active high thhis indictes that the xmit_dataH has been fully transmitted
                    xmit_active	                    //indicates if the transmitter is actively transmitting a data
		);

    always@(posedge baud_xmit)

    
endmodule
