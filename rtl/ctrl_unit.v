module ctrl_unit (
    input  wire [31:0] inst_i,
    output wire [ 7:0] alu_ctrl_o,
    output wire        alu_src_b_sel_o,
    output wire [ 2:0] imm_type_o,
    output wire        reg_wen_o,
    output wire [ 1:0] wb_sel_o,
    output wire        mem_read_o,
    output wire        mem_write_o,
    output wire        mem_byte_o,
    output wire        mem_sext_o,
    output wire [ 1:0] branch_type_o,
    output wire        bge_not_blt_o,
    output wire        jump_o,
    output wire        jump_reg_o
);
    wire [6:0] opcode = inst_i[6:0];
    wire [2:0] func3  = inst_i[14:12];
    wire       func7  = inst_i[30];

    wire op_1_0_11   = (opcode[1:0] == 2'b11);
    wire op_4_2_000  = (opcode[4:2] == 3'b000);
    wire op_4_2_001  = (opcode[4:2] == 3'b001);
    wire op_4_2_011  = (opcode[4:2] == 3'b011);
    wire op_4_2_100  = (opcode[4:2] == 3'b100);
    wire op_6_5_00   = (opcode[6:5] == 2'b00);
    wire op_6_5_01   = (opcode[6:5] == 2'b01);
    wire op_6_5_11   = (opcode[6:5] == 2'b11);

    wire func3_000 = (func3 == 3'b000);
    wire func3_001 = (func3 == 3'b001);
    wire func3_010 = (func3 == 3'b010);
    wire func3_100 = (func3 == 3'b100);
    wire func3_101 = (func3 == 3'b101);
    wire func3_110 = (func3 == 3'b110);
    wire func3_111 = (func3 == 3'b111);

    wire func7_0 = (func7 == 1'b0);
    wire func7_1 = (func7 == 1'b1);

    wire is_R      = (op_1_0_11 && op_6_5_01 && op_4_2_100);
    wire is_I_alu  = (op_1_0_11 && op_6_5_00 && op_4_2_100);
    wire is_I_load = (op_1_0_11 && op_6_5_00 && op_4_2_000);
    wire is_I_jalr = (op_1_0_11 && op_6_5_11 && op_4_2_001);
    wire is_S      = (op_1_0_11 && op_6_5_01 && op_4_2_000);
    wire is_B      = (op_1_0_11 && op_6_5_11 && op_4_2_000);
    wire is_J      = (op_1_0_11 && op_6_5_11 && op_4_2_011);

    wire is_add = (is_R && func3_000 && func7_0);
    wire is_sub = (is_R && func3_000 && func7_1);
    wire is_sll = (is_R && func3_001 && func7_0);
    wire is_srl = (is_R && func3_101 && func7_0);
    wire is_sra = (is_R && func3_101 && func7_1);
    wire is_or  = (is_R && func3_110 && func7_0);
    wire is_and = (is_R && func3_111 && func7_0);

    wire is_addi = (is_I_alu && func3_000);
    wire is_slli = (is_I_alu && func3_001 && func7_0);
    wire is_srli = (is_I_alu && func3_101 && func7_0);
    wire is_andi = (is_I_alu && func3_111);

    wire is_lb  = (is_I_load && func3_000);
    wire is_lw  = (is_I_load && func3_010);
    wire is_lbu = (is_I_load && func3_100);

    wire is_sb = (is_S && func3_000);
    wire is_sw = (is_S && func3_010);

    wire is_beq = (is_B && func3_000);
    wire is_bne = (is_B && func3_001);
    wire is_blt = (is_B && func3_100);
    wire is_bge = (is_B && func3_101);

    wire is_jal  = is_J;
    wire is_jalr = is_I_jalr;

    assign alu_ctrl_o[0] = (is_addi || is_lw || is_sw || is_add
                            || is_lb || is_lbu || is_sb || is_jalr);
    assign alu_ctrl_o[1] = (is_bne || is_sub || is_beq || is_bge || is_blt);
    assign alu_ctrl_o[2] = (is_sra);
    assign alu_ctrl_o[3] = (is_srli || is_srl);
    assign alu_ctrl_o[4] = (is_slli || is_sll);
    assign alu_ctrl_o[5] = (is_andi || is_and);
    assign alu_ctrl_o[6] = (is_or);
    assign alu_ctrl_o[7] = 1'b0;

    assign alu_src_b_sel_o = (is_addi || is_lw || is_sw || is_lb
                              || is_lbu || is_sb || is_slli || is_srli
                              || is_andi || is_jalr);

    wire is_shamt = (is_srli || is_slli);
    wire is_I = (is_I_alu || is_I_load || is_I_jalr);
    assign imm_type_o = is_shamt ? 3'b100 :
                        is_I     ? 3'b000 :
                        is_S     ? 3'b001 :
                        is_B     ? 3'b010 :
                        is_J     ? 3'b011 : 3'b000;

    assign reg_wen_o = (is_addi || is_jal || is_jalr || is_lw
                        || is_sub || is_add || is_andi || is_srli
                        || is_slli || is_or || is_lb || is_lbu
                        || is_sll || is_sra || is_srl || is_and);

    assign wb_sel_o[0] = is_lw || is_lb || is_lbu;
    assign wb_sel_o[1] = is_jal || is_jalr;

    assign mem_read_o  = is_lw || is_lb || is_lbu;
    assign mem_write_o = is_sw || is_sb;
    assign mem_byte_o  = is_lb || is_lbu || is_sb;
    assign mem_sext_o  = is_lb;

    assign branch_type_o[0] = is_beq || is_blt || is_bge;
    assign branch_type_o[1] = is_bne || is_blt || is_bge;
    assign bge_not_blt_o    = is_bge;

    assign jump_o     = is_jal;
    assign jump_reg_o = is_jalr;
endmodule
