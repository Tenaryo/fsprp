`ifndef TEST_MACROS_VH
`define TEST_MACROS_VH

`define PASS(msg) begin $display("PASS: %s", msg); $finish; end
`define FAIL(msg) begin $display("FAIL: %s", msg); $finish; end
`define CHECK_EQ(got, expected, label) \
    if ((got) !== (expected)) begin \
        $display("FAIL: %s expected %h, got %h", label, expected, got); \
        $finish; \
    end

`endif
