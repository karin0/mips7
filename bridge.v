`timescale 1ns / 1ps

// support r/w by word
module Bridge #(parameter
    BEGIN_0 = 'h7f00 >> 2,
    END_0   = 'h7f0b >> 2,
    BEGIN_1 = 'h7f10 >> 2,
    END_1   = 'h7f1b >> 2,  // closed; by word
    RO      = 'h2
    ) (
    input [31:2] a,
    input [31:0] wd,
    input we,
    input [1:0] em,
    output [31:0] rd,
    output hit, erq,
    output [5:0] int,

    input [31:0] rd0, rd1,
    input irq0, irq1, irq2,
    output [31:2] a0, a1,
    output we0, we1,
    output [31:0] wdx
    );

    wire hit0 = BEGIN_0 <= a && a <= END_0;
    wire hit1 = BEGIN_1 <= a && a <= END_1;
    assign hit = hit0 || hit1;

    assign a0 = a - BEGIN_0;
    assign a1 = a - BEGIN_1;
    assign wdx = wd;
    assign rd = hit0 ? rd0 : rd1;

    wire erq0 = hit0 && we && a0 == RO;
    wire erq1 = hit1 && we && a1 == RO;
    assign erq = |em || erq0 || erq1;

    assign we0 = hit0 && we && ~erq;
    assign we1 = hit1 && we && ~erq;

    assign int = { 3'b0, irq2, irq1, irq0 };
endmodule
