`default_nettype none
`timescale 1ns/1ps

`include "inc.h"
/*
ref_rec	ref_rec(
		.sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .uart_REC_dataH(uart_REC_dataH),		//Main_inputs
		.rec_readyH(rec_readyH), .rec_busy(rec_busy), .rec_dataH(rec_dataH)			//Main_outputs
		);
*/
module ref_rec (
    input  wire                     sys_clk,
    input  wire                     sys_rst_l,
    //input  wire                     baud_tick,
    input  wire                     uart_REC_dataH,//uart_REC_dataHH

    output reg                     rec_readyH,
    output reg                     rec_busy,
    output reg  [`data_len-1:0]     rec_dataH      
);
  reg prev_rec; 
  reg [`data_len-1:0] temp;
  
  //reg a;

    localparam cycle_ts =`clock_rate /( `baudrate * `sampling);
    localparam delay = cycle_ts*10;
    
    initial
  forever begin #10  prev_rec = uart_REC_dataH; end
  
initial begin
            rec_readyH =  'd1;
            rec_busy =    'd0;
            rec_dataH =   'd0;
    fork
      begin
        if(!sys_rst_l)
          begin
            rec_readyH =  'd0;
            rec_busy =    'd0;
            rec_dataH =   'd0;
          end
      end
      begin
        rec_readyH = 1;rec_busy=0;
        temp = 'd0;
        #(delay*`sampling);
        #(delay*`sampling);
        @(prev_rec && !uart_REC_dataH) 
        #(delay*(`sampling/2));
        //a=1;
        @(!uart_REC_dataH) 
        //a=0;
        #(delay*17);
        //a=1;
        temp[0] =  uart_REC_dataH; //rec_readyH = 0;rec_busy=1;
        #(delay*16);
        temp[1] = uart_REC_dataH;
        #(delay*16);
        temp[2] = uart_REC_dataH;
        #(delay*16);
        temp[3] = uart_REC_dataH;
        #(delay*16);
        temp[4] = uart_REC_dataH;
        #(delay*16);
        temp[5] = uart_REC_dataH;
        #(delay*16);
        temp[6] = uart_REC_dataH;
        #(delay*16);
        temp[ 7] = uart_REC_dataH;
        #(delay*16);
        if (uart_REC_dataH) rec_dataH = temp; 
        #delay;
        rec_readyH = 1;rec_busy=0;
      end
    join
end
endmodule
