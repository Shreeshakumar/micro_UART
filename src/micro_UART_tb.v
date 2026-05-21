`timescale 1ns/1ps

`include "inc.h"

module micro_UART_tb;

    // SAME INPUT signals
    reg sys_clk, sys_rst_l, xmitH;
    reg [`data_len - 1 : 0]xmit_dataH;
    reg uart_REC_dataH;

    // Reference mode signals
    wire dut_uart_XMIT_dataH;
    wire [`data_len - 1 : 0]dut_rec_dataH;
    wire dut_xmit_doneH;
    wire dut_xmit_active;
    wire dut_rec_readyH;
    wire dut_rec_busy;
    
    // Reference mode signals
    reg ref_uart_XMIT_dataH;
    reg [`data_len - 1 : 0]ref_rec_dataH;
    reg ref_xmit_doneH;
    reg ref_xmit_active;
    reg ref_rec_readyH;
    reg ref_rec_busy;

    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

  localparam cycle =`clock_rate / (`baudrate * `sampling);
  localparam delay_rx = (cycle *10); 
  localparam delay_tx = delay_rx/`sampling; 
    
    // DUT instantiation
    top     #(
        .WIDTH(`data_len), .BAUD(`baudrate), .SAMPLE(`sampling), .FREQ(`clock_rate)
    )   
    DUT_uart(
        .sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        .uart_REC_dataH(uart_REC_dataH), 
        .uart_XMIT_dataH(dut_uart_XMIT_dataH),
        .rec_dataH(dut_rec_dataH),
        .xmit_doneH(dut_xmit_doneH), .xmit_active(dut_xmit_active),
        .rec_readyH(dut_rec_readyH), .rec_busy(dut_rec_busy)
        );

  // Clock generation
    initial sys_clk = 0;
    always #5 sys_clk = ~sys_clk;
 
  // Testing DUT 
  initial begin
    // sys_rst_l toggle
    toggle_rst();
      
    // Test transmiter Operations
    $display("\n=== Testing transmiter basic working ===");
    toggle_rst(); 
    test_tx(`data_len'h5a, "basic_tx");
  /*
    // Test reciever Operations
    $display("\n=== Testing reciever basic working ===");
    test_reciever(8'h0f, "basix_rx");
*/
    // Summary
    summary();
    #10000 $finish;
  end

    // Test transmitter operations
    task test_tx(
        input [`data_len -1 :0]data,
        input [80*8:1] test_name
    );
        integer i;
        begin fork
            begin
                xmit_dataH = data;
                xmitH =0; 
                @(posedge sys_clk);  xmitH =1; 
            end
            begin
                ref_uart_XMIT_dataH = 1;
                @(posedge xmitH);    ref_uart_XMIT_dataH = 0;
                for (i = 0; i < `data_len; i = i+1 )
                    begin ref_uart_XMIT_dataH = data[i]; # delay_tx; end
                ref_uart_XMIT_dataH = 1;
            end
        join 
        scoreboard();
        end
    endtask
    /*
    // Test reciever operations
    task test_reciever(
        input [`data_len -1 :0]data,
        input [80*8:1] test_name
    );
        begin
              #delay_apply_rec;
        uart_REC_dataH = 1;     sys_rst_l = 0;
              #delay_apply_rec; sys_rst_l = 1;
              #delay_apply_rec;
        uart_REC_dataH = 0; 
              #delay_apply_rec;
        uart_REC_dataH = data[0];
              #delay_apply_rec;
        uart_REC_dataH = data[ 1];
              #delay_apply_rec;
        uart_REC_dataH = data[2];
              #delay_apply_rec;
        uart_REC_dataH = data[3];
              #delay_apply_rec;
        uart_REC_dataH = data[4];
              #delay_apply_rec;
        uart_REC_dataH = data[5];
              #delay_apply_rec;
        uart_REC_dataH = data[6];
              #delay_apply_rec;
        uart_REC_dataH = data[7];
        #delay_apply_rec;
        uart_REC_dataH = 1;
        #delay_apply_rec;
            scoreboard();
        end
    endtask

*/





  
  task toggle_rst();
    begin
      @(posedge sys_clk);   sys_rst_l = 0;
      @(posedge sys_clk);   sys_rst_l = 1;        // Release reset
      @(posedge sys_clk);   sys_rst_l = 0;
      @(posedge sys_clk);   sys_rst_l = 1;        // Release reset
    end
  endtask

  task summary();
    begin
      $display("\n=== TEST SUMMARY === \n Total Tests: %0d \n PASS: %0d \n FAIL: %0d \n \n ", test_count, pass_count, fail_count);
      if (fail_count == 0)  $display("\n*** ALL TESTS PASSED ***\n");
      else  $display("\n*** SOME TESTS FAILED ***\n");
    end
  endtask
  
  task scoreboard();
      begin
        test_count = test_count + 1;
        if (compare_outputs(1)) 
          begin
            $display("[PASS] %s: xmit_dataH=0x%h ", test_name, data);
            pass_count = pass_count + 1;
          end 
        else 
          begin
            $display("[FAIL] %s: xmit_dataH=0x%h ", test_name, data);
            display_mismatch();
            fail_count = fail_count + 1;
          end
      end
    endtask
  
    // Compare DUT vs REF
    function compare_outputs(input dummy);
        begin
            compare_outputs =(dut_uart_XMIT_dataH !== ref_uart_XMIT_dataH)? 1 : 0;
            compare_outputs =(dut_rec_dataH !== ref_rec_dataH)? 1 : 0;
    
            compare_outputs =(dut_xmit_doneH !== ref_xmit_doneH)? 1 : 0;
            compare_outputs =(dut_xmit_active !== ref_xmit_active)? 1 : 0;
    
            compare_outputs =(dut_rec_readyH !== ref_rec_readyH)? 1 : 0;
            compare_outputs =(dut_rec_busy !== ref_rec_busy)? 1 : 0;           
        end
    endfunction

    // Display mismatch details
    task display_mismatch();
        begin
                $display("  SYS INPUTS : \n  sys_rst_l= %b, xmitH= %b, xmit_dataH= 0x%h, uart_REC_dataH= %b \n\n",
                                 sys_rst_l, xmitH, xmit_dataH, uart_REC_dataH);
    
                $display("  DUT & REF OUTPUTS :\n dut_uart_XMIT_dataH= %b, dut_rec_dataH= 0x%h, \n ref_uart_XMIT_dataH= %b, ref_rec_dataH= 0x%h, \n dut_xmit_doneH= %b, dut_xmit_active= %b, \n  ref_xmit_doneH= %b, ref_xmit_active= %b, \n dut_rec_readyH= %b, dut_rec_busy= %b, \n  ref_rec_readyH= %b, ref_rec_busy= %b \n",
             
                                 dut_uart_XMIT_dataH, dut_rec_dataH, ref_uart_XMIT_dataH, ref_rec_dataH,
                                 dut_xmit_doneH, dut_xmit_active, ref_xmit_doneH, ref_xmit_active,
                                 dut_rec_readyH, dut_rec_busy, ref_rec_readyH, ref_rec_busy );  
        end
    endtask

    // Waveform dump
    initial begin
        $dumpfile("micro_UART_tb.vcd");
        $dumpvars(0, micro_UART_tb);
    end

endmodule
