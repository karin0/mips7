`timescale 1ns / 1ps

module RF(
    input clk,
    input reset,
    input [31:0] wpc,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
    );

    reg [31:0] regs [1:31];
    assign rd1 = ra1 ? we && ra1 == wa ? wd : regs[ra1] : 0,
           rd2 = ra2 ? we && ra2 == wa ? wd : regs[ra2] : 0;

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 0;
        end else if (we && wa) begin
            regs[wa] <= wd;
            $display("%d@%h: $%d <= %h", $time, wpc, wa, wd);
        end
    end
endmodule
