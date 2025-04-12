#include <common.h>
#include <memory.h>
#include <time.h>

extern int monitor_start;

mem_t mem_arr[TOTAL_MEM] = {
	(mem_t){MEM_BASE, NULL, MEM_SIZE, "psram"},
//	(mem_t){MROM_BASE, NULL, MROM_SIZE, "mrom"},
//	(mem_t){SRAM_BASE, NULL, SRAM_SIZE, "sram"},
//	(mem_t){FLASH_BASE, NULL, FLASH_SIZE, "flash"},
//	(mem_t){SDRAM_BASE, NULL, SDRAM_SIZE, "sdram"},
};
uint32_t total_mem = TOTAL_MEM;

static uint8_t memory[MEM_SIZE];

uint8_t *guest2host(uint32_t paddr) {return memory + paddr - MEM_BASE;}
uint32_t host2guest(uint8_t *haddr) {return haddr - memory + MEM_BASE;}
void difftest_skip_ref();
void reg_display();

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	if (waddr == SERIAL_BASE) {
		printf("%c", (char)wdata);
		return;
	}

	uint8_t *haddr = guest2host(waddr & ~0x3u);
	if (!(haddr >= memory && haddr <= memory + MEM_SIZE)) {
		printf("\nwrite %x out of bound\n\n", waddr);
		reg_display();
		assert(0);
	}
	//printf("write address: %x, data: %x\n", waddr, wdata);

	if (wmask & 0x1) haddr[0] = wdata & 0xff;
	if (wmask & 0x2) haddr[1] = (wdata >> 8) & 0xff;
	if (wmask & 0x4) haddr[2] = (wdata >> 16) & 0xff;
	if (wmask & 0x8) haddr[3] = (wdata >> 24) & 0xff;
}

extern "C" int pmem_read(int raddr) {
	if (monitor_start == 0) return 0;
	uint8_t *haddr = guest2host(raddr & ~0x3u);
	if (!(haddr >= memory && haddr <= memory + MEM_SIZE)) {
		printf("\nread %x out of bound\n\n", raddr);
		reg_display();
		assert(0);
	}
	//printf("read  address: %x, data: %x\n", raddr, *(int *)haddr);

	return *(int *)haddr;
}

void init_memory() {
}
