module inst_mem (
    input  wire [31:0] addr_i,
    output wire [31:0] inst_o
);
    reg [7:0] rom [0:127];
    integer i;

    initial begin
        for (i = 0; i < 128; i = i + 1) begin
            rom[i] = 8'b0;
        end
        {rom[3], rom[2], rom[1], rom[0]}   = 32'hff600293;
        {rom[7], rom[6], rom[5], rom[4]}   = 32'h00528333;
        {rom[11], rom[10], rom[9], rom[8]} = 32'h406283b3;
        {rom[15], rom[14], rom[13], rom[12]} = 32'h00037e33;
        {rom[19], rom[18], rom[17], rom[16]} = 32'h00536eb3;
        {rom[23], rom[22], rom[21], rom[20]} = 32'h01d02023;
        {rom[27], rom[26], rom[25], rom[24]} = 32'h00502223;
        {rom[31], rom[30], rom[29], rom[28]} = 32'h00028463;
        {rom[35], rom[34], rom[33], rom[32]} = 32'h00030eb3;
        {rom[39], rom[38], rom[37], rom[36]} = 32'h01d31463;
        {rom[43], rom[42], rom[41], rom[40]} = 32'h01c31463;
        {rom[47], rom[46], rom[45], rom[44]} = 32'h000003b3;
        {rom[51], rom[50], rom[49], rom[48]} = 32'h00002403;
        {rom[55], rom[54], rom[53], rom[52]} = 32'h00402483;
        {rom[59], rom[58], rom[57], rom[56]} = 32'h00848493;
        {rom[63], rom[62], rom[61], rom[60]} = 32'h00940463;
        {rom[67], rom[66], rom[65], rom[64]} = 32'h000003b3;
        {rom[71], rom[70], rom[69], rom[68]} = 32'h007383b3;
    end

    assign inst_o = {rom[addr_i+3], rom[addr_i+2], rom[addr_i+1], rom[addr_i]};
endmodule
