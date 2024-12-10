`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 04:59:30 PM
// Design Name: 
// Module Name: scaler_mod
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

module scaler_mod (
    input logic clk,
    input logic reset,
    input logic ready_pulse,          // Trigger for scaling
    input logic [15:0] ave_data,      // Input: Averaged ADC value
    output logic [15:0] scaled_value  // Output: Scaled value
);
    // Internal register for pipelining (if needed)
    logic [15:0] scaled_value_temp;

    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_value <= 0;
            scaled_value_temp <= 0;
        end else if (ready_pulse) begin
            // Perform scaling: (ave_data * 413) >> 13
            scaled_value_temp <= (ave_data * 413) >> 13;
            scaled_value <= scaled_value_temp; // Pipelined output
        end
    end
endmodule
