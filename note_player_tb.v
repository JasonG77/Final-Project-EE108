`timescale 1ns/1ps

module tb_note_player;

    reg clk;
    reg reset;
    reg play_enable;
    reg [5:0] note_to_load1;
    reg [5:0] note_to_load2;
    reg [5:0] note_to_load3;
    reg [5:0] duration_to_load;
    reg load_new_note;
    reg [1:0] mode;
    reg beat;
    reg generate_next_sample;

    wire done_with_note;
    wire [15:0] sample_out;
    wire new_sample_ready;

    note_player dut(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load1(note_to_load1),
        .note_to_load2(note_to_load2),
        .note_to_load3(note_to_load3),
        .duration_to_load(duration_to_load),
        .load_new_note(load_new_note),
        .mode(mode),
        .done_with_note(done_with_note),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(sample_out),
        .new_sample_ready(new_sample_ready)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        play_enable = 0;
        note_to_load1 = 0;
        note_to_load2 = 0;
        note_to_load3 = 0;
        duration_to_load = 0;
        load_new_note = 0;
        mode = 2'b00;
        beat = 0;
        generate_next_sample = 0;

        #30;
        reset = 0;
        play_enable = 1;

        // Load a chord: 4A, 4D, 5A for 8 beats
        note_to_load1 = 6'd37;
        note_to_load2 = 6'd42;
        note_to_load3 = 6'd49;
        duration_to_load = 6'd8;
        load_new_note = 1;
        #10;
        load_new_note = 0;

        // Generate audio sample requests and beats
        repeat (40) begin
            generate_next_sample = 1;
            #10;
            generate_next_sample = 0;
            #10;
        end

        // 8 beat pulses
        repeat (8) begin
            beat = 1;
            #10;
            beat = 0;
            #30;
        end

        #50;

        // Fast-forward mode: same chord, same duration register,
        // should finish sooner if effective duration is shortened
        mode = 2'b01;
        note_to_load1 = 6'd35;
        note_to_load2 = 6'd42;
        note_to_load3 = 6'd47;
        duration_to_load = 6'd8;
        load_new_note = 1;
        #10;
        load_new_note = 0;

        repeat (20) begin
            generate_next_sample = 1;
            #10;
            generate_next_sample = 0;
            #10;
        end

        repeat (4) begin
            beat = 1;
            #10;
            beat = 0;
            #30;
        end

        #100;
        $stop;
    end

endmodule