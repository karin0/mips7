`timescale 1ns / 1ps

module IFU #(parameter
    SIZE = 4096,
    //  SIZE_WIDTH = 12,
    PC_BEGIN = 'h3000,
    PC_END = 'h4ffc // closed
    ) (
    input clk, reset,
    input we,
    input [31:0] npc,
    output reg [31:0] pc,
    output [31:0] ins,
    output erq
    // output halt
    );

    reg [31:0] im[0 : SIZE - 1];
    // reg [SIZE_WIDTH - 1 : 0] ind;

    wire [31:2] ind = (pc - PC_BEGIN) >> 2;
    // wire [31:0] ind32 = ind;
    // assign pc = (ind32 << 2) + START;

    wire [31:2] nind = (npc - PC_BEGIN) >> 2;
    // wire halt = ind >= SIZE;
    assign erq = pc[1] || pc[0] || pc < PC_BEGIN || pc > PC_END;
    assign ins = erq ? 0 : im[ind];

    wire [63:0] fn = "code.txt";
    wire [127:0] handler_fn = "code_handler.txt";

    wire [31:0] pad = 'hfff114514;
    reg [31:0] pcEnd;
    task init_im;
        integer i;
        begin
            pc <= PC_BEGIN;

            for (i = 0; i < SIZE; i = i + 1)
                im[i] = pad;
            $readmemh(fn, im);

            i = 0;
            while (im[i] != pad)
                i = i + 1;

            for (pcEnd = PC_BEGIN + ((i + 6) << 2);
                 i < SIZE; i = i + 1)
                im[i] = 0;

            $readmemh(handler_fn, im, 1120, 2047);
        end
    endtask

    initial init_im();

    always @(posedge clk) begin
        if (reset)
            init_im();
        else if (we)
            pc <= npc;

        // cannot detect by >= for compatibility with exception
        if (pc == pcEnd)
            $finish();
    end
endmodule
