module ADC_capture (
    input  logic clk,                // System clock
    input  logic reset,              // Active-high reset
    input  logic comparator_out,     // Comparator output signal
    input  logic [7:0] sawtooth_out, // 8-bit sawtooth waveform
    output logic [7:0] adc_value     // Captured duty cycle value (8-bit)
);

    logic comparator_out_prev; // To track the previous state of comparator_out

    // Sequential logic to capture sawtooth value on the negative edge of comparator_out
    always_ff @(posedge clk) begin
        if (reset) begin
            comparator_out_prev <= 1'b0; // Initialize previous state
            adc_value <= 8'b0;           // Reset ADC value
        end else begin
            comparator_out_prev <= comparator_out; // Update previous state

            // Detect negative edge of comparator_out
            if (~comparator_out && comparator_out_prev) begin
                adc_value <= sawtooth_out; // Capture sawtooth value on negative edge
            end
        end
    end

endmodule
