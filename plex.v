`timescale 1ns / 1ps

module MUX4 #(parameter WIDTH = 32) (
    input [WIDTH - 1 : 0] x0, x1, x2, x3,
    input [1:0] ind,
    output reg [WIDTH - 1 : 0] y
    );
    always @(*) case (ind)
        'b01: y = x1;
        'b10: y = x2;
        'b11: y = x3;
        default: y = x0;
    endcase
endmodule

module MUX3 #(parameter WIDTH = 32) (
    input [WIDTH - 1 : 0] x0, x1, x2,
    input [1:0] ind,
    output reg [WIDTH - 1 : 0] y
    );
    always @(*) case (ind)
        'b01: y = x1;
        'b10: y = x2;
        default: y = x0;
    endcase
endmodule

module PE4(
    input x1, x2, x3,
    output [1:0] y
);
    assign y = x3 ? 3 : x2 ? 2 : x1 ? 1 : 0;
endmodule

module PE3(
    input x1, x2,
    output [1:0] y
);
    assign y = x2 ? 2 : x1 ? 1 : 0;
endmodule

module RPE #(parameter WIDTH = 32, WIDTH_WIDTH = 5) (
    input [WIDTH - 1 : 1] x,
    output reg [WIDTH_WIDTH - 1 : 0] y
);
    integer i;
    always @(*) begin
        y = 0;
        for (i = 1; i < WIDTH; i = i + 1)
            if (x[i])
                y = WIDTH - i;
    end
endmodule

module RMUX #(parameter SIZE = 4, SIZE_WIDTH = 2) (
    input [SIZE - 1 : 0] x,
    input [SIZE_WIDTH - 1 : 0] ind,
    output y
);
    assign y = x[SIZE - 1 - ind];
endmodule
