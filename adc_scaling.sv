module adc_scaling #(
    parameter SCALING_FACTOR = 106,   // Precomputed scaling factor for 3.3V
    parameter SHIFT_BITS = 13         // Number of bits to shift for scaling
) (
    input  logic        clk,              // System clock
    input  logic        reset,            // Active-high reset
    input  logic [15:0] averaged_adc,     // Averaged ADC value (16 bits)
    output logic [15:0] scaled_voltage    // Scaled voltage in millivolts
);

    logic [31:0] scaled_temp;             // Temporary register to hold intermediate result

    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_voltage <= 16'b0;
            scaled_temp    <= 32'b0;
        end else begin
            // Perform scaling: (averaged_adc * SCALING_FACTOR) >> SHIFT_BITS
            scaled_temp    <= averaged_adc * SCALING_FACTOR;
            scaled_voltage <= scaled_temp >> SHIFT_BITS; // Final scaled voltage
        end
    end

endmodule
