`default_nettype none

`timescale 1ns/1ps

module refrence_model #(		//default values
	parameter baudrate	 	= 2400,
	parameter data_len 	    = 8,
	parameter clock_rate 	= 100_000_000,  //100 Mhz	
	parameter sampling 	= 16
)(

	input wire 	//sys_clk,			//main sys clock
			    //sys_rst_l,			//main sys reset
			    xmitH,				//active high -> uart clock with baudrate pulse starts the trasmit process
			    uart_REC_dataH,		//asynchromous input data
	input wire	[data_len - 1:0]xmit_dataH,	//data to be sent, This data is sample when xmith high

	output wire	uart_XMIT_dataH,		//ouput asynchronous transmitter
			    xmit_doneH,				//when active high thhis indictes that the xmit_dataH has been fully transmitted
				rec_readyH,				//when high indicates fresh data is available on rec_dataH 
				rec_busy,				//indicatedd if the receiver is currently busy
				xmit_active,			//indicates if the transmitter is actively transmitting a data
	output wire	[data_len - 1:0]rec_dataH		//de-serialized recieved from the remote
			);

wire baud_tick;
/*
baud    #(
        .baudrate(baudrate), .data_len(data_len), .clock_rate(clock_rate), .sampling(sampling)
        )
        baud(.sys_rst_l(sys_rst_l), .sys_clk(sys_clk), .baud_tick(baud_tick));
*/
u_xmit 	#(
        .baudrate(baudrate), .data_len(data_len), .clock_rate(clock_rate), .sampling(sampling)
        )
        xmit(
		//.sys_rst_l(sys_rst_l), 
          .xmitH(xmitH), .xmit_dataH(xmit_dataH),							//Main_inputs
		.uart_XMIT_dataH(uart_XMIT_dataH), .xmit_doneH(xmit_doneH), .xmit_active(xmit_active),	//Main_outputs
		.baud_tick(baud_tick)																	//Wires
		);
		
u_rec	#(
        .baudrate(baudrate), .data_len(data_len), .clock_rate(clock_rate), .sampling(sampling)
        )
        rec(
		.sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .xmit_active(xmit_active), .uart_REC_dataH(uart_REC_dataH),		//Main_inputs
		.rec_readyH(rec_readyH), .rec_busy(rec_busy), .rec_dataH(rec_dataH),			//Main_outputs
		.baud_tick(baud_tick)															//Wires
		);

  endmodule
