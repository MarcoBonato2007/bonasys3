`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marco Bonato
// 
// Create Date: 20.10.2026 21:27:57
// Design Name: 
// Module Name: uart_hello_world
// Project Name: uart-hello-world
// Target Devices: Basys 3
// Tool Versions: 2026.1
// Description: send "Hello World!" via UART when btnC is pressed
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

const logic [7:0] hello_world_ascii [11:0] = {
    8'h48, // 'H'
    8'h65, // 'e'
    8'h6C, // 'l'
    8'h6C, // 'l'
    8'h6F, // 'o'
    8'h20, // ' '
    8'h57, // 'W'
    8'h6F, // 'o'
    8'h72, // 'r'
    8'h6C, // 'l'
    8'h64, // 'd'
    8'h21  // '!'
};

module uart_hello_world(
    input logic clk,
    input logic rst_n,
    input logic btnC,
    output logic RsTx
);
    logic btnC_disabled;
    logic btnC_ff1;
    logic btnC_ff2;

    logic [7:0] num_pending; // number of pending hello worlds to send
    logic [3:0] ptr; // index of byte to send
    logic [7:0] byte_to_send;
    logic is_uart_ready; // from uart
    logic send_to_uart; // set to 1 when sending a byte to uart

    to_uart to_uart_i (
        .clk (clk),
        .rst_n (rst_n),
        .byte (byte_to_send),
        .receiving (send_to_uart)
        .ready (is_uart_ready),
    )

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btnC_disabled <= 0;
            btnC_ff1 <= 0;
            btnC_ff2 <= 0;
            num_pending <= 0;
            ptr <= 0;
            send_to_uart <= 0;
        end
        else begin
            // Button debouncing
            btnC_ff1 <= btnC;
            btnC_ff2 <= btnC_ff1;
            if (btnC_ff2 && !btnC_disabled) begin
                btnC_disabled <= 1;
                num_pending <= num_pending + 1;
            end
            else if (!btnC_ff2) begin
                btnC_disabled <= 0;
            end

            // Sending to uart
            if (num_pending > 0 && is_uart_ready) begin
                byte_to_send = hello_world_ascii[ptr];
                ptr <= (ptr + 1) % 12;
                send_to_uart <= 1;
            end
            else begin
                send_to_uart <= 0;
            end
        end
    end

endmodule

// A module should only set receiving = 1 when ready = 1
// Unexpected behaviour may occur if this is not respected
module to_uart(
    input logic clk,
    input logic rst_n,
    input logic [7:0] byte,
    input logic receiving,
    output logic ready,
);
    logic [13:0] counter; // count to 10417 for 9600 baud rate
    logic [9:0] byte_to_send; // padded with start/stop bits
    logic [3:0] remaining_to_send; // number of bits left to send
    assign ready = remaining_to_send == 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready <= 1;
            counter <= 0;
            sending <= 0;
            remaining_to_send <= 0;
            RsTx <= 1;
        end
        else begin
            counter <= counter + 1;
            if (counter >= 5'd10417) begin
                counter <= 0;
                if (remaining_to_send > 0) begin
                    RsTx <= byte_to_send[0]
                    byte_to_send <= byte_to_send >> 1;
                    remaining_to_send <= remaining_to_send - 1
                end
                else begin
                    RsTx <= 1; // if nothing is sending, keep UART idle
                end
            end

            if (receiving) begin
                byte_to_send = {1, byte, 0}; // start bit 0, stop bit 1
                remaining_to_send = 10;
            end
        end
    end

endmodule
