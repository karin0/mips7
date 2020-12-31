// `default_nettype none
`timescale 1ns / 1ps

module CPU(
    input wire clk, reset,
    input wire [5:0] int,
    input wire [31:0] iord,
    input wire ioHit, ioErq,
    output wire dwe,
    output wire [1:0] dem,
    output wire [31:0] da, dwd, pc
    );

    localparam EXEC_AdEL = 4;

    wire [31:0] npcD;
    wire stall, trap, eretM;
    IFU IfuF(.clk(clk), .reset(reset),
        .we(~stall || flush),
        .npc(npcD)
    );

    wire flush = eretM || trap || reset;
    wire [3:0] execF = IfuF.erq ? EXEC_AdEL : 0;
    wire bdF = |CtlD.nm;
    IF_ID F_D(.clk(clk),
        .reset(flush),
        .we(~stall),
        .pcF(IfuF.pc),
        .insF(IfuF.ins),
        .bdF(bdF),
        .execF(execF)
    );

    DEC DecD(F_D.ins);
    CTL CtlD(DecD.op, DecD.func, DecD.rs, DecD.rt);

    wire [4:0] rwaE, rwaM;
    wire [1:0] tnE;
    wire tnM, rweE, rweM, xstallE;
    STL StlD(
        .tueRs(CtlD.tueRs),
        .tuRs(CtlD.tuRs),
        .rs(DecD.rs),
        .tueRt(CtlD.tueRt),
        .tuRt(CtlD.tuRt),
        .rt(DecD.rt),
        .xu(CtlD.xu), // D uses HILO
        .tnE(tnE),
        .rweE(rweE),
        .rwaE(rwaE),
        .tnM(tnM),
        .rweM(rweM),
        .rwaM(rwaM),
        .xstallE(xstallE),
        .stall(stall)
    );

    EXT ExtD(.x(DecD.imm),
        .e0(CtlD.e0)
    );

    wire rweW;
    wire [4:0] rwaW;
    wire [31:0] rwdW, pcW;
    RF RfD(.clk(clk), .reset(reset),
        .wpc(pcW),
        .we(rweW),
        .ra1(DecD.rs),
        .ra2(DecD.rt),
        .wa(rwaW),
        .wd(rwdW)
    );

    wire [31:0] rwdE, rwdM;
    wire [31:0] rd1FD, rd2FD;
    DFWD FwdD(
        DecD.rs, RfD.rd1,
        DecD.rt, RfD.rd2,
        rweE, rwaE, rwdE,
        rweM, rwaM, rwdM,
        rd1FD, rd2FD
    );

    CMP CmpD(.a(rd1FD), .b(rd2FD),
        .mode(CtlD.bm)
    );

    wire [31:0] epcM;
    NPC NpcD(
        .pcF(IfuF.pc),
        .pcD(F_D.pc),
        .boff(ExtD.r),
        .jind(DecD.iind),
        .jwd(rd1FD),
        .be(CmpD.r),
        .mode(CtlD.nm),
        .trap(trap),
        .eret(eretM),
        .epc(epcM),
        .npc(npcD)
    );

    wire [4:0] rwaD;
    MUX3 #(5) mrwa(DecD.rd, DecD.rt, 5'd31, CtlD.rwaSrc, rwaD);

    wire [3:0] execD = F_D.exec ? F_D.exec : CtlD.erq ? CtlD.exec : 0;  // not so robust?
    ID_EX D_E(.clk(clk),
        .reset(flush || stall),
        .pcD(F_D.pc),
        .insD(F_D.ins),
        .rwaD(rwaD),
        .rd1D(rd1FD),
        .rd2D(rd2FD),
        .erD(ExtD.r),
        .rpcD(NpcD.rpc),
        .execD(execD),
        .bdD(F_D.bd),
        .validD(F_D.valid),

        .rwa(rwaE),
        .rpc(rwdE)
    );

    DEC DecE(D_E.ins);
    CTL CtlE(.op(DecE.op), .func(DecE.func), .rs(DecE.rs), .rt(DecE.rt),
        .rwe(rweE),
        .tnE(tnE)
    );

    wire [31:0] rd1FE, rd2FE;
    DFWD FwdE(
        DecE.rs, D_E.rd1,
        DecE.rt, D_E.rd2,
        rweM, rwaM, rwdM,
        rweW, rwaW, rwdW,
        rd1FE, rd2FE
    );

    wire [31:0] ab = CtlE.abSrc ? D_E.er : rd2FE;
    ALU AluE(
        .a(rd1FE),
        .b(ab),
        .sh(DecE.sh),
        .op(CtlE.aop),
        .ssh(CtlE.xop[0])
    );

    HILO HiloE(.clk(clk), .reset(reset),
        .a(rd1FE),
        .b(rd2FE),
        .op(CtlE.xop),
        .start(CtlE.xst && ~flush),
        .we(CtlE.xwe && ~flush),
        .rollback((CtlM.xst || CtlM.xwe) && trap),
        .stall(xstallE)
    );

    wire [31:0] resE = CtlE.resESrc ? HiloE.rd : AluE.r;
    wire [3:0] execE = D_E.exec ? D_E.exec
                                : CtlE.aee && AluE.erq ? CtlE.exec : 0;
    EX_MEM E_M(.clk(clk),
        .reset(flush),
        .pcE(D_E.pc),
        .insE(D_E.ins),
        .rwaE(rwaE),
        .rd2E(rd2FE),
        .arE(resE),
        .tnE(tnE),
        .rwdE(rwdE),
        .execE(execE),
        .bdE(D_E.bd),
        .validE(D_E.valid),

        .rwa(rwaM),
        .tn(tnM)
    );

    wire bd;
    assign { pc, bd } = reset ?     { 32'h3000, 1'b0 } :
                        E_M.valid ? { E_M.pc, E_M.bd } :
                        D_E.valid ? { D_E.pc, D_E.bd } :
                        F_D.valid ? { F_D.pc, F_D.bd } :
                                    { IfuF.pc, bdF };
    DEC DecM(E_M.ins);
    CTL CtlM(.op(DecM.op), .func(DecM.func), .rs(DecM.rs), .rt(DecM.rt),
        .rwe(rweM),
        .eret(eretM)
    );

    wire [31:0] rd2FM;
    HFWD FwdM(
        DecM.rt, E_M.rd2,
        rweW, rwaW, rwdW,
        rd2FM
    );

    wire trapIntM;
    wire dill = (dem == 0 && da[1:0]) ||
                (dem == 2 && da[0]);
    assign da  = E_M.ar,
           dwd = rd2FM,
           dwe = CtlM.dwe && !E_M.exec && ~trapIntM && ~dill,
           dem = CtlM.dem;
    DM DmM(.clk(clk), .reset(reset),
        .pc(E_M.pc),
        .we(dwe),
        .em(dem),
        .a(da),
        .wd(dwd)
    );

    // hits must be mutually exclusive
    wire [3:0] execM = E_M.exec ? E_M.exec
                                : CtlM.dee && (
                                      dill ||
                                      (ioErq && ioHit) ||
                                      ~(DmM.hit || ioHit)
                                  ) ? CtlM.exec : 0;
    CP0 Cp0M(.clk(clk), .reset(reset),
        .we(CtlM.cp0we && ~trap),
        .a(DecM.rd),
        .wd(rd2FM),
        .pc(pc),
        .bd(bd),
        .exec(execM),
        .int(int),
        .eret(eretM),
        .epc(epcM),
        .trap(trap),
        .trapInt(trapIntM)
    );

    wire [31:0] drdM = DmM.hit ? DmM.rd : iord;
    assign rwdM = CtlM.rwdMSrc ? Cp0M.rd : E_M.rwd;
    MEM_WB M_W(.clk(clk),
        .reset(flush || execM),  // flush?
        .pcM(E_M.pc),
        .insM(E_M.ins),
        .rwaM(rwaM),
        .resM(drdM),
        .dalM(da[1:0]),
        .tnM(tnM),
        .rwdM(rwdM),
        .pc(pcW),
        .rwa(rwaW)
    );

    DEC DecW(M_W.ins);
    CTL CtlW(.op(DecW.op), .func(DecW.func), .rs(DecW.rs), .rt(DecW.rt),
        .rwe(rweW)
    );
    // assign rweW = CtlW.rwe && ~(trap && E_M.bd);

    DEXT DExtW(
        .x(M_W.lres),
        .a(M_W.dal),
        .mode(CtlW.dem),
        .e0(CtlW.de0)
    );

    assign rwdW = M_W.ltn ? DExtW.r : M_W.lrwd;
endmodule
