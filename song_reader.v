module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input note_done,
    input [1:0] mode,
    output song_done,
    output [5:0] note1,
    output [5:0] note2,
    output [5:0] note3,
    output [5:0] duration,
    output new_note
);

    // Implementation goes here!
    localparam WAIT_FOR_PLAY = 2'D0;
    localparam LOAD_NOTE = 2'D1;
    //   localparam WAIT_ROM = 2'd2;  
    localparam WAIT_FOR_NOTE_DONE =  2'D2;
    
    
    
    wire [1:0] state;
    wire [1:0] next_state;
    wire [4:0] counter;
    wire [4:0] next_counter;
    wire [6:0] rom_address;
    wire [23:0] rom_data;
    wire last_note;
    wire first_note;
    
    assign first_note = (counter == 5'd0);
    assign last_note  = (counter == 5'd31);
    
    dffr #(2) state_mem (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );
    
    dffr #(5) counter_mem (
        .clk(clk),
        .r(reset),
        .d(next_counter),
        .q(counter)
    );
    
    assign rom_address = {song, counter};
    
    song_rom rom (
        .clk(clk),
        .addr(rom_address),
        .dout(rom_data)
    );
    
    assign next_state =
    (state == WAIT_FOR_PLAY) ? (play ? LOAD_NOTE : WAIT_FOR_PLAY) :
    (state == LOAD_NOTE) ? WAIT_FOR_NOTE_DONE :
    (state == WAIT_FOR_NOTE_DONE && note_done) ?
        (song_done ? WAIT_FOR_PLAY : LOAD_NOTE) :
    state;

// WAIT_FOR_PLAY state
// Increment counter when WAIT_NOTE_DONE to LOAD_NOTE
    
     assign next_counter =
    (state == WAIT_FOR_PLAY) ? ((mode == 2'b10) ? 5'd31 : 5'd0) :
    (state == WAIT_FOR_NOTE_DONE && note_done) ?
        ((mode == 2'b00) ? (last_note  ? counter : (counter + 5'd1)) :
         (mode == 2'b01) ? (last_note  ? counter : (counter + 5'd1)) :
         (mode == 2'b10) ? (first_note ? counter : (counter - 5'd1)) :
                           counter) :
    counter;
//    assign next_counter = 
//        (state == WAIT_FOR_PLAY) ? 5'd0 :
//        (state == WAIT_FOR_NOTE_DONE && note_done && !last_note) ? 
//            (counter + 5'd1) : counter;  // Hold current value
            
    // out
    
    //fix assign statements to new ROM format
    assign note1    = rom_data[23:18];
    assign note2    = rom_data[17:12];
    assign note3    = rom_data[11:6];
    assign duration = rom_data[5:0];
    
    //last note done playin 
    assign song_done =
    (state == WAIT_FOR_NOTE_DONE) && note_done &&
    (((mode == 2'b00) || (mode == 2'b01)) ? last_note :
     (mode == 2'b10) ? first_note :
                       1'b0); 
    //new_note pulses for one cycle when entering WAIT_FOR_NOTE_DONE state
    // from LOAD_NOTE
    assign new_note = (state == LOAD_NOTE);




endmodule
