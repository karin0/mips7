`timescale 1ns / 1ps

// rd2, rpc, ar
module EX_MEM (
    input clk, reset,
    input [31:0] pcE, insE,
    input [4:0] rwaE,
    input [31:0] rd2E, arE,
    input [1:0] tnE,
    input [31:0] rwdE,
    input [3:0] execE,
    input bdE, validE,
    output reg [31:0] pc, ins,
    output reg [4:0] rwa,
    output reg [31:0] rd2, ar, // ar after E could be from HILO
    output reg tn,
    output reg [31:0] rwd,
    output reg [3:0] exec,
    output reg bd, valid
    );

    always @(posedge clk)
        { pc,  ins,  rwa,  rd2,  ar,  tn, rwd, exec, bd, valid } <= reset ? 0 :
        { pcE, insE, rwaE, rd2E, arE, tnE[1],
            tnE == 2'd1 ? arE : rwdE,
            execE, bdE, validE
        };
        // 10, 01, 00 -> 1, 0, 0
endmodule
