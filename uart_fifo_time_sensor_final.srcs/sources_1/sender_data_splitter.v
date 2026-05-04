`timescale 1ns / 1ps

module sender_data_splitter(
    input [72:0] i_sender_data,
    output [7:0] ascii_wt_hour_10,
    output [7:0] ascii_wt_hour_1,
    output [7:0] ascii_wt_min_10,
    output [7:0] ascii_wt_min_1,
    output [7:0] ascii_wt_sec_10,
    output [7:0] ascii_wt_sec_1,
    output [7:0] ascii_wt_msec_10,
    output [7:0] ascii_wt_msec_1,
    output [7:0] ascii_st_hour_10,
    output [7:0] ascii_st_hour_1,
    output [7:0] ascii_st_min_10,
    output [7:0] ascii_st_min_1,
    output [7:0] ascii_st_sec_10,
    output [7:0] ascii_st_sec_1,
    output [7:0] ascii_st_msec_10,
    output [7:0] ascii_st_msec_1,
    output [7:0] ascii_temp_10,
    output [7:0] ascii_temp_1,
    output [7:0] ascii_hum_100,
    output [7:0] ascii_hum_10,
    output [7:0] ascii_hum_1,
    output [7:0] ascii_dist_100,
    output [7:0] ascii_dist_10,
    output [7:0] ascii_dist_1
    );

    wire [8:0] unit_input [0:10];

    assign unit_input[0]  = i_sender_data[8:0];

    assign unit_input[1]  = i_sender_data[16:9];  // humidity
    assign unit_input[2]  = i_sender_data[24:17]; // temperature

    assign unit_input[3]  = i_sender_data[31:25]; 
    assign unit_input[4]  = i_sender_data[37:32]; 
    assign unit_input[5]  = i_sender_data[43:38]; 
    assign unit_input[6]  = i_sender_data[48:44]; 

    assign unit_input[7]  = i_sender_data[55:49];  // msec 7
    assign unit_input[8]  = i_sender_data[61:56]; // sec 6
    assign unit_input[9] = i_sender_data[67:62];  // min 6
    assign unit_input[10] = i_sender_data[72:68]; // hour 5

     bits_to_ascii U_BTA_WT_HOUR (
    .digit_in       (unit_input[10]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_wt_hour_10), 
    .ascii_digit_1  (ascii_wt_hour_1 )
     );

     bits_to_ascii U_BTA_WT_MIN (
    .digit_in       (unit_input[9]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_wt_min_10), 
    .ascii_digit_1  (ascii_wt_min_1 )
     );

     bits_to_ascii U_BTA_WT_SEC (
    .digit_in       (unit_input[8]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_wt_sec_10), 
    .ascii_digit_1  (ascii_wt_sec_1 )
     );

     bits_to_ascii U_BTA_WT_MSEC (
    .digit_in       (unit_input[7]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_wt_msec_10), 
    .ascii_digit_1  (ascii_wt_msec_1 )
     );

     bits_to_ascii U_BTA_ST_HOUR (
    .digit_in       (unit_input[6]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_st_hour_10), 
    .ascii_digit_1  (ascii_st_hour_1 )
     );

     bits_to_ascii U_BTA_ST_MIN (
    .digit_in       (unit_input[5]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_st_min_10), 
    .ascii_digit_1  (ascii_st_min_1 )
     );

     bits_to_ascii U_BTA_ST_SEC (
    .digit_in       (unit_input[4]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_st_sec_10), 
    .ascii_digit_1  (ascii_st_sec_1 )
     );

     bits_to_ascii U_BTA_ST_MSEC (
    .digit_in       (unit_input[3]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_st_msec_10), 
    .ascii_digit_1  (ascii_st_msec_1 )
     );

     bits_to_ascii U_BTA_DHT11_TEMP (
    .digit_in       (unit_input[2]),        
    .ascii_digit_100(), 
    .ascii_digit_10 (ascii_temp_10), 
    .ascii_digit_1  (ascii_temp_1 )
     );

     bits_to_ascii U_BTA_HUM (
    .digit_in       (unit_input[1]),        
    .ascii_digit_100(ascii_hum_100), 
    .ascii_digit_10 (ascii_hum_10), 
    .ascii_digit_1  (ascii_hum_1 )
     );

     bits_to_ascii U_BTA_DIST (
    .digit_in       (unit_input[0]),        
    .ascii_digit_100(ascii_dist_100), 
    .ascii_digit_10 (ascii_dist_10), 
    .ascii_digit_1  (ascii_dist_1)
     );


endmodule

module bits_to_ascii (
    input      [8:0] digit_in,       
    output reg [7:0] ascii_digit_100, // 100의 자리
    output reg [7:0] ascii_digit_10, // 십의 자리 문자
    output reg [7:0] ascii_digit_1   // 일의 자리 문자
);

    wire [3:0] digit_1  = digit_in % 10;
    wire [3:0] digit_10 = (digit_in / 10) % 10;
    wire [3:0] digit_100 = (digit_in / 100) % 10;

always @(*) begin
    if (digit_in > 99) begin
        ascii_digit_1   = 8'h30 + digit_1;
        ascii_digit_10  = 8'h30 + digit_10;
        ascii_digit_100 = 8'h30 + digit_100;
    end else begin
        ascii_digit_1   = 8'h30 + digit_1;
        ascii_digit_10  = 8'h30 + digit_10;
        ascii_digit_100 = 8'h30;
    end
end
endmodule
