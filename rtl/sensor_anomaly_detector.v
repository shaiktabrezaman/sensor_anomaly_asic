`timescale 1ns/1ps
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

    reg [2:0] persistence_counter;

    wire       abnormal = (sensor_data > threshold);
    wire [2:0] limit_eff = {persistence_limit[2:1],
                            persistence_limit[0] | ~(|persistence_limit[2:1])};
    wire [2:0] count_next = persistence_counter + 3'd1;
    wire       limit_hit  = (count_next >= limit_eff);

    assign warning  = state[0];
    assign critical = state[1];

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
