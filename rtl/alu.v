module alu (
    input  wire [31:0] srca_i,
    input  wire [31:0] srcb_i,
    input  wire [ 7:0] alu_ctrl_i,
    output wire [31:0] result_o,
    output wire        borrow_o,
    output wire        overflow_o
);
    wire is_sub = alu_ctrl_i[1];
    wire [31:0] srcb_eff = srcb_i ^ {32{is_sub}};
    wire [32:0] extended = {1'b0, srca_i} + {1'b0, srcb_eff} + {32'b0, is_sub};
    assign borrow_o = ~extended[32];
    wire [31:0] result_add_sub = extended[31:0];
    wire sign_a = srca_i[31];
    wire sign_b = srcb_i[31];
    wire sign_res = result_add_sub[31];
    assign overflow_o = (sign_a != sign_b) && (sign_res != sign_a);

    wire [31:0] result_sra = ($signed(srca_i)) >>> srcb_i;
    wire [31:0] result_srl = srca_i >> srcb_i;
    wire [31:0] result_sll = srca_i << srcb_i;
    wire [31:0] result_and = srca_i & srcb_i;
    wire [31:0] result_or  = srca_i | srcb_i;
    wire [31:0] result_xor = srca_i ^ srcb_i;

    assign result_o =
        ({32{alu_ctrl_i[0]}} & result_add_sub) |
        ({32{alu_ctrl_i[1]}} & result_add_sub) |
        ({32{alu_ctrl_i[2]}} & result_sra)      |
        ({32{alu_ctrl_i[3]}} & result_srl)      |
        ({32{alu_ctrl_i[4]}} & result_sll)      |
        ({32{alu_ctrl_i[5]}} & result_and)      |
        ({32{alu_ctrl_i[6]}} & result_or)       |
        ({32{alu_ctrl_i[7]}} & result_xor);
endmodule
