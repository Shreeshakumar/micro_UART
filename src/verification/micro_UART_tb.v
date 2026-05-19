`timescale 1ns/1ps

`include "inc.h"

module micro_UART_tb

    // SAME INPUT signals
    reg sys_clk, sys_rst_l, xmitH;
    reg [`data_len - 1 : 0]xmit_dataH;
    reg uart_REC_dataH;

    // Reference mode signals
    reg dut_uart_XMIT_dataH;
    reg [`data_len - 1 : 0]dut_rec_dataH;
    reg dut_xmit_doneH;
    reg dut_xmit_active;
    reg dut_rec_readyH;
    reg dut_rec_busy;
    
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

    // DUT instantiation
    uart    DUT_uart(
        .sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        .uart_REC_dataH(uart_REC_dataH), 
        .uart_XMIT_dataH(dut_uart_XMIT_dataH) ,
        .rec_dataH(dut_rec_dataH),
        .xmit_doneH(dut_xmit_doneH), .xmit_active(dut_xmit_active),
        .rec_readyH(dut_rec_readyH), .rec_busy(dut_rec_busy)
        );

    // Reference model instantiation
    uart    DUT_uart(
        .sys_clk(sys_clk), .sys_rst_l(sys_rst_l), .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        .uart_REC_dataH(uart_REC_dataH), 
        .uart_XMIT_dataH(ref_uart_XMIT_dataH) ,
        .rec_dataH(ref_rec_dataH),
        .xmit_doneH(ref_xmit_doneH), .xmit_active(ref_xmit_active),
        .rec_readyH(ref_rec_readyH), .rec_busy(ref_rec_busy)
        );

 // Clock generation
        initial sys_clk = 0;
        always #10 sys_clk = ~sys_clk;
 
    // Test DUT with respect to REF
    initial begin
        // Initialize
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);

        // sys_rst_l toggle
        @(posedge CLK);
        sys_rst_l = 0;

        @(posedge CLK);
        sys_rst_l = 1;
        
        @(posedge CLK);
        sys_rst_l = 0;        // Release reset

        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);        

        // Test transmiter Operations
        $display("\n=== Testing transmiter working ===");
        test_transmitter(8'h0f);
/*
        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        test_reciever();
*/
        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

    // Test transmitter operations
    task test_transmitter(
        input [`data_len -1 : 0]data;
    );
        begin
            // apply test
            apply_test(data, "BASIC_xmit");
        end
    endtask
/*
    // Test reciever operations
    task test_reciever();
        begin
            apply_test(8'hF0, 8'h0F, 4'b0000, "AND");
        end
    endtask
*/
    // Apply test and check
    task apply_test(
        input [`data_len -1 :0]data,
        input [80*8:1] test_name
    );
        begin
            @(posedge CLK);
            xmit_dataH = data;
            xmitH = 1;
            @(posedge CLK);
            xmitH = 1;
            
            test_count = test_count + 1;
            
            if (compare_outputs()) begin
                $display("[PASS] %s: xmit_dataH=0x%h ", 
                         test_name, data);
                //display_mismatch();
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: xmit_dataH=0x%h ", 
                         test_name, data);
                display_mismatch();
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Compare DUT vs REF
    function compare_outputs();
        begin
            compare_outputs = 1;
            
            // Compare RES 
            if (dut_uart_XMIT_dataH !== ref_uart_XMIT_dataH) compare_outputs = 0;
            if (dut_rec_dataH !== ref_rec_dataH) compare_outputs = 0;
    
            if (dut_xmit_doneH !== ref_xmit_doneH) compare_outputs = 0;
            if (dut_xmit_active !== ref_xmit_active) compare_outputs = 0;
    
            if (dut_rec_readyH !== ref_rec_readyH) compare_outputs = 0;
            if (dut_rec_busy !== ref_rec_busy) compare_outputs = 0;            
        end
    endfunction

    // Display mismatch details
    task display_mismatch();
        begin
                $display("  SYS INPUTS : \n 
                             sys_rst_l= %b, xmitH= %b, xmit_dataH= 0x%h, uart_REC_dataH= %b \n",
                                 sys_rst_l, xmitH, xmit_dataH, uart_REC_dataH);
    
                $display("  DUT & REF OUTPUTS :\n 
                             dut_uart_XMIT_dataH= %b, dut_rec_dataH= 0x%h, \n 
                             ref_uart_XMIT_dataH= %b, ref_rec_dataH= 0x%h,
                 
                             dut_xmit_doneH= %b, dut_xmit_active= %b, \n
                             ref_xmit_doneH= %b, ref_xmit_active= %b,
                 
                             dut_rec_readyH= %b, dut_rec_busy= %b, \n
                             ref_rec_readyH= %b, ref_rec_busy= %b \n",
             
                                 dut_uart_XMIT_dataH, dut_rec_dataH, ref_uart_XMIT_dataH, ref_rec_dataH,
                                 dut_xmit_doneH, dut_xmit_active, ref_xmit_doneH, ref_xmit_active,
                                 dut_rec_readyH, dut_rec_busy, ref_rec_readyH, ref_rec_busy );  
        end
    endtask

    // Waveform dump
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end

endmodule
