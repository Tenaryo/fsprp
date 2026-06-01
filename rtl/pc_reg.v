module pc_reg (
    input  wire        clk,
    input  wire        pc_en_i,
    input  wire [31:0] next_pc_i,
    output reg  [31:0] pc_o = 0,
    output wire [31:0] pc_plus_4_o
);
    assign pc_plus_4_o = pc_o + 4;

    always @(posedge clk) begin
        if (pc_en_i)
            pc_o <= next_pc_i;
    end
endmodule
