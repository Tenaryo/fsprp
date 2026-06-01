`timescale 1ns / 1ps

module sim1;
    parameter half_period = 3;
    reg clk;
    FiveStagePipeline FSP(clk);

    initial begin
        $dumpfile("build/sim1.vcd");
        $dumpvars(0, sim1);
    end

    initial begin
        #3 clk = 0;
        forever #half_period clk = ~clk;
    end

    initial begin
        forever #6 begin
            $display("time:", $time);
            $display("PC:%h", FSP.PC_cs);
            $display("Inst:%h", FSP.Inst);
            $display("x5(t0):%h", FSP.RF1.regs[5]);
            $display("x6(t1):%h", FSP.RF1.regs[6]);
            $display("x7(t2):%h", FSP.RF1.regs[7]);
            $display("x28(t3):%h", FSP.RF1.regs[28]);
            $display("x29(t4):%h", FSP.RF1.regs[29]);
            $display("x8(s0):%h", FSP.RF1.regs[8]);
            $display("x9(s1):%h", FSP.RF1.regs[9]);
            $display("Mem[0]:%h",
                {FSP.DataMem1.regs[3], FSP.DataMem1.regs[2],
                 FSP.DataMem1.regs[1], FSP.DataMem1.regs[0]});
            $display("Mem[4]:%h",
                {FSP.DataMem1.regs[7], FSP.DataMem1.regs[6],
                 FSP.DataMem1.regs[5], FSP.DataMem1.regs[4]});
        end
    end

    initial #200 $stop;
endmodule
