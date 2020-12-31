`timescale 1ns / 1ps

module IF_ID (
    input clk, reset,
    input we,
    input [31:0] pcF, insF,
    input bdF,
    input [3:0] execF,
    output reg [31:0] pc, ins,
    output reg bd,
    output reg [3:0] exec,
    output reg valid
    );

    always @(posedge clk)
        { pc, ins, bd, exec, valid } <= reset ? 0 :
            we ? { pcF, insF, bdF, execF, 1'b1 } :
                 { pc, ins, bd, exec, valid };
endmodule
