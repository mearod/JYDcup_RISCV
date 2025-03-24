# RTL命名规范风格

### 文件与模块

1. 全部采用**verilog**语法，以.v文件为后缀

2. 一个v文件可以例化任意多个module，但只能声明**一个与文件名相同**的module。例化module名

3. v文件名命名规则：**core\_[stage]\_[function1]**，对于可以分到对应流线段的，stage为三级流水阶段其中一段：if \ id \ ex , function1为该模块具体名字。例如：core_if_pc \ core_ex_alu \ core_id_imm；对于不好分段的，function1直接前移，例如core_biu \ core_fifo \  core_defines    .function1内部允许任意加_号，内部如何命名加\_号不作限制，例如core\_if_pc_mux \ core_biu_xbar

### 宏

1. 所有的宏的声明都应写入到core_defines.v中，所有宏命名都应该以core_开头
2. 严格区分SIZE和WIDTH后缀。例如a[15:0]，A_SIZE为64K，A_WIDTH为16。极少数情况下需要用到width的width，就用WIDTH_WIDTH作为后缀，例如上例中A_WIDTH_WIDTH为4。为了减少宏而复用时，WIDTH优先级大于SIZE，例如a[15:0] b[3:0]，b作为a的索引，则应当为a[2**\`B_WIDTH-1:0]，b[`B_WIDTH-1:0]
3. 宏应当尽量分类并同类聚集。
4. verilator仿真相关的宏可以不用满足以上要求。

### 变量

1. 除了文件名和模块名，任何变量不能含有core字样。所有时钟变量统一命名为**clk**，所有复位信号统一命名为**rst_n** (低电平复位)；自定义的写读功能统一有wr、rd后缀；
2. 前后缀顺序：逻辑功能按照英语自然语言顺序（主谓宾），标志功能的信号若采用flag前缀，flag永远在开头；使能功能的信号中，若采用en后缀，en永远在结尾；（待补充规则），以_分隔；例如：flag\_branch；sel_alu_en
3. 文本行顺序：一组同服务对象逻辑中，valid一定在ready前面；rd一定在wr前面；（待补充规则）
4. 若变量位宽为不可配置的且为1，一般情况下不用显式地声明其位宽为1；其余情况下，**除了riscv手册规定的长度，比如func3，func7之外，任何没规定的变量位宽都不应直接声明数字**，而应以**宏**来声明。例如：不能为 pc[31:0],而应该为pc.[`core_pc_width-1:0]；因此，为了防止过多宏产生，应当尽量根据功能对变量位宽复用宏
5. 端口变量不声明reg变量，若有必要声明reg端口变量在模块内对其声明

###  逻辑功能

1. 所有寄存器均使用标准DFF模块例化生成寄存器。标准DFF模板位于rtl/general/gnrl_dffs.v下
2. 禁止使用always语法。所有选择器使用assign语法实现，即优先级形式（assign a= ？ ：？：）或并行形式（asssign a = （）&（）|（）&（））
3. 禁止使用或生成锁存器