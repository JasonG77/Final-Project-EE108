`timescale 1ns / 1ps

module stereo_effects(
    input signed [15:0] voice1,
    input signed [15:0] voice2,
    input signed [15:0] voice3,
    output signed [15:0] sample_outL,
    output signed [15:0] sample_outR
);

    wire signed [17:0] sumL = {{2{voice1[15]}}, voice1} + {{2{voice2[15]}}, (voice2 >>> 1)};
    wire signed [17:0] sumR = {{2{voice3[15]}}, voice3} + {{2{voice2[15]}}, (voice2 >>> 1)};

    assign sample_outL = sumL[16:1];
    assign sample_outR = sumR[16:1];
    
    
    
endmodule
