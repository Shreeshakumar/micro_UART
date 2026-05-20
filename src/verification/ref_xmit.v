`default_nettype none
`timescale 1ns/1ps

`include "inc.h"
/*
ref_xmit 	ref_xmit(
		.sys_clk(sys_clk),.sys_rst_l(sys_rst_l), .xmitH(xmitH), .xmit_dataH(xmit_dataH),							//Main_inputs
		.uart_XMIT_dataH(uart_XMIT_dataH), .xmit_doneH(xmit_doneH), .xmit_active(xmit_active)	//Main_outputs
		);
*/
module ref_xmit (
    input wire sys_clk,
    input wire sys_rst_l,
    input wire xmitH,
    input wire [`data_len-1:0] xmit_dataH,

    output reg uart_XMIT_dataH,
    output reg xmit_doneH,
    output reg xmit_active
);

    localparam cycle_a_tx =`clock_rate / `baudrate * `sampling;
    localparam delay = (cycle_a_tx*10)/`sampling;
    
  reg [`data_len-1:0]temp;
    
initial begin
    fork
      begin
        if(sys_rst_l)
          begin
            uart_XMIT_dataH = 0;
            xmit_doneH = 0;
            xmit_active = 0;
          end
      end
      begin
        xmit_doneH = 0;
        @(posedge xmitH);
        //a = 1;
        temp = xmit_dataH;
                      #delay;
              #delay;

        uart_XMIT_dataH = 0;  xmit_active = 1;
              #delay;
        uart_XMIT_dataH = temp[0];
              #delay;
        uart_XMIT_dataH = temp[ 1];
              #delay;
        uart_XMIT_dataH = temp[ 2];
              #delay;
        uart_XMIT_dataH = temp[ 3];
              #delay;
        uart_XMIT_dataH = temp[ 4];
              #delay;
        uart_XMIT_dataH = temp[ 5];
              #delay;
        uart_XMIT_dataH = temp[ 6];
              #delay;
        uart_XMIT_dataH = temp[ 7];
              #delay;
        uart_XMIT_dataH = 1;  xmit_active = 0;
              #delay;
        xmit_doneH = 1;
      end

    join
end
endmodule
