`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 04:44:06 PM
// Design Name: 
// Module Name: btn_mux
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


module btn_mux #(
    parameter WIDTH = 1 // Default width is 1 bit; can be parameterized
) (
    input logic sel,          // Select signal
    input logic [WIDTH-1:0] in0, // Input 0
    input logic [WIDTH-1:0] in1, // Input 1
    output logic [WIDTH-1:0] out  // Output
);
    assign out = sel ? in1 : in0;
endmodule
