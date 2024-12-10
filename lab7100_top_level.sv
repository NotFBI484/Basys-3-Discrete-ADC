
module lab7100_top_level (
    input  logic   clk,
    input  logic   reset,
    input  logic [3:0] mode_select,
    input  logic compare_one, compare_two,
    input  logic [11:0] switches_inputs,
    input  logic [7:0]  FLASH_IN,
    input  logic   btnUP, btnLE,
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,
    output logic   AN1, AN2, AN3, AN4,
    output logic [15:0] led,
    output logic   pwm_out,
    output logic [7:0] R2R_out
);
    // Internal signal declarations
  
    logic        ready;              // Data ready from XADC
    logic [15:0] data, ave_data;              // Raw ADC data
    logic [15:0] scaled_adc_data, scaled_adc_data_temp; // Scaled ADC data for display
    logic [6:0]  daddr_in;              // XADC address
    logic        enable;                // XADC enable
    logic        eos_out;               // End of sequence
    logic        busy_out;              // XADC busy signal
    logic        ready_r, ready_pulse;
    logic [3:0]  decimal_pt; // vector to control the decimal point, 1 = DP on, 0 = DP off
                             // [0001] DP right of seconds digit        
                             // [0010] DP right of tens of seconds digit
                             // [0100] DP right of minutes digit        
                             // [1000] DP right of tens of minutes digit
    logic [15:0] bcd_value, mux_out;
    logic [7:0]  sawtooth_out;
    logic [7:0]  pwm_ramp_adc;
    logic [7:0]  pwm_SAR_adc;
    logic [15:0]  pwm_avg;
    logic [15:0]  pwm_scal;
    logic [7:0]  R2R_ramp_adc;
    logic [7:0]  R2R_SAR_adc;
    logic [15:0]  R2R_avg;
    logic [15:0]  R2R_scal;
    logic [15:0] MAIN_MUX_out;
    logic [15:0] disp_in;
    logic        compare_one_db;
    logic        compare_two_db;
    logic [7:0] pwm_raw;
    logic [7:0] R2R_raw;
    logic       pwm_ramp;
    logic [7:0] R2R_ramp;
    logic       pwm_SAR;
    logic [7:0] R2R_SAR;
    logic [2:0] FLASH_ADC;
    logic       R2R_SAR_done;
    logic       R2R_avg_en;
    logic       pwm_SAR_done;
    logic       pwm_avg_en;
    logic [15:0]FLASH_ADC_SCAL;
    logic [3:0] decimal_con;
 
     // Instantiate generic_mux for `pwm_out` and `R2R_out`
    btn_mux #(.WIDTH(1)) pwm_out_mux (
        .sel(btnLE),
        .in0(pwm_ramp),
        .in1(pwm_SAR),
        .out(pwm_out)
    );

    btn_mux #(.WIDTH(8)) R2R_out_mux (
        .sel(btnLE),
        .in0(R2R_ramp),
        .in1(R2R_SAR),
        .out(R2R_out)
    );

    // Instantiate btn_mux for averaging enable signals
    btn_mux #(.WIDTH(1)) R2R_avg_mux (
        .sel(btnLE),
        .in0(1'b1),
        .in1(R2R_SAR_done),
        .out(R2R_avg_en)
    );

    btn_mux #(.WIDTH(1)) pwm_avg_mux (
        .sel(btnLE),
        .in0(1'b1),
        .in1(pwm_SAR_done),
        .out(pwm_avg_en)
    );

    // Instantiate btn_mux for raw ADC values
    btn_mux #(.WIDTH(8)) pwm_raw_mux (
        .sel(btnLE),
        .in0(pwm_ramp_adc),
        .in1(pwm_SAR_adc),
        .out(pwm_raw)
    );

    btn_mux #(.WIDTH(8)) R2R_raw_mux (
        .sel(btnLE),
        .in0(R2R_ramp_adc),
        .in1(R2R_SAR_adc),
        .out(R2R_raw)
    );

    // Instantiate btn_mux for display input
    btn_mux #(.WIDTH(16)) disp_in_mux (
        .sel(btnUP),
        .in0(bcd_value),
        .in1(MAIN_MUX_out),
        .out(disp_in)
    );
    
    btn_mux #(.WIDTH(4)) hex_mux (
    .sel(btnUP),
    .in0(decimal_pt),
    .in1(0),
    .out(decimal_con)
    );
 
 Flash_ADC_encoder flash_adc_inst(
    .in(FLASH_IN),
    .out(FLASH_ADC),
    .scaled_out(FLASH_ADC_SCAL)
    );
   
 PWM_SAR pwm_sar_inst (
    .clk(clk),
    .go(btnLE),
    .valid(pwm_SAR_done),
    .cmp(compare_one_db),
    .sample(),
    .result(pwm_SAR_adc),
    .pwm_out(pwm_SAR)
    );
   
   R2R_SAR R2R_sar_inst (
    .clk(clk),
    .cmp(compare_two_db),
    .result(R2R_SAR_adc),
    .value(R2R_SAR),
    .sample(),
    .valid(R2R_SAR_done),
    .go(btnLE)
    );
           
 waveform (
    .clk(clk),
    .reset(reset),
    .enable(1),
    .sawtooth_out(sawtooth_out),
    .pwm_out(pwm_ramp),
    .R2R_out(R2R_ramp)
    );
   
    debounce pwm_debounce_inst(
    .clk(clk),
    .reset(reset),
    .comparator_in(compare_one), // Noisy comparator signal
    .comparator_db(compare_one_db) // Debounced signal
);

    debounce R2R_debounce_inst(
    .clk(clk),
    .reset(reset),
    .comparator_in(compare_two), // Noisy comparator signal
    .comparator_db(compare_two_db) // Debounced signal
);
   
    ADC_capture pwm_capture_inst(
    .clk(clk),
    .reset(reset),
    .comparator_out(compare_one_db),
    .sawtooth_out(sawtooth_out),
    .adc_value(pwm_ramp_adc)
    );
   
    ADC_capture R2R_capture_inst(
    .clk(clk),
    .reset(reset),
    .comparator_out(compare_two_db),
    .sawtooth_out(sawtooth_out),
    .adc_value(R2R_ramp_adc)
    );
   
   averager    #( .power(8), //2**N samples, default is 2**8 = 256 samples
      .N(16)     // # of bits to take the average of
    )  pwm_average_inst(
    .reset(reset),
      .clk(clk),
      .EN(pwm_avg_en),
      .Din(pwm_raw),
      .Q(pwm_avg)
  );
 
   averager    #( .power(8), //2**N samples, default is 2**8 = 256 samples
      .N(16)     // # of bits to take the average of
    )  R2R_average_inst (
    .reset(reset),
          .clk(clk),
          .EN(R2R_avg_en),
          .Din(R2R_raw),
          .Q(R2R_avg)
  );
 
 
     adc_scaling #(
        .SCALING_FACTOR(3300), // Scale 8-bit value to millivolts (0-3.3V -> 0-3300)
        .SHIFT_BITS(8)       // Divide by 2^8 (8 bits)
    ) pwm_scaling_inst (
        .clk(clk),
        .reset(reset),
        .averaged_adc(pwm_avg), // Input: Averaged ADC value
        .scaled_voltage(pwm_scal) // Output: Scaled voltage value
    );
   
     adc_scaling #(
        .SCALING_FACTOR(3300), // Scale 8-bit value to millivolts (0-3.3V -> 0-3300)
        .SHIFT_BITS(8)       // Divide by 2^8 (8 bits)
    ) R2R_scaling_inst (
        .clk(clk),
        .reset(reset),
        .averaged_adc(R2R_avg), // Input: Averaged ADC value
        .scaled_voltage(R2R_scal) // Output: Scaled voltage value
    );
   
    // Constants
    localparam CHANNEL_ADDR = 7'h1f;     // XA4/AD15 (for XADC4)
   
    // XADC Instantiation
    xadc_wiz_0 XADC_INST (
        .di_in(16'h0000),        // Not used for reading
        .daddr_in(CHANNEL_ADDR), // Channel address
        .den_in(enable),         // Enable signal
        .dwe_in(1'b0),           // Not writing, so set to 0
        .drdy_out(ready),        // Data ready signal (when high, ADC data is valid)
        .do_out(data),           // ADC data output
        .dclk_in(clk),           // Use system clock
        .reset_in(reset),   // Active-high reset
        .vp_in(1'b0),            // Not used, leave disconnected
        .vn_in(1'b0),            // Not used, leave disconnected
        .vauxp15(vauxp15),       // Auxiliary analog input (positive)
        .vauxn15(vauxn15),       // Auxiliary analog input (negative)
        .channel_out(),          // Current channel being converted
        .eoc_out(enable),        // End of conversion
        .alarm_out(),            // Not used
        .eos_out(eos_out),       // End of sequence
        .busy_out(busy_out)      // XADC busy signal
    );

   averager  
   #( .power(12), //2**N samples, default is 2**8 = 256 samples
      .N(16)     // # of bits to take the average of
    )
   AVERAGER
    ( .reset(reset),
      .clk(clk),
      .EN(ready_pulse),
      .Din(data),
      .Q(ave_data)
    );
   

    scaler_mod scaler_inst (
        .clk(clk),
        .reset(reset),
        .ready_pulse(ready_pulse), // Pulse indicating data is ready
        .ave_data(ave_data),       // Input: Averaged ADC value
        .scaled_value(scaled_adc_data) // Output: Scaled value
    );

MAIN_MUX MAIN_MUX_inst (
    .select(mode_select),
    .in0(16'b0),
    .in1(switches_inputs),
    .in2(pwm_raw),
    .in3(pwm_avg),
    .in4(pwm_scal),
    .in5(R2R_raw),
    .in6(R2R_avg),
    .in7(R2R_scal),
    .in8(data),
    .in9(ave_data),
    .in10(scaled_adc_data),
    .in11(FLASH_ADC),  // Add SAR ADC for PWM
    .in12(FLASH_ADC_SCAL),
    .out(MAIN_MUX_out),
    .decimal_pt(decimal_pt)
    );
   
assign led = MAIN_MUX_out;

    bin_to_bcd BIN2BCD (
        .clk(clk),
        .reset(reset),
        .bin_in(MAIN_MUX_out),
        .bcd_out(bcd_value)
    );
   

   readypulse pulse_gen_inst (
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .ready_pulse(ready_pulse)
    );
 
    // Seven Segment Display Subsystem
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk),
        .reset(reset),
        .sec_dig1(disp_in[3:0]),     // Lowest digit
        .sec_dig2(disp_in[7:4]),     // Second digit
        .min_dig1(disp_in[11:8]),    // Third digit
        .min_dig2(disp_in[15:12]),   // Highest digit
        .decimal_point(decimal_con),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD),
        .CE(CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
   
endmodule
