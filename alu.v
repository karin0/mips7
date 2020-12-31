`timescale 1ns / 1ps

module ALU(
    input [31:0] a, b,
    input [4:0] sh,
    input [3:0] op,
    input ssh,
    output reg [31:0] r,
    output erq
    );

    wire [4:0] s = ssh ? sh : a[4:0];

    wire signed [32:0] la = $signed(a), lb = $signed(b);
    wire [32:0] lr = op == 1 ? la - lb : la + lb;
    assign erq = lr[31] ^ lr[32];

    always @(*) begin
        case (op)
            1: r <= a - b;
            2: r <= a | b;
            3: r <= b << 16;
            4: r <= a ^ b;
            5: r <= ~(a | b);
            6: r <= a & b;
            7: r <= a < b;
            8: r <= $signed(a) < $signed(b);
            9: r <= b << s;
            10: r <= b >> s;
            11: r <= $signed($signed(b) >>> $signed(s));
            default: r <= a + b;
        endcase
    end
endmodule
