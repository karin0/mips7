`timescale 1ns / 1ps

/*
    R: add(u), sub(u), sllv, srlv, srav, and, or, xor, nor, slt, sltu
    I: addi(u), andi, ori, xori, slti, sltiu
    X: mult, div, multu, divu
    S: sll, srl, sra
    M: mfhi, mflo, mthi, mtlo

    B: beq, bne, bltz, bgtz, blez, bgez

    lb, lbu, lh, lhu, lw
    sb, sh, sw


    lui
    j, jal, jalr, jr
*/

module CTL(
    input [5:0] op, func,
    input [4:0] rs, rt,
    output rwe, dwe,
    output [1:0] nm,
    output xst, xwe, cp0we, aee, dee, eret,
    output [2:0] bm,
    output e0,
    output [3:0] aop,
    output [1:0] xop,
    output abSrc, resESrc, rwdMSrc,
    output [1:0] dem,
    output de0,
    output [1:0] rwaSrc,
    output tueRs, tuRs, tueRt, tuRt,
    output [1:0] tnE,
    output xu, erq,
    output [3:0] exec
    );

    localparam EXEC_AdEL = 4,
               EXEC_AdES = 5,
               EXEC_RI   = 10,
               EXEC_Ov   = 12;

    // wire sp = !op;
    wire [5:0] fun = op ? 'h3f : func;

    wire addu = fun == 'h21;
    wire add  = fun == 'h20;
    wire subu = fun == 'h23;
    wire sub  = fun == 'h22;
    wire or_  = fun == 'h25;
    wire xor_ = fun == 'h26;
    wire nor_ = fun == 'h27;
    wire and_ = fun == 'h24;
    wire sltu = fun == 'h2b;
    wire slt  = fun == 'h2a;
    wire sllv = fun == 'h4;
    wire srlv = fun == 'h6;
    wire srav = fun == 'h7;

    wire ir = addu | add | subu | sub | or_ | xor_ | nor_ | and_ | sltu | slt | sllv | srlv | srav;

    wire addiu = op == 'h9;
    wire addi  = op == 'h8;
    wire andi  = op == 'hc;
    wire ori   = op == 'hd;
    wire xori  = op == 'he;
    wire sltiu = op == 'hb;
    wire slti  = op == 'ha;

    wire ii2 = addiu | addi | andi | ori | xori | sltiu | slti;

    wire sll = fun == 'h0;
    wire srl = fun == 'h2;
    wire sra = fun == 'h3;

    wire is = sll | srl | sra;

    wire beq  = op == 'h4;
    wire bne  = op == 'h5;
    wire bltz = op == 'h1 && rt == 'h0;
    wire bgtz = op == 'h7;
    wire blez = op == 'h6;
    wire bgez = op == 'h1 && rt == 'h1;

    wire ibz = bltz | bgtz | blez | bgez;
    wire ib2 = beq | bne;
    wire ib = ib2 | ibz;

    wire multu = fun == 'h19;
    wire mult  = fun == 'h18;
    wire divu  = fun == 'h1b;
    wire div   = fun == 'h1a;
    wire mfhi  = fun == 'h10;
    wire mflo  = fun == 'h12;
    wire mthi  = fun == 'h11;
    wire mtlo  = fun == 'h13;

    wire ix = multu | mult | divu | div;
    wire imf = mfhi | mflo;
    wire imt = mthi | mtlo;

    wire lb  = op == 'h20;
    wire lbu = op == 'h24;
    wire lh  = op == 'h21;
    wire lhu = op == 'h25;
    wire lw  = op == 'h23;

    wire ilm = lb | lbu | lh | lhu | lw;

    wire sb = op == 'h28;
    wire sh = op == 'h29;
    wire sw = op == 'h2b;

    wire ism = sb | sh | sw;

    wire lui = op == 'hf;
    wire j   = op == 'h2;
    wire jal = op == 'h3;
    wire jr   = fun == 'h8;
    wire jalr = fun == 'h9;

    wire ij = j | jal | jr | jalr;

    assign eret = op == 'h10 && func == 'h18;
    wire mfc0 = op == 'h10 && rs == 0;
    wire mtc0 = op == 'h10 && rs == 'h4;

    wire ic0 = eret | mfc0 | mtc0;
    wire ii = ii2 | lui;
    wire iall = ir | ii | is | ib | ix | imf | imt | ilm | ism | ij | ic0;

    assign erq = ~iall;
    // assign bde = ij | ib; // |nm is used for this

    assign rwe = ir | ii | imf | is | ilm | jal | jalr | mfc0;
    assign dwe = ism;
    assign xst = ix;
    assign xwe = imt;

    assign e0 = ori | xori | andi;
    assign abSrc = ii | ilm | ism;
    assign resESrc = imf;
    assign de0 = lbu | lhu;

    assign cp0we = mtc0;
    assign rwdMSrc = mfc0;

    assign dee = ilm | ism;
    assign aee = add | sub | addi | dee;

    /*
    PE4 uex(
        add | sub | addi,
        ilm,
        ism,
        exem
    );
    */

    // mutually exclusive so give a worst prediction
    assign exec = add | sub | addi ? EXEC_Ov :
                  ilm ? EXEC_AdEL :
                  ism ? EXEC_AdES :
                  EXEC_RI;

    PE4 unm(ib,
        j | jal,
        jr | jalr,
        nm
    ); // |nm is used for bde, making it strict
    RPE #(6, 3) ubm(
        { bne, bltz, bgtz, blez, bgez },
        bm
    );
    RPE #(12, 4) uaop(
        { subu | sub, or_ | ori, lui, xor_ | xori, nor_, and_ | andi,
          sltu | sltiu, slt | slti, sllv | sll, srlv | srl, srav | sra },
        aop
    );
    PE4 uxop(mult | mfhi | mthi | is,
        divu, div,
        xop
    );
    PE3 udem(lb | lbu | sb, lh | lhu | sh,
        dem
    );
    PE3 uwa(ii | ilm | mfc0, jal, rwaSrc);

    assign xu = ix | imf | imt;

    wire tuRs0 = ib | jr | jalr;
    assign tuRs = ir | ii2 | ix | imt | ilm | ism;
    assign tueRs = tuRs0 | tuRs;

    wire tuRt0 = ib2;
    assign tuRt = ir | ix | is;
    // wire tuRt2 = ism | mtc0;
    assign tueRt = tuRt0 | tuRt;

    PE3 utn(ir | ii | imf | is | mfc0,
        ilm,
        tnE
    );
endmodule
