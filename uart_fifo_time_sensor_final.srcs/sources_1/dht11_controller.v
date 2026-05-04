`timescale 1ns / 1ps

module dht11_controller (
    input        clk,
    input        rst,
    input        i_dht11_start,
    input        tick_us,
    output [7:0] o_humidity,
    output [7:0] o_temperature,
    output       valid,          // for ckeck sum
    output       o_dht11_done,
    inout        dht11
);

    parameter IDLE = 0, START = 1, WAIT = 2, SYNC_L = 3, SYNC_H = 4;
    parameter DATA_SYNC = 5, DATA_COUNT = 6, DATA_DECISION = 7;
    parameter STOP = 8;

    reg [3:0] c_state, n_state;
    reg [5:0] bit_cnt_reg, bit_cnt_next;  // receive bit counter
    reg [$clog2(19_000)-1:0]
        tick_cnt_reg, tick_cnt_next;  // general rick counter
    reg out_sel_reg, out_sel_next;  // dht11 io 3state control
    reg dht11_reg, dht11_next;  // dht11 output drive
    reg o_dht11_done_reg, o_dht11_done_next;

    reg [39:0] data_reg, data_next;
    // dht11 output 3state control
    assign dht11 = (out_sel_reg) ? dht11_reg : 1'bz;

    assign valid = (data_reg[7:0] == (data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]))? 1:0;
    assign o_humidity = data_reg[39:32];
    assign o_temperature = data_reg[23:16];

    assign o_dht11_done = o_dht11_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state          <= IDLE;
            bit_cnt_reg      <= 0;
            tick_cnt_reg     <= 0;
            out_sel_reg      <= 1'b1;  // defualtoutput mode
            dht11_reg        <= 1'b1;  // default high state
            data_reg         <= 0;
            o_dht11_done_reg <= 1'b0;
        end else begin
            c_state          <= n_state;
            bit_cnt_reg      <= bit_cnt_next;
            tick_cnt_reg     <= tick_cnt_next;
            out_sel_reg      <= out_sel_next;
            dht11_reg        <= dht11_next;
            data_reg         <= data_next;
            o_dht11_done_reg <= o_dht11_done_next;
        end
    end

    always @(*) begin
        n_state           = c_state;
        bit_cnt_next      = bit_cnt_reg;
        tick_cnt_next     = tick_cnt_reg;
        out_sel_next      = out_sel_reg;
        dht11_next        = dht11_reg;
        data_next         = data_reg;

        o_dht11_done_next = 1'b0;

        case (c_state)
            IDLE: begin
                dht11_next        = 1'b1;
                out_sel_next      = 1'b1;
                o_dht11_done_next = 1'b0;
                if (i_dht11_start) begin
                    bit_cnt_next  = 0;
                    tick_cnt_next = 0;
                    n_state       = START;
                end
            end
            START: begin
                dht11_next = 1'b0;
                if (tick_us) begin
                    if (tick_cnt_reg > 19_000) begin
                        tick_cnt_next = 0;
                        n_state = WAIT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                dht11_next = 1'b1;
                if (tick_us) begin
                    if (tick_cnt_reg > 30) begin
                        tick_cnt_next = 0;
                        n_state = SYNC_L;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNC_L: begin
                // output is high impedance "z"
                out_sel_next = 1'b0;
                if (tick_us) begin
                    if ((tick_cnt_reg > 40) && (dht11)) begin
                        tick_cnt_next = 0;
                        n_state = SYNC_H;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNC_H: begin
                if (tick_us) begin
                    if ((tick_cnt_reg > 40) && (!dht11)) begin
                        tick_cnt_next = 0;
                        n_state = DATA_SYNC;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_SYNC: begin
                if (tick_us) begin
                    if (dht11) begin
                        tick_cnt_next = 0;
                        n_state = DATA_COUNT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_COUNT: begin
                if (tick_us) begin
                    if (!dht11) begin
                        //tick_cnt_next = 0;
                        n_state = DATA_DECISION;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end

            DATA_DECISION: begin
                if (tick_cnt_reg > 45) begin
                    data_next = {data_reg[38:0], 1'b1};
                end else begin
                    data_next = {data_reg[38:0], 1'b0};
                end

                tick_cnt_next = 0;

                if (bit_cnt_reg == 39) begin
                    bit_cnt_next = 0;
                    o_dht11_done_next = 1'b1;
                    n_state = STOP;
                end else begin
                    bit_cnt_next = bit_cnt_reg + 1;
                    n_state = DATA_SYNC;
                end
            end

            STOP: begin
                if (tick_us) begin
                    if (tick_cnt_reg > 60) begin
                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                        n_state = STOP;
                    end
                end else n_state = STOP;
            end

        endcase
    end

endmodule
