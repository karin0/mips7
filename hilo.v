`timescale 1ns / 1ps

module HILO(
    input clk, reset,
    input [31:0] a, b,
    input [1:0] op,
    input start, we, rollback,
    output [31:0] rd,
    output busy,
    output stall
    );

    reg [31:0] hi, lo, lhi, llo;
    reg [3:0] cnt;

    assign busy = cnt > 0;
    assign stall = busy || start; // cnt > 1 || start;
    assign rd = busy ? 32'b0 : op[0] ? hi : lo;

    always @(posedge clk) begin
        if (reset)
            { hi, lo, cnt, lhi, llo } <= 0;
        else begin
            { lhi, llo } <= { hi, lo };
            if (busy) begin
                if (rollback) begin
                    cnt <= 0;
                    { hi, lo } <= { lhi, llo };
                end else
                    cnt <= cnt - 1;
            end else if (start) begin
                case (op)
                    0: begin
                        { hi, lo } <= a * b;
                        cnt <= 5;
                    end
                    1: begin
                        { hi, lo } <= $signed(a) * $signed(b);
                        cnt <= 5;
                    end
                    2: begin
                        lo <= a / b;
                        hi <= a % b;
                        cnt <= 10;
                    end
                    default: begin
                        lo <= $signed(a) / $signed(b);
                        hi <= $signed(a) % $signed(b);
                        cnt <= 10;
                    end
                endcase
            end else if (we) begin
                if (op[0])
                    hi <= a;
                else
                    lo <= a;
            end if (rollback) begin
                cnt <= 0;
                { hi, lo } <= { lhi, llo };
            end
        end
    end
endmodule
