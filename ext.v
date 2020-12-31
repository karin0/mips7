`timescale 1ns / 1ps

module EXT(
    input [15:0] x,
    input e0,
    output [31:0] r
    );

    wire signed [31:0] sr = $signed(x);
    assign r = e0 ? x : sr;
endmodule
