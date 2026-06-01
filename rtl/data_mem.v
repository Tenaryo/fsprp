module data_mem (
    input  wire        clk,
    input  wire [31:0] addr_i,
    input  wire [31:0] wdata_i,
    input  wire        mem_read_i,
    input  wire        mem_write_i,
    input  wire        mem_byte_i,
    input  wire        mem_sext_i,
    output wire [31:0] rdata_o
);
    reg [7:0] regs [0:127];

    integer _i;
    initial begin
        for (_i = 0; _i < 128; _i = _i + 1) begin
            regs[_i] = 8'b0;
        end
    end

    wire [31:0] word_read = {regs[addr_i+3], regs[addr_i+2],
                             regs[addr_i+1], regs[addr_i]};
    wire [ 7:0] byte_read = regs[addr_i];

    assign rdata_o = ~mem_read_i ? 32'b0 :
                     mem_byte_i ? (mem_sext_i ? {{24{byte_read[7]}}, byte_read}
                                              : {24'b0, byte_read})
                                : word_read;

    always @(posedge clk) begin
        if (mem_write_i) begin
            if (mem_byte_i) begin
                regs[addr_i] <= wdata_i[7:0];
            end else begin
                {regs[addr_i+3], regs[addr_i+2],
                 regs[addr_i+1], regs[addr_i]} <= wdata_i;
            end
        end
    end
endmodule
