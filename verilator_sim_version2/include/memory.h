#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <stdint.h>

#define TOTAL_MEM   1
#define MEM_BASE    0x80000000
#define MEM_SIZE    0x08000000

#define SERIAL_BASE 0xa00003f8
#define TIMER_BASE  0xa0000048
#define KEYBRD_BASE 0xa0000060

typedef struct {
	uint32_t start;
	uint8_t *mem;
	uint32_t size;
	const char *name;
} mem_t;//与difftest一致
extern mem_t mem_arr[TOTAL_MEM];
extern uint32_t total_mem;

extern "C" void pmem_write(int waddr, int wdata, char wmask);
extern "C" int pmem_read(int raddr);
void init_memory();
uint8_t *guest2host(uint32_t paddr);
uint32_t host2guest(uint8_t *haddr);

#endif
