module extend (
    input  wire [31:7] raw_imm_i,
    input  wire [ 2:0] imm_type_i,
    output wire [31:0] imm_o
);
    wire [31:0] imm_i = {{20{raw_imm_i[31]}}, raw_imm_i[31:20]};
    wire [31:0] imm_s = {{20{raw_imm_i[31]}}, raw_imm_i[31:25], raw_imm_i[11:7]};
    wire [31:0] imm_b = {{20{raw_imm_i[31]}}, raw_imm_i[7], raw_imm_i[30:25], raw_imm_i[11:8], 1'b0};
    wire [31:0] imm_j = {{12{raw_imm_i[31]}}, raw_imm_i[19:12], raw_imm_i[20], raw_imm_i[30:21], 1'b0};
    wire [31:0] imm_shamt = {26'b0, raw_imm_i[25:20]};

    assign imm_o = (imm_type_i == 3'b000) ? imm_i :
                   (imm_type_i == 3'b001) ? imm_s :
                   (imm_type_i == 3'b010) ? imm_b :
                   (imm_type_i == 3'b011) ? imm_j :
                                            imm_shamt;
endmodule
