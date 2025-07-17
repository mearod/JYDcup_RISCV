#include <common.h>
#include <memory.h>
#include <cpu.h>

#define LSU_ADDR signal(u_core_ls_lsu_test__DOT__mem_addr)

TOP_NAME *top = NULL;
VerilatedFstC *tfp = NULL;
VerilatedContext *contextp = NULL;

int trigger_difftest = 0;
extern int wave_trace;

static uint64_t total_cycle = 0;
static uint64_t total_inst = 0;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
void difftest_step();
void difftest_skip_ref();
extern void (*ref_difftest_regcpy)(void *dut, uint32_t *pc, bool direction);
void print_difftest_reg();

static void one_cycle() {
	top->clk = 0; top->eval(); 
#ifdef WAVE_TRACE
	if (wave_trace) { tfp->dump(contextp->time()); contextp->timeInc(1); }
#endif
	top->clk = 1; top->eval(); 
#ifdef WAVE_TRACE
	if (wave_trace) { tfp->dump(contextp->time()); contextp->timeInc(1); }
#endif
}

void reset(uint32_t n) {
	top->rst_n = 0;
	for (int i = 0; i < n; ++i)
		one_cycle();
	top->rst_n = 1;
}

void cpu_exec(unsigned long n) {
	if (top->rv_ebreak_sim || trigger_difftest) {
		printf("the program is ended.\n");
		return;
	}

	for (; n > 0; --n) {
		one_cycle();
		++total_cycle;
		if (top->inst_end) ++total_inst;
#ifdef DIFFTEST
		static int write_back = 0;
		if (write_back == 1) {
			if (LSU_ADDR == SERIAL_BASE || 
					LSU_ADDR == TIMER_BASE  ||
					LSU_ADDR == TIMER_BASE + 4) 
				difftest_skip_ref();
			difftest_step();
		}
		write_back = top->inst_end;
#endif
		if (top->rv_ebreak_sim || trigger_difftest) break;
	}

	if (trigger_difftest) {
		reg_display();
		printf("\33[1;31mdifftest ABORT\33[1;0m at pc = %#x\n", signal(ifu_pc));
		one_cycle();
		one_cycle();
		one_cycle();
		return;
	}
	if (!top->rv_ebreak_sim) return;
	printf("total cycle: %ld\ntotal inst: %ld\nIPC: %f\n", 
			total_cycle, total_inst, (double)total_inst/total_cycle);
	if (cpu_gpr(10))
		printf("\33[1;31mHIT BAD TRAP\33[1;0m (return value: %d) ", cpu_gpr(10));
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	printf("at pc = %#x\n", signal(ifu_pc));
}
