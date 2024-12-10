module MAIN_MUX (
    input  logic [3:0] select,         // 4-bit select input
    input  logic [15:0] in0,           // Input 0 (16 bits)
    input  logic [15:0] in1,           // Input 1 (16 bits)
    input  logic [15:0] in2,           // Input 2 (16 bits)
    input  logic [15:0] in3,           // Input 3 (16 bits)
    input  logic [15:0] in4,           // Input 4 (16 bits)
    input  logic [15:0] in5,           // Input 5 (16 bits)
    input  logic [15:0] in6,           // Input 6 (16 bits)
    input  logic [15:0] in7,           // Input 7 (16 bits)
    input  logic [15:0] in8,           // Input 8 (16 bits)
    input  logic [15:0] in9,           // Input 9 (16 bits)
    input  logic [15:0] in10,          // Input 10 (16 bits)
    input  logic [15:0] in11,          // Input 11 (SAR PWM ADC)
    input  logic [15:0] in12,
    output logic [15:0] out,           // Selected output (16 bits)
    output logic [3:0]  decimal_pt     // Decimal point control
);

    // Multiplexer Logic
    always_comb begin
        case (select)
            4'b0000: out = in0;
            4'b0001: out = in1;
            4'b0010: out = in2;
            4'b0011: out = in3;
            4'b0100: out = in4;
            4'b0101: out = in5;
            4'b0110: out = in6;
            4'b0111: out = in7;
            4'b1000: out = in8;
            4'b1001: out = in9;
            4'b1010: out = in10;
            4'b1011: out = in11; // SAR PWM ADC value
            4'b1100: out = in12;
            default: out = 16'b0; // Default output for invalid select
        endcase
    end
    
    // Decimal Point Logic
    always_comb begin
        case (select)
            4'b0100: decimal_pt = 4'b1000; // PWM scaled value
            4'b0111: decimal_pt = 4'b1000; // R2R scaled value
            4'b1010: decimal_pt = 4'b1000; // XADC scaled value
            4'b1100: decimal_pt = 4'b1000;
            default: decimal_pt = 4'b0000; // Default case (no decimal point)
        endcase
    end

endmodule
