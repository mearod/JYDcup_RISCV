#ifndef __COMMON_H__
#define __COMMON_H__

#define DIFFTEST
#define WAVE_TRACE

//#define signal(s) top->rootp->

#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>

#include <Vcore_cpu.h>
#include <verilated.h>
#include <verilated_fst_c.h>
#include <Vcore_cpu___024root.h>

extern TOP_NAME *top;
extern VerilatedFstC *tfp;
extern VerilatedContext *contextp;

#endif
