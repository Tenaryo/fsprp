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
            $display("time:%d", $time);
            $display("ra =%h", FSP.RF1.regs[1]);
            $display("t0 =%h", FSP.RF1.regs[5]);
            $display("t1 =%h", FSP.RF1.regs[6]);
            $display("t2 =%h", FSP.RF1.regs[7]);
            $display("t3 =%h", FSP.RF1.regs[28]);
            $display("t4 =%h", FSP.RF1.regs[29]);
        end
    end

    initial #2000 $stop;
endmodule
