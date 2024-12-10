module Flash_ADC_encoder (
    input  logic [7:0] in,         // 8-bit input
    output logic [2:0] out,        // 3-bit encoded output
    output logic [15:0] scaled_out // Scaled output in millivolts
);

    // Precomputed scaling factors (3300 mV scaled to 7 steps)
    localparam logic [15:0] SCALE_0 = 17'd0;    // 0 * 471
    localparam logic [15:0] SCALE_1 = 17'd471;  // 1 * 471
    localparam logic [15:0] SCALE_2 = 17'd942;  // 2 * 471
    localparam logic [15:0] SCALE_3 = 17'd1413; // 3 * 471
    localparam logic [15:0] SCALE_4 = 17'd1884; // 4 * 471
    localparam logic [15:0] SCALE_5 = 17'd2355; // 5 * 471
    localparam logic [15:0] SCALE_6 = 17'd2826; // 6 * 471
    localparam logic [15:0] SCALE_7 = 17'd3300; // 7 * 471

    always_comb begin
        // Default output
        out = 3'b000;
        scaled_out = SCALE_0;

        // Priority encoding and scaling
        casez (in)
            8'b1???????: begin
                out = 3'b111; 
                scaled_out = SCALE_7; // 3300 mV
            end
            8'b01??????: begin
                out = 3'b110; 
                scaled_out = SCALE_6; // 2826 mV
            end
            8'b001?????: begin
                out = 3'b101; 
                scaled_out = SCALE_5; // 2355 mV
            end
            8'b0001????: begin
                out = 3'b100; 
                scaled_out = SCALE_4; // 1884 mV
            end
            8'b00001???: begin
                out = 3'b011; 
                scaled_out = SCALE_3; // 1413 mV
            end
            8'b000001??: begin
                out = 3'b010; 
                scaled_out = SCALE_2; // 942 mV
            end
            8'b0000001?: begin
                out = 3'b001; 
                scaled_out = SCALE_1; // 471 mV
            end
            8'b00000001: begin
                out = 3'b000; 
                scaled_out = SCALE_0; // 0 mV
            end
            default: begin
                out = 3'b000;
                scaled_out = SCALE_0;
            end
        endcase
    end

endmodule

