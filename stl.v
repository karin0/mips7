`timescale 1ns / 1ps

module STL(
    input tueRs, tuRs,
    input [4:0] rs,
    input tueRt, tuRt,
    input [4:0] rt,
    input xu,
    input [1:0] tnE,
    input rweE,
    input [4:0] rwaE,
    input tnM,
    input rweM,
    input [4:0] rwaM,
    input xstallE,
    output stall
    );

    function f;
        input tue, tu;
        input [4:0] ra;
        input rweE, rweM;
        input [4:0] rwaE, rwaM;
        input [1:0] tnE;
        input tnM;
        f = tue && ra && (
            (tu < tnE && rweE && rwaE == ra) ||
            (tu < tnM && rweM && rwaM == ra)
        );
    endfunction

    assign stall = f(tueRs, tuRs, rs, rweE, rweM, rwaE, rwaM, tnE, tnM) ||
                   f(tueRt, tuRt, rt, rweE, rweM, rwaE, rwaM, tnE, tnM) ||
                   (xu && xstallE);

    /*
    wire se = rweE && rwaE;
    wire se0 = tnE && se;
    wire sm0 = tnM && rweM && rwaM;
    wire se1 = (tnE == 2'd2) && se;

    assign stall = tuRs0 && se0 && rsD == rwaE;
    assign stall = tuRs0 && sm0 && rsD == rwaM;
    assign stall = tuRs1 && se1 && rsD == rwaE;

    assign stall = tuRt0 && se0 && rtD == rwaE;
    assign stall = tuRt0 && sm0 && rtD == rwaM;
    assign stall = tuRt1 && se1 && rtD == rwaE;
    */
endmodule
