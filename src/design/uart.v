`default_nettype none

`include "inc.h"

module baud (

	input 	sys_clk,			//main sys clock
			sys_rst_l,			//main sys reset
			xmitH,				//active high -> uart clock with baudrate pulse starts the trasmit process
			uart_REC_dataH,		//asynchromous input data
	input	[7:0]xmit_dataH,	//data to m=be sent, This data is sample when xmith high

	output	uart_XMIT_dataH,	//ouput asynchronous transmitter
			xmit_doneH,			//when active high thhis indictes that the xmit_dataH has been fully transmitted
			rec_readyH,			//de-serialized recieved from the remote
			rec_busy,			//indicates if the transmitter is actively transmitting a data
			xmit_active,		//indicatedd if the receiver is currently busy
	output	[7:0]rec_dataH,		//when high indicates fresh data is available on rec_dataH
	
			);

	
	u_baud	baud();

	u_xmit 	xmit();

	u_rec	rec();

endmodule
