module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,

    output sample_ready,
    output wire [15:0] sample
);

    //implementation goes here
    wire [21:0] phase_counter;
    wire [21:0] next_phase_counter;
    wire [1:0] q;
    wire [9:0] raw_addr;
    wire [9:0] rom_addr;
    wire [15:0] rom_out;
    wire invert_out;
    wire invert_final;
    
//    assign next_phase_counter = phase_counter + {2'b00, step_size};
    assign next_phase_counter =
        generate_next ? phase_counter + {2'b00, step_size}
                      : phase_counter;
    
    dffr #(22) increment_phase(
        .clk(clk),
        .r(reset),
        .d(next_phase_counter),
        .q(phase_counter)
    );
    
    assign q = phase_counter [21:20] ;
    assign raw_addr = phase_counter [19:10];
    
    reg [9:0] rom_addr_comb;
    reg invert_out_comb;
    
    always @(*) begin 
        case(q)
            2'b00: begin 
                rom_addr_comb = raw_addr;
                invert_out_comb = 1'b0;
            end
            2'b01: begin  // 90� - 180� (flip horizontal)
                rom_addr_comb = 10'd1023 - raw_addr;
                invert_out_comb = 1'b0;
            end
            2'b10: begin  // 180� - 270� (flip vertical)
                rom_addr_comb = raw_addr;
                invert_out_comb = 1'b1;
            end
            2'b11: begin  // 270� - 360� (flip both)
                rom_addr_comb = 10'd1023 - raw_addr;
                invert_out_comb = 1'b1;
            end
            default: begin
                rom_addr_comb = raw_addr;
                invert_out_comb = 1'b0;
            end
        endcase
    end
    
    assign rom_addr = rom_addr_comb;
    assign invert_out = invert_out_comb;
    
    
    sine_rom rom (
        .clk(clk),
        .addr(rom_addr),
        .dout(rom_out)
    );
    
    dffr #(1) invert_pipline (
        .clk(clk),
        .r(reset),
        .d(invert_out),
        .q(invert_final)
    );
    
    //invert
    assign sample = invert_final ? (16'd0 - rom_out) : 
        rom_out;
        
    dffr #(1) sample_ready_fop (
        .clk(clk),
        .r(reset),
        .d(generate_next),
        .q(sample_ready)
    );
    
endmodule