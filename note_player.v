module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load1,
    input [5:0] note_to_load2,
    input [5:0] note_to_load3,
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    input [1:0] mode,
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  
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
    
    wire [5:0] real_duration;
    
    
    
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
    assign real_duration =
    (mode == 2'b01) ?
        ((duration_reg > 6'd1) ? (duration_reg >> 1) : 6'd1) :
        duration_reg;
    
    dffr #(6) duration_counter_reg (
        .clk(clk),
        .r(reset),
        .d(next_dur_counter),
        .q(dur_counter)
    );
    
    assign done_with_note = (dur_counter == real_duration);
    
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
    assign voice1 = (note_reg1 == 6'd0) ? 16'sd0 : sample1;
    assign voice2 = (note_reg2 == 6'd0) ? 16'sd0 : sample2;
    assign voice3 = (note_reg3 == 6'd0) ? 16'sd0 : sample3;
    
    wire signed [15:0] voice1_scaled;
    wire signed [15:0] voice2_scaled;
    wire signed [15:0] voice3_scaled;
    wire signed [17:0] mix_sum;
    
    assign voice1_scaled = voice1 >>> 2;
    assign voice2_scaled = voice2 >>> 2;
    assign voice3_scaled = voice3 >>> 2;
    
    assign mix_sum = voice1_scaled + voice2_scaled + voice3_scaled;
    assign sample_out = mix_sum[15:0];

    assign new_sample_ready = sample_ready1 && sample_ready2 && sample_ready3;

        
endmodule