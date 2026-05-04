`timescale 1ns / 1ps

module control_unit (
    input        clk,
    input        rst,
    input        i_wt_left,
    input        i_wt_right,
    input        i_wt_up,
    input        i_wt_down,
    input        i_st_type,       //down
    input        i_st_clear,      //left
    input        i_st_run_stop,   // right
    input        i_dht11_signal,
    input        i_sr04_signal,
    input        sw_fnd,          //sw[1]
    input        sw_edit,         // sw[2]
    output       o_type,
    output       o_run_stop,
    output       o_clear,
    output [7:0] o_wt_led,
    output [2:0] o_edit,
    output       o_digit,
    output       o_up_down,
    output       o_dht11_start,
    output       o_sr04_start
);

    watch_control_unit U_WT_CTRL (
        .clk       (clk),
        .rst       (rst),
        .i_wt_left (i_wt_left),
        .i_wt_right(i_wt_right),
        .i_wt_up   (i_wt_up),
        .i_wt_down (i_wt_down),
        .sw_fnd    (sw_fnd),
        .sw_edit   (sw_edit),
        .o_wt_led  (o_wt_led),
        .o_edit    (o_edit),
        .o_digit   (o_digit),
        .o_up_down (o_up_down)
    );

    stop_watch_control_unit U_ST_CTRL (
        .clk          (clk),
        .rst          (rst),
        .i_st_type    (i_st_type),      //down
        .i_st_clear   (i_st_clear),     //left
        .i_st_run_stop(i_st_run_stop),  // right
        .o_type       (o_type),
        .o_run_stop   (o_run_stop),
        .o_clear      (o_clear)
    );

    dht11_control_unit U_DHT11_CTRL (
        .clk           (clk),
        .rst           (rst),
        .i_dht11_signal(i_dht11_signal),
        .o_dht11_start (o_dht11_start)
    );

    sr04_control_unit U_SR04_CTRL (
        .clk          (clk),
        .rst          (rst),
        .i_sr04_signal(i_sr04_signal),
        .o_sr04_start (o_sr04_start)
    );

endmodule

module dht11_control_unit (
    input  clk,
    input  rst,
    input  i_dht11_signal,
    output o_dht11_start
);

    parameter DHT_SET = 0, DHT_MEASURE = 1;

    reg c_state, n_state;
    reg dht11_start_reg, dht11_start_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= DHT_SET;
            dht11_start_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            dht11_start_reg <= dht11_start_next;
        end
    end

    assign o_dht11_start = dht11_start_reg;

    always @(*) begin
        dht11_start_next = 1'b0;
        n_state = c_state;
        case (c_state)
            DHT_SET: begin
                if (i_dht11_signal) begin
                    n_state = DHT_MEASURE;
                end
            end
            DHT_MEASURE: begin
                dht11_start_next = 1'b1;
                n_state = DHT_SET;
            end
        endcase
    end

endmodule

module sr04_control_unit (
    input  clk,
    input  rst,
    input  i_sr04_signal,
    output o_sr04_start
);

    parameter DIST_SET = 0, DIST_MEASURE = 1;

    reg c_state, n_state;
    reg sr04_start_reg, sr04_start_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= DIST_SET;
            sr04_start_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            sr04_start_reg <= sr04_start_next;
        end
    end

    assign o_sr04_start = sr04_start_reg;

    always @(*) begin
        sr04_start_next = 1'b0;
        n_state = c_state;
        case (c_state)
            DIST_SET: begin
                if (i_sr04_signal) begin
                    n_state = DIST_MEASURE;
                end
            end
            DIST_MEASURE: begin
                sr04_start_next = 1'b1;
                n_state = DIST_SET;
            end
        endcase
    end

endmodule
