#include <common.h>
#include <dlfcn.h>
#include <memory.h>

#define TOTAL_REG 32

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
extern TOP_NAME* top;
extern int trigger_difftest;

void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, uint32_t *pc, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_init)(int port, mem_t *mem_arr, uint32_t total_mem) = NULL;

#ifdef DIFFTEST

static bool is_skip_ref = false;

void difftest_skip_ref() {
	is_skip_ref = true;
}

void init_difftest(char *ref_so_file, long img_size, int port, mem_t *mem_arr, uint32_t total_mem) {
  assert(ref_so_file != NULL);

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy = (void (*)(uint32_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void *, uint32_t *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec = (void (*)(uint64_t n))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_init = (void (*)(int, mem_t *, uint32_t))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port, mem_arr, total_mem);
  ref_difftest_memcpy(MEM_BASE, guest2host(MEM_BASE), img_size, DIFFTEST_TO_REF);
	uint32_t pc_start = 0x80000000;
  ref_difftest_regcpy(&cpu_gpr(0), &pc_start, DIFFTEST_TO_REF);
}

void print_difftest_reg (int pc, int i) {
	uint32_t ref_r[32];
	uint32_t ref_pc;
  ref_difftest_regcpy(ref_r, &ref_pc, DIFFTEST_TO_DUT);
	if (pc) printf("pc\t%#x\n", ref_pc);
	else printf("x%d\t%#x\n", i, ref_r[i]);
}

static void checkregs(uint32_t *ref, uint32_t ref_pc, uint32_t pc) {
	for (int i = 0; i < TOTAL_REG; ++i) {
		if (ref[i] != cpu_gpr(i)) {
			trigger_difftest = 1;
			print_difftest_reg(0, i);
		}
	}
	//if (pc != ref_pc) trigger_difftest = 1;
	if (trigger_difftest) {
		print_difftest_reg(1, 0);
		printf("nemu reference above\n\n");
	}
}

void difftest_step() {
	uint32_t ref_r[32];
	uint32_t ref_pc;

	if (is_skip_ref) {
		ref_difftest_regcpy(ref_r, &ref_pc, DIFFTEST_TO_DUT);
		ref_pc += 4;
		ref_difftest_regcpy(&cpu_gpr(0), &ref_pc, DIFFTEST_TO_REF);
		is_skip_ref = false;
		return;
	}

  ref_difftest_exec(1);
  ref_difftest_regcpy(ref_r, &ref_pc, DIFFTEST_TO_DUT);

  checkregs(ref_r, ref_pc, signal(ifu_pc));
}
#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif
