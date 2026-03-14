`timescale 1ns/1ps

module tb_song_reader;

    reg clk;
    reg reset;
    reg play;
    reg [1:0] song;
    reg note_done;
    reg [1:0] mode;

    wire song_done;
    wire [5:0] note1;
    wire [5:0] note2;
    wire [5:0] note3;
    wire [5:0] duration;
    wire new_note;

    song_reader dut(
        .clk(clk),
        .reset(reset),
        .play(play),
        .song(song),
        .note_done(note_done),
        .mode(mode),
        .song_done(song_done),
        .note1(note1),
        .note2(note2),
        .note3(note3),
        .duration(duration),
        .new_note(new_note)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task pulse_note_done;
    begin
        note_done = 1;
        #10;
        note_done = 0;
        #20;
    end
    endtask

    initial begin
        reset = 1;
        play = 0;
        song = 2'b00;
        note_done = 0;
        mode = 2'b00;

        #30;
        reset = 0;

        // NORMAL MODE 
        mode = 2'b00;
        play = 1;
        #20;

        // Step through a few notes
        pulse_note_done();
        pulse_note_done();
        pulse_note_done();

        // FAST-FORWARD TEST
      
        reset = 1;
        #20;
        reset = 0;

        mode = 2'b01;
        play = 1;
        #20;

        pulse_note_done();
        pulse_note_done();
        pulse_note_done();

        // REWIND TEST
        reset = 1;
        #20;
        reset = 0;

        mode = 2'b10;
        play = 1;
        #20;

        pulse_note_done();
        pulse_note_done();
        pulse_note_done();
        pulse_note_done();

        #100;
        $stop;
    end

endmodule`timescale 1ns/1ps

module tb_song_reader;

    reg clk;
    reg reset;
    reg play;
    reg [1:0] song;
    reg note_done;
    reg [1:0] mode;

    wire song_done;
    wire [5:0] note1;
    wire [5:0] note2;
    wire [5:0] note3;
    wire [5:0] duration;
    wire new_note;

    song_reader dut(
        .clk(clk),
        .reset(reset),
        .play(play),
        .song(song),
        .note_done(note_done),
        .mode(mode),
        .song_done(song_done),
        .note1(note1),
        .note2(note2),
        .note3(note3),
        .duration(duration),
        .new_note(new_note)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task pulse_note_done;
    begin
        note_done = 1;
        #10;
        note_done = 0;
        #20;
    end
    endtask

    initial begin
        reset = 1;
        play = 0;
        song = 2'b00;
        note_done = 0;
        mode = 2'b00;

        #30;
        reset = 0;

        // NORMAL MODE TEST
        mode = 2'b00;
        play = 1;
        #20;

        // Step through a few notes
        pulse_note_done();
        pulse_note_done();
        pulse_note_done();

        // FAST-FORWARD TEST
        reset = 1;
        #20;
        reset = 0;

        mode = 2'b01;
        play = 1;
        #20;

        pulse_note_done();
        pulse_note_done();
        pulse_note_done();

        // REWIND TEST
        reset = 1;
        #20;
        reset = 0;

        mode = 2'b10;
        play = 1;
        #20;

        pulse_note_done();
        pulse_note_done();
        pulse_note_done();
        pulse_note_done();

        #100;
        $stop;
    end

endmodule