`timescale 1ns / 1ps

// {Code.exe} -g $1:$2
module DEXT(
    input [31:0] x,
    input [1:0] a, mode,
    input e0,
    output [31:0] r
    );

    wire [7:0] b;
    MUX4 #(8) u1(
        x[7:0], x[15:8], x[23:16], x[31:24],
        a, b
    );
    wire [15:0] h = a[1] ? x[31:16] : x[15:0];

    wire pb, ph;
    assign { pb, ph } = e0 ? 2'b0 : { b[7], h[15] };

    MUX3 u(x,
        { {24{pb}}, b },
        { {16{ph}}, h },
        mode, r
    );
endmodule
