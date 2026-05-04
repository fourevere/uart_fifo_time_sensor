`timescale 1ns / 1ps

module stop_watch_control_unit(
    input      clk,
    input      rst,
    input      i_st_type,      //down
    input      i_st_clear,     //left
    input      i_st_run_stop,  // right
    output     o_type,
    output reg o_run_stop,
    output reg o_clear
);

    parameter [1:0] STATE_STP = 2'b00;
    parameter [1:0] STATE_RUN = 2'b01;
    parameter [1:0] STATE_CLR = 2'b10;
    parameter [1:0] STATE_MOD = 2'b11;

    reg [1:0] st_c_state, st_n_state;
    reg type_reg, type_next;

    assign o_type = type_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            st_c_state <= STATE_STP;
            type_reg   <= 1'b0;
        end else begin
            st_c_state <= st_n_state;
            type_reg   <= type_next;
        end
    end


    always @(*) begin
        st_n_state = st_c_state;
        type_next = type_reg;
        o_clear = 1'b0;
        o_run_stop = 1'b0;

        case (st_c_state)
            STATE_STP: begin
                o_run_stop = 1'b0;
                o_clear    = 1'b0;
                if (i_st_run_stop) st_n_state = STATE_RUN;
                else if (i_st_clear) st_n_state = STATE_CLR;
                else if (i_st_type) st_n_state = STATE_MOD;
                else st_n_state = st_c_state;
            end
            STATE_RUN: begin
                o_run_stop = 1'b1;
                if (i_st_run_stop) st_n_state = STATE_STP;
                //else             next_state = current_state;
            end
            STATE_CLR: begin
                o_clear    = 1'b1;
                st_n_state = STATE_STP;
            end
            STATE_MOD: begin
                st_n_state = STATE_STP;
                type_next  = ~type_reg;
            end
        endcase
    end

endmodule