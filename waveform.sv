module waveform #(
    parameter int WIDTH = 8,                   // Bit width for duty cycle and sawtooth waveform
    parameter int CLOCK_FREQ = 100_000_000,    // System clock frequency in Hz
    parameter real WAVE_FREQ = 50.0             // Desired wave frequency in Hz
) (
    input  logic             clk,          // System clock
    input  logic             reset,        // Active-high reset
    input  logic             enable,       // Active-high enable
    output logic [WIDTH-1:0] sawtooth_out, // 8-bit sawtooth waveform output
    output logic             pwm_out,      // PWM output signal
    output logic [WIDTH-1:0] R2R_out       // R2R output signal
);

    // Calculate maximum duty cycle value and downcounter period
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ / (WAVE_FREQ * 256)); // 256 for 8-bit resolution

    // Internal signals
    logic zero;                   // Downcounter zero pulse signal
    logic [WIDTH-1:0] sawtooth;   // Sawtooth waveform value

    // Instantiate downcounter to generate the zero pulse at desired intervals
    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)
    ) downcounter_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .zero(zero)
    );

    // Sawtooth waveform generation logic
    always_ff @(posedge clk) begin
        if (reset) begin
            sawtooth <= 8'b0; // Initialize sawtooth to 0 on reset
        end else if (enable && zero) begin
            if (sawtooth == 8'hFF) begin
                sawtooth <= 8'b0;  // Reset to 0 after reaching max value
            end else begin
                sawtooth <= sawtooth + 1; // Increment sawtooth
            end
        end
    end

    // Assign the sawtooth waveform to the output
    assign sawtooth_out = sawtooth;

    // Assign the sawtooth waveform directly to the R2R output
    assign R2R_out = sawtooth;

    // Instantiate PWM module with the sawtooth waveform as the duty cycle input
    pwm #(
        .WIDTH(WIDTH)
    ) pwm_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .duty_cycle(sawtooth), // Use sawtooth waveform as the duty cycle
        .pwm_out(pwm_out)      // Output PWM signal
    );

endmodule
