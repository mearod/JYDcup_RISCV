#include <common.h>
#include <monitor.h>

int main(int argc, char *argv[]) {
	Verilated::commandArgs(argc, argv);
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new TOP_NAME{contextp};

#ifdef WAVE_TRACE
	tfp = new VerilatedFstC;
	contextp->traceEverOn(true);
	top->trace(tfp, 0);
	tfp->open("wave.fst");
#endif

	init_monitor(argc, argv);

#ifdef RISCV_TESTS_ENV
	printf("WARNING: NOW IN RISCV_TESTS_ENV MODE\n");
#endif

	sdb_mainloop();

	delete top;
	delete contextp;
#ifdef WAVE_TRACE
	tfp->close();
#endif

	return 0;
}
