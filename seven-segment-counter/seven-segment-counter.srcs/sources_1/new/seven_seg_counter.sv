`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marco Bonato
// 
// Create Date: 09.10.2026 21:01:03
// Design Name: 
// Module Name: seven_seg_counter
// Project Name: seven-segment-counter
// Target Devices: Basys 3
// Tool Versions: 2026.1
// Description: hex count +1 every second with resets / freeze / adds
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Seven segment display increases by 1 every second, 4-digit hex
// Wraps around to 0 after FFFF
// sw (sw[0]) enables or disables the clock signal (i.e. enables/disables the counter increasing)
// btnU adds 1, btnL adds 16, btnR adds 16^2, btnD adds 16^3
// btnC resets the count to 0

module seven_seg_counter (
    input logic clk,
    input logic sw,
    input logic btnC,
    input logic btnU,
    input logic btnL,
    input logic btnR,
    input logic btnD,

    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an
);
    assign dp = 1; // don't show decimal points
    logic [26:0] clk_counter; // 27 bits for 100e6
    logic [15:0] sevenseg_counter; // 16 bits for FFFF
    logic [14:0] refresh; // last 2 bits are which digit to display
    logic [1:0] digit_selector;
    assign digit_selector = refresh[14:13];

    logic btnC_disable;
    logic btnU_disable;
    logic btnL_disable;
    logic btnR_disable;
    logic btnD_disable;

    function automatic logic [6:0] get_segments(
        input logic [3:0] hex_digit 
    );
        get_segments = 7'b0000000;
        unique case (hex_digit)
            4'h0: 
                get_segments = 7'b1000000;
            4'h1:
                get_segments = 7'b1111001;
            4'h2:
                get_segments = 7'b0100100;
            4'h3:
                get_segments = 7'b0110000;
            4'h4:
                get_segments = 7'b0011001;
            4'h5:
                get_segments = 7'b0010010;
            4'h6:
                get_segments = 7'b0000010;
            4'h7:
                get_segments = 7'b1111000;
            4'h8:
                get_segments = 7'b0000000;
            4'h9:
                get_segments = 7'b0011000;
            4'hA:
                get_segments = 7'b0001000;
            4'hB: 
                get_segments = 7'b0000011;
            4'hC:
                get_segments = 7'b1000110;
            4'hD:
                get_segments = 7'b0100001;
            4'hE:
                get_segments = 7'b0000110;
            4'hF:
                get_segments = 7'b0001110;
            default: // 0
                get_segments = 7'b1000000;
        endcase
    endfunction

    always_ff @(posedge clk) begin
        refresh <= refresh + 1;

        if (sw) begin
            clk_counter <= clk_counter + 1;
        end
        if (clk_counter >= 27'd100000000) begin
            clk_counter <= 0;
            sevenseg_counter <= sevenseg_counter + 1;
        end

        // Pretty ugly button debouncing code
        // Should replace with macros in future
        if (btnC && !btnC_disable) begin
            sevenseg_counter <= 0;
            btnC_disable <= 1;
        end
        else if (!btnC && btnC_disable) begin
            btnC_disable <= 0;
        end

        if (btnU && !btnU_disable) begin
            sevenseg_counter <= sevenseg_counter + 16'h1;
            btnU_disable <= 1;
        end
        else if (!btnU && btnU_disable) begin
            btnU_disable <= 0;
        end

        if (btnL && !btnL_disable) begin
            sevenseg_counter <= sevenseg_counter + 16'h10;
            btnL_disable <= 1;
        end
        else if (!btnL && btnL_disable) begin
            btnL_disable <= 0;
        end

        if (btnR && !btnR_disable) begin
            sevenseg_counter <= sevenseg_counter + 16'h100;
            btnR_disable <= 1;
        end
        else if (!btnR && btnR_disable) begin
            btnR_disable <= 0;
        end

        if (btnD && !btnD_disable) begin
            sevenseg_counter <= sevenseg_counter + 16'h1000;
            btnD_disable <= 1;
        end
        else if (!btnD && btnD_disable) begin
            btnD_disable <= 0;
        end
    end

    always_comb begin
        an = 4'b1111;
        an[digit_selector] = 0;
        unique case (digit_selector)
            2'b00: 
                seg = get_segments(sevenseg_counter[3:0]);
            2'b01:
                seg = get_segments(sevenseg_counter[7:4]);
            2'b10:
                seg = get_segments(sevenseg_counter[11:8]);
            2'b11:
                seg = get_segments(sevenseg_counter[15:12]);
            default: // digit 0
                seg = get_segments(sevenseg_counter[3:0]);
        endcase
    end

endmodule
