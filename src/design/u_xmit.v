`default_nettype none

module u_xmit #(		//default values
	parameter baudrate	 	= 2400,
	parameter data_len 	    = 8,
	parameter clock_rate 	= 100_000_000,  //100 Mhz	
	parameter oversample 	= 16
)(
    input wire sys_rst_l,
    input wire xmitH,
    input wire baud_xmit,
    input wire [data_len-1:0] xmit_dataH,

    output reg uart_XMIT_dataH,
    output wire xmit_doneH,
    output wire xmit_active
);

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam SEND  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;
reg [data_len-1:0] data_ts;
reg [$clog2(data_len)-1:0] count_ts;

always @(posedge baud_xmit or posedge sys_rst_l)
begin
    if(sys_rst_l)
    begin
        state <= IDLE;
        uart_XMIT_dataH <= 1'b1;
        count_ts <= 0;
        data_ts <= 0;
    end

    else
    begin
        case(state)
            IDLE:    begin
                     uart_XMIT_dataH <= 1'b1;
                     if(~xmitH)
                        begin
                            data_ts <= xmit_dataH;
                            count_ts <= 0;
                            state <= START;
                        end
                    end

            START:    begin
                        uart_XMIT_dataH <= 1'b0;
                        state <= SEND;
                    end

            SEND:    begin
                        uart_XMIT_dataH <= data_ts[count_ts];
                    if(count_ts == data_len-1)
                        state <= STOP;
                    else
                        count_ts <= count_ts + 1;
                    end

            STOP:    begin
                        uart_XMIT_dataH <= 1'b1;
                        state <= IDLE;
                    end

            default:    state <= IDLE;
        endcase
    end
end

assign xmit_doneH = (state == IDLE);
assign xmit_active = (state != IDLE);

endmodule
