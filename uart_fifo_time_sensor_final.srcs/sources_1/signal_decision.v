`timescale 1ns / 1ps

module signal_decision (
    input        clk,
    input        rst,
    input        i_btnL,
    input        i_btnR,
    input        i_btnU,
    input        i_btnD,
    input        signal_L,
    input        signal_R,
    input        signal_U,
    input        signal_D,
    input        signal_C,
    input        signal_S,
    input        signal_T,
    input        signal_M,
    input  [1:0] sw_mode,
    input        i_sr04_done,
    input        i_dht11_done,
    output       o_wt_left,
    output       o_wt_right,
    output       o_wt_up,
    output       o_wt_down,
    output       o_st_clear,
    output       o_st_run_stop,
    output       o_st_type,
    output       o_dht11_signal,
    output       o_sr04_signal,
    output       o_sender_start
);

    assign o_wt_left      = (sw_mode == 2'b00) && (i_btnL | signal_L);
    assign o_wt_right     = (sw_mode == 2'b00) && (i_btnR | signal_R);
    assign o_wt_up        = (sw_mode == 2'b00) && (i_btnU | signal_U);
    assign o_wt_down      = (sw_mode == 2'b00) && (i_btnD | signal_D);

    assign o_st_clear     = (sw_mode == 2'b01) && (i_btnL | signal_C);
    assign o_st_run_stop  = (sw_mode == 2'b01) && (i_btnR | signal_S);
    assign o_st_type      = (sw_mode == 2'b01) && (i_btnD | signal_T);

    assign o_dht11_signal = (sw_mode == 2'b10) && (i_btnR | signal_M);
    assign o_sr04_signal  = (sw_mode == 2'b11) && (i_btnR | signal_M);

    wire sensor_done;
    wire sensor_signal;

    assign sensor_done   = i_sr04_done | i_dht11_done;
    assign sensor_signal = o_dht11_signal | o_sr04_signal;

    wire w_active = i_btnL | i_btnR | i_btnU | i_btnD | 
                    signal_L | signal_R | signal_U | signal_D | 
                    signal_C | signal_S | signal_T | signal_M;

    reg r_active_delay;
    reg o_sender_start_reg, o_sender_start_next;
    reg sensor_pending, sensor_pending_next;

    assign o_sender_start = o_sender_start_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_active_delay     <= 1'b0;
            o_sender_start_reg <= 1'b0;
            sensor_pending     <= 1'b0;
        end else begin
            r_active_delay     <= w_active;
            o_sender_start_reg <= o_sender_start_next;
            sensor_pending     <= sensor_pending_next;
        end
    end

    always @(*) begin
        o_sender_start_next = 1'b0;
        sensor_pending_next = sensor_pending;

        if (sensor_signal & w_active & ~r_active_delay) begin
            sensor_pending_next = 1'b1;
        end

        if (sensor_pending & sensor_done) begin
            o_sender_start_next = 1'b1;
            sensor_pending_next = 1'b0;
        end else begin
            if ((~sensor_signal) & w_active & ~r_active_delay) begin
                o_sender_start_next = 1'b1;
            end
        end
    end


endmodule
