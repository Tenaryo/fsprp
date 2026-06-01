module reg_file (
    input  wire        clk,
    input  wire [ 4:0] rs1_addr_i,
    input  wire [ 4:0] rs2_addr_i,
    input  wire [ 4:0] rd_addr_i,
    input  wire [31:0] rd_data_i,
    input  wire        rd_wen_i,
    output wire [31:0] rs1_data_o,
    output wire [31:0] rs2_data_o
);
    reg [31:0] regs [31:1];

    integer _i;
    initial begin
        for (_i = 1; _i < 32; _i = _i + 1) begin
            regs[_i] = 32'b0;
        end
    end

    assign rs1_data_o = (rs1_addr_i == 0) ? 32'b0 : regs[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == 0) ? 32'b0 : regs[rs2_addr_i];

    always @(posedge clk) begin
        if (rd_wen_i && rd_addr_i != 0) begin
            regs[rd_addr_i] <= rd_data_i;
        end
    end
endmodule
