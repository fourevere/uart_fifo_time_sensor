`timescale 1ns / 1ps

module sr04_controller (
    input            clk,
    input            rst,
    input            i_sr04_start,
    input            tick_us,
    input            echo,
    output           trig,
    output           o_sr04_done,
    output reg [8:0] o_distance
);
    parameter IDLE = 0, START = 1, WAIT = 2, RESPONSE = 3;
    parameter BIT = $clog2(400 * 58);


    reg [1:0] current_state, next_state;
    reg [BIT:0] tick_us_cnt_reg, tick_us_cnt_next;
    reg trig_reg, trig_next;
    reg o_sr04_done_reg, o_sr04_done_next;

    assign trig = trig_reg;
    assign o_sr04_done = o_sr04_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state   <= IDLE;
            tick_us_cnt_reg <= 1'b0;
            trig_reg        <= 1'b0;
            o_sr04_done_reg <= 1'b0;
        end else begin
            current_state   <= next_state;
            tick_us_cnt_reg <= tick_us_cnt_next;
            trig_reg        <= trig_next;
            o_sr04_done_reg <= o_sr04_done_next;
        end
    end

    always @(*) begin
        next_state       = current_state;
        tick_us_cnt_next = tick_us_cnt_reg;
        trig_next        = trig_reg;
        o_sr04_done_next = o_sr04_done_reg;
        o_distance       = tick_us_cnt_next / 58;

        case (current_state)
            IDLE: begin
                trig_next = 1'b0;
                o_sr04_done_next = 1'b0;
                if (i_sr04_start) begin
                    tick_us_cnt_next = 0; 
                    next_state = START;
                end else next_state = IDLE;
            end
            START: begin
                trig_next = 1'b1;
                if (tick_us) begin
                    tick_us_cnt_next = tick_us_cnt_reg + 1;
                    if (tick_us_cnt_reg == 11) begin
                        next_state = WAIT;
                    end else next_state = START;
                end else next_state = START;
            end
            WAIT: begin
                trig_next = 1'b0;
                if (tick_us == 1) begin
                    if (echo) begin
                        tick_us_cnt_next = 0;
                        next_state = RESPONSE;
                    end else next_state = WAIT;
                end else next_state = WAIT;
            end
            RESPONSE: begin
                if (tick_us) begin
                    tick_us_cnt_next = tick_us_cnt_reg + 1;
                    if (!echo) begin
                        o_sr04_done_next = 1'b1;
                        next_state = IDLE;
                    end else next_state = RESPONSE;
                end else next_state = RESPONSE;
            end
        endcase
    end
endmodule