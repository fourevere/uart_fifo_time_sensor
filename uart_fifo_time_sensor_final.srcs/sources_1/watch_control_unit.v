`timescale 1ns / 1ps

module watch_control_unit(
    input            clk,
    input            rst,
    input            i_wt_left,
    input            i_wt_right,
    input            i_wt_up,
    input            i_wt_down,
    input            sw_fnd,
    input            sw_edit,
    output reg [7:0] o_wt_led,
    output reg [2:0] o_edit,
    output reg       o_digit,
    output reg       o_up_down
);

    parameter RUN_HOUR_MIN = 0, RUN_SEC_MSEC = 1;
    parameter SET_10_HOUR = 2, CH_10U_HOUR = 3, CH_10D_HOUR = 4;
    parameter SET_1_HOUR = 5, CH_1U_HOUR = 6, CH_1D_HOUR = 7;
    parameter SET_10_MIN = 8, CH_10U_MIN = 9, CH_10D_MIN = 10;
    parameter SET_1_MIN = 11, CH_1U_MIN = 12, CH_1D_MIN = 13;
    parameter SET_10_SEC = 14, CH_10U_SEC = 15, CH_10D_SEC = 16;
    parameter SET_1_SEC = 17, CH_1U_SEC = 18, CH_1D_SEC = 19;

    reg [4:0] wt_c_state, wt_n_state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            wt_c_state <= RUN_HOUR_MIN;
        end else begin
            wt_c_state <= wt_n_state;
        end
    end

    always @(*) begin
        o_wt_led[7:0] = 8'b00000000;
        o_edit = 3'b000;  //3'b001 : sec, 3'b010 : min, 3'b100 : hour
        o_digit = 1'b0;  // 1'b1 : digit1, 1'b0 : digit10
        o_up_down = 1'b0;  // 1'b0 : up, 1'b1 : down
        wt_n_state = wt_c_state;
        case (wt_c_state)
            RUN_HOUR_MIN: begin
                o_wt_led = 8'b00000000;
                if (sw_fnd) wt_n_state = RUN_SEC_MSEC;
                else if (i_wt_right & sw_edit) wt_n_state = SET_10_HOUR;
                else if (i_wt_left & sw_edit) wt_n_state = SET_1_MIN;
                else wt_n_state = RUN_HOUR_MIN;
            end
            RUN_SEC_MSEC: begin
                o_wt_led = 8'b00000100;
                if (!sw_fnd) wt_n_state = RUN_HOUR_MIN;
                else if (i_wt_right & sw_edit) wt_n_state = SET_10_SEC;
                else if (i_wt_left & sw_edit) wt_n_state = SET_1_SEC;
                else wt_n_state = RUN_SEC_MSEC;
            end
            SET_10_HOUR: begin
                o_wt_led = 8'b10001000;
                if (!sw_edit) wt_n_state = RUN_HOUR_MIN;
                else if (i_wt_left) wt_n_state = SET_1_MIN;
                else if (i_wt_right) wt_n_state = SET_1_HOUR;
                else if (i_wt_up) wt_n_state = CH_10U_HOUR;
                else if (i_wt_down) wt_n_state = CH_10D_HOUR;
                else if (sw_fnd) wt_n_state = SET_10_SEC;
                else wt_n_state = SET_10_HOUR;
            end
            CH_10U_HOUR: begin
                o_edit = 3'b100;
                o_digit = 1'b0;
                o_up_down = 1'b0;
                wt_n_state = SET_10_HOUR;
            end
            CH_10D_HOUR: begin
                o_edit = 3'b100;
                o_digit = 1'b0;
                o_up_down = 1'b1;
                wt_n_state = SET_10_HOUR;
            end
            SET_1_HOUR: begin
                o_wt_led = 8'b01001000;
                if (!sw_edit) wt_n_state = RUN_HOUR_MIN;
                else if (i_wt_left) wt_n_state = SET_10_HOUR;
                else if (i_wt_right) wt_n_state = SET_10_MIN;
                else if (i_wt_up) wt_n_state = CH_1U_HOUR;
                else if (i_wt_down) wt_n_state = CH_1D_HOUR;
                else if (sw_fnd) wt_n_state = SET_1_SEC;
                else wt_n_state = SET_1_HOUR;
            end
            CH_1U_HOUR: begin
                o_edit = 3'b100;
                o_digit = 1'b1;
                o_up_down = 1'b0;
                wt_n_state = SET_1_HOUR;
            end
            CH_1D_HOUR: begin
                o_edit = 3'b100;
                o_digit = 1'b1;
                o_up_down = 1'b1;
                wt_n_state = SET_1_HOUR;
            end
            SET_10_MIN: begin
                o_wt_led = 8'b00101000;
                if (!sw_edit) wt_n_state = RUN_HOUR_MIN;
                else if (i_wt_left) wt_n_state = SET_1_HOUR;
                else if (i_wt_right) wt_n_state = SET_1_MIN;
                else if (i_wt_up) wt_n_state = CH_10U_MIN;
                else if (i_wt_down) wt_n_state = CH_10D_MIN;
                else if (sw_fnd) wt_n_state = SET_10_SEC;
                else wt_n_state = SET_10_MIN;
            end
            CH_10U_MIN: begin
                o_edit = 3'b010;
                o_digit = 1'b0;
                o_up_down = 1'b0;
                wt_n_state = SET_10_MIN;
            end
            CH_10D_MIN: begin
                o_edit = 3'b010;
                o_digit = 1'b0;
                o_up_down = 1'b1;
                wt_n_state = SET_10_MIN;
            end
            SET_1_MIN: begin
                o_wt_led = 8'b00011000;
                if (!sw_edit) wt_n_state = RUN_HOUR_MIN;
                else if (i_wt_left) wt_n_state = SET_10_MIN;
                else if (i_wt_right) wt_n_state = SET_10_HOUR;
                else if (i_wt_up) wt_n_state = CH_1U_MIN;
                else if (i_wt_down) wt_n_state = CH_1D_MIN;
                else if (sw_fnd) wt_n_state = SET_1_SEC;
                else wt_n_state = SET_1_MIN;
            end
            CH_1U_MIN: begin
                o_edit = 3'b010;
                o_digit = 1'b1;
                o_up_down = 1'b0;
                wt_n_state = SET_1_MIN;
            end
            CH_1D_MIN: begin
                o_edit = 3'b010;
                o_digit = 1'b1;
                o_up_down = 1'b1;
                wt_n_state = SET_1_MIN;
            end
            SET_10_SEC: begin
                o_wt_led = 8'b10001100;
                if (!sw_edit) wt_n_state = RUN_SEC_MSEC;
                else if (i_wt_left) wt_n_state = SET_1_SEC;
                else if (i_wt_right) wt_n_state = SET_1_SEC;
                else if (i_wt_up) wt_n_state = CH_10U_SEC;
                else if (i_wt_down) wt_n_state = CH_10D_SEC;
                else if (!sw_fnd) wt_n_state = SET_10_HOUR;
                else wt_n_state = SET_10_SEC;
            end
            CH_10U_SEC: begin
                o_edit = 3'b001;
                o_digit = 1'b0;
                o_up_down = 1'b0;
                wt_n_state = SET_10_SEC;
            end
            CH_10D_SEC: begin
                o_edit = 3'b001;
                o_digit = 1'b0;
                o_up_down = 1'b1;
                wt_n_state = SET_10_SEC;
            end
            SET_1_SEC: begin
                o_wt_led = 8'b01001100;
                if (!sw_edit) wt_n_state = RUN_SEC_MSEC;
                else if (i_wt_left) wt_n_state = SET_10_SEC;
                else if (i_wt_right) wt_n_state = SET_10_SEC;
                else if (i_wt_up) wt_n_state = CH_1U_SEC;
                else if (i_wt_down) wt_n_state = CH_1D_SEC;
                else if (!sw_fnd) wt_n_state = SET_1_HOUR;
                else wt_n_state = SET_1_SEC;
            end
            CH_1U_SEC: begin
                o_edit = 3'b001;
                o_digit = 1'b1;
                o_up_down = 1'b0;
                wt_n_state = SET_1_SEC;
            end
            CH_1D_SEC: begin
                o_edit = 3'b001;
                o_digit = 1'b1;
                o_up_down = 1'b1;
                wt_n_state = SET_1_SEC;
            end
        endcase

        if (sw_edit) o_wt_led[3] = 1'b1;
    end

endmodule
