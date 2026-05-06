`timescale 1ns / 1ps

module top_uart_time_sensor (
    input        clk,
    input        rst,
    input        echo,
    input        btnR,
    input        btnL,
    input        btnU,
    input        btnD,
    input  [3:0] sw,
    input        rx,
    output       tx,
    output       trig,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [7:0] led,
    inout        dht11
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [7:0] w_rx_data, w_tx_pop_data;
    wire w_rx_done, w_tx_pop_empty;
    wire w_tx_busy;
    wire w_rx_pop_empty, w_tx_fifo_full, w_tx_fifo_push;
    wire w_sender_start;

    wire w_signal_U, w_signal_D, w_signal_L, w_signal_R;
    wire w_signal_T, w_signal_S, w_signal_C, w_signal_M;

    wire [MSEC_WIDTH-1:0] w_msec, w_wt_msec, w_st_msec;
    wire [SEC_WIDTH-1:0] w_sec, w_wt_sec, w_st_sec;
    wire [MIN_WIDTH-1:0] w_min, w_wt_min, w_st_min;
    wire [HOUR_WIDTH-1:0] w_hour, w_wt_hour, w_st_hour;

    wire w_run_stop, w_clear, w_type;
    wire w_btnR, w_btnL, w_btnU, w_btnD;
    wire w_wt_left, w_wt_right, w_wt_up, w_wt_down;
    wire w_st_run_stop, w_st_clear, w_st_type;

    wire [2:0] w_edit;
    wire w_digit, w_up_down;

    wire [7:0] w_wt_led;
    wire [1:0] w_led1;
    wire w_tick_us;
    wire [7:0] w_humidity, w_temperature;
    wire [8:0] w_distance, w_temp_dist, w_humi_dist;

    wire [72:0] w_sender_data;
    wire w_dht11_signal, w_sr04_signal;
    wire w_dht11_start, w_sr04_start;
    wire w_sr04_done, w_dht11_done;
    
    wire [7:0] w_ascii_decoder, w_tx_fifo_push_data;
    wire w_rx_fifo_pop;
    assign w_rx_fifo_pop = ~w_rx_pop_empty;

    assign w_sender_data = {
        w_wt_hour,  // [72:68]  (5-bit)
        w_wt_min,  // [67:62]  (6-bit)
        w_wt_sec,  // [61:56]  (6-bit)
        w_wt_msec,  // [55:49]  (7-bit)
        w_st_hour,  // [48:44]  (5-bit)
        w_st_min,  // [43:38]  (6-bit)
        w_st_sec,  // [37:32]  (6-bit)
        w_st_msec,  // [31:25]  (7-bit)
        w_temperature,  // [24:17]  (8bit)
        w_humidity,  // [16:9]   (8bit)
        w_distance  // [8:0]    (9bit)
    };

    uart U_UART_TOP (
        .clk     (clk),
        .rst     (rst),
        .tx_start(~w_tx_pop_empty),
        .tx_data (w_tx_pop_data),
        .rx      (rx),
        .rx_data (w_rx_data),
        .rx_done (w_rx_done),
        .tx_busy (w_tx_busy),
        .tx      (tx)
    );

    fifo U_FIFO_RX (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_data),
        .push     (w_rx_done),
        .pop      (w_rx_fifo_pop),
        .pop_data (w_ascii_decoder),
        .full     (),
        .empty    (w_rx_pop_empty)
    );


    fifo #(
        .DEPTH(32)
    ) U_FIFO_TX (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_tx_fifo_push_data),
        .push     (w_tx_fifo_push),
        .pop      (~w_tx_busy),
        .pop_data (w_tx_pop_data),
        .full     (w_tx_fifo_full),
        .empty    (w_tx_pop_empty)
    );

    ascii_decoder U_ASCII_DECODER (
        .i_valid        (w_rx_fifo_pop),
        .i_ascii_decoder(w_ascii_decoder),
        .signal_U       (w_signal_U),
        .signal_D       (w_signal_D),
        .signal_R       (w_signal_R),
        .signal_L       (w_signal_L),
        .signal_T       (w_signal_T),
        .signal_S       (w_signal_S),
        .signal_C       (w_signal_C),
        .signal_M       (w_signal_M)
    );

    ascii_sender U_ASCII_SENDER (
        .clk              (clk),
        .rst              (rst),
        .i_sender_start   (w_sender_start),
        .i_tx_fifo_full   (w_tx_fifo_full),
        .i_sender_data    (w_sender_data),
        .sw_mode          (sw[1:0]),
        .tx_fifo_push     (w_tx_fifo_push),
        .tx_fifo_push_data(w_tx_fifo_push_data),  // [7:0]
        .o_sender_busy    (),
        .o_sender_done    ()
    );

    btn_debounce U_BTN_DEBOUNCE (
        .clk(clk),
        .rst(rst),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .btnD(btnD),
        .o_btnR(w_btnR),
        .o_btnL(w_btnL),
        .o_btnU(w_btnU),
        .o_btnD(w_btnD)
    );

    signal_decision U_SIG_DECISION (
        .clk           (clk),
        .rst           (rst),
        .i_btnL        (w_btnL),
        .i_btnR        (w_btnR),
        .i_btnU        (w_btnU),
        .i_btnD        (w_btnD),
        .signal_U      (w_signal_U),
        .signal_D      (w_signal_D),
        .signal_L      (w_signal_L),
        .signal_R      (w_signal_R),
        .signal_T      (w_signal_T),
        .signal_S      (w_signal_S),
        .signal_C      (w_signal_C),
        .signal_M      (w_signal_M),
        .sw_mode       (sw[1:0]),
        .i_sr04_done   (w_sr04_done),
        .i_dht11_done  (w_dht11_done),
        .o_wt_left     (w_wt_left),
        .o_wt_right    (w_wt_right),
        .o_wt_up       (w_wt_up),
        .o_wt_down     (w_wt_down),
        .o_st_clear    (w_st_clear),
        .o_st_run_stop (w_st_run_stop),
        .o_st_type     (w_st_type),
        .o_dht11_signal(w_dht11_signal),
        .o_sr04_signal (w_sr04_signal),
        .o_sender_start(w_sender_start)
    );

    control_unit U_CTRL_UNIT (
        .clk           (clk),
        .rst           (rst),
        .i_wt_left     (w_wt_left),
        .i_wt_right    (w_wt_right),
        .i_wt_up       (w_wt_up),
        .i_wt_down     (w_wt_down),
        .i_st_type     (w_st_type),
        .i_st_clear    (w_st_clear),
        .i_st_run_stop (w_st_run_stop),
        .i_dht11_signal(w_dht11_signal),
        .i_sr04_signal (w_sr04_signal),
        .sw_fnd        (sw[2]),
        .sw_edit       (sw[3]),
        .o_type        (w_type),
        .o_run_stop    (w_run_stop),
        .o_clear       (w_clear),
        .o_wt_led      (w_wt_led),
        .o_edit        (w_edit),
        .o_digit       (w_digit),
        .o_up_down     (w_up_down),
        .o_dht11_start (w_dht11_start),
        .o_sr04_start  (w_sr04_start)
    );

    watch_datapath U_WATCH_DATAPATH (
        .clk      (clk),
        .rst      (rst),
        .i_digit  (w_digit),
        .i_up_down(w_up_down),
        .i_edit   (w_edit),
        .o_wt_msec(w_wt_msec),
        .o_wt_sec (w_wt_sec),
        .o_wt_min (w_wt_min),
        .o_wt_hour(w_wt_hour)
    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk       (clk),
        .rst       (rst),
        .i_run_stop(w_run_stop),
        .i_clear   (w_clear),
        .i_type    (w_type),
        .o_st_msec (w_st_msec),
        .o_st_sec  (w_st_sec),
        .o_st_min  (w_st_min),
        .o_st_hour (w_st_hour)
    );

    tick_gen_us U_TICK_GEN_US (
        .clk(clk),
        .rst(rst),
        .tick_us(w_tick_us)
    );

    dht11_controller U_DHT11_CONTROLLER (
        .clk          (clk),
        .rst          (rst),
        .i_dht11_start(w_dht11_start),
        .tick_us      (w_tick_us),
        .o_humidity   (w_humidity),
        .o_temperature(w_temperature),
        .valid        (),               // for ckeck sum
        .o_dht11_done (w_dht11_done),
        .dht11        (dht11)
    );

    sr04_controller U_SR04_CONTROLLER (
        .clk         (clk),
        .rst         (rst),
        .i_sr04_start(w_sr04_start),
        .tick_us     (w_tick_us),
        .echo        (echo),
        .trig        (trig),
        .o_sr04_done (w_sr04_done),
        .o_distance  (w_distance)
    );

    mux_4x_1_top #(
        .WIDTH(8)
    ) U_LED_SEL (
        .i_wt_led   (w_wt_led),
        .i_st_led   ({5'b00000, sw[2:0]}),
        .i_dht11_led({5'b00000, sw[2:0]}),
        .i_sr04_led ({5'b00000, sw[2:0]}),
        .sw_mode    (sw[1:0]),
        .out_mux    (led)
    );

    mux_2sel #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_MODE_SEL (
        .i_st_msec    (w_st_msec),
        .i_st_sec     (w_st_sec),
        .i_st_min     (w_st_min),
        .i_st_hour    (w_st_hour),
        .i_wt_msec    (w_wt_msec),
        .i_wt_sec     (w_wt_sec),
        .i_wt_min     (w_wt_min),
        .i_wt_hour    (w_wt_hour),
        .i_humidity   (w_humidity),
        .i_temperature(w_temperature),
        .i_distance   (w_distance),
        .sw_mode      (sw[1:0]),
        .o_msec       (w_msec),
        .o_sec        (w_sec),
        .o_min        (w_min),
        .o_hour       (w_hour),
        .o_temp_dist  (w_temp_dist),
        .o_humi_dist  (w_humi_dist)
    );

    fnd_controller U_FND_CNTL (
        .clk        (clk),
        .rst        (rst),
        .sw         (sw),
        .i_temp_dist(w_temp_dist),
        .i_humi_dist(w_humi_dist),
        .i_digit_led(led[7:4]),
        .i_msec     (w_msec),
        .i_sec      (w_sec),
        .i_min      (w_min),
        .i_hour     (w_hour),
        .fnd_com    (fnd_com),
        .fnd_data   (fnd_data)
    );

endmodule

module mux_2sel #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input  [MSEC_WIDTH-1:0] i_st_msec,
    input  [ SEC_WIDTH-1:0] i_st_sec,
    input  [ MIN_WIDTH-1:0] i_st_min,
    input  [HOUR_WIDTH-1:0] i_st_hour,
    input  [MSEC_WIDTH-1:0] i_wt_msec,
    input  [ SEC_WIDTH-1:0] i_wt_sec,
    input  [ MIN_WIDTH-1:0] i_wt_min,
    input  [HOUR_WIDTH-1:0] i_wt_hour,
    input  [           7:0] i_humidity,
    input  [           7:0] i_temperature,
    input  [           8:0] i_distance,
    input  [           1:0] sw_mode,
    output [MSEC_WIDTH-1:0] o_msec,
    output [ SEC_WIDTH-1:0] o_sec,
    output [ MIN_WIDTH-1:0] o_min,
    output [HOUR_WIDTH-1:0] o_hour,
    output [           8:0] o_temp_dist,
    output [           8:0] o_humi_dist
);

    assign o_msec = (sw_mode == 2'b01) ? i_st_msec : i_wt_msec;
    assign o_sec = (sw_mode == 2'b01) ? i_st_sec : i_wt_sec;
    assign o_min = (sw_mode == 2'b01) ? i_st_min : i_wt_min;
    assign o_hour = (sw_mode == 2'b01) ? i_st_hour : i_wt_hour;

    assign o_temp_dist = (sw_mode == 2'b10) ? {1'b0,i_temperature} : i_distance;
    assign o_humi_dist = (sw_mode == 2'b10) ? {1'b0, i_humidity} : i_distance;
endmodule

module mux_4x_1_top #(
    parameter WIDTH = 7
) (
    input  [WIDTH - 1:0] i_wt_led,
    input  [WIDTH - 1:0] i_st_led,
    input  [WIDTH - 1:0] i_dht11_led,
    input  [WIDTH - 1:0] i_sr04_led,
    input  [        1:0] sw_mode,
    output [WIDTH - 1:0] out_mux
);

    reg [WIDTH-1:0] out_reg;
    assign out_mux = out_reg;

    always @(*) begin
        case (sw_mode)
            2'b00:   out_reg = i_wt_led;
            2'b01:   out_reg = i_st_led;
            2'b10:   out_reg = i_dht11_led;
            2'b11:   out_reg = i_sr04_led;
            default: out_reg = i_wt_led;
        endcase
    end

endmodule
