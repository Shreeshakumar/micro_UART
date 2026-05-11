`default_nettype none

`include "inc.h"

module baud (
		input wire sys_rst_l,         //main sys reset
        //wire xmitH,                   //active high -> uart clock with baudrate pulse starts the trasmit process
        wire sys_clk,                 //main sys clock
  
		output reg baud_ticks							 //Wire
		);

    reg [3:0]count;
    
    always@(posedge sys_clk or posedge sys_rst_l)
        begin
        if (sys_rst_l)
            begin
                baud_ticks <= 0;
                count <= 0;
            end
            else if (count == 4'14)
                begin
                baud_ticks = ~baudticks;
                count = count + 1;
                end
            else if (count == 4'15)
                begin
                baud_ticks = ~baudticks;
                count = count + 1;
                end
            else
                count = count +1;
        end
                
endmodule
