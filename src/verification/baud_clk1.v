`timescale 1ns / 1ps
`default_nettype none
module baud_clk1#(parameter BAUD=2400)(
    input wire clk,rst,
    output reg clk_baud
   );
   
   localparam VAL= 100_000_000/(BAUD*16*2);
   reg [$clog2(VAL)-1:0]count;
   always @ (posedge clk or negedge rst) begin
    if(!rst)begin
        count<=0;
        clk_baud<=0;
    end
    else if (count==VAL-1)begin
        count<=0;
        clk_baud<=~clk_baud;
    end
    else
        count<=count+1;
   end
     
endmodule
