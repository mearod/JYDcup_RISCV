TOPNAME = core_cpu

INC_PATH ?= 

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -O3 --x-assign \
										fast --x-initial fast --noassert --autoflush \
										--timescale "1ns/1ns" --no-timing --trace-fst

PROJECT_HOME = $(abspath ../)
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
IMG ?= 
BIN = $(BUILD_DIR)/$(TOPNAME)

CXX_INC_PATH = $(abspath ./include) $(INC_PATH)
VER_INC_PATH += $(abspath ../rtl_version2/student_core)

default:
	rm -f $(BIN)
	make $(BIN)

$(shell mkdir -p $(BUILD_DIR))

VSRCS = $(shell find $(abspath ../rtl_version2) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

CXX_INCFLAGS = $(addprefix -I, $(CXX_INC_PATH))
VER_INCFLAGS = $(addprefix -I, $(VER_INC_PATH))
CXXFLAGS += $(CXX_INCFLAGS) \
						-DTOP_NAME=\"V$(TOPNAME)\"
VERILATOR_CFLAGS += $(VER_INCFLAGS)
DIFF_SO = $(PROJECT_HOME)/utils/difftest/riscv32-nemu-interpreter-so
LDFLAGS += -lreadline
ifneq ($(IMG),)
override ARGS += -g $(IMG)
endif
ifneq ($(DIFF_SO),)
override ARGS += -d $(DIFF_SO)
endif
ifeq ($(BATCH),1)
override ARGS += -b
endif

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) 

all: default

sim: 
	rm -f $(BIN)
	make $(BIN)
	$(BIN) $(ARGS)

.PHONY: clean all default sim

clean:
	rm -rf $(BUILD_DIR)

count:
	find ./csrc ./vsrc -name *.[chv] | xargs cat | wc -l

countNoblank:
	find ./csrc ./vsrc -name *.[cvh] | xargs grep -v '^$$' | wc -l

CHECK_VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CHECKFLAGS = --lint-only -Wall $(VER_INCFLAGS)

check:
	$(VERILATOR) $(CHECKFLAGS) $(CHECK_VSRCS)
