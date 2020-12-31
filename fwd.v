`timescale 1ns / 1ps

module FWD(
    input [4:0] ra,
    input [31:0] rd,
    input we1,
    input [4:0] wa1,
    input [31:0] wd1,
    input we2,
    input [4:0] wa2,
    input [31:0] wd2,
    output [31:0] r
    );
    assign r = ra ? we1 && wa1 == ra ? wd1 :
                    we2 && wa2 == ra ? wd2 : rd
                  : 0;
endmodule

module DFWD(
    input [4:0] ra1,
    input [31:0] rd1,
    input [4:0] ra2,
    input [31:0] rd2,
    input we1,
    input [4:0] wa1,
    input [31:0] wd1,
    input we2,
    input [4:0] wa2,
    input [31:0] wd2,
    output [31:0] r1,
    output [31:0] r2
);
    FWD u1(ra1, rd1, we1, wa1, wd1, we2, wa2, wd2, r1);
    FWD u2(ra2, rd2, we1, wa1, wd1, we2, wa2, wd2, r2);
endmodule

module HFWD(
    input [4:0] ra,
    input [31:0] rd,
    input we,
    input [4:0] wa,
    input [31:0] wd,
    output [31:0] r
    );
    assign r = ra ? we && wa == ra ? wd : rd : 0;
endmodule
