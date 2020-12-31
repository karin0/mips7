`timescale 1ns / 1ps

module DM #(parameter
    SIZE = 4096,
    SIZE_WIDTH = 12,
    ADDR_BEGIN = 0,
    ADDR_END = 'h2fff // closed
    ) (
    input clk, reset,
    input [31:0] pc,
    input we,
    input [1:0] em,
    input [31:0] a, wd,
    output [31:0] rd,
    output hit  // dep: also works as a validater, regardless of hit or not
    );

    reg [31:0] dm[0 : SIZE - 1];
    wire [SIZE_WIDTH - 1 : 0] ind = a >> 2;
    assign rd = dm[ind];

    assign hit = ADDR_BEGIN <= a && a <= ADDR_END;

    wire [31:0] wb;
    MUX4 u1(
        { rd[31:8], wd[7:0] },
        { rd[31:16], wd[7:0], rd[7:0] },
        { rd[31:24], wd[7:0], rd[15:0] },
        { wd[7:0], rd[23:0] },
        a[1:0], wb
    );

    wire [31:0] wh = a[1] ? { wd[15:0], rd[15:0] } : { rd[31:16], wd[15:0] };

    wire [31:0] awd;
    MUX3 u2(wd, wb, wh, em, awd);

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < SIZE; i = i + 1)
                dm[i] <= 0;
        end else if (we && hit) begin
            dm[ind] <= awd;
            $display("%d@%h: *%h <= %h", $time, pc, { a[31:2], 2'b0 }, awd);
        end
    end
endmodule
