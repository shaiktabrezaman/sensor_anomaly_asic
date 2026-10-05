`timescale 1ns/1ps
//==============================================================================
// sensor_anomaly_detector.v
// Low-area configurable digital anomaly detector (standard-cell ASIC, SKY130A)
//
// Design decisions (all intentional, see project notes):
//  * Reset        : SYNCHRONOUS, active-low (rst_n). No async-reset flops needed.
//  * Abnormal     : sensor_data > threshold  (equal-to-threshold is NORMAL).
//  * Timing rule  : the abnormal sample that makes the consecutive count reach
//                   the (effective) persistence_limit IS the sample that causes
//                   CRITICAL. i.e. at the clock edge that captures that sample,
//                   state becomes CRITICAL and event_detected becomes 1.
//  * limit = 0    : treated as limit = 1 (fail-safe: most sensitive setting).
//  * limit = 1    : first abnormal sample goes NORMAL -> CRITICAL directly
//                   (WARNING is never visible).
//  * enable = 0   : FSM forced to NORMAL, counter cleared, all outputs 0.
//  * Overflow     : 3-bit counter only increments in NORMAL/WARNING, where its
//                   value is <= 6 (a count of 7 always triggers CRITICAL, since
//                   the max limit is 7). In CRITICAL the counter is HELD.
//  * Latches      : none (every reg assigned on every path / clocked only).
//  * State 2'b11  : unreachable; default branch returns to NORMAL.
//==============================================================================
module sensor_anomaly_detector (
    input  wire       clk,
    input  wire       rst_n,              // synchronous, active-low
    input  wire       enable,
    input  wire [7:0] sensor_data,
    input  wire [7:0] threshold,
    input  wire [2:0] persistence_limit,
    output wire       warning,
    output wire       critical,
    output reg        event_detected,     // 1-cycle pulse on entry to CRITICAL
    output reg  [1:0] state
);

    localparam [1:0] S_NORMAL   = 2'b00;
    localparam [1:0] S_WARNING  = 2'b01;
    localparam [1:0] S_CRITICAL = 2'b10;

    // Internal counter (visible in GTKWave as dut.persistence_counter)
    reg [2:0] persistence_counter;

    // ---- combinational datapath -------------------------------------------
    wire       abnormal = (sensor_data > threshold);

    // limit 0 -> 1 ; otherwise unchanged (bit0 forced to 1 only if limit==0)
    wire [2:0] limit_eff = {persistence_limit[2:1],
                            persistence_limit[0] | ~(|persistence_limit[2:1])};

    // Consecutive-abnormal count INCLUDING the current sample.
    // Safe from wrap: only used while counter <= 6 (see header).
    wire [2:0] count_next = persistence_counter + 3'd1;
    wire       limit_hit  = (count_next >= limit_eff);  // >= (not ==) so that
                                                       // lowering the limit
                                                       // mid-count still works

    // Outputs decoded straight from the state bits (state 2'b11 unreachable)
    assign warning  = state[0];
    assign critical = state[1];

    // ---- sequential FSM + counter -----------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            state               <= S_NORMAL;
            persistence_counter <= 3'd0;
            event_detected      <= 1'b0;
        end else begin
            event_detected <= 1'b0;                 // default: no pulse

            if (!enable) begin
                state               <= S_NORMAL;
                persistence_counter <= 3'd0;
            end else begin
                case (state)
                    // NORMAL and WARNING share behaviour: counter is 0 in
                    // NORMAL, so "count_next" is correct for both.
                    S_NORMAL, S_WARNING: begin
                        if (abnormal) begin
                            persistence_counter <= count_next;
                            if (limit_hit) begin
                                state          <= S_CRITICAL;
                                event_detected <= 1'b1;
                            end else begin
                                state          <= S_WARNING;
                            end
                        end else begin
                            state               <= S_NORMAL;
                            persistence_counter <= 3'd0;
                        end
                    end

                    S_CRITICAL: begin
                        // counter held; stay while abnormal
                        if (!abnormal) begin
                            state               <= S_NORMAL;
                            persistence_counter <= 3'd0;
                        end
                    end

                    default: begin
                        state               <= S_NORMAL;
                        persistence_counter <= 3'd0;
                    end
                endcase
            end
        end
    end

endmodule
