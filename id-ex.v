`timescale 1ns / 1ps

module ID_EX (
    input clk, reset,
    input [31:0] pcD, insD,
    input [4:0] rwaD,
    input [31:0] rd1D, rd2D, erD, rpcD,
    input [3:0] execD,
    input bdD, validD,
    output reg [31:0] pc, ins,
    output reg [4:0] rwa,
    output reg [31:0] rd1, rd2, er, rpc,
    output reg [3:0] exec,
    output reg bd, valid
    );

    always @(posedge clk)
        { pc,  ins,  rwa,  rd1,  rd2,  er,  rpc,  exec,  bd,  valid } <= reset ? 0 :
        { pcD, insD, rwaD, rd1D, rd2D, erD, rpcD, execD, bdD, validD };
endmodule
