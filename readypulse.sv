`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 05:07:38 PM
// Design Name: 
// Module Name: readypulse
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module readypulse (
    input logic clk,
    input logic reset,
    input logic ready,       // Input signal to detect the rising edge
    output logic ready_pulse // Output one-clock pulse
);
    logic ready_r; // Register to store the previous state of `ready`

    always_ff @(posedge clk) begin
        if (reset)
            ready_r <= 1'b0;
        else
            ready_r <= ready; // Capture the current state of `ready`
    end

    // Generate a one-clock pulse when `ready` goes high
    assign ready_pulse = ~ready_r & ready;
endmodule
