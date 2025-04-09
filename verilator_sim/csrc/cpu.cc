#include <common.h>
#include <memory.h>
#include <cpu.h>

TOP_NAME *top = NULL;
VerilatedFstC *tfp = NULL;
VerilatedContext *contextp = NULL;

int trigger_difftest = 0;
extern int wave_trace;

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
#ifdef DIFFTEST
#endif
		if (top->rv_ebreak_sim || trigger_difftest) break;
	}

	if (trigger_difftest) {
		reg_display();
		//printf("\33[1;31mdifftest ABORT\33[1;0m at pc = %#x\n", pc);
		return;
	}
	if (!top->rv_ebreak_sim) return;
	if (cpu_gpr(10))
		printf("\33[1;31mHIT BAD TRAP\33[1;0m ");
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	//printf("at pc = %#x\n", signal(ifu_pc));
#ifdef PRINT_PERF
	print_statistic();
#endif
}
