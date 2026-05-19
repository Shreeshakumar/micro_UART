`timescale 1ns / 1ps

`include "inc.h"

module tb;
	reg sys_clk, sys_rst_l;
	reg xmitH;
	reg [`data_len-1:0] xmit_dataH;
	
	wire uart_XMIT_dataH;
	wire xmit_doneH;
	wire xmit_active;

	wire baud_tick;

	wire uart_REC_dataH;
	wire rec_readyH;
	wire rec_busy;
	wire [`data_len-1:0]rec_dataH;

uart    uart(
        .sys_clk(sys_clk),.sys_rst_l(sys_rst_l),.xmitH(xmitH),
        .uart_REC_dataH(uart_REC_dataH),.xmit_dataH(xmit_dataH) ,.uart_XMIT_dataH(uart_XMIT_dataH) ,
        .xmit_doneH(xmit_doneH) ,.rec_readyH(rec_readyH) ,.rec_busy(rec_busy) ,.xmit_active(xmit_active) ,.rec_dataH(rec_dataH)
        );

assign uart_REC_dataH = uart_XMIT_dataH; //equal equal

initial sys_clk = 0;
always #10 sys_clk = ~sys_clk;

initial begin
@(posedge sys_clk);
sys_rst_l = 0;xmitH = 1;

@(posedge sys_clk);
sys_rst_l = 1;

@(posedge sys_clk);
xmitH = 0;

@(posedge sys_clk);
xmit_dataH = 8'h0f;

@(posedge sys_clk);
xmitH = 1;

@(posedge sys_clk);
xmitH = 0;


end
endmodule
