`timescale 1ns / 1ps

module mips(
    input clk, reset, interrupt,
    output [31:0] addr
    );

    wire [31:0] a, wd, rd0, rd1;
    wire we, irq0, irq1;
    wire [1:0] em;
    Bridge Brd(
        .a(a[31:2]), .wd(wd), .we(we), .em(em),
        .rd0(rd0), .rd1(rd1), .irq0(irq0), .irq1(irq1), .irq2(interrupt)
    );
    TC Tc0(.clk(clk), .reset(reset),
        .Addr(Brd.a0),
        .WE(Brd.we0),
        .Din(Brd.wdx),
        .Dout(rd0),
        .IRQ(irq0)
    );
    TC Tc1(.clk(clk), .reset(reset),
        .Addr(Brd.a1),
        .WE(Brd.we1),
        .Din(Brd.wdx),
        .Dout(rd1),
        .IRQ(irq1)
    );

    CPU Cpu(.clk(clk), .reset(reset),
        .int(Brd.int),
        .iord(Brd.rd),
        .ioHit(Brd.hit),
        .ioErq(Brd.erq),
        .dwe(we), .dem(em), .da(a), .dwd(wd),
        .pc(addr)
    );

endmodule
