`timescale 1ns / 1ps

module ascii_decoder (
    input            i_valid,
    input      [7:0] i_ascii_decoder,
    output reg       signal_U,
    output reg       signal_D,
    output reg       signal_R,
    output reg       signal_L,
    output reg       signal_T,
    output reg       signal_S,
    output reg       signal_C,
    output reg       signal_M

);

    always @(*) begin
        signal_U       = 0;
        signal_D       = 0;
        signal_R       = 0;
        signal_L       = 0;
        signal_T       = 0;
        signal_S       = 0;
        signal_C       = 0;
        signal_M       = 0;

        if (i_valid) begin
            case (i_ascii_decoder)
            8'h55, 8'h75: begin
                signal_U = 1;
            end
            8'h44, 8'h64: begin
                signal_D = 1;
            end
            8'h52, 8'h72: begin
                signal_R = 1;
            end
            8'h4C, 8'h6C: begin
                signal_L = 1;
            end
            8'h54, 8'h74: begin
                signal_T = 1;
            end
            8'h53, 8'h73: begin
                signal_S = 1;
            end
            8'h43, 8'h63: begin
                signal_C = 1;
            end
            8'h4D, 8'h6D: begin
                signal_M = 1;
            end
        endcase
        end
    end
endmodule
