`timescale 1ns / 1ps

module CP0(
    input clk, reset, we,
    input [4:0] a,
    input [31:0] wd, pc,
    input bd,
    input [3:0] exec,
    input [5:0] int,
    input eret,
    output [31:0] rd,
    output reg [31:0] epc,
    output trap, trapInt
    );

    localparam SR = 12, CAUSE = 13, EPC = 14;

    reg [5:0] srIm;
    reg srExl, srIe;
    wire [31:0] sr = { 16'b0, srIm, 8'b0, srExl, srIe };

    reg [5:0] csIp;
    reg [3:0] csExec;  // shorten from 5-bit
    reg csBd;
    wire [31:0] cause = { csBd, 15'b0, csIp, 4'b0, csExec, 2'b0 };

    wire [31:0] prid = 'h616b6172;

    assign rd = a == SR ? sr :
                a == CAUSE ? cause :
                a == EPC ? epc : prid;

    wire i = (int & srIm) && srIe;  // srExl is considered later
    assign trap = (i || exec) && ~srExl;  // not only int, but also exe
    assign trapInt = i && ~srExl;

    always @(posedge clk) begin
        if (reset) begin
            { srIm, srExl, srIe, csIp, csExec, csBd, epc } <= 0;
            // srIe <= 1;  // ?
        end else begin
            csIp <= int;
            if (eret)  // ?
                srExl <= 0;
            else if (trap) begin
                // put this former to trap eret properly in user mode
                srExl <= 1;
                csExec <= trapInt ? 0 : exec;  // int first
                csBd <= bd;
                epc <= { pc[31:2] - bd, 2'b0 };
            end else if (we) case (a)  // it also conflicts with writing to srExl
                SR: begin
                    srIm <= wd[15:10];
                    srExl <= wd[1];  // ?
                    srIe <= wd[0];
                end
                EPC:
                    epc <= wd;  // could be illegal and cause excepton after return
            endcase
        end
    end
endmodule
