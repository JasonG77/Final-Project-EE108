module context_icons(
    input [10:0] x,
    input [9:0] y,
    input [1:0] state,
    output icon_on,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b
);

    // state encoding
    // 00 = play
    // 01 = fast-forward
    // 10 = rewind
    // 11 = pause

    // visible display starts near (88,32), so place icon inside that region
    localparam X0 = 11'd108;
    localparam Y0 = 10'd52;

    wire in_box;
    wire [10:0] lx;
    wire [9:0]  ly;

    assign in_box = (x >= X0) && (x < X0 + 11'd80) &&
                    (y >= Y0) && (y < Y0 + 10'd80);

    assign lx = x - X0;
    assign ly = y - Y0;

    // ------------------------------------------------------------
    // Pause icon: two vertical bars
    // ------------------------------------------------------------
    wire pause_left_bar;
    wire pause_right_bar;
    wire pause_icon;

    assign pause_left_bar =
        in_box &&
        (lx >= 11'd15) && (lx <= 11'd25) &&
        (ly >= 10'd10) && (ly <= 10'd70);

    assign pause_right_bar =
        in_box &&
        (lx >= 11'd45) && (lx <= 11'd55) &&
        (ly >= 10'd10) && (ly <= 10'd70);

    assign pause_icon = pause_left_bar || pause_right_bar;

    // ------------------------------------------------------------
    // Play icon: right-facing triangle
    // ------------------------------------------------------------
    wire play_icon;

    assign play_icon =
        in_box &&
        (lx >= 11'd15) && (lx <= 11'd45) &&
        (ly >= (10'd40 - (11'd45 - lx))) &&
        (ly <= (10'd40 + (11'd45 - lx)));    

    // ------------------------------------------------------------
    // Fast-forward icon: two right-facing triangles
    // ------------------------------------------------------------
    wire ff_left;
    wire ff_right;
    wire ff_icon;

    assign ff_left =
        in_box &&
        (lx >= 11'd5) && (lx <= 11'd25) &&
        (ly >= (10'd40 - (11'd25 - lx))) &&
        (ly <= (10'd40 + (11'd25 - lx)));

    assign ff_right =
        in_box &&
        (lx >= 11'd30) && (lx <= 11'd50) &&
        (ly >= (10'd40 - (11'd50 - lx))) &&
        (ly <= (10'd40 + (11'd50 - lx)));

    assign ff_icon = ff_left || ff_right;

    // ------------------------------------------------------------
    // Rewind icon: two left-facing triangles
    // ------------------------------------------------------------
    wire rew_left;
    wire rew_right;
    wire rew_icon;

   assign rew_left =
    in_box &&
    (lx >= 11'd5) && (lx <= 11'd25) &&
    (ly >= (10'd20 + (11'd25 - lx))) &&
    (ly <= (10'd60 - (11'd25 - lx)));

    assign rew_right =
        in_box &&
        (lx >= 11'd30) && (lx <= 11'd50) &&
        (ly >= (10'd20 + (11'd50 - lx))) &&
        (ly <= (10'd60 - (11'd50 - lx)));

    assign rew_icon = rew_left || rew_right;

    // ------------------------------------------------------------
    // Select icon from state
    // ------------------------------------------------------------
    assign icon_on =
        (state == 2'b00) ? play_icon  :
        (state == 2'b01) ? ff_icon    :
        (state == 2'b10) ? rew_icon   :
                           pause_icon;

    assign r = icon_on ? 8'hFF : 8'h00;
    assign g = icon_on ? 8'hFF : 8'h00;
    assign b = icon_on ? 8'hFF : 8'h00;

endmodule