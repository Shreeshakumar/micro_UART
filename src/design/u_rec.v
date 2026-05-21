`default_nettype none
`include "inc.h"

module u_rec (
    /*input  wire                     sys_clk,*/
    input  wire                     sys_rst_l,
    input  wire                     baud_tick,
    input  wire                     uart_REC_dataH,//uart_REC_dataHH

    output reg                     rec_readyH,
    output reg                     rec_busy,
    output reg  [`data_len-1:0]      rec_dataH      
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam REC   = 2'b10;
    localparam STOP  = 2'b11;
    
    reg rec_temp = 0;
    reg FF = 0;
    reg [1:0] CS, NS;
    reg [$clog2(`sampling)-1:0]   sample_cnt;
    reg [$clog2(`data_len):0]   bit_cnt;
    reg [`data_len-1:0]           temp;
    
    reg match;
    reg previous_REC;
    
	always @(posedge baud_tick or negedge sys_rst_l)
	   begin 
		   if(~sys_rst_l)
			   begin
				CS <= IDLE;
		   		previous_REC<='d0; 
		   		FF <= 'd0;
		   		rec_temp <= 'd0;
		   	end
			else
			begin 	
				CS <= NS;
	   	   		//CS <= (~sys_rst_l)? IDLE : NS ;
		   		previous_REC<=rec_temp; 
		   		FF <= uart_REC_dataH;
		   		rec_temp <= FF;
			end
		end

	always @(*) if(CS == IDLE) NS <= (!rec_temp & previous_REC) ? START : IDLE; 
	
	always @(posedge baud_tick or negedge sys_rst_l)
    begin
		if (~sys_rst_l) 
            begin
            sample_cnt <= 'd0;
            bit_cnt    <= 'd0;
            temp       <= 'd0;
            rec_dataH  <= 'd0;
            match      <= 0;
            rec_readyH <= 1;
            rec_busy <= 0;
            end
        else begin
            case (CS)

                IDLE: begin
                        if (!rec_temp & previous_REC && rec_temp == 1'b0) 
                            begin sample_cnt <= 'd0; temp <= 'd0; match <= 0; rec_readyH <= 1;end
                        end

                START: begin
                rec_readyH <= 0;
                            if (sample_cnt == `sampling - 1) 
                                begin
                                sample_cnt <= 'd0;
                                bit_cnt    <= 'd0;
                                match <= 0;
                                NS <= (match)? REC : IDLE;
                                rec_busy <= (match);
                                end 
                            else if (sample_cnt == (`sampling / 2)-2) 
                                begin
                                match <= (rec_temp == 1'd0)? 1 : 0;
                                sample_cnt <= sample_cnt + 'd1;
                                end 
                            else
                                sample_cnt <= sample_cnt + 'd1;
                        end

                REC: begin
                            if (sample_cnt == `sampling - 1) 
                            begin
                                NS <= (bit_cnt == `data_len )? STOP : REC;
                                sample_cnt <= sample_cnt + 'd1;
                                end
                            else if (sample_cnt == (`sampling / 2)-2) 
                                begin
                                temp[bit_cnt] <= rec_temp;
                                bit_cnt       <= bit_cnt + 1'b1;
                                sample_cnt <= sample_cnt + 'd1;
                                end 
                            else 
                                sample_cnt <= sample_cnt + 'd1;
                            end

                STOP: begin
                            if (sample_cnt == `sampling - 1) 
                                begin
                                sample_cnt <= 'd0;
                                match <= 0;
                                rec_dataH  <= (match)? temp: 'd0;
                                temp  <= 'd0;
                                NS <= IDLE;
                                rec_busy <= 0;
                                rec_readyH <= 1;
                                end 
                            else if (sample_cnt == (`sampling / 2)-2) 
                                begin
                                match <= (rec_temp == 1'd1)? 1 : 0;
                                sample_cnt <= sample_cnt + 'd1;
                                end 
                            else
                                sample_cnt <= sample_cnt + 'd1;
                        end
            endcase
        end
    end

    //assign rec_readyH = (CS === IDLE && ~sys_rst_l);
    //assign rec_busy   = (CS !== IDLE && sys_rst_l);

endmodule
