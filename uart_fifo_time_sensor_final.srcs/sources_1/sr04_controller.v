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

    parameter IDLE     = 0;
    parameter START    = 1;
    parameter WAIT     = 2;
    parameter RESPONSE = 3;

    parameter MAX_DISTANCE = 400;

    reg [1:0] current_state, next_state;

    reg [4:0] tick_us_cnt_reg, tick_us_cnt_next;
    reg [5:0] cm_cnt_reg, cm_cnt_next;       // 0~57 count
    reg trig_reg, trig_next;

    reg o_sr04_done_reg, o_sr04_done_next;
    reg [8:0] distance_next;

    assign trig = trig_reg;
    assign o_sr04_done = o_sr04_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state      <= IDLE;
            tick_us_cnt_reg    <= 0;
            cm_cnt_reg         <= 0;
            trig_reg           <= 1'b0;
            o_sr04_done_reg    <= 1'b0;
            o_distance         <= 0;
        end else begin
            current_state      <= next_state;
            tick_us_cnt_reg    <= tick_us_cnt_next;
            cm_cnt_reg         <= cm_cnt_next;
            trig_reg           <= trig_next;
            o_sr04_done_reg    <= o_sr04_done_next;
            o_distance         <= distance_next;
        end
    end

    always @(*) begin
        next_state        = current_state;
        tick_us_cnt_next  = tick_us_cnt_reg;
        cm_cnt_next       = cm_cnt_reg;
        trig_next         = trig_reg;
        o_sr04_done_next  = 1'b0;
        distance_next     = o_distance;

        case (current_state)

            IDLE: begin
                trig_next = 1'b0;
                if (i_sr04_start) begin
                    tick_us_cnt_next = 0;
                    cm_cnt_next   = 0;
                    distance_next = 0;
                    next_state    = START;
                end
            end

            START: begin
                trig_next = 1'b1;
                if (tick_us) begin
                    if (tick_us_cnt_reg == 11) begin
                        tick_us_cnt_next = 0;
                        trig_next     = 1'b0;
                        next_state    = WAIT;
                    end else begin
                        tick_us_cnt_next = tick_us_cnt_reg + 1;
                        next_state = START;
                    end
                end
            end

            WAIT: begin
                trig_next = 1'b0;
                if (echo) begin
                    cm_cnt_next   = 0;
                    distance_next = 0;
                    next_state    = RESPONSE;
                end
            end

            RESPONSE: begin
                if (tick_us) begin
                    if (echo) begin
                        if (cm_cnt_reg == 57) begin
                            cm_cnt_next = 0;
                            if (o_distance < MAX_DISTANCE) begin
                                distance_next = o_distance + 1;
                            end
                        end else begin
                            cm_cnt_next = cm_cnt_reg + 1;
                        end
                    end else begin
                        cm_cnt_next      = 0;
                        o_sr04_done_next = 1'b1;
                        next_state       = IDLE;
                    end
                end
            end
        endcase
    end
endmodule