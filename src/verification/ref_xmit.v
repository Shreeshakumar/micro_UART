`default_nettype none

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
    output wire xmit_doneH,
    output wire xmit_active
);

  reg temp = xmit_dataH;
  
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
        if(xmitH)    uart_XMIT_dataH = 1;  xmit_active = 1;
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 1];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 2];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 3];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 4];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 5];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 6];
        #41665;
        uart_XMIT_dataH = temp[`data_len - `data_len + 7];
        #41665;
        uart_XMIT_dataH = 1;  xmit_active = 0;
        #41665;
        xmit_doneH = 1;
      end
    join
end
endmodule
/*    
localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam SEND  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;
reg [`data_len-1:0] data_ts;
reg [$clog2(`data_len)-1:0] count_ts;

reg [3:0]count;

reg previous_xmitH;
always @(posedge xmitH)		previous_xmitH<=1;          

always @(posedge baud_tick or negedge sys_rst_l)
begin
	if(~sys_rst_l)
    	begin
        	state <= IDLE;
        	uart_XMIT_dataH <= 1'b1;
        	count_ts <= 0;
        	data_ts <= 0;
        	count <= 4'd0;
    	end

    else
    begin
        case(state)
            IDLE:   begin
                    	if(count == 4'b1111)
                    		begin
                        		count <= 4'd0;
                        		uart_XMIT_dataH <= 1'b1;
                     			if(previous_xmitH)
                        			begin
                            			data_ts <= xmit_dataH;
                            			count_ts <= 0;
                            			state <= START;
                            			previous_xmitH <= 0;
                        			end
                    		end
                    	else
                        	begin state <= IDLE;    count <= count + 1'b1;  end
                    end

            START:    begin
                		if(count == 4'b1111)
                        	begin
                        		count <= 4'd0;
                            	uart_XMIT_dataH <= 1'b0;
                            	state <= SEND;
                        	end
                      	else
                        	begin state <= START;    count <= count + 1'b1;  end
    				end

            SEND:    begin
            			if(count == 4'b1111)
                        	begin
                        		count <= 4'd0;
                        		uart_XMIT_dataH <= data_ts[count_ts];
                    			if(count_ts == `data_len-1)		state <= STOP;
                    			else							count_ts <= count_ts + 1;
                    		end
        				else
                        	begin state <= SEND;    count <= count + 1'b1;  end
					end

            STOP:    begin
            			if(count == 4'b1111)
                        	begin
                        		count <= 4'd0;
                        		uart_XMIT_dataH <= 1'b1;
                        		state <= IDLE;
                    		end
                    	else
                        	begin state <= STOP;    count <= count + 1'b1;  end
                    end

            default:    state <= IDLE;
        endcase
    end
end

assign xmit_doneH = (state == IDLE);
assign xmit_active = (state != IDLE);

endmodule/*
