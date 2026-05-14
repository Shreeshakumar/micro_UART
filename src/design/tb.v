`timescale 1ns / 1ps

module tb#(		//default values
	parameter baudrate	 	= 2400,
	parameter data_len 	    = 8,
	parameter clock_rate 	= 100_000_000,  //100 Mhz	
	parameter oversample 	= 16
);
	reg sys_clk, sys_rst_l;
	reg xmitH;
	reg [data_len-1:0] xmit_dataH;
	
	wire uart_XMIT_dataH;
	wire xmit_doneH;
	wire xmit_active;

	wire baud_rec;
	wire baud_xmit;

	wire uart_REC_dataH;
	wire rec_readyH;
	wire rec_busy;
	wire [data_len-1:0]rec_dataH;

baud dut(.sys_rst_l(sys_rst_l), .sys_clk(sys_clk), .baud_rec(baud_rec), .baud_xmit(baud_xmit));

u_xmit 	xmit(
		.sys_rst_l(sys_rst_l), .xmitH(xmitH), .xmit_dataH(xmit_dataH),							//Main_inputs
		.uart_XMIT_dataH(uart_XMIT_dataH), .xmit_doneH(xmit_doneH), .xmit_active(xmit_active),	//Main_outputs
		.baud_xmit(baud_xmit)																	//Wires
		);
		
u_rec	rec(
		.sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .xmit_active(xmit_active), .uart_REC_dataH(uart_REC_dataH),		//Main_inputs
		.rec_readyH(rec_readyH), .rec_busy(rec_busy), .rec_dataH(rec_dataH),			//Main_outputs
		.baud_rec(baud_rec)															//Wires
		);

assign uart_REC_dataH = uart_XMIT_dataH; //equal equal

initial sys_clk = 0;
always #10 sys_clk = ~sys_clk;

initial begin
@(posedge sys_clk);
sys_rst_l = 0;

@(posedge sys_clk);
sys_rst_l = 1;

@(posedge sys_clk);
xmitH = 0;

@(posedge sys_clk);
xmit_dataH = 8'h0f;

@(posedge sys_clk);
xmitH = 1;

end
endmodule
