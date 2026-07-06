module FiveStagePipeline (
    input wire clk
);
    wire        flush_if, flush_id, stall;
    wire        pc_en;
    wire [31:0] next_pc;

    wire [31:0] pc, pc_plus_4;
    wire [31:0] inst;

    wire [31:0] pc_id, pc_plus_4_id;
    wire [31:0] inst_id;

    wire [ 7:0] alu_ctrl;
    wire        alu_src_b_sel;
    wire [ 2:0] imm_type;
    wire        reg_wen;
    wire [ 1:0] wb_sel;
    wire        mem_read, mem_write, mem_byte, mem_sext;
    wire [ 1:0] branch_type;
    wire        bge_not_blt, jump, jump_reg;

    wire [31:0] rs1_data, rs2_data;
    wire [31:0] imm;

    wire [ 7:0] alu_ctrl_ex;
    wire        alu_src_b_sel_ex;
    wire        reg_wen_ex;
    wire [ 1:0] wb_sel_ex;
    wire        mem_read_ex, mem_write_ex, mem_byte_ex, mem_sext_ex;
    wire        jump_reg_ex;
    wire [ 4:0] rs1_addr_ex, rs2_addr_ex;
    wire [31:0] pc_ex, pc_plus_4_ex;
    wire [31:0] rs1_data_ex, rs2_data_ex, imm_ex;
    wire [ 4:0] rd_addr_ex;

    wire [31:0] alu_src_a, alu_src_b, alu_result;
    wire        alu_borrow, alu_overflow;

    wire [ 1:0] wb_sel_mem;
    wire        reg_wen_mem;
    wire        mem_read_mem, mem_write_mem, mem_byte_mem, mem_sext_mem;
    wire [31:0] pc_plus_4_mem;
    wire [31:0] alu_result_mem, rs2_data_mem;
    wire [ 4:0] rd_addr_mem;

    wire [31:0] mem_rdata;

    wire [ 1:0] wb_sel_wb;
    wire        reg_wen_wb;
    wire [31:0] pc_plus_4_wb;
    wire [31:0] mem_rdata_wb;
    wire [31:0] alu_result_wb;
    wire [ 4:0] rd_addr_wb;

    wire [31:0] wb_data;

    pc_reg pc_reg_inst (
        .clk        (clk),
        .pc_en_i    (pc_en),
        .next_pc_i  (next_pc),
        .pc_o       (pc),
        .pc_plus_4_o(pc_plus_4)
    );

    inst_mem inst_mem_inst (
        .addr_i (pc),
        .inst_o (inst)
    );

    wire [31:0] PC_cs = pc;
    wire [31:0] Inst  = inst;

    if_id_reg if_id (
        .clk        (clk),
        .flush      (flush_if),
        .stall      (stall),
        .pc_i       (pc),
        .pc_plus_4_i(pc_plus_4),
        .inst_i     (inst),
        .pc_o       (pc_id),
        .pc_plus_4_o(pc_plus_4_id),
        .inst_o     (inst_id)
    );

    ctrl_unit ctrl_unit_inst (
        .inst_i          (inst_id),
        .alu_ctrl_o      (alu_ctrl),
        .alu_src_b_sel_o (alu_src_b_sel),
        .imm_type_o      (imm_type),
        .reg_wen_o       (reg_wen),
        .wb_sel_o        (wb_sel),
        .mem_read_o      (mem_read),
        .mem_write_o     (mem_write),
        .mem_byte_o      (mem_byte),
        .mem_sext_o      (mem_sext),
        .branch_type_o   (branch_type),
        .bge_not_blt_o   (bge_not_blt),
        .jump_o          (jump),
        .jump_reg_o      (jump_reg)
    );

    extend extend_inst (
        .raw_imm_i  (inst_id[31:7]),
        .imm_type_i (imm_type),
        .imm_o      (imm)
    );

    reg_file RF1 (
        .clk        (clk),
        .rs1_addr_i (inst_id[19:15]),
        .rs2_addr_i (inst_id[24:20]),
        .rd_addr_i  (rd_addr_wb),
        .rd_data_i  (wb_data),
        .rd_wen_i   (reg_wen_wb),
        .rs1_data_o (rs1_data),
        .rs2_data_o (rs2_data)
    );

    wire [31:0] fwd_mem_val = mem_read_mem ? mem_rdata : alu_result_mem;

    wire br_fwd_a_ex = !mem_read_ex && reg_wen_ex && rd_addr_ex != 5'b0 && (rd_addr_ex == inst_id[19:15]);
    wire br_fwd_b_ex = !mem_read_ex && reg_wen_ex && rd_addr_ex != 5'b0 && (rd_addr_ex == inst_id[24:20]);
    wire br_fwd_a_mem = reg_wen_mem && rd_addr_mem != 5'b0 && (rd_addr_mem == inst_id[19:15])
                        && !(br_fwd_a_ex && rd_addr_ex == rd_addr_mem);
    wire br_fwd_a_wb  = reg_wen_wb  && rd_addr_wb  != 5'b0 && (rd_addr_wb  == inst_id[19:15])
                        && !((br_fwd_a_mem && rd_addr_mem == rd_addr_wb)
                          || (br_fwd_a_ex && rd_addr_ex == rd_addr_wb));
    wire br_fwd_b_mem = reg_wen_mem && rd_addr_mem != 5'b0 && (rd_addr_mem == inst_id[24:20])
                        && !(br_fwd_b_ex && rd_addr_ex == rd_addr_mem);
    wire br_fwd_b_wb  = reg_wen_wb  && rd_addr_wb  != 5'b0 && (rd_addr_wb  == inst_id[24:20])
                        && !((br_fwd_b_mem && rd_addr_mem == rd_addr_wb)
                          || (br_fwd_b_ex && rd_addr_ex == rd_addr_wb));

    wire [31:0] br_rs1 = br_fwd_a_ex ? alu_result  :
                         br_fwd_a_mem ? fwd_mem_val :
                         br_fwd_a_wb  ? wb_data      :
                                        rs1_data;
    wire [31:0] br_rs2 = br_fwd_b_ex ? alu_result  :
                         br_fwd_b_mem ? fwd_mem_val :
                         br_fwd_b_wb  ? wb_data      :
                                        rs2_data;

    wire [31:0] diff   = br_rs1 - br_rs2;
    wire        diff_z = (diff == 32'b0);
    wire        diff_n = diff[31];
    wire        diff_v = (br_rs1[31] != br_rs2[31]) && (diff[31] != br_rs1[31]);
    wire        signed_less = (br_rs1[31] != br_rs2[31])
                            ? br_rs1[31] : (diff_n ^ diff_v);

    wire beq_taken = (branch_type == 2'b01) && diff_z;
    wire bne_taken = (branch_type == 2'b10) && ~diff_z;
    wire blt_taken = (branch_type == 2'b11) && ~bge_not_blt && signed_less;
    wire bge_taken = (branch_type == 2'b11) &&  bge_not_blt && ~signed_less;

    wire        branch_taken = beq_taken | bne_taken | blt_taken | bge_taken;
    wire [31:0] branch_target = pc_id + imm;
    wire [31:0] jump_target   = pc_id + imm;

    wire take_br_or_j = branch_taken || jump;
    wire take_jalr_ex = jump_reg_ex;

    wire load_use_stall = mem_read_ex && rd_addr_ex != 5'b0 &&
        ((rd_addr_ex == inst_id[19:15]) || (rd_addr_ex == inst_id[24:20]));

    assign stall = load_use_stall;
    assign flush_if = ~stall && (take_br_or_j || take_jalr_ex);
    assign flush_id = (~stall && take_jalr_ex) || stall;
    assign pc_en = ~stall;

    assign next_pc = take_jalr_ex      ? {alu_result[31:1], 1'b0} :
                     take_br_or_j       ? (jump ? jump_target : branch_target) :
                                          pc_plus_4;

    id_ex_reg id_ex (
        .clk            (clk),
        .flush          (flush_id),
        .alu_ctrl_i     (alu_ctrl),
        .alu_src_b_sel_i(alu_src_b_sel),
        .reg_wen_i      (reg_wen),
        .wb_sel_i       (wb_sel),
        .mem_read_i     (mem_read),
        .mem_write_i    (mem_write),
        .mem_byte_i     (mem_byte),
        .mem_sext_i     (mem_sext),
        .jump_reg_i     (jump_reg),
        .rs1_addr_i     (inst_id[19:15]),
        .rs2_addr_i     (inst_id[24:20]),
        .pc_i           (pc_id),
        .pc_plus_4_i    (pc_plus_4_id),
        .rs1_data_i     (rs1_data),
        .rs2_data_i     (rs2_data),
        .imm_i          (imm),
        .rd_addr_i      (inst_id[11:7]),
        .alu_ctrl_o     (alu_ctrl_ex),
        .alu_src_b_sel_o(alu_src_b_sel_ex),
        .reg_wen_o      (reg_wen_ex),
        .wb_sel_o       (wb_sel_ex),
        .mem_read_o     (mem_read_ex),
        .mem_write_o    (mem_write_ex),
        .mem_byte_o     (mem_byte_ex),
        .mem_sext_o     (mem_sext_ex),
        .jump_reg_o     (jump_reg_ex),
        .rs1_addr_o     (rs1_addr_ex),
        .rs2_addr_o     (rs2_addr_ex),
        .pc_o           (pc_ex),
        .pc_plus_4_o    (pc_plus_4_ex),
        .rs1_data_o     (rs1_data_ex),
        .rs2_data_o     (rs2_data_ex),
        .imm_o          (imm_ex),
        .rd_addr_o      (rd_addr_ex)
    );

    wire        forward_a_ex = reg_wen_mem && rd_addr_mem != 5'b0
                            && (rd_addr_mem == rs1_addr_ex);
    wire        forward_b_ex = reg_wen_mem && rd_addr_mem != 5'b0
                            && (rd_addr_mem == rs2_addr_ex);
    wire        forward_a_wb = reg_wen_wb && rd_addr_wb != 5'b0
                            && (rd_addr_wb == rs1_addr_ex)
                            && !(forward_a_ex && rd_addr_mem == rd_addr_wb);
    wire        forward_b_wb = reg_wen_wb && rd_addr_wb != 5'b0
                            && (rd_addr_wb == rs2_addr_ex)
                            && !(forward_b_ex && rd_addr_mem == rd_addr_wb);

    wire [31:0] forward_a_val = forward_a_ex ? fwd_mem_val :
                                 forward_a_wb ? wb_data        :
                                                rs1_data_ex;
    wire [31:0] forward_b_val = forward_b_ex ? fwd_mem_val :
                                 forward_b_wb ? wb_data        :
                                                rs2_data_ex;

    assign alu_src_a = forward_a_val;
    assign alu_src_b = alu_src_b_sel_ex ? imm_ex : forward_b_val;

    alu alu_inst (
        .srca_i     (alu_src_a),
        .srcb_i     (alu_src_b),
        .alu_ctrl_i (alu_ctrl_ex),
        .result_o   (alu_result),
        .borrow_o   (alu_borrow),
        .overflow_o (alu_overflow)
    );

    ex_mem_reg ex_mem (
        .clk          (clk),
        .wb_sel_i     (wb_sel_ex),
        .reg_wen_i    (reg_wen_ex),
        .mem_read_i   (mem_read_ex),
        .mem_write_i  (mem_write_ex),
        .mem_byte_i   (mem_byte_ex),
        .mem_sext_i   (mem_sext_ex),
        .pc_plus_4_i  (pc_plus_4_ex),
        .alu_result_i (alu_result),
        .rs2_data_i   (forward_b_val),
        .rd_addr_i    (rd_addr_ex),
        .wb_sel_o     (wb_sel_mem),
        .reg_wen_o    (reg_wen_mem),
        .mem_read_o   (mem_read_mem),
        .mem_write_o  (mem_write_mem),
        .mem_byte_o   (mem_byte_mem),
        .mem_sext_o   (mem_sext_mem),
        .pc_plus_4_o  (pc_plus_4_mem),
        .alu_result_o (alu_result_mem),
        .rs2_data_o   (rs2_data_mem),
        .rd_addr_o    (rd_addr_mem)
    );

    data_mem DataMem1 (
        .clk        (clk),
        .addr_i     (alu_result_mem),
        .wdata_i    (rs2_data_mem),
        .mem_read_i (mem_read_mem),
        .mem_write_i(mem_write_mem),
        .mem_byte_i (mem_byte_mem),
        .mem_sext_i (mem_sext_mem),
        .rdata_o    (mem_rdata)
    );

    mem_wb_reg mem_wb (
        .clk          (clk),
        .wb_sel_i     (wb_sel_mem),
        .reg_wen_i    (reg_wen_mem),
        .pc_plus_4_i  (pc_plus_4_mem),
        .mem_rdata_i  (mem_rdata),
        .alu_result_i (alu_result_mem),
        .rd_addr_i    (rd_addr_mem),
        .wb_sel_o     (wb_sel_wb),
        .reg_wen_o    (reg_wen_wb),
        .pc_plus_4_o  (pc_plus_4_wb),
        .mem_rdata_o  (mem_rdata_wb),
        .alu_result_o (alu_result_wb),
        .rd_addr_o    (rd_addr_wb)
    );

    assign wb_data = (wb_sel_wb == 2'b01) ? mem_rdata_wb :
                     (wb_sel_wb == 2'b10) ? pc_plus_4_wb  :
                                            alu_result_wb;

endmodule
