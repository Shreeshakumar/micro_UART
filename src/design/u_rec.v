`default_nettype none

module u_rec #(		//default values
	parameter baudrate	 	= 2400,
	parameter data_len 	    = 8,
	parameter clock_rate 	= 100_000_000,  //100 Mhz	
	parameter sampling 	= 16
)(  
    input  wire                     sys_clk,
    input  wire                     sys_rst_l,
    input  wire                     xmit_active,
    input  wire                     baud_tick,
    input  wire                     uart_REC_dataH,

    output wire                     rec_readyH,
    output wire                     rec_busy,
    output reg  [data_len-1:0]      rec_dataH      
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam REC   = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] CS, NS;
    reg [$clog2(sampling)-1:0]   sample_cnt;
    reg [$clog2(data_len)-1:0]   bit_cnt;
    reg [data_len-1:0]           temp;
    
    reg a;

	always @(posedge sys_clk or negedge sys_rst_l)
    begin
		if (~sys_rst_l)
            CS <= IDLE;
        else
            CS <= NS;
    end

    always @(*)
    begin
        NS = CS; 
        case (CS)
            IDLE:    if (xmit_active && uart_REC_dataH == 1'b0)
                            NS = START;

            START:   if (baud_tick && sample_cnt == sampling - 1)
                            NS = REC;

            REC:     if (baud_tick && sample_cnt == sampling - 2 && bit_cnt == data_len - 1)
                            NS = STOP;

            STOP:    if (baud_tick && sample_cnt == sampling - 1 && uart_REC_dataH == 1'b1)
                            NS = IDLE;

            default:    NS = IDLE;
        endcase
    end
	
	always @(posedge sys_clk or negedge sys_rst_l)
    begin
		if (~sys_rst_l) 
            begin
            sample_cnt <= 'd0;
            bit_cnt    <= 'd0;
            temp       <= 'd0;
            rec_dataH  <= 'd0;
            end
        else begin
            case (CS)

                IDLE: begin
                        if (xmit_active && uart_REC_dataH == 1'b0) 
                            begin sample_cnt <= 'd0; temp       <= 'd0; end
                        end

                START: begin
                        if (baud_tick) 
                            begin
                            if (sample_cnt == sampling - 1) 
                                begin
                                sample_cnt <= 'd0;
                                bit_cnt    <= 'd0;
                                end 
                            else 
                                sample_cnt <= sample_cnt + 'd1;
                            end
                        end

                REC: begin
                        if (baud_tick) 
                            begin
                            if (sample_cnt == sampling - 2) 
                                begin
                                a <= 1;
                                temp[bit_cnt] <= uart_REC_dataH;
                                bit_cnt       <= bit_cnt + 1'b1;
                                sample_cnt    <= 'd0;
                                    if (bit_cnt == data_len - 1) 
                                        rec_dataH <= {uart_REC_dataH, temp[data_len-2:0]};
                                end 
                            else 
                                sample_cnt <= sample_cnt + 'd1;
                            end
                    end

                STOP: begin
                        if (baud_tick) 
                            begin
                            if (sample_cnt == sampling - 1) 
                                sample_cnt <= 'd0;
                            else 
                                sample_cnt <= sample_cnt + 'd1;
                            end
                        end
            endcase
        end
    end

    assign rec_readyH = (CS == IDLE);
    assign rec_busy   = (CS != IDLE);

endmodule
