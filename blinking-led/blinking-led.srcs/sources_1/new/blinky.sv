`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marco Bonato
// 
// Create Date: 09.10.2026 17:19:00
// Design Name: blinky
// Module Name: blinky
// Project Name: blinking-led
// Target Devices: Basys 3
// Tool Versions: 2026.1
// Description: first project on the Basys 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: yay it works
// 
//////////////////////////////////////////////////////////////////////////////////


module blinky(
    input clk,
    output led
);
    logic [24:0] count = 0;
    assign led = count[24];
    always_ff @(posedge clk) begin
        count <= count + 1;
    end
endmodule
