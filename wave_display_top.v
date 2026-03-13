module wave_display_top(
    input clk,
    input reset,
    input new_sample,
    input [15:0] sample,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]   
    input [15:0] voice1, //enhaanced display 
    input [15:0] voice2,
    input [15:0] voice3,       
    input valid,
    input vsync,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b
);
    //enhanced display - write 4 waves
    wire [7:0] write_sample_1;
    wire [7:0] write_sample_2;
    wire [7:0] write_sample_3;
    wire [7:0] write_sample_mix;
    
    wire [8:0] read_address, write_address;
    wire read_index;
    wire write_en;
    wire wave_display_idle = ~vsync;

    wave_capture wc(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(sample),
        .write_address(write_address),
        .write_enable(write_en),
        .write_sample(write_sample_mix),
        .wave_display_idle(wave_display_idle),
        .read_index(read_index)
    );
    
    //enhanced display - convert  to unsigned 8bit
    assign write_sample_1 = voice1[15:8] + 8'd128;
    assign write_sample_2 = voice2[15:8] + 8'd128;
    assign write_sample_3 = voice3[15:8] + 8'd128;
    
    // enhanced display RAM | voice1 : red | voice2 : green | voice3 : blue | mix : white
    wire [7:0] read_voice1;
    wire [7:0] read_voice2;
    wire [7:0] read_voice3;
    wire [7:0] read_mix;
    
    
    //mix
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_1(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample_1),
        .douta(),
        .addrb(read_address),
        .doutb(read_voice1)
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_2(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample_2),
        .douta(),
        .addrb(read_address),
        .doutb(read_voice2)
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_3(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample_3),
        .douta(),
        .addrb(read_address),
        .doutb(read_voice3)
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_mix(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample_mix),
        .douta(),
        .addrb(read_address),
        .doutb(read_mix)
    );
    
    
    
    
 
    wire valid_pixel;
    wire [7:0] wd_r, wd_g, wd_b;
    wave_display wd(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .valid(valid),
        .read_address(read_address),
        .read_mix(read_mix),
        .read_voice1(read_voice1),
        .read_voice2(read_voice2),
        .read_voice3(read_voice3),
        .read_index(read_index),
        .valid_pixel(valid_pixel),
        .r(wd_r), .g(wd_g), .b(wd_b)
    );

    assign {r, g, b} = valid_pixel ? {wd_r, wd_g, wd_b} : {3{8'b0}};

endmodule
