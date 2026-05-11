`default_nettype none

`include "inc.h"

module baud (

	input 	sys_clk,			//main sys clock
			sys_rst_l,			//main sys reset
			xmitH,				//active high -> uart clock with baudrate pulse starts the trasmit process
			uart_REC_dataH,		//asynchromous input data
	input	[7:0]xmit_dataH,	//data to be sent, This data is sample when xmith high

	output	uart_XMIT_dataH,	//ouput asynchronous transmitter
			xmit_doneH,			//when active high thhis indictes that the xmit_dataH has been fully transmitted
			rec_readyH,			//when high indicates fresh data is available on rec_dataH 
			rec_busy,			//indicatedd if the receiver is currently busy
			xmit_active,		//indicates if the transmitter is actively transmitting a data
	output	[7:0]rec_dataH,		//de-serialized recieved from the remote
	
			);

	/*(in inc.h)
	DEFAULT PARAMETERS: 
	parameter baudrate	 	= 2400;
	parameter data_length 	= 8;
	*/
	
	wire 

	u_baud	baud(
		.sys_rst_l(sys_rst_l), .sys_clk(sys_clk),		//Main_inputs
		.baud_ticks(baud_ticks)							//Wires
		);

	u_xmit 	xmit(
		.sys_rst(sys_rst_l), .xmitH(xmitH), .xmit_dataH(xmit_dataH),							//Main_inputs
		.uart_XMIT_dataH(uart_XMIT_dataH), .xmit_doneH(xmit_doneH), .xmit_active(xmit_active)	//Main_outputs
		.baud_ticks(baud_ticks)																	//Wires
		);

	u_rec	rec(
		.sys_rst(sys_rst_l), .xmitH(xmitH), .uart_REC_dataH(uart_REC_dataH),		//Main_inputs
		.rec_readyH(rec_readyH), .rec_busy(rec_busy), .rec_dataH(rec_dataH)			//Main_outputs
		.baud_ticks(baud_ticks)														//Wires
		);

endmodule
