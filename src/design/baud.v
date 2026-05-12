`default_nettype none

`include "inc.h"

module baud (
		input wire 	sys_rst_l,         //main sys reset
        //wire xmitH,                   //active high -> uart clock with baudrate pulse starts the trasmit process
        			 sys_clk,                 //main sys clock
  
		output reg baud_rec, baud_xmit						 //Wire
		);
	
	/*(in inc.h)
	DEFAULT PARAMETERS: 
	parameter baudrate	 	= 2400;
	parameter data_length 	= 8;
	parameter clock_rate 	= 1000 000 000;  //100 Mhz	
	parameter oversample 	= 16;
	*/

	localparam cycles_rec = (1/(baudrate*oversample))*clock_rate ;//cycle is bit time * clock
	localparam cycles_xmit = (1/baudrate)*clock_rate ;//cycle is bit time * clock

	reg [$clog2(cycles_rec)-1:0] count_rec;
	reg [$clog2(cycles_xmit)-1:0] count_xmit;
	    
    always@(posedge sys_clk or posedge sys_rst_l)
        begin
        if (sys_rst_l)
            begin
                baud_rec = 0;
                count_rec = 0;
            end
			else if (count_rec == cycles_rec)
                begin
                baud_rec = 1;
                count_rec = 0;
                end
            else 
				begin
                baud_rec = 1;
                count_rec = count_rec + 1;
                end
        end

	lways@(posedge sys_clk or posedge sys_rst_l)
        begin
        if (sys_rst_l)
            begin
                baud_xmit = 0;
                count_xmit = 0;
            end
			else if (count_xmit == cycles_xmit)
                begin
                baud_xmit = 1;
                count_xmit = 0;
                end
            else 
				begin
                baud_xmit = 0;
                count_xmit = count_xmit + 1;
				end
        end
                
endmodule
