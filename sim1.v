`timescale 1ns / 1ps

module sim1;
    reg clk;
    FiveStagePipeline SCP(clk);

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        while ($time < 60) @(posedge clk) begin
            $display("===============================================");
            $display("Clock cycle %d, PC = %H", $time/2, SCP.PC_cs);
            $display("ra = %H, t0 = %H, t1 = %H",
                SCP.RF1.regs[1], SCP.RF1.regs[5], SCP.RF1.regs[6]);
            $display("t2 = %H, t3 = %H, t4 = %H",
                SCP.RF1.regs[7], SCP.RF1.regs[28], SCP.RF1.regs[29]);
            $display("===============================================");
        end
        $finish();
    end
endmodule
