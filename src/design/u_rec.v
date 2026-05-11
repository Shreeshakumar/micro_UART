`default_nettype none

`include "inc.h"

module u_rec (
    input wire      sys_rst_l,                      //main sys reset 
                    xmitH,                          //active high -> uart clock with baudrate pulse starts the trasmit process
                    baud_rec,                       //baud rate for xmith
                    uart_REC_dataH,                 //asynchromous input data
    output wire     rec_readyH,                     //when high indicates fresh data is available on rec_dataH
                    rec_busy,                       //indicatedd if the receiver is currently busy
    output reg      [data_len - 1:0]rec_dataH       //indicates if the transmitter is actively transmitting a data
		);

	//state parameters
	parameter IDLE	= 0;
	parameter START	= 1;
	parameter REC	  = 2;
	parameter STOP	= 3;

	//state reg
	reg [1:0]CS;
	reg [1:0]NS;

	reg [$clog2(data_len)-1:0] count_ts;
	
	/*always@(posedge clk or posedge sys_rst_l)
		begin
			if(sys_rst_l)
				CS <= IDLE;
			else
				CS <= NS;
		end*/

  always@(posedge clk)
    begin
      if (sys_rst_l) begin
        rdy = 0;
        data_out = 0;
    end
    end
  
    always @(posedge clk)
        begin
            if(!xmitH)
                rdy <= 0;
            if(baud_rec)
                begin
                    case(state)
                        IDLE :      begin
                                               if(rx == 0 && sample != 0)
                                                    sample <= sample + 1'b1;
                                                if(sample == 15)
                                                    begin
                                                        state <= data_out_state;
                                                        sample <= 0;
                                                        index <= 0;
                                                        temp_register <= 0;
                                                    end
                                            end
                        data_out_state :    begin
                                                sample <= sample + 1'b1;
                                                if(sample == 4'h8)
                                                    begin
                                                        temp_register[index] <= rx;
                                                        index <= index + 1'b1;
                                                    end
                                                if(index == 8 && sample == 15)
                                                    state <= stop_state;
                                            end
                        stop_state :       begin
                                                if(sample == 15)
                                                    begin
                                                        NS = IDLE;
                                                        data_out <= temp_register;
                                                        rdy <= 1'b1;
                                                        sample <= 0;
                                                    end
                                                else
                                                    sample <= sample + 1'b1;
                                            end
                        default :           NS = IDLE;
                end
        end
	
    assign rec_readyH = (CS == IDLE)? 1 : 0;                     //when high indicates fresh data is available on rec_dataH
    assign rec_busy   = (CS == IDLE)? 0 : 1;                       //indicatedd if the receiver is currently busy
endmodule
