`timescale 1ns / 1ps

module note_display(
    input clk,
    input reset,

    // song_reader 
    input [5:0] note1,
    input [5:0] note2,
    input [5:0] note3,

    // VGA pixel coordinates
    input [10:0] x,
    input [9:0]  y,
    input        valid,

    // tcgrom interface
    output reg [8:0] char_addr,
    input      [7:0] char_data,

    // Pixel output
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b,
    output wire       valid_pixel

    );
    
    // Display
    parameter [9:0]  TEXT_Y   = 10'd460;   // top of text row
    parameter [9:0]  TEXT_H   = 10'd16;     // character height
    parameter [10:0] TEXT_X1  = 11'd670;   // note1 x start
    parameter [10:0] TEXT_X2  = 11'd720;   // note2 x start
    parameter [10:0] TEXT_X3  = 11'd770;   // note3 x start
    parameter [10:0] TEXT_W   = 11'd32;    // 2 chars * 8px each
    
    // convert note index  to tcgrom char index
    reg [5:0] letter1, digit1;
    reg [5:0] letter2, digit2;
    reg [5:0] letter3, digit3;
    
    // note 1 to char
    always @(*) begin
        case(note1)
            6'd0:  begin letter1 = 6'd45; digit1 = 6'd45; end // rest
            6'd1:  begin letter1 = 6'd1;  digit1 = 6'd49; end // 1A
            6'd3:  begin letter1 = 6'd2;  digit1 = 6'd49; end // 1B
            6'd4:  begin letter1 = 6'd3;  digit1 = 6'd49; end // 1C
            6'd6:  begin letter1 = 6'd4;  digit1 = 6'd49; end // 1D
            6'd8:  begin letter1 = 6'd5;  digit1 = 6'd49; end // 1E
            6'd9:  begin letter1 = 6'd6;  digit1 = 6'd49; end // 1F
            6'd10: begin letter1 = 6'd6;  digit1 = 6'd49; end // 1F#
            6'd11: begin letter1 = 6'd7;  digit1 = 6'd49; end // 1G
            6'd13: begin letter1 = 6'd1;  digit1 = 6'd50; end // 2A
            6'd15: begin letter1 = 6'd2;  digit1 = 6'd50; end // 2B
            6'd16: begin letter1 = 6'd3;  digit1 = 6'd50; end // 2C
            6'd18: begin letter1 = 6'd4;  digit1 = 6'd50; end // 2D
            6'd20: begin letter1 = 6'd5;  digit1 = 6'd50; end // 2E
            6'd21: begin letter1 = 6'd6;  digit1 = 6'd50; end // 2F
            6'd22: begin letter1 = 6'd6;  digit1 = 6'd50; end // 2F#
            6'd23: begin letter1 = 6'd7;  digit1 = 6'd50; end // 2G
            6'd25: begin letter1 = 6'd1;  digit1 = 6'd51; end // 3A
            6'd27: begin letter1 = 6'd2;  digit1 = 6'd51; end // 3B
            6'd28: begin letter1 = 6'd3;  digit1 = 6'd51; end // 3C
            6'd30: begin letter1 = 6'd4;  digit1 = 6'd51; end // 3D
            6'd32: begin letter1 = 6'd5;  digit1 = 6'd51; end // 3E
            6'd33: begin letter1 = 6'd6;  digit1 = 6'd51; end // 3F
            6'd34: begin letter1 = 6'd6;  digit1 = 6'd51; end // 3F#
            6'd35: begin letter1 = 6'd7;  digit1 = 6'd51; end // 3G
            6'd37: begin letter1 = 6'd1;  digit1 = 6'd52; end // 4A
            6'd38: begin letter1 = 6'd1;  digit1 = 6'd52; end // 4A#
            6'd39: begin letter1 = 6'd2;  digit1 = 6'd52; end // 4B
            6'd40: begin letter1 = 6'd3;  digit1 = 6'd52; end // 4C
            6'd41: begin letter1 = 6'd3;  digit1 = 6'd52; end // 4C#
            6'd42: begin letter1 = 6'd4;  digit1 = 6'd52; end // 4D
            6'd43: begin letter1 = 6'd4;  digit1 = 6'd52; end // 4D#
            6'd44: begin letter1 = 6'd5;  digit1 = 6'd52; end // 4E
            6'd45: begin letter1 = 6'd6;  digit1 = 6'd52; end // 4F
            6'd46: begin letter1 = 6'd6;  digit1 = 6'd52; end // 4F#
            6'd47: begin letter1 = 6'd7;  digit1 = 6'd52; end // 4G
            6'd49: begin letter1 = 6'd1;  digit1 = 6'd53; end // 5A
            6'd50: begin letter1 = 6'd1;  digit1 = 6'd53; end // 5A#
            6'd51: begin letter1 = 6'd2;  digit1 = 6'd53; end // 5B
            6'd52: begin letter1 = 6'd3;  digit1 = 6'd53; end // 5C
            6'd53: begin letter1 = 6'd3;  digit1 = 6'd53; end // 5C#
            6'd54: begin letter1 = 6'd4;  digit1 = 6'd53; end // 5D
            6'd55: begin letter1 = 6'd4;  digit1 = 6'd53; end // 5D#
            6'd56: begin letter1 = 6'd5;  digit1 = 6'd53; end // 5E
            6'd57: begin letter1 = 6'd6;  digit1 = 6'd53; end // 5F
            6'd58: begin letter1 = 6'd6;  digit1 = 6'd53; end // 5F#
            6'd59: begin letter1 = 6'd7;  digit1 = 6'd53; end // 5G
            6'd61: begin letter1 = 6'd1;  digit1 = 6'd54; end // 6A
            6'd62: begin letter1 = 6'd1;  digit1 = 6'd54; end // 6A#
            6'd63: begin letter1 = 6'd2;  digit1 = 6'd54; end // 6B
            default: begin letter1 = 6'd45; digit1 = 6'd45; end
        endcase 
    end
    
    //note 2 to char
    always @(*) begin
        case (note2)
            6'd0:  begin letter2 = 6'd45; digit2 = 6'd45; end // rest
            6'd1:  begin letter2 = 6'd1;  digit2 = 6'd49; end // 1A
            6'd3:  begin letter2 = 6'd2;  digit2 = 6'd49; end // 1B
            6'd4:  begin letter2 = 6'd3;  digit2 = 6'd49; end // 1C
            6'd6:  begin letter2 = 6'd4;  digit2 = 6'd49; end // 1D
            6'd8:  begin letter2 = 6'd5;  digit2 = 6'd49; end // 1E
            6'd9:  begin letter2 = 6'd6;  digit2 = 6'd49; end // 1F
            6'd10: begin letter2 = 6'd6;  digit2 = 6'd49; end // 1F#
            6'd11: begin letter2 = 6'd7;  digit2 = 6'd49; end // 1G
            6'd13: begin letter2 = 6'd1;  digit2 = 6'd50; end // 2A
            6'd15: begin letter2 = 6'd2;  digit2 = 6'd50; end // 2B
            6'd16: begin letter2 = 6'd3;  digit2 = 6'd50; end // 2C
            6'd18: begin letter2 = 6'd4;  digit2 = 6'd50; end // 2D
            6'd20: begin letter2 = 6'd5;  digit2 = 6'd50; end // 2E
            6'd21: begin letter2 = 6'd6;  digit2 = 6'd50; end // 2F
            6'd22: begin letter2 = 6'd6;  digit2 = 6'd50; end // 2F#
            6'd23: begin letter2 = 6'd7;  digit2 = 6'd50; end // 2G
            6'd25: begin letter2 = 6'd1;  digit2 = 6'd51; end // 3A
            6'd27: begin letter2 = 6'd2;  digit2 = 6'd51; end // 3B
            6'd28: begin letter2 = 6'd3;  digit2 = 6'd51; end // 3C
            6'd30: begin letter2 = 6'd4;  digit2 = 6'd51; end // 3D
            6'd32: begin letter2 = 6'd5;  digit2 = 6'd51; end // 3E
            6'd33: begin letter2 = 6'd6;  digit2 = 6'd51; end // 3F
            6'd34: begin letter2 = 6'd6;  digit2 = 6'd51; end // 3F#
            6'd35: begin letter2 = 6'd7;  digit2 = 6'd51; end // 3G
            6'd37: begin letter2 = 6'd1;  digit2 = 6'd52; end // 4A
            6'd38: begin letter2 = 6'd1;  digit2 = 6'd52; end // 4A#
            6'd39: begin letter2 = 6'd2;  digit2 = 6'd52; end // 4B
            6'd40: begin letter2 = 6'd3;  digit2 = 6'd52; end // 4C
            6'd41: begin letter2 = 6'd3;  digit2 = 6'd52; end // 4C#
            6'd42: begin letter2 = 6'd4;  digit2 = 6'd52; end // 4D
            6'd43: begin letter2 = 6'd4;  digit2 = 6'd52; end // 4D#
            6'd44: begin letter2 = 6'd5;  digit2 = 6'd52; end // 4E
            6'd45: begin letter2 = 6'd6;  digit2 = 6'd52; end // 4F
            6'd46: begin letter2 = 6'd6;  digit2 = 6'd52; end // 4F#
            6'd47: begin letter2 = 6'd7;  digit2 = 6'd52; end // 4G
            6'd49: begin letter2 = 6'd1;  digit2 = 6'd53; end // 5A
            6'd50: begin letter2 = 6'd1;  digit2 = 6'd53; end // 5A#
            6'd51: begin letter2 = 6'd2;  digit2 = 6'd53; end // 5B
            6'd52: begin letter2 = 6'd3;  digit2 = 6'd53; end // 5C
            6'd53: begin letter2 = 6'd3;  digit2 = 6'd53; end // 5C#
            6'd54: begin letter2 = 6'd4;  digit2 = 6'd53; end // 5D
            6'd55: begin letter2 = 6'd4;  digit2 = 6'd53; end // 5D#
            6'd56: begin letter2 = 6'd5;  digit2 = 6'd53; end // 5E
            6'd57: begin letter2 = 6'd6;  digit2 = 6'd53; end // 5F
            6'd58: begin letter2 = 6'd6;  digit2 = 6'd53; end // 5F#
            6'd59: begin letter2 = 6'd7;  digit2 = 6'd53; end // 5G
            6'd61: begin letter2 = 6'd1;  digit2 = 6'd54; end // 6A
            6'd62: begin letter2 = 6'd1;  digit2 = 6'd54; end // 6A#
            6'd63: begin letter2 = 6'd2;  digit2 = 6'd54; end // 6B
            default: begin letter2 = 6'd45; digit2 = 6'd45; end
        endcase
    end
    
    //note 3 to char
    always @(*) begin
        case (note3)
            6'd0:  begin letter3 = 6'd45; digit3 = 6'd45; end // rest
            6'd1:  begin letter3 = 6'd1;  digit3 = 6'd49; end // 1A
            6'd3:  begin letter3 = 6'd2;  digit3 = 6'd49; end // 1B
            6'd4:  begin letter3 = 6'd3;  digit3 = 6'd49; end // 1C
            6'd6:  begin letter3 = 6'd4;  digit3 = 6'd49; end // 1D
            6'd8:  begin letter3 = 6'd5;  digit3 = 6'd49; end // 1E
            6'd9:  begin letter3 = 6'd6;  digit3 = 6'd49; end // 1F
            6'd10: begin letter3 = 6'd6;  digit3 = 6'd49; end // 1F#
            6'd11: begin letter3 = 6'd7;  digit3 = 6'd49; end // 1G
            6'd13: begin letter3 = 6'd1;  digit3 = 6'd50; end // 2A
            6'd15: begin letter3 = 6'd2;  digit3 = 6'd50; end // 2B
            6'd16: begin letter3 = 6'd3;  digit3 = 6'd50; end // 2C
            6'd18: begin letter3 = 6'd4;  digit3 = 6'd50; end // 2D
            6'd20: begin letter3 = 6'd5;  digit3 = 6'd50; end // 2E
            6'd21: begin letter3 = 6'd6;  digit3 = 6'd50; end // 2F
            6'd22: begin letter3 = 6'd6;  digit3 = 6'd50; end // 2F#
            6'd23: begin letter3 = 6'd7;  digit3 = 6'd50; end // 2G
            6'd25: begin letter3 = 6'd1;  digit3 = 6'd51; end // 3A
            6'd27: begin letter3 = 6'd2;  digit3 = 6'd51; end // 3B
            6'd28: begin letter3 = 6'd3;  digit3 = 6'd51; end // 3C
            6'd30: begin letter3 = 6'd4;  digit3 = 6'd51; end // 3D
            6'd32: begin letter3 = 6'd5;  digit3 = 6'd51; end // 3E
            6'd33: begin letter3 = 6'd6;  digit3 = 6'd51; end // 3F
            6'd34: begin letter3 = 6'd6;  digit3 = 6'd51; end // 3F#
            6'd35: begin letter3 = 6'd7;  digit3 = 6'd51; end // 3G
            6'd37: begin letter3 = 6'd1;  digit3 = 6'd52; end // 4A
            6'd38: begin letter3 = 6'd1;  digit3 = 6'd52; end // 4A#
            6'd39: begin letter3 = 6'd2;  digit3 = 6'd52; end // 4B
            6'd40: begin letter3 = 6'd3;  digit3 = 6'd52; end // 4C
            6'd41: begin letter3 = 6'd3;  digit3 = 6'd52; end // 4C#
            6'd42: begin letter3 = 6'd4;  digit3 = 6'd52; end // 4D
            6'd43: begin letter3 = 6'd4;  digit3 = 6'd52; end // 4D#
            6'd44: begin letter3 = 6'd5;  digit3 = 6'd52; end // 4E
            6'd45: begin letter3 = 6'd6;  digit3 = 6'd52; end // 4F
            6'd46: begin letter3 = 6'd6;  digit3 = 6'd52; end // 4F#
            6'd47: begin letter3 = 6'd7;  digit3 = 6'd52; end // 4G
            6'd49: begin letter3 = 6'd1;  digit3 = 6'd53; end // 5A
            6'd50: begin letter3 = 6'd1;  digit3 = 6'd53; end // 5A#
            6'd51: begin letter3 = 6'd2;  digit3 = 6'd53; end // 5B
            6'd52: begin letter3 = 6'd3;  digit3 = 6'd53; end // 5C
            6'd53: begin letter3 = 6'd3;  digit3 = 6'd53; end // 5C#
            6'd54: begin letter3 = 6'd4;  digit3 = 6'd53; end // 5D
            6'd55: begin letter3 = 6'd4;  digit3 = 6'd53; end // 5D#
            6'd56: begin letter3 = 6'd5;  digit3 = 6'd53; end // 5E
            6'd57: begin letter3 = 6'd6;  digit3 = 6'd53; end // 5F
            6'd58: begin letter3 = 6'd6;  digit3 = 6'd53; end // 5F#
            6'd59: begin letter3 = 6'd7;  digit3 = 6'd53; end // 5G
            6'd61: begin letter3 = 6'd1;  digit3 = 6'd54; end // 6A
            6'd62: begin letter3 = 6'd1;  digit3 = 6'd54; end // 6A#
            6'd63: begin letter3 = 6'd2;  digit3 = 6'd54; end // 6B
            default: begin letter3 = 6'd45; digit3 = 6'd45; end
        endcase
    end
    
    wire in_y_range;
    assign in_y_range = 
    (y >= TEXT_Y) && (y < TEXT_Y + TEXT_H);
    
    
    wire [9:0] y_offset;
    assign y_offset = y - TEXT_Y;    
    wire [2:0] pix_row;
    assign pix_row = y_offset[3:1];
    
    wire in_region1, in_region2, in_region3, in_region;
    
    assign in_region1 = 
    valid && in_y_range && (x >= TEXT_X1) && (x < TEXT_X1 + TEXT_W);
    
    assign in_region2 = 
    valid && in_y_range && (x >= TEXT_X2) && (x < TEXT_X2 + TEXT_W);
    
    assign in_region3 = 
    valid && in_y_range && (x >= TEXT_X3) && (x < TEXT_X3 + TEXT_W);
    
    assign in_region = in_region1 | in_region2 | in_region3;
    
    // pixel offset
    wire [10:0] x_offset;
    assign x_offset = 
        in_region1 ? (x - TEXT_X1) :
        in_region2 ? (x - TEXT_X2) : 
        (x - TEXT_X3);
    
    wire char_col;      // 0 = letter, 1 = digit
    wire [2:0] pix_col; //column in 8x char
    assign char_col = x_offset[4];
    assign pix_col = x_offset[3:1];
    
    wire [5:0] char_idx;
    assign char_idx =
        in_region1 ? (char_col ? digit1 : letter1) :
        in_region2 ? (char_col ? digit2 : letter2) :
        (char_col ? digit3 : letter3);
        
    // tcgrom address
    
    always @(*) begin
        char_addr = {char_idx, pix_row};
    end
        
   // accounting latency
   wire [2:0] pix_col_delayed;
   wire in_region_delayed;
   
   dffr #(3) delay_pix_col (
        .clk(clk),
        .r(reset),
        .d(pix_col),
        .q(pix_col_delayed)
   );
   
   dffr #(1) delay_region (
        .clk(clk),
        .r(reset),
        .d(in_region),
        .q(in_region_delayed)
   );
   
   // pixel output
   wire pixel;
   assign pixel = in_region_delayed && char_data[7 - pix_col_delayed];
   assign r = pixel ? 8'hFF : 8'h00;
   assign g = pixel ? 8'hFF : 8'h00;
   assign b = pixel ? 8'hFF : 8'h00;
   
   assign valid_pixel = in_region_delayed;
   
    

endmodule
