`timescale 1ns/1ps
//==============================================================================
// tb_sensor_anomaly_detector.v  -- plain Verilog-2001, Icarus compatible
// Inputs are changed 1 ns after a rising edge; outputs are checked 1 ns after
// the edge that captured the sample (i.e. the registered result of that sample).
//==============================================================================
module tb_sensor_anomaly_detector;

    reg        clk;
    reg        rst_n;
    reg        enable;
    reg  [7:0] sensor_data;
    reg  [7:0] threshold;
    reg  [2:0] persistence_limit;
    wire       warning, critical, event_detected;
    wire [1:0] state;

    // Internal counter, observed hierarchically (does not touch the RTL)
    wire [2:0] persistence_counter = dut.persistence_counter;

    sensor_anomaly_detector dut (
        .clk(clk), .rst_n(rst_n), .enable(enable),
        .sensor_data(sensor_data), .threshold(threshold),
        .persistence_limit(persistence_limit),
        .warning(warning), .critical(critical),
        .event_detected(event_detected), .state(state)
    );

    // 100 MHz clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // VCD for GTKWave
    initial begin
        $dumpfile("sensor_anomaly_detector.vcd");
        $dumpvars(0, tb_sensor_anomaly_detector);
    end

    // Watchdog
    initial begin
        #200000;
        $display("FATAL: simulation timeout");
        $finish;
    end

    localparam [7:0] NORM = 8'd50;    // below threshold (100)
    localparam [7:0] ABN  = 8'd150;   // above threshold

    integer test_errors, total_errors, tests_run, tests_passed, tests_failed;
    integer evt_count;                // number of clock cycles event_detected=1

    // count event_detected high-cycles (reads pre-NBA value at the edge)
    always @(posedge clk) if (event_detected === 1'b1) evt_count = evt_count + 1;

    // one clock: drive sample, wait for capturing edge, settle
    task tick(input [7:0] d);
        begin
            sensor_data = d;
            @(posedge clk);
            #1;
        end
    endtask

    task check(input [1:0] s, input w, input c, input e, input [2:0] cnt,
               input [8*28-1:0] label);
        begin
            if (state !== s || warning !== w || critical !== c ||
                event_detected !== e || persistence_counter !== cnt) begin
                test_errors = test_errors + 1;
                $display("    [MISMATCH] %0s : got st=%b w=%b c=%b e=%b cnt=%0d | exp st=%b w=%b c=%b e=%b cnt=%0d  (t=%0t)",
                         label, state, warning, critical, event_detected,
                         persistence_counter, s, w, c, e, cnt, $time);
            end
        end
    endtask

    task check_val(input integer got, input integer exp, input [8*28-1:0] label);
        begin
            if (got !== exp) begin
                test_errors = test_errors + 1;
                $display("    [MISMATCH] %0s : got %0d expected %0d (t=%0t)",
                         label, got, exp, $time);
            end
        end
    endtask

    task start_test(input integer n, input [8*44-1:0] name);
        begin
            test_errors = 0;
            $display("---- TEST %0d: %0s", n, name);
        end
    endtask

    task end_test(input integer n);
        begin
            tests_run = tests_run + 1;
            if (test_errors == 0) begin
                tests_passed = tests_passed + 1;
                $display("TEST %0d: PASS", n);
            end else begin
                tests_failed = tests_failed + 1;
                total_errors = total_errors + test_errors;
                $display("TEST %0d: FAIL (%0d errors)", n, test_errors);
            end
        end
    endtask

    // shorthand state codes
    localparam [1:0] NORMAL = 2'b00, WARN = 2'b01, CRIT = 2'b10;

    initial begin
        total_errors = 0; tests_run = 0; tests_passed = 0; tests_failed = 0;
        test_errors = 0;  evt_count = 0;
        rst_n = 1'b0; enable = 1'b0; sensor_data = 8'd0;
        threshold = 8'd100; persistence_limit = 3'd3;
        @(posedge clk); #1;

        //---------------------------------------------------------------
        start_test(1, "Reset (held while input is abnormal)");
        enable = 1'b1;
        tick(ABN); tick(ABN); tick(ABN);
        check(NORMAL, 0, 0, 0, 3'd0, "reset dominates");
        sensor_data = NORM;
        rst_n = 1'b1;
        tick(NORM);
        check(NORMAL, 0, 0, 0, 3'd0, "after reset release");
        end_test(1);

        //---------------------------------------------------------------
        start_test(2, "Normal values below/equal threshold");
        tick(8'd0);   check(NORMAL, 0, 0, 0, 3'd0, "0");
        tick(NORM);   check(NORMAL, 0, 0, 0, 3'd0, "50");
        tick(8'd99);  check(NORMAL, 0, 0, 0, 3'd0, "99");
        tick(8'd100); check(NORMAL, 0, 0, 0, 3'd0, "100 == threshold (normal)");
        end_test(2);

        //---------------------------------------------------------------
        start_test(3, "One abnormal sample then normal");
        tick(ABN);  check(WARN, 1, 0, 0, 3'd1, "1st abnormal -> WARNING");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "back to NORMAL, cnt=0");
        end_test(3);

        //---------------------------------------------------------------
        start_test(4, "Two abnormal samples, limit=3");
        tick(ABN);  check(WARN, 1, 0, 0, 3'd1, "abn #1");
        tick(ABN);  check(WARN, 1, 0, 0, 3'd2, "abn #2 (critical must be 0)");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "recover");
        end_test(4);

        //---------------------------------------------------------------
        // Tests 5-8 form one continuous sequence
        start_test(5, "Three abnormal samples, limit=3 -> CRITICAL");
        evt_count = 0;
        tick(ABN);  check(WARN, 1, 0, 0, 3'd1, "abn #1");
        tick(ABN);  check(WARN, 1, 0, 0, 3'd2, "abn #2");
        tick(ABN);  check(CRIT, 0, 1, 1, 3'd3, "abn #3 -> CRITICAL + event");
        end_test(5);

        start_test(6, "event_detected is exactly one cycle");
        tick(ABN);  check(CRIT, 0, 1, 0, 3'd3, "event drops after 1 cycle");
        check_val(evt_count, 1, "event cycles so far");
        end_test(6);

        start_test(7, "Stay abnormal in CRITICAL");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd3, "crit hold 1");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd3, "crit hold 2");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd3, "crit hold 3");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd3, "crit hold 4");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd3, "crit hold 5");
        check_val(evt_count, 1, "total event cycles");
        end_test(7);

        start_test(8, "Return to normal from CRITICAL");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "CRITICAL -> NORMAL");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "stays NORMAL");
        end_test(8);

        //---------------------------------------------------------------
        start_test(9, "persistence_limit = 1");
        persistence_limit = 3'd1;
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "normal");
        tick(ABN);  check(CRIT, 0, 1, 1, 3'd1, "1st abnormal -> CRITICAL direct");
        tick(ABN);  check(CRIT, 0, 1, 0, 3'd1, "hold, no new event");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "recover");
        end_test(9);

        //---------------------------------------------------------------
        start_test(10, "enable = 0");
        persistence_limit = 3'd3;
        enable = 1'b0;
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "disabled 1");
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "disabled 2");
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "disabled 3");
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "disabled 4 (no critical)");
        enable = 1'b1;
        tick(ABN); check(WARN, 1, 0, 0, 3'd1, "enabled: monitoring resumes");
        enable = 1'b0;
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "disable in WARNING clears");
        enable = 1'b1;
        tick(ABN); tick(ABN); tick(ABN);
        check(CRIT, 0, 1, 1, 3'd3, "reach CRITICAL again");
        enable = 1'b0;
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "disable in CRITICAL clears");
        enable = 1'b1;
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "idle");
        end_test(10);

        //---------------------------------------------------------------
        start_test(11, "Reset during WARNING");
        tick(ABN); tick(ABN);
        check(WARN, 1, 0, 0, 3'd2, "in WARNING cnt=2");
        rst_n = 1'b0;
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "reset clears FSM+counter");
        rst_n = 1'b1;
        tick(ABN); check(WARN, 1, 0, 0, 3'd1, "count restarts from 0");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "recover");
        end_test(11);

        //---------------------------------------------------------------
        start_test(12, "Reset during CRITICAL");
        tick(ABN); tick(ABN); tick(ABN);
        check(CRIT, 0, 1, 1, 3'd3, "in CRITICAL");
        tick(ABN);
        rst_n = 1'b0;
        tick(ABN); check(NORMAL, 0, 0, 0, 3'd0, "reset clears CRITICAL");
        rst_n = 1'b1;
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "idle after reset");
        end_test(12);

        //---------------------------------------------------------------
        start_test(13, "persistence_limit = 0 behaves as 1 (safe)");
        persistence_limit = 3'd0;
        tick(ABN);  check(CRIT, 0, 1, 1, 3'd1, "limit 0 -> critical on 1st");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "recover");
        end_test(13);

        //---------------------------------------------------------------
        start_test(14, "persistence_limit = 7 (max), no overflow");
        persistence_limit = 3'd7;
        evt_count = 0;
        tick(ABN); check(WARN, 1, 0, 0, 3'd1, "abn 1");
        tick(ABN); check(WARN, 1, 0, 0, 3'd2, "abn 2");
        tick(ABN); check(WARN, 1, 0, 0, 3'd3, "abn 3");
        tick(ABN); check(WARN, 1, 0, 0, 3'd4, "abn 4");
        tick(ABN); check(WARN, 1, 0, 0, 3'd5, "abn 5");
        tick(ABN); check(WARN, 1, 0, 0, 3'd6, "abn 6");
        tick(ABN); check(CRIT, 0, 1, 1, 3'd7, "abn 7 -> CRITICAL");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd7, "hold (no wrap)");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd7, "hold (no wrap)");
        tick(ABN); check(CRIT, 0, 1, 0, 3'd7, "hold (no wrap)");
        check_val(evt_count, 1, "event cycles");
        tick(NORM); check(NORMAL, 0, 0, 0, 3'd0, "recover");
        end_test(14);

        //---------------------------------------------------------------
        $display("==================== SIMULATION SUMMARY ====================");
        $display(" Tests run    : %0d", tests_run);
        $display(" Tests passed : %0d", tests_passed);
        $display(" Tests failed : %0d", tests_failed);
        $display(" Total errors : %0d", total_errors);
        if (tests_failed == 0) $display(" RESULT: ALL TESTS PASSED");
        else                   $display(" RESULT: SOME TESTS FAILED");
        $display("============================================================");
        $finish;
    end

endmodule
