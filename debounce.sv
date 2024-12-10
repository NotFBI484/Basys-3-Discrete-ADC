`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 05:37:17 PM
// Design Name: 
// Module Name: debounce
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
module debounce (
    input  logic clk,              // System clock
    input  logic reset,            // Active-high reset
    input  logic comparator_in,    // Noisy comparator signal
    output logic comparator_db    // Debounced comparator signal
);

    // Internal registers for debouncing
    logic [2:0] shift_reg;         // 3-bit shift register to track stable signal

    // Shift register logic for debouncing
    always_ff @(posedge clk) begin
        if (reset) begin
            shift_reg <= 3'b000;    // Reset shift register
        end else begin
            shift_reg <= {shift_reg[1:0], comparator_in}; // Shift in new value
        end
    end

    // Output logic: Signal is stable if all 3 bits are the same
    always_comb begin
        if (shift_reg == 3'b111) begin
            comparator_db = 1'b1; // Stable high
        end else if (shift_reg == 3'b000) begin
            comparator_db = 1'b0; // Stable low
        end else begin
            comparator_db = comparator_db; // Hold last state
        end
    end

endmodule
