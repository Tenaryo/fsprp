RTL_DIR      = rtl
BUILD_DIR    = build
TEST_DIR     = tests
SIM_SRC      = sim1.v
CORE_RTL     = $(filter-out $(RTL_DIR)/inst_mem.v, $(wildcard $(RTL_DIR)/*.v))
TEMPLATE_SRC = $(wildcard $(RTL_DIR)/templates/*.v)
VVP          = $(BUILD_DIR)/sim1.vvp
VCD          = $(BUILD_DIR)/sim1.vcd

.PHONY: sim clean tests wave

sim: $(VVP)
	@vvp -n $(VVP) 2>&1 | grep -v -e "VCD info" -e '\$$stop' > $(BUILD_DIR)/sim_output.txt; \
	echo "--------- Final Output ---------"; \
	tail -7 $(BUILD_DIR)/sim_output.txt; \
	echo "--------------------------------"; \
	if diff -q $(BUILD_DIR)/sim_output.txt $(TEST_DIR)/golden/sim1_expected.txt > /dev/null 2>&1; then \
		echo "PASS: sim"; \
	else \
		echo "FAIL: sim (output differs, check diff $(BUILD_DIR)/sim_output.txt $(TEST_DIR)/golden/sim1_expected.txt)"; \
		diff $(BUILD_DIR)/sim_output.txt $(TEST_DIR)/golden/sim1_expected.txt; \
	fi

$(VVP): $(SIM_SRC) $(wildcard $(RTL_DIR)/*.v) $(TEMPLATE_SRC)
	@mkdir -p $(BUILD_DIR)
	iverilog -o $@ $^

wave: $(VVP)
	@vvp -n $(VVP)
	@surfer $(VCD) &

test_%: $(TEST_DIR)/test_%.v $(CORE_RTL) $(TEMPLATE_SRC)
	@mkdir -p $(BUILD_DIR)
	iverilog -I . -o $(BUILD_DIR)/$@.vvp $^
	vvp -n $(BUILD_DIR)/$@.vvp

tests:
	@passed=0; failed=0; \
	for t in $(basename $(notdir $(wildcard $(TEST_DIR)/test_*.v))); do \
		if $(MAKE) --no-print-directory $$t 2>&1 | grep -q "PASS"; then \
			passed=$$((passed+1)); \
			echo "PASS: $$t"; \
		else \
			failed=$$((failed+1)); \
			echo "FAIL: $$t"; \
		fi; \
	done; \
	echo "=== Passed: $$passed, Failed: $$failed ==="

clean:
	rm -rf $(BUILD_DIR)
