`timescale 1ns / 1ps

`default_nettype none
module rec #(parameter WIDTH = 8, SAMPLE=16)(
    input  wire clk_baud,  
    input  wire rst,
    input  wire uart_REC_dataH,
    output reg [WIDTH-1:0] rec_dataH,
    output reg rec_readyH,
    output reg rec_busy
);

    localparam IDLE  = 2'b00, START = 2'b01, DATA  = 2'b10, STOP  = 2'b11;

    reg [1:0] state;
    reg [$clog2(SAMPLE)-1:0] baud_count;
    reg [$clog2(WIDTH)-1:0] bit_count;
    reg [WIDTH-1:0] rx_shift;
    reg ff1,ff2;
  
    always @ (posedge clk_baud or negedge rst) begin
	if(!rst)begin
		ff2 <= 1;
		ff1 <= 1;
	end
	else begin
		ff2 <= ff1;
		ff1 <= uart_REC_dataH;
	end
    end


    always @(posedge clk_baud or negedge rst) begin
        if(!rst) begin
            state <= IDLE;
            baud_count <= 0;
            bit_count <= 0;
            rx_shift <= 0;
            rec_dataH <= 0;
            rec_readyH <= 1'b1;
            rec_busy <= 0;
        end
        else begin
            case(state)
            IDLE: begin
		
                if(ff2 == 0) begin
                    state <= START;
                    baud_count <= 0;
		    rec_busy <= 1'b1;
                    rec_readyH <= 0;
                end
            end
	    
	    START: begin
    		if(baud_count == (SAMPLE/2)-4) begin
        		baud_count <= 0;
        	if(ff2 == 0)
            		state <= DATA;
		
       		else
            		state <= IDLE;
    		end

    		else begin
        		baud_count <= baud_count + 1;
    		end
	    end


            DATA: begin
    		if(baud_count == SAMPLE-1) begin
        		baud_count <= 0;
        		rx_shift <= {ff2, rx_shift[WIDTH-1:1]};
        		if(bit_count == WIDTH-1) begin
            			bit_count <= 0;
            			state <= STOP;
        		end
        		else
            			bit_count <= bit_count + 1;
    		end
    		else 
        		baud_count <= baud_count + 1;
		end
            STOP: begin
    		if(baud_count == SAMPLE-1) begin
        		baud_count <= 0;
        		if(ff2 == 1) begin
            			rec_dataH <= rx_shift;
            			rec_readyH <= 1;
        		end
        	state <= IDLE;
        	rec_busy <= 0;
    		end
    		else
        		baud_count <= baud_count + 1;
		end

            default:state <= IDLE;
            endcase
        end
    end
endmodule
