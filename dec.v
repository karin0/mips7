`timescale 1ns / 1ps

module DEC(
    input [31:0] ins,
    output [5:0] op, func,
    output [4:0] rs, rt,
    output [15:0] imm,
    output [4:0] rd,
    output [4:0] sh,
    output [25:0] iind
    );

    assign op = ins[31:26];
    assign func = ins[5:0];
    assign rs = ins[25:21];
    assign rt = ins[20:16];
    assign imm = ins[15:0];
    assign rd = ins[15:11];
    assign sh = ins[10:6];
    assign iind = ins[25:0];
endmodule
