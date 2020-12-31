`timescale 1ns / 1ps

module NPC(
    input [31:0] pcF, pcD,
    input [31:0] boff,
    input [25:0] jind,
    input [31:0] jwd,
    input be,
    input [1:0] mode,
    input trap, eret,
    input [31:0] epc,
    output [31:0] npc, rpc
    );

    assign rpc = pcD + 8;
    wire [31:0] ncF = pcF + 4;
    MUX4 mux(ncF,
        be ? pcD + 4 + (boff << 2) : ncF,
        { pcD[31:28], jind, 2'b00 },
        jwd,
        mode);

    assign npc = eret ? epc : trap ? 'h4180 : mux.y;  // ?

endmodule
