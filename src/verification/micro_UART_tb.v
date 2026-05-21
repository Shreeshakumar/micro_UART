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
    reg ref_uart_XMIT_dataH = 'd0;
    reg [`data_len - 1 : 0]ref_rec_dataH= 'd0;
    reg ref_xmit_doneH= 'd0;
    reg ref_xmit_active= 'd0;
    reg ref_rec_readyH= 'd0;
    reg ref_rec_busy= 'd0;

    reg a,b;

    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

    reg cmp_pass = 0;

  localparam cycle_rx = `clock_rate/ (`baudrate * `sampling);
  localparam cycle_tx = `clock_rate/ `baudrate ;
  localparam delay_rx = (cycle_rx *10); 
  localparam delay_tx = (cycle_tx *10);  
    
    // DUT instantiation
    top     #(
        .WIDTH(`data_len), .BAUD(`baudrate), .SAMPLE(`sampling), .FREQ(`clock_rate)
    )   
    DUT_uart(
        .clk(sys_clk), .rst(sys_rst_l), .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        .uart_rx(uart_REC_dataH), 
        .uart_tx(dut_uart_XMIT_dataH),
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
      
    // sys_rst_l toggle
    toggle_rst();
      
    // Test reciever Operations
    $display("\n=== Testing reciever basic working ===");
    test_rx(8'h0f, "basic_rx");

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
                #(delay_tx);a=1;
                compare('d0,test_name);
                for (i = 0; i < `data_len; i = i+1 )
                    begin ref_uart_XMIT_dataH = data[i]; a=i; compare((i+1),test_name); #(delay_tx); end
                ref_uart_XMIT_dataH = 1;
                compare('d9,test_name);
                #(delay_tx); 
            end
        join 
            //a=1;
            scoreboard(data,test_name);
        end
    endtask
    
    // Test receiver operations
    task test_rx(
        input [`data_len -1 :0]data,
        input [80*8:1] test_name
    );
        integer i;
        begin fork
            begin
                uart_REC_dataH = 1;
                #(delay_tx);b=1;
                uart_REC_dataH = 0;
                #(delay_tx);b=0;
                compare('d0,test_name);
                for (i = 0; i < `data_len; i = i+1 )
                    begin uart_REC_dataH = data[i]; b=i; compare((i),test_name); #(delay_tx); end
                uart_REC_dataH = 1;
                compare('d9,test_name);
                #(delay_tx); 
            end
            begin
                #(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);#(delay_tx);
                ref_rec_dataH = data;
            end
        join 
            //a=1;
            scoreboard(data,test_name);
        end
    endtask
  
  task toggle_rst();
    begin
      @(posedge sys_clk);   sys_rst_l = 0;
      @(posedge sys_clk);   sys_rst_l = 1;        // Release reset
      @(posedge sys_clk);   sys_rst_l = 0;
      @(posedge sys_clk);   sys_rst_l = 1;        // Release reset

    sys_clk= 0; xmitH= 0;
    xmit_dataH= 'd0;
    uart_REC_dataH= 'd0;
        
        // Reference mode signals
     ref_uart_XMIT_dataH = 'd0;
     ref_rec_dataH= 'd0;
     ref_xmit_doneH= 'd0;
     ref_xmit_active= 'd0;
     ref_rec_readyH= 'd0;
     ref_rec_busy= 'd0;

     a= 'd0;
     b= 'd0;
        
    end
  endtask

  task summary();
    begin
      $display("\n=== TEST SUMMARY === \n Total Tests: %0d \n PASS: %0d \n FAIL: %0d \n \n ", test_count, pass_count, fail_count);
      if (fail_count == 0)  $display("\n*** ALL TESTS PASSED ***\n");
      else  $display("\n*** SOME TESTS FAILED ***\n");
    end
  endtask
  
  task compare(
      input [$clog2(`data_len + 2)-1:0]test,
    input [80*8:1] test_name
  );
      begin
        if (compare_outputs(1)) 
              begin 
                $display("[PASS] %s: xmit_dataH=%d ", test_name, test);
                cmp_pass = 1;
              end
        else 
            begin
                $display("[FAIL] %s: xmit_dataH=%d ", test_name, test);
                display_mismatch();
                cmp_pass = 0;
          end
      end
    endtask

  task scoreboard(
        input [`data_len -1 :0]data,
        input [80*8:1] test_name
  );
      begin
        test_count = test_count + 1;
          if (cmp_pass) 
          begin
            $display("[PASS] %s: xmit_dataH=0x%h ", test_name, data);
            pass_count = pass_count + 1;
          end 
        else 
          begin
            $display("[FAIL] %s: xmit_dataH=0x%h ", test_name, data);
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
