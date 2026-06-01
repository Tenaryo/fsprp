module if_id_reg (
    input  wire        clk,
    input  wire        flush,
    input  wire        stall,
    input  wire [31:0] pc_i,
    input  wire [31:0] pc_plus_4_i,
    input  wire [31:0] inst_i,
    output reg  [31:0] pc_o        = 0,
    output reg  [31:0] pc_plus_4_o = 0,
    output reg  [31:0] inst_o      = 0
);
    always @(posedge clk) begin
        if (stall) begin
        end else if (flush) begin
            pc_o        <= 32'b0;
            pc_plus_4_o <= 32'b0;
            inst_o      <= 32'b0;
        end else begin
            pc_o        <= pc_i;
            pc_plus_4_o <= pc_plus_4_i;
            inst_o      <= inst_i;
        end
    end
endmodule

module id_ex_reg (
    input  wire        clk,
    input  wire        flush,
    input  wire [ 7:0] alu_ctrl_i,
    input  wire        alu_src_b_sel_i,
    input  wire        reg_wen_i,
    input  wire [ 1:0] wb_sel_i,
    input  wire        mem_read_i,
    input  wire        mem_write_i,
    input  wire        mem_byte_i,
    input  wire        mem_sext_i,
    input  wire        jump_reg_i,
    input  wire [ 4:0] rs1_addr_i,
    input  wire [ 4:0] rs2_addr_i,
    input  wire [31:0] pc_i,
    input  wire [31:0] pc_plus_4_i,
    input  wire [31:0] rs1_data_i,
    input  wire [31:0] rs2_data_i,
    input  wire [31:0] imm_i,
    input  wire [ 4:0] rd_addr_i,
    output reg  [ 7:0] alu_ctrl_o      = 0,
    output reg         alu_src_b_sel_o = 0,
    output reg         reg_wen_o       = 0,
    output reg  [ 1:0] wb_sel_o        = 0,
    output reg         mem_read_o      = 0,
    output reg         mem_write_o     = 0,
    output reg         mem_byte_o      = 0,
    output reg         mem_sext_o      = 0,
    output reg         jump_reg_o      = 0,
    output reg  [ 4:0] rs1_addr_o      = 0,
    output reg  [ 4:0] rs2_addr_o      = 0,
    output reg  [31:0] pc_o            = 0,
    output reg  [31:0] pc_plus_4_o     = 0,
    output reg  [31:0] rs1_data_o      = 0,
    output reg  [31:0] rs2_data_o      = 0,
    output reg  [31:0] imm_o           = 0,
    output reg  [ 4:0] rd_addr_o       = 0
);
    always @(posedge clk) begin
        if (flush) begin
            alu_ctrl_o      <= 8'b0;
            alu_src_b_sel_o <= 1'b0;
            reg_wen_o       <= 1'b0;
            wb_sel_o        <= 2'b0;
            mem_read_o      <= 1'b0;
            mem_write_o     <= 1'b0;
            mem_byte_o      <= 1'b0;
            mem_sext_o      <= 1'b0;
            jump_reg_o      <= 1'b0;
            rs1_addr_o      <= 5'b0;
            rs2_addr_o      <= 5'b0;
            pc_o            <= 32'b0;
            pc_plus_4_o     <= 32'b0;
            rs1_data_o      <= 32'b0;
            rs2_data_o      <= 32'b0;
            imm_o           <= 32'b0;
            rd_addr_o       <= 5'b0;
        end else begin
            alu_ctrl_o      <= alu_ctrl_i;
            alu_src_b_sel_o <= alu_src_b_sel_i;
            reg_wen_o       <= reg_wen_i;
            wb_sel_o        <= wb_sel_i;
            mem_read_o      <= mem_read_i;
            mem_write_o     <= mem_write_i;
            mem_byte_o      <= mem_byte_i;
            mem_sext_o      <= mem_sext_i;
            jump_reg_o      <= jump_reg_i;
            rs1_addr_o      <= rs1_addr_i;
            rs2_addr_o      <= rs2_addr_i;
            pc_o            <= pc_i;
            pc_plus_4_o     <= pc_plus_4_i;
            rs1_data_o      <= rs1_data_i;
            rs2_data_o      <= rs2_data_i;
            imm_o           <= imm_i;
            rd_addr_o       <= rd_addr_i;
        end
    end
endmodule

module ex_mem_reg (
    input  wire        clk,
    input  wire [ 1:0] wb_sel_i,
    input  wire        reg_wen_i,
    input  wire        mem_read_i,
    input  wire        mem_write_i,
    input  wire        mem_byte_i,
    input  wire        mem_sext_i,
    input  wire [31:0] pc_plus_4_i,
    input  wire [31:0] alu_result_i,
    input  wire [31:0] rs2_data_i,
    input  wire [ 4:0] rd_addr_i,
    output reg  [ 1:0] wb_sel_o      = 0,
    output reg         reg_wen_o     = 0,
    output reg         mem_read_o    = 0,
    output reg         mem_write_o   = 0,
    output reg         mem_byte_o    = 0,
    output reg         mem_sext_o    = 0,
    output reg  [31:0] pc_plus_4_o   = 0,
    output reg  [31:0] alu_result_o  = 0,
    output reg  [31:0] rs2_data_o    = 0,
    output reg  [ 4:0] rd_addr_o     = 0
);
    always @(posedge clk) begin
        wb_sel_o      <= wb_sel_i;
        reg_wen_o     <= reg_wen_i;
        mem_read_o    <= mem_read_i;
        mem_write_o   <= mem_write_i;
        mem_byte_o    <= mem_byte_i;
        mem_sext_o    <= mem_sext_i;
        pc_plus_4_o   <= pc_plus_4_i;
        alu_result_o  <= alu_result_i;
        rs2_data_o    <= rs2_data_i;
        rd_addr_o     <= rd_addr_i;
    end
endmodule

module mem_wb_reg (
    input  wire        clk,
    input  wire [ 1:0] wb_sel_i,
    input  wire        reg_wen_i,
    input  wire [31:0] pc_plus_4_i,
    input  wire [31:0] mem_rdata_i,
    input  wire [31:0] alu_result_i,
    input  wire [ 4:0] rd_addr_i,
    output reg  [ 1:0] wb_sel_o     = 0,
    output reg         reg_wen_o    = 0,
    output reg  [31:0] pc_plus_4_o  = 0,
    output reg  [31:0] mem_rdata_o  = 0,
    output reg  [31:0] alu_result_o = 0,
    output reg  [ 4:0] rd_addr_o    = 0
);
    always @(posedge clk) begin
        wb_sel_o     <= wb_sel_i;
        reg_wen_o    <= reg_wen_i;
        pc_plus_4_o  <= pc_plus_4_i;
        mem_rdata_o  <= mem_rdata_i;
        alu_result_o <= alu_result_i;
        rd_addr_o    <= rd_addr_i;
    end
endmodule
