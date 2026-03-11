module wave_capture (
    input clk,
    input reset,
    input new_sample_ready,
    input [15:0] new_sample_in,
    input wave_display_idle,

    output wire [8:0] write_address,
    output wire write_enable,
    output wire [7:0] write_sample,
    output wire read_index
);

    localparam ARMED  = 2'd0;
    localparam ACTIVE = 2'd1;
    localparam WAIT   = 2'd2;
    
    wire [1:0] state, next_state;
    wire [7:0] count, next_count;
    wire readIdx, nextRead;
    wire [15:0] prev_sample, nextP_sample;

    
    dffr #(2) state_ff (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );
    
    dffr #(8) count_ff (
        .clk(clk),
        .r(reset),
        .d(next_count),
        .q(count)
    );
    
    dffr #(1) readIdx_ff (
        .clk(clk),
        .r(reset),
        .d(nextRead),
        .q(readIdx)
    );
    
    dffr #(16) prev_sample_ff (
        .clk(clk),
        .r(reset),
        .d(nextP_sample),
        .q(prev_sample)
    );
    
    assign read_index = readIdx;
    // Positive-going zero-cross detection
    // Detect transition from negative to non-negative sample
    wire prev_neg = prev_sample[15];
    wire curr_neg = new_sample_in[15];
    wire pos_zero_cross = (prev_neg == 1'b1) && (curr_neg == 1'b0);
    // Convert signed 16-bit audio sample to unsigned 8-bit 
    wire [7:0] displaySample = new_sample_in[15:8] + 8'd128;
    
    assign write_enable =
        (state == ACTIVE) && new_sample_ready;
    
    assign write_address =
        ((state == ACTIVE) && new_sample_ready) ? {~readIdx, count} : 9'd0;
    
    assign write_sample = displaySample;
    
    assign next_state =
        (state == ARMED)  ? ((new_sample_ready && pos_zero_cross) ? ACTIVE : ARMED) :
        (state == ACTIVE) ? ((new_sample_ready && (count == 8'd255)) ? WAIT : ACTIVE) :
        (state == WAIT)   ? (wave_display_idle ? ARMED : WAIT) :
                            ARMED;
    
    assign next_count =
        (state == ARMED)  ? 8'd0 :
        (state == ACTIVE) ? (new_sample_ready ? (count + 8'd1) : count) :
                            count;
    // Double Buffer Flip
    //Flip buffer only when WAIT and display is idle (prevents tearing)
    assign nextRead =
        (state == WAIT && wave_display_idle) ? ~readIdx : readIdx;
    
    assign nextP_sample =
        new_sample_ready ? new_sample_in : prev_sample;


endmodule

