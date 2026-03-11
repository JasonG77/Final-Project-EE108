module wave_display (
    input clk,
    input reset,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]
    input valid,
    input [7:0] read_value,
    input read_index,
    output wire [8:0] read_address,
    output wire valid_pixel,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

    assign r = 8'hFF;
    assign g = 8'hFF;
    assign b = 8'hFF;

    wire in_mid      = (x[9:8] == 2'b01) || (x[9:8] == 2'b10);
    wire in_top_half = (y[9] == 1'b0);
    wire in_region   = valid && in_mid && in_top_half;

    wire [7:0] low_addr = {x[9], x[7:1]};
    assign read_address = {read_index, low_addr};

    wire [7:0] y_8bit = y[8:1];

    // 800x480 adjustment for sample values
    wire [7:0] read_adj = (read_value >> 1) + 8'd32;

    wire [8:0] addr_delay;
    wire [8:0] next_addr_delay;

    wire addr_changed;     // 1-cycle delayed "address changed" pulse
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

    // Address tracking + delayed change pulse
    assign next_changed    = (read_address != addr_delay);
    assign next_addr_delay = read_address;

    // Delay region gate to align with sample pipeline
    assign next_region = in_region;

    // First-column handling to prevent vertical line at sweep start
    wire wrap_to_zero = (read_address[7:0] == 8'd0);

    assign next_first_column =
        wrap_to_zero ? 1'b1 :
        (addr_changed ? (first_column ? 1'b0 : first_column) : first_column);

    // Update endpoints only when the delayed change pulse is high
    assign next_previous =
        addr_changed ? (first_column ? read_adj : current) : previous;

    assign next_sample =
        addr_changed ? read_adj : current;

    // Draw a line segment between previous and current
    wire [7:0] high = (previous > current) ? previous : current;
    wire [7:0] low  = (previous > current) ? current  : previous;

    assign valid_pixel = in_region_d && (y_8bit >= low) && (y_8bit <= high);

endmodule

