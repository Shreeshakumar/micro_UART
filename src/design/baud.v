`default_nettype none

`include "inc.h"

module baud (
		input wire 	sys_rst_l,         		//main sys reset
        			sys_clk,                //main sys clock
		output reg  baud_tick		//Wire

		);
	localparam  cycles = (`clock_rate/(`baudrate*`sampling)) ;//cycle is bit time * clock

	reg [$clog2(cycles)-1:0] count;

	always@(posedge sys_clk or negedge sys_rst_l)
        begin
			if (~sys_rst_l)
            begin
                baud_tick <= 0;
                count <= 0;
            end
			else if (count == cycles - 1)
                begin
                baud_tick <= 1;
                count <= 0;
                end
            else 
				begin
                baud_tick <= 0;
                count <= count + 1;
                end
        end

endmodule
