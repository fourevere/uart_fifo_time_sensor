`timescale 1ns / 1ps

module stopwatch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                     clk,
    input                     rst,
    input                     i_run_stop,
    input                     i_clear,
    input                     i_type,
    output [MSEC_WIDTH - 1:0] o_st_msec,
    output [ SEC_WIDTH - 1:0] o_st_sec,
    output [ MIN_WIDTH - 1:0] o_st_min,
    output [HOUR_WIDTH - 1:0] o_st_hour
);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    tick_counter #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_hour_tick),  // from min o_tick
        .i_clear     (i_clear),
        .i_type      (i_type),
        .time_counter(o_st_hour),
        .o_tick      ()
    );

    tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_min_tick),  // from sec o_tick
        .i_clear     (i_clear),
        .i_type      (i_type),
        .time_counter(o_st_min),
        .o_tick      (w_hour_tick)
    );

    tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_sec_tick),  // from msec o_tick
        .i_clear     (i_clear),
        .i_type      (i_type),
        .time_counter(o_st_sec),
        .o_tick      (w_min_tick)
    );

    tick_counter #(
        .TIMES    (100),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_tick_100hz),
        .i_clear     (i_clear),
        .i_type      (i_type),
        .time_counter(o_st_msec),
        .o_tick      (w_sec_tick)
    );

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk         (clk),
        .rst         (rst),
        .i_run_stop  (i_run_stop),
        .i_clear     (i_clear),
        .o_tick_100hz(w_tick_100hz)
    );

endmodule

// tick_counter
module tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input                          clk,
    input                          rst,
    input                          i_tick,
    input                          i_clear,
    input                          i_type,
    output     [BIT_WIDTH - 1 : 0] time_counter,
    output reg                     o_tick
);

    // counter register
    reg [BIT_WIDTH-1:0] counter_reg, counter_next;
    assign time_counter = counter_reg;





    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    // next counter CL : blocking / =
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (i_tick) begin
            // output : next / counter_next , input : current / counter_reg
            if (i_type) begin
                counter_next = counter_reg - 1;
                if (counter_reg == 0) begin
                    o_tick = 1'b1;
                    counter_next = TIMES - 1;
                end else begin
                    o_tick = 1'b0;
                end
            end else begin
                counter_next = counter_reg + 1;
                if (counter_reg == TIMES - 1) begin
                    o_tick = 1'b1;
                    counter_next = 0;
                end else begin
                    o_tick = 1'b0;
                end
            end
        end else if (i_clear) begin
            counter_next = 0;
            o_tick       = 1'b0;
        end
    end

endmodule

// tick gen 100hz
module tick_gen_100hz (
    input      clk,
    input      rst,
    input      i_run_stop,
    input      i_clear,
    output reg o_tick_100hz
);
    // 100 Hz counter number
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg  <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            if (i_run_stop) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == F_COUNT - 1) begin
                    counter_reg  <= 0;
                    o_tick_100hz <= 1'b1;
                end else begin
                    o_tick_100hz <= 1'b0;
                end
            end else if (i_clear) begin
                counter_reg  <= 0;
                o_tick_100hz <= 1'b0;
            end
        end
    end
endmodule
