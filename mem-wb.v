`timescale 1ns / 1ps

// rpc, ar, drd
module MEM_WB (
    input clk,
    input reset,
    input [31:0] pcM,
    input [31:0] insM,
    input [4:0] rwaM,
    input [31:0] resM,
    input [1:0] dalM,
    input tnM,
    input [31:0] rwdM,
    output reg [31:0] pc,
    output reg [31:0] ins,
    output reg [4:0] rwa,
    output reg [31:0] lres,
    output reg [1:0] dal,
    output reg ltn,
    output reg [31:0] lrwd
    );

    always @(posedge clk)
        { pc,  ins,  rwa,  lres, dal,  ltn, lrwd } <= reset ? 0 :
        { pcM, insM, rwaM, resM, dalM, tnM, rwdM };

endmodule
