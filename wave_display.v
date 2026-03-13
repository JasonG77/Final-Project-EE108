module wave_display (
    input clk,
    input reset,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]
    input valid,
//    input [7:0] read_value, //remove
    input [7:0] read_voice1,
    input [7:0] read_voice2,
    input [7:0] read_voice3,
    input [7:0] read_mix,
    input read_index,
    output wire [8:0] read_address,
    output wire valid_pixel,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);
    //removed for enhanced wave display
//    assign r = 8'hFF;
//    assign g = 8'hFF;
//    assign b = 8'hFF;


    wire in_mid      = (x[9:8] == 2'b01) || (x[9:8] == 2'b10);
    wire in_top_half = (y[9] == 1'b0);
    wire in_region   = valid && in_mid && in_top_half;

    wire [7:0] low_addr = {x[9], x[7:1]};
    assign read_address = {read_index, low_addr};

    wire [7:0] y_8bit = y[8:1];

    // 800x480 adjustment for sample values (all 4 channles for enhanced display)
    wire [7:0] adj_mix = (read_mix >> 1) + 8'd32;
    wire [7:0] adj_voice1 = (read_voice1 >> 1) + 8'd32;

    wire [7:0] adj_voice2 = (read_voice2 >> 1) + 8'd32;

    wire [7:0] adj_voice3 = (read_voice3 >> 1) + 8'd32;


    wire [8:0] addr_delay;
    wire [8:0] next_addr_delay;

    wire addr_changed;     // 1-cycle delayed pulse
    wire next_changed;

    wire in_region_d;
    wire next_region;

    wire [7:0] previous;
    wire [7:0] next_previous;

    wire [7:0] current;
    wire [7:0] next_sample;

    wire first_column;
    wire next_first_column;

    dffr #(9) addr_delay_ff (
        .clk(clk),
        .r(reset),
        .d(next_addr_delay),
        .q(addr_delay)
    );

    dffr #(1) addr_changed_ff (
        .clk(clk),
        .r(reset),
        .d(next_changed),
        .q(addr_changed)
    );

    dffr #(1) in_region_ff (
        .clk(clk),
        .r(reset),
        .d(next_region),
        .q(in_region_d)
    );

    dffr #(8) previous_ff (
        .clk(clk),
        .r(reset),
        .d(next_previous),
        .q(previous)
    );

    dffr #(8) current_ff (
        .clk(clk),
        .r(reset),
        .d(next_sample),
        .q(current)
    );

    dffr #(1) first_column_ff (
        .clk(clk),
        .r(reset),
        .d(next_first_column),
        .q(first_column)
    );
    
    

    assign next_changed    = (read_address != addr_delay);
    assign next_addr_delay = read_address;
    
    // Delay region gate to align with sample pipeline
    assign next_region = in_region;

    // First-column handling to prevent vertical line at sweep start
    wire wrap_to_zero = (read_address[7:0] == 8'd0);

    assign next_first_column =
        wrap_to_zero ? 1'b1 :
        (addr_changed ? (first_column ? 1'b0 : first_column) : first_column);

    assign next_previous =
        addr_changed ? (first_column ? adj_mix : current) : previous;

    assign next_sample =
        addr_changed ? adj_mix : current;

    // Draw a line segment between previous and current
//    wire [7:0] high = (previous > current) ? previous : current;
//    wire [7:0] low  = (previous > current) ? current  : previous;

//    assign valid_pixel = in_region_d && (y_8bit >= low) && (y_8bit <= high);

    
    wire [7:0] previous_v1, current_v1, next_previous_v1, next_sample_v1;
    wire [7:0] previous_v2, current_v2, next_previous_v2, next_sample_v2;
    wire [7:0] previous_v3, current_v3, next_previous_v3, next_sample_v3;

    dffr #(8) prev_v1 (
        .clk(clk),
        .r(reset),
        .d(next_previous_v1),
        .q(previous_v1)
        );
    
    
    dffr #(8) curr_v1  (
        .clk(clk),
        .r(reset), 
        .d(next_sample_v1),
        .q(current_v1)
        );
        
    dffr #(8) prev_v2 (
        .clk(clk),
        .r(reset),
        .d(next_previous_v2),
        .q(previous_v2)
        );
        
    dffr #(8) curr_v2  (
        .clk(clk),
        .r(reset),
        .d(next_sample_v2),
        .q(current_v2)
        );
        
    dffr #(8) prev_v3 (
        .clk(clk),
        .r(reset),
        .d(next_previous_v3),
        .q(previous_v3)
        );
        
    dffr #(8) curr_v3 (
        .clk(clk),
        .r(reset),
        .d(next_sample_v3),
        .q(current_v3)
        );

    assign next_previous_v1 = addr_changed ? (first_column ? adj_voice1 : current_v1) : previous_v1;
    assign next_sample_v1   = addr_changed ? adj_voice1 : current_v1;
    assign next_previous_v2 = addr_changed ? (first_column ? adj_voice2 : current_v2) : previous_v2;
    assign next_sample_v2   = addr_changed ? adj_voice2 : current_v2;
    assign next_previous_v3 = addr_changed ? (first_column ? adj_voice3 : current_v3) : previous_v3;
    assign next_sample_v3   = addr_changed ? adj_voice3 : current_v3;

    // line segments
    wire [7:0] high_mix = (previous   > current)    ? previous   : current;
    wire [7:0] low_mix  = (previous   > current)    ? current    : previous;
    wire [7:0] high_v1  = (previous_v1 > current_v1) ? previous_v1 : current_v1;
    wire [7:0] low_v1   = (previous_v1 > current_v1) ? current_v1  : previous_v1;
    wire [7:0] high_v2  = (previous_v2 > current_v2) ? previous_v2 : current_v2;
    wire [7:0] low_v2   = (previous_v2 > current_v2) ? current_v2  : previous_v2;
    wire [7:0] high_v3  = (previous_v3 > current_v3) ? previous_v3 : current_v3;
    wire [7:0] low_v3   = (previous_v3 > current_v3) ? current_v3  : previous_v3;

    wire hit_mix = in_region_d && (y_8bit >= low_mix) && (y_8bit <= high_mix);
    wire hit_v1  = in_region_d && (y_8bit >= low_v1)  && (y_8bit <= high_v1);
    wire hit_v2  = in_region_d && (y_8bit >= low_v2)  && (y_8bit <= high_v2);
    wire hit_v3  = in_region_d && (y_8bit >= low_v3)  && (y_8bit <= high_v3);

    assign valid_pixel = hit_mix | hit_v1 | hit_v2 | hit_v3;

    // white > red > green > blue
    assign r = (hit_mix | hit_v1) ? 8'hFF : 8'h00;
    assign g = (hit_mix | hit_v2) ? 8'hFF : 8'h00;
    assign b = (hit_mix | hit_v3) ? 8'hFF : 8'h00;

endmodule