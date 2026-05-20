`timescale 1ns / 1ps
`default_nettype none

module top #(parameter WIDTH = 8, BAUD = 2400,SAMPLE = 16, FREQ=100_000_000)(
    input  wire clk,
    input  wire rst,
    
    input  wire xmitH,
    input  wire [WIDTH-1:0] xmit_dataH,
    output wire xmit_doneH,
    output wire xmit_active,

    output wire [WIDTH-1:0] rec_dataH,
    output wire rec_readyH,
    output wire rec_busy,
    output wire uart_tx,
    input  wire uart_rx,
    output wire clk_baud );

  

    baud_clk1 #(.BAUD(BAUD),.FREQ(FREQ)) c1 (
        .clk(clk),
        .rst(rst),
        .clk_baud(clk_baud)
    );

    xmit #(.WIDTH(WIDTH), .SAMPLE(SAMPLE))tx1 (
        .clk_baud(clk_baud),
        .rst(rst),
        .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        
        .uart_XMIT_dataH(uart_tx),
        .xmit_doneH(xmit_doneH),
        .xmit_active(xmit_active)
    );

    rec #(.WIDTH(WIDTH),.SAMPLE(SAMPLE)) rx1 (
        .clk_baud(clk_baud),
        .rst(rst),
        .uart_REC_dataH(uart_rx),

        .rec_dataH(rec_dataH),
        .rec_readyH(rec_readyH),
        .rec_busy(rec_busy)
    );

endmodule`timescale 1ns / 1ps

`default_nettype none

module top #(parameter WIDTH = 8,parameter BAUD  = 2400)(
    input  wire clk,
    input  wire rst,
    
    input  wire xmitH,
    input  wire [WIDTH-1:0] xmit_dataH,
    output wire xmit_doneH,
    output wire xmit_active,

    output wire [WIDTH-1:0] rec_dataH,
    output wire rec_readyH,
    output wire rec_busy,
    output wire uart_tx,
    input  wire uart_rx );

  

    baud_clk1 #(.BAUD(BAUD)) c1 (
        .clk(clk),
        .rst(rst),
        .clk_baud(clk_baud)
    );

    xmit #(.WIDTH(WIDTH))tx1 (
        .clk_baud(clk_baud),
        .rst(rst),
        .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        
        .uart_XMIT_dataH(uart_tx),
        .xmit_doneH(xmit_doneH),
        .xmit_active(xmit_active)
    );

    rec #(.WIDTH(WIDTH)) rx1 (
        .clk_baud(clk_baud),
        .rst(rst),
        .uart_REC_dataH(uart_rx),

        .rec_dataH(rec_dataH),
        .rec_readyH(rec_readyH),
        .rec_busy(rec_busy)
    );

endmodule
