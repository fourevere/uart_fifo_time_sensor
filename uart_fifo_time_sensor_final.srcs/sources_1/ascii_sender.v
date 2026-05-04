`timescale 1ns / 1ps

module ascii_sender (
    input clk,
    input rst,

    input        i_sender_start,
    input        i_tx_fifo_full,
    input [72:0] i_sender_data,
    input [ 1:0] sw_mode,

    output       tx_fifo_push,
    output [7:0] tx_fifo_push_data,
    output       o_sender_busy,
    output       o_sender_done
);

    parameter IDLE = 0, LOAD = 1, SEND = 2, WAIT = 3, NEXT = 4, DONE = 5;

    reg [2:0] c_state, n_state;
    reg [3:0] idx_reg, idx_next;
    reg [7:0] tx_fifo_push_data_reg, tx_fifo_push_data_next;
    reg tx_fifo_push_reg, tx_fifo_push_next;
    reg o_sender_busy_reg, o_sender_busy_next;
    reg o_sender_done_reg, o_sender_done_next;

    wire [7:0] w_ascii_wt_hour_10, w_ascii_wt_hour_1,w_ascii_wt_min_10,w_ascii_wt_min_1;
    wire [7:0] w_ascii_wt_sec_10, w_ascii_wt_sec_1 ,w_ascii_wt_msec_10,w_ascii_wt_msec_1;
    wire [7:0] w_ascii_st_hour_10,w_ascii_st_hour_1 ,w_ascii_st_min_10 ,w_ascii_st_min_1;
    wire [7:0]w_ascii_st_sec_10 ,w_ascii_st_sec_1  ,w_ascii_st_msec_10,w_ascii_st_msec_1;
    wire [7:0] w_ascii_temp_10, w_ascii_temp_1;
    wire [7:0] w_ascii_hum_100, w_ascii_hum_10, w_ascii_hum_1;
    wire [7:0] w_ascii_dist_100, w_ascii_dist_10, w_ascii_dist_1;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state               <= IDLE;
            idx_reg               <= 4'd0;
            tx_fifo_push_reg      <= 1'b0;
            tx_fifo_push_data_reg <= 0;
            o_sender_busy_reg     <= 1'b0;
            o_sender_done_reg     <= 1'b0;
        end else begin
            c_state               <= n_state;
            idx_reg               <= idx_next;
            tx_fifo_push_reg      <= tx_fifo_push_next;
            tx_fifo_push_data_reg <= tx_fifo_push_data_next;
            o_sender_busy_reg     <= o_sender_busy_next;
            o_sender_done_reg     <= o_sender_done_next;
        end
    end

    assign tx_fifo_push      = tx_fifo_push_reg;
    assign tx_fifo_push_data = tx_fifo_push_data_reg;
    assign o_sender_busy     = o_sender_busy_reg;
    assign o_sender_done     = o_sender_done_reg;

    always @(*) begin
        n_state                = c_state;
        idx_next               = idx_reg;
        tx_fifo_push_next      = tx_fifo_push_reg;
        tx_fifo_push_data_next = tx_fifo_push_data_reg;
        o_sender_busy_next     = o_sender_busy_reg;
        o_sender_done_next     = o_sender_done_reg;

        case (c_state)
            IDLE: begin
                tx_fifo_push_next  = 1'b0;
                o_sender_done_next = 1'b0;
                o_sender_busy_next = 1'b0;
                if (i_sender_start) begin
                    n_state = LOAD;
                end else begin
                    n_state = IDLE;
                end
            end
            LOAD: begin
                o_sender_busy_next = 1'b1;
                idx_next           = 4'd0;
                n_state            = SEND;
            end
            SEND: begin
                if (!i_tx_fifo_full) begin
                    tx_fifo_push_next = 1'b1;
                    case (sw_mode[1:0])
                        // watch
                        2'b00: begin
                            case (idx_reg)
                                0: tx_fifo_push_data_next = 8'h57;
                                1: tx_fifo_push_data_next = 8'h54;
                                2: tx_fifo_push_data_next = 8'h20;
                                3: tx_fifo_push_data_next = w_ascii_wt_hour_10;
                                4: tx_fifo_push_data_next = w_ascii_wt_hour_1;
                                5: tx_fifo_push_data_next = 8'h3A;
                                6: tx_fifo_push_data_next = w_ascii_wt_min_10;
                                7: tx_fifo_push_data_next = w_ascii_wt_min_1;
                                8: tx_fifo_push_data_next = 8'h3A;
                                9: tx_fifo_push_data_next = w_ascii_wt_sec_10;
                                10: tx_fifo_push_data_next = w_ascii_wt_sec_1;
                                11: tx_fifo_push_data_next = 8'h3A;
                                12: tx_fifo_push_data_next = w_ascii_wt_msec_10;
                                13: tx_fifo_push_data_next = w_ascii_wt_msec_1;
                                14: tx_fifo_push_data_next = 8'h0D;
                                15: tx_fifo_push_data_next = 8'h0A;
                                default: tx_fifo_push_data_next = 8'h20;
                            endcase
                        end
                        // stop watch
                        2'b01: begin
                            case (idx_reg)
                                0: tx_fifo_push_data_next = 8'h53;
                                1: tx_fifo_push_data_next = 8'h54;
                                2: tx_fifo_push_data_next = 8'h20;
                                3: tx_fifo_push_data_next = w_ascii_st_hour_10;
                                4: tx_fifo_push_data_next = w_ascii_st_hour_1;
                                5: tx_fifo_push_data_next = 8'h3A;
                                6: tx_fifo_push_data_next = w_ascii_st_min_10;
                                7: tx_fifo_push_data_next = w_ascii_st_min_1;
                                8: tx_fifo_push_data_next = 8'h3A;
                                9: tx_fifo_push_data_next = w_ascii_st_sec_10;
                                10: tx_fifo_push_data_next = w_ascii_st_sec_1;
                                11: tx_fifo_push_data_next = 8'h3A;
                                12: tx_fifo_push_data_next = w_ascii_st_msec_10;
                                13: tx_fifo_push_data_next = w_ascii_st_msec_1;
                                14: tx_fifo_push_data_next = 8'h0D;
                                15: tx_fifo_push_data_next = 8'h0A;
                                default: tx_fifo_push_data_next = 8'h20;
                            endcase
                        end
                        // dht11
                        2'b10: begin
                            case (idx_reg)
                                0: tx_fifo_push_data_next = 8'h54;
                                1: tx_fifo_push_data_next = 8'h3A;
                                2: tx_fifo_push_data_next = w_ascii_temp_10;
                                3: tx_fifo_push_data_next = w_ascii_temp_1;
                                4: tx_fifo_push_data_next = 8'hA1;
                                5: tx_fifo_push_data_next = 8'hC6;
                                6: tx_fifo_push_data_next = 8'h43;
                                7: tx_fifo_push_data_next = 8'h20;
                                8: tx_fifo_push_data_next = 8'h48;
                                9: tx_fifo_push_data_next = 8'h3A;
                                10: tx_fifo_push_data_next = w_ascii_hum_100;
                                11: tx_fifo_push_data_next = w_ascii_hum_10;
                                12: tx_fifo_push_data_next = w_ascii_hum_1;
                                13: tx_fifo_push_data_next = 8'h25;
                                14: tx_fifo_push_data_next = 8'h0D;
                                15: tx_fifo_push_data_next = 8'h0A;
                                default: tx_fifo_push_data_next = 8'h20;
                            endcase
                        end
                        // sr04
                        2'b11: begin
                            case (idx_reg)
                                0: tx_fifo_push_data_next = 8'h44;
                                1: tx_fifo_push_data_next = 8'h3A;
                                2: tx_fifo_push_data_next = w_ascii_dist_100;
                                3: tx_fifo_push_data_next = w_ascii_dist_10;
                                4: tx_fifo_push_data_next = w_ascii_dist_1;
                                5: tx_fifo_push_data_next = 8'h63;
                                6: tx_fifo_push_data_next = 8'h6D;
                                7: tx_fifo_push_data_next = 8'h20;
                                8: tx_fifo_push_data_next = 8'h20;
                                9: tx_fifo_push_data_next = 8'h20;
                                10: tx_fifo_push_data_next = 8'h20;
                                11: tx_fifo_push_data_next = 8'h20;
                                12: tx_fifo_push_data_next = 8'h20;
                                13: tx_fifo_push_data_next = 8'h20;
                                14: tx_fifo_push_data_next = 8'h0D;
                                15: tx_fifo_push_data_next = 8'h0A;
                                default: tx_fifo_push_data_next = 8'h20;
                            endcase
                        end
                    endcase
                    n_state = WAIT;
                end else begin
                    tx_fifo_push_next = 1'b0;
                    n_state = SEND;
                end
            end
            WAIT: begin
                tx_fifo_push_next = 1'b0;
                n_state = NEXT;
            end
            NEXT: begin
                if (idx_reg == 4'd15) begin
                    idx_next = 4'd0;
                    n_state  = DONE;
                end else begin
                    idx_next = idx_reg + 1;
                    n_state  = SEND;
                end
            end
            DONE: begin
                o_sender_busy_next = 1'b0;
                o_sender_done_next = 1'b1;
                n_state = IDLE;
            end
        endcase
    end

    sender_data_splitter U_SENDER_DATA_SPLIT (
        .i_sender_data   (i_sender_data),
        .ascii_wt_hour_10(w_ascii_wt_hour_10),
        .ascii_wt_hour_1 (w_ascii_wt_hour_1),
        .ascii_wt_min_10 (w_ascii_wt_min_10),
        .ascii_wt_min_1  (w_ascii_wt_min_1),
        .ascii_wt_sec_10 (w_ascii_wt_sec_10),
        .ascii_wt_sec_1  (w_ascii_wt_sec_1),
        .ascii_wt_msec_10(w_ascii_wt_msec_10),
        .ascii_wt_msec_1 (w_ascii_wt_msec_1),
        .ascii_st_hour_10(w_ascii_st_hour_10),
        .ascii_st_hour_1 (w_ascii_st_hour_1),
        .ascii_st_min_10 (w_ascii_st_min_10),
        .ascii_st_min_1  (w_ascii_st_min_1),
        .ascii_st_sec_10 (w_ascii_st_sec_10),
        .ascii_st_sec_1  (w_ascii_st_sec_1),
        .ascii_st_msec_10(w_ascii_st_msec_10),
        .ascii_st_msec_1 (w_ascii_st_msec_1),
        .ascii_temp_10   (w_ascii_temp_10),
        .ascii_temp_1    (w_ascii_temp_1),
        .ascii_hum_100   (w_ascii_hum_100),
        .ascii_hum_10    (w_ascii_hum_10),
        .ascii_hum_1     (w_ascii_hum_1),
        .ascii_dist_100  (w_ascii_dist_100),
        .ascii_dist_10   (w_ascii_dist_10),
        .ascii_dist_1    (w_ascii_dist_1)
    );

endmodule
