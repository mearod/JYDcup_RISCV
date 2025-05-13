# JYDcup_RISCV
JYDcup_RISCV project sjtu

该项目在Ubuntu22.04环境下开发，需要GNU/Linux环境支持。
运行时若发生环境缺失，按照提示添加所需。

项目目录的简要内容如下：
.
├── cdp-tests/
├── LICENSE
├── Makefile
├── README.md
├── riscv_program
│   ├── abstract-machine/
│   └── jyd-test/
├── rtl/
├── rv_emu/
├── utils
│   ├── difftest/
│   ├── Makefile
│   └── yosys-sta/
└── verilator_sim

下面简要介绍文件关键内容

cdp-tests: 官方提供的仿真环境，用于基础的测试，在其中的mySoC/目录下放置rtl代码，make编译，再运行run_all_tests.py即可简单测试riscv32i指令集cpu的基础功能

riscv_program: 借助南京大学的抽象机abstract-machine搭建代码编译环境，在jyd-test中编写C代码，可交叉编译为符合运行时环境的可执行文件，并抽取出包含代码和数据的二进制文件加载运行。

rtl: 包含rtl代码，其中rtl/student_core/目录下为cpu核的主要rtl代码。rtl/general/目录下为一些编写rtl代码所需的模板，比如寄存器模板。rtl/RTL_style_document.md为rtl代码风格规范。cpu的复位值为0x80000000，可通过修改rtl/student_core/core_defines.v文件中的CORE_PC_RESET_VALUE来更改。

utils: 包含一些工具，其中utils/difftest/目录下为差分测试difftest相关内容，其中包含一个南京大学指令级模拟器nemu作为difftest基准的动态链接库。utils/yosys-sta/目录下包含一个开源综合工具，用以简单评估cpu设计的频率和面积等性能。

verilator_sim: 包含一个功能性和定制化更强的verilator仿真环境。在verilator_sim/tests/目录下有已经编译好的alu_test和rt-thread的elf文件和包含代码和数据的bin二进制文件和包含指令反汇编的txt文件。verilator_sim/wave.fst文件为波形记录文件。在verilator_sim/include/common.h下有DIFFTEST宏，若定义该宏则打开difftest,还有WAVE_TRACE宏，若定义则打开波形记录，此时下面的wt命令才生效。运行make sim IMG=PATH/TO/BINARY_FILE即可将路径为PATH/TO/BINARY_FILE的二进制文件加载到地址0x80000000下运行,例如输入make sim IMG=tests/rtthread.bin以运行rtthread。运行时会出现一个命令行提示符(jyd)，可通过输入help回车来查看相关命令，这里简述如下：
help : 显示指令列表及介绍
c : 直接运行，直到遇到ebreak指令或触发difftest
q : 退出仿真
sc [数字] : cpu运行[数字]个周期，不加参数则为一个周期
info [r]: 显示信息，目前只有寄存器信息
x [字节数] [起始地址]: 扫描内存，[起始地址]开始的[字节数]个字节的内存，以4字节为一组显示
wt [c/o] : 波形开关，在verilator_sim/include/commom.h中定义宏WAVE_TRACE后该命令才生效。wt o为打开波形记录，wt c为关闭波形记录，运行结束后波形记录在wave.fst文件中，用gtkwave打开
如果不想进入命令行调试而是直接运行，可在make命令后加BATCH=1，这相当于自动键入c,运行完成后键入q。例如：make sim IMG=tests/rtthread.bin BATCH=1
运行完成后，会统计周期数，指令数，并计算IPC,若显示HIT GOOD TRAP at pc = 0x8xxxxxxx则在某处pc正确退出（即return 0，或者说a0返回值寄存器最终为0），若显示HIT BAD TRAP (return value: x) at pc = 0x8xxxxxxx则在某处pc错误退出（即return x，或者说a0返回值寄存器最终为非0）。
