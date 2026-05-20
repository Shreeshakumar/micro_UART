`timescale 1ns / 1ps
`default_nettype none
module xmit #(parameter WIDTH = 8, SAMPLE=16)(
    input  wire clk_baud,
    input  wire rst,
    input  wire xmitH,
    input  wire [WIDTH-1:0]xmit_dataH,
    output reg  uart_XMIT_dataH,
    output reg  xmit_doneH,
    output reg  xmit_active );

    localparam IDLE  = 2'b00, START = 2'b01, DATA  = 2'b10, STOP  = 2'b11;

    reg [1:0] state;
    reg [$clog2(SAMPLE)-1:0] baud_count;      // counts 0 -> 15 for tx
    reg [$clog2(WIDTH)-1:0] bit_count;       // counts data bits
    reg [WIDTH-1:0] tx_shift;
    
    always @(posedge clk_baud or negedge rst) begin
    if(!rst)
        baud_count <= 0;
    else if(state == IDLE)
        baud_count <= 0;
    else
        baud_count <= baud_count + 1;
    end

    always @(posedge clk_baud or negedge rst) begin

        if(!rst) begin
            state <= IDLE;
            uart_XMIT_dataH <= 1'b1;
            xmit_doneH <= 1'b1;
            xmit_active <= 0;
            bit_count <= 0;
            tx_shift <= 0;
        end

        else begin
            case(state)
            IDLE: begin
                uart_XMIT_dataH <= 1'b1;
                bit_count <= 0;
                xmit_active <= 0;
                xmit_doneH <= 1'b1;
                if(xmitH) begin
                    tx_shift <= xmit_dataH;
                    xmit_doneH <= 1'b0;
                    state <= START;
                    xmit_active <= 1;
                end
            end

            START: begin
                uart_XMIT_dataH <= 1'b0;
                if(baud_count == SAMPLE-1)
                    state <= DATA;
            end

            DATA: begin
                uart_XMIT_dataH <= tx_shift[0];
                if(baud_count == SAMPLE-1) begin
                    tx_shift <= tx_shift >> 1;
                    if(bit_count == WIDTH-1) begin
                        bit_count <= 0;
                        state <= STOP;
                    end
                    else
                        bit_count <= bit_count + 1;
                end
            end

            STOP: begin
                uart_XMIT_dataH <= 1'b1;
                if(baud_count == SAMPLE-1) begin
                    if(xmitH)begin
                        tx_shift <= xmit_dataH;
                        state <= START;
                        xmit_doneH <= 0;
                        xmit_active <= 1;
                    end
                    else begin
                        state <= IDLE;
                        xmit_doneH <= 1;
                        xmit_active <= 0;
                    end
                end
            end
            default:state<=IDLE;

            endcase
        end
    end

endmodule
