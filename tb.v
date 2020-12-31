`timescale 1ns / 1ps

module tb;
	reg clk, reset, interrupt;
    wire [31:0] addr;

	mips uut(
		.clk(clk),
		.reset(reset),
        .interrupt(interrupt),
        .addr(addr)
	);

	initial begin
		clk = 1;
        interrupt = 0;
		reset = 1;

		#40;
        reset = 0;

		// No stimulus here
	end
    always #5 clk <= ~clk;
endmodule
