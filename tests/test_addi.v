`include "tests/include/test_macros.vh"

module inst_mem (
    input  wire [31:0] addr_i,
    output wire [31:0] inst_o
);
    reg [7:0] rom [0:127];
    integer i;
    initial begin
        for (i = 0; i < 128; i = i + 1) rom[i] = 8'b0;
        {rom[3], rom[2], rom[1], rom[0]}   = 32'h00500293;
        {rom[7], rom[6], rom[5], rom[4]}   = 32'h00a28313;
    end
    assign inst_o = {rom[addr_i+3], rom[addr_i+2], rom[addr_i+1], rom[addr_i]};
endmodule

module test_addi;
    parameter HALF_PERIOD = 3;
    reg clk;
    FiveStagePipeline SCP(clk);
    initial begin #3 clk = 0; forever #HALF_PERIOD clk = ~clk; end
    initial begin
        #200;
        `CHECK_EQ(SCP.RF1.regs[5], 32'd5, "t0")
        `CHECK_EQ(SCP.RF1.regs[6], 32'd15, "t1")
        `PASS("test_addi")
    end
endmodule
