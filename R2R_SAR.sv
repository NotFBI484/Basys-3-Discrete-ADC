module R2R_SAR (
    input  wire clk,                 // Clock input
    input  wire go,                  // Go signal to start conversion
    input  wire cmp,                 // Comparator output
    output wire valid,               // Valid signal: high when conversion is done
    output wire sample,              // Sample signal for S&H circuit
    output wire [7:0] value,         // Current DAC value
    output reg [7:0] result          // Final 8-bit result
);

    // Internal signals and registers
    reg [1:0] state;                 // Current state of the FSM
    reg [7:0] mask;                  // Mask to isolate the current bit
    logic delay_zero;

    // State encoding
    localparam sWait   = 2'b00;      // Wait state
    localparam sSample = 2'b01;      // Sampling state
    localparam sConv   = 2'b10;      // Conversion state
    localparam sDone   = 2'b11;      // Done state
    
  downcounter #(
        .PERIOD(10000) // Delay period in clock cycles
    ) delay_counter (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),        // Always enabled for continuous operation
        .zero(delay_zero)
    );
    // Synchronous FSM
    always @(posedge clk) begin
        if (!go) begin
            // Reset state and clear results when go=0
            state <= sWait;
            result <= 8'b0;
            mask <= 8'b10000000; // Reset mask to MSB
        end else begin
            case (state)
                sWait: begin
                    // Wait for go signal to start conversion
                    state <= sSample;
                end

                sSample: begin
                    // Sampling phase: reset result and mask, move to conversion state
                    state <= sConv;
                    mask <= 8'b10000000; // Start with MSB
                    result <= 8'b0;      // Clear result register
                end

                sConv: begin
                  if (delay_zero) begin
                    if (cmp) begin
                        // If comparator indicates input > current value, set the bit
                        result <= result | mask;
                    end
                    // Shift mask to test the next bit
                    mask <= mask >> 1;

                    // Move to done state after testing the LSB
                    if (mask == 8'b00000001) begin
                        state <= sDone;
                    end
                    end
                end

                sDone: begin
                    // Stay in done state until go=0
                    state <= sSample;
                end

                default: begin
                    // Safety reset in case of invalid state
                    state <= sWait;
                end
            endcase
        end
    end

    // Assign outputs
    assign sample = (state == sSample);      // High during sampling phase
    assign value = result | mask;           // DAC value during conversion
    assign valid = (state == sDone);        // High when conversion is complete

endmodule