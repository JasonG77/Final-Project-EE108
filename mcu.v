module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output play,
    output reset_player,
    output [1:0] song,
    input song_done
);
    // Implementation goes here!
    localparam PAUSED = 1'b0;
    localparam PLAYING = 1'b1;
    
    wire state;
    wire next_state;
    wire [1:0] next_song;
    
    dffr #(1) state_reg(
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );
    
    dffr #(2) song_counter (
        .clk(clk),
        .r(reset),
        .d(next_song),
        .q(song)
    );
    
    assign next_state = next_button ? PAUSED :      // pressed next
        (state == PLAYING && song_done) ? PAUSED :     // song done
        play_button ? ~state :                      // toggle play/paused
        state;                                      // stay in current state
    
    wire increment_song;
    assign increment_song = next_button || (state == PLAYING && song_done);
    
    assign next_song = increment_song ? (song + 2'b01) : song; 
    
    assign play = state == PLAYING;
    assign reset_player = next_button;
    
endmodule