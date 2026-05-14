`default_nettype none

module baud #(		//default values
	parameter baudrate	 	= 2400,
	parameter data_len 	    = 8,
	parameter clock_rate 	= 100_000_000,  //100 Mhz	
	parameter oversample 	= 16
)(
		input wire 	sys_rst_l,         		//main sys reset
        			sys_clk,                //main sys clock
		output reg  baud_rec, baud_xmit		//Wire

		);
	localparam  cycles_rec = (clock_rate/(baudrate*oversample)) ,//cycle is bit time * clock
	localparam cycles_xmit = (clock_rate/baudrate) //cycle is bit time * clock

	//reg [$clog2(cycles_rec)-1:0] count_rec;
	reg [$clog2(cycles_xmit)-1:0] count_xmit;
	reg [$clog2(cycles_rec)-1:0] count_rec;
    //initial $display(cycles_xmit,"cycles of rx");
	//initial $display(cycles_rec,"cycles of rx");

    always@(posedge sys_clk or posedge sys_rst_l)
        begin
        if (sys_rst_l)
            begin
                baud_rec <= 0;
                count_rec <= 0;
            end
			else if (count_rec == cycles_rec-1)
                begin
                baud_rec <= 1;
                count_rec <= 0;
                end
            else 
				begin
                baud_rec <= 0;
                count_rec <= count_rec + 1;
                end
        end

	always@(posedge sys_clk or posedge sys_rst_l)
        begin
        if (sys_rst_l)
            begin
                baud_xmit <= 0;
                count_xmit <= 0;
            end
			else if (count_xmit == cycles_xmit - 1)
                begin
                baud_xmit <= 1;
                count_xmit <= 0;
                end
            else 
				begin
                baud_xmit <= 0;
                count_xmit <= count_xmit + 1;
				end
        end

endmodule
