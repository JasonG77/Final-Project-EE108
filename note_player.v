module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load1,
    input [5:0] note_to_load2,
    input [5:0] note_to_load3,
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready,
    
    // enhanced wave display
    output [15:0] voice_out1,
    output [15:0] voice_out2,
    output [15:0] voice_out3
);

    // Implementation goes here!
    wire [5:0] note_reg1;
    wire [5:0] note_reg2;
    wire [5:0] note_reg3;
    wire [5:0] duration_reg;
    wire [5:0] dur_counter;
    wire [5:0] next_dur_counter;
    wire [19:0] step_size1;
    wire [19:0] step_size2;
    wire [19:0] step_size3;
    
    wire signed [15:0] sample1;
    wire signed [15:0] sample2;
    wire signed [15:0] sample3;
    wire sample_ready1;
    wire sample_ready2;
    wire sample_ready3;
    wire signed [15:0] voice1;
    wire signed [15:0] voice2;
    wire signed [15:0] voice3;    
    
    dffre #(6) note_register1(
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(note_to_load1),
        .q(note_reg1)
    );
    
    dffre #(6) note_register2(
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(note_to_load2),
        .q(note_reg2)
    );
    
    dffre #(6) note_register3(
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(note_to_load3),
        .q(note_reg3)
    );
    
    dffre #(6) duration_register (
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(duration_to_load),
        .q(duration_reg)
    );
    
    //duration counter
    //increment every 48hz then reset to 0 when note loaded
    wire count_en;
    assign count_en = beat && play_enable;
    
    assign next_dur_counter = load_new_note ? 6'd0 :
        count_en ? (dur_counter + 6'd1) : 
        dur_counter;
    
    dffr #(6) duration_counter_reg (
        .clk(clk),
        .r(reset),
        .d(next_dur_counter),
        .q(dur_counter)
    );
    
    assign done_with_note = (dur_counter == duration_reg);
    
    frequency_rom freq_rom1 (
        .clk(clk),
        .addr(note_reg1),
        .dout(step_size1)
    );
    frequency_rom freq_rom2 (
        .clk(clk),
        .addr(note_reg2),
        .dout(step_size2)
    );
    frequency_rom freq_rom3 (
        .clk(clk), 
        .addr(note_reg3),
        .dout(step_size3)
    );
    
    // harmonic step sizes
    wire [19:0] step1_x2 = step_size1 << 1;
    wire [19:0] step1_x3 = step_size1 + (step_size1 << 1);
    
    wire [19:0] step2_x2 = step_size2 << 1;
    wire [19:0] step2_x3 = step_size2 + (step_size2 << 1);
    
    wire [19:0] step3_x2 = step_size3 << 1;
    wire [19:0] step3_x3 = step_size3 + (step_size3 << 1);
    
    

    sine_reader read_sine1 (
        .clk(clk),
        .reset(reset), 
        .step_size(step_size1),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(sample_ready1),
        .sample(sample1)
    );
    sine_reader read_sine2 (
        .clk(clk),
        .reset(reset), 
        .step_size(step_size2),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(sample_ready2),
        .sample(sample2)
    );
    sine_reader read_sine3 (
        .clk(clk),
        .reset(reset), 
        .step_size(step_size3),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(sample_ready3),
        .sample(sample3)
    );
    
    
    // harmonics
    
    wire signed [15:0] harmonic1_x2, harmonic1_x3;
    wire signed [15:0] harmonic2_x2, harmonic2_x3;
    wire signed [15:0] harmonic3_x2, harmonic3_x3;
    
    wire harmonic1_x2_ready, harmonic1_x3_ready;
    wire harmonic2_x2_ready, harmonic2_x3_ready;
    wire harmonic3_x2_ready, harmonic3_x3_ready;
    
    sine_reader read_harmonic1_x2(
        .clk(clk),
        .reset(reset),
        .step_size(step1_x2),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(harmonic1_x2_ready),
        .sample (harmonic1_x2)
    );
    
    sine_reader read_harmonic1_x3(
        .clk(clk),
        .reset(reset),
        .step_size(step1_x3),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(harmonic1_x3_ready),
        .sample (harmonic1_x3)
    );
    
    sine_reader read_harmonic2_x2(
        .clk(clk),
        .reset(reset),
        .step_size(step2_x2),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(harmonic2_x2_ready),
        .sample (harmonic2_x2)
    );
    
    sine_reader read_harmonic2_x3(
        .clk(clk),
        .reset(reset),
        .step_size(step2_x3),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(harmonic2_x3_ready),
        .sample (harmonic2_x3)
    );
    
       sine_reader read_harmonic3_x2(
        .clk(clk),
        .reset(reset),
        .step_size(step3_x2),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(harmonic3_x2_ready),
        .sample (harmonic3_x2)
    );
    
    sine_reader read_harmonic3_x3(
        .clk(clk),
        .reset(reset),
        .step_size(step3_x3),
        .generate_next(generate_next_sample && play_enable),
        .sample_ready(harmonic3_x3_ready),
        .sample (harmonic3_x3)
    );
    
    assign voice1 = (note_reg1 == 6'd0) ? 16'sd0 : 
        (sample1 >>> 1) + (harmonic1_x2 >>> 4) + (harmonic1_x3 >>> 5);
    
 
    assign voice2 = (note_reg2 == 6'd0) ? 16'sd0 : 
        (sample2 >>> 1) + (harmonic2_x2 >>> 4) + (harmonic2_x3 >>> 5);
    
    
    assign voice3 = (note_reg3 == 6'd0) ? 16'sd0 : 
        (sample3 >>> 1) + (harmonic3_x2 >>> 4) + (harmonic3_x3 >>> 5);
    
    wire signed [15:0] voice1_scaled;
    wire signed [15:0] voice2_scaled;
    wire signed [15:0] voice3_scaled;
//    wire signed [17:0] mix_sum;
    
    assign voice1_scaled = voice1;
    assign voice2_scaled = voice2;
    assign voice3_scaled = voice3;
    
    // enhanced wave display
    assign voice_out1 = voice1_scaled;
    assign voice_out2 = voice2_scaled;
    assign voice_out3 = voice3_scaled;
    
//    assign mix_sum = voice1_scaled + voice2_scaled + voice3_scaled;
//    assign sample_out = mix_sum[15:0];
    wire signed [19:0] mix_sum;
    assign mix_sum = {{4{voice1_scaled[15]}}, voice1_scaled} + 
                     {{4{voice2_scaled[15]}}, voice2_scaled} + 
                     {{4{voice3_scaled[15]}}, voice3_scaled};
    assign sample_out = mix_sum[17:2];

    assign new_sample_ready = 
        sample_ready1 && sample_ready2 && sample_ready3 &&
        harmonic1_x2_ready && harmonic1_x3_ready &&
        harmonic2_x2_ready && harmonic2_x3_ready &&
        harmonic3_x2_ready && harmonic3_x3_ready;

        
endmodule