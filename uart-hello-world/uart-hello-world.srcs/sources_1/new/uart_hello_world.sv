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

module uart_hello_world(
    input logic clk,
    input logic btnC,
    output logic RsTx
);
    logic btnC_disabled;
    logic btnC_ff1;
    logic btC_ff2;

    logic num_pending = 0; // number of pending hello worlds to send
    logic ptr = 0; // index of byte to send

    always_ff @(posedge clk) begin
        btnC_ff1 <= btnC;
        btnC_ff2 <= btnC_ff1;
        if (btnC_ff2 && !btnC_disabled) begin
            btnC_disabled <= 1;
            num_pending <= num_pending + 1;
        end
        else if (!btnC_ff2) begin
            btnC_disabled <= 0;
        end

        // TODO: if to_uart module is ready and num_pending > 0, send a byte and increment ptr
    end

endmodule

module to_uart(
    input logic clk,
    input logic [7:0] byte,
    output logic ready,
);
    // 8 data bits, 1 start bit, 1 stop bit, no parity
        // keep the line high while nothing is transmitting
        // start bit to 0 for one period
        // then the bits
        // then a stop bit of 1

    // TODO: send out data from byte progressively
    // perhaps shift values along as you go
    // remember to return back to 1

    logic [13:0] counter; // count to 10417 for 9600 baud rate
    always_ff @(posedge clk) begin
        counter <= counter + 1;
        if (counter >= 5'd10417) begin
            baud_clk = 0;
            // send out the next bit
        end
    end

endmodule
