`timescale 1ns / 1ps

module CMP(
    input [31:0] a, b,
    input [2:0] mode,
    output r
    );

    wire signed [31:0] sa = a;
    RMUX #(6, 3) u({
        a == b,
        a != b,
        sa < 0,
        sa > 0,
        sa <= 0,
        sa >= 0
    }, mode, r);
endmodule
