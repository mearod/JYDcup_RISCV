import sys
import os

def bin_to_coe_4byte(input_bin, irom_coe, dram_coe, split_addr=0x4000):
    try:
        with open(input_bin, 'rb') as f:
            data = f.read()
        
        # 检查文件是否足够大
        if len(data) < split_addr:
            print(f"Warning: Input file is smaller than {split_addr:#x}, dram.coe will be empty")
        
        # 分割数据
        irom_data = data[:split_addr]
        dram_data = data[split_addr:]
        
        def write_coe(filename, data):
            with open(filename, 'w') as f:
                f.write("memory_initialization_radix=16;\n")
                f.write("memory_initialization_vector=\n")
                
                # 补齐数据长度为4的倍数
                pad_len = (4 - len(data) % 4) % 4
                padded_data = data + bytes([0] * pad_len)
                
                for i in range(0, len(padded_data), 4):
                    # 小端序组合4个字节
                    word = (padded_data[i+3] << 24) | (padded_data[i+2] << 16) | \
                           (padded_data[i+1] << 8) | padded_data[i]
                    
                    # 最后一行用分号，其他用逗号
                    if i >= len(data) - 4 and pad_len == 0:
                        f.write(f"{word:08x};\n")
                    else:
                        f.write(f"{word:08x},\n")
        
        # 写入irom.coe
        write_coe(irom_coe, irom_data)
        
        # 写入dram.coe
        write_coe(dram_coe, dram_data)
        
        print(f"Successfully split {input_bin} into:")
        print(f"- {irom_coe} (0x0000-0x{split_addr-1:04x}, {len(irom_data)} bytes)")
        print(f"- {dram_coe} (0x{split_addr:04x}-end, {len(dram_data)} bytes)")
        if len(irom_data) % 4 != 0:
            print(f"Note: {irom_coe} padded with {4 - len(irom_data) % 4} zeros to align to 4 bytes")
        if len(dram_data) % 4 != 0:
            print(f"Note: {dram_coe} padded with {4 - len(dram_data) % 4} zeros to align to 4 bytes")
    
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python split_bin_to_coe.py <input.bin>")
        sys.exit(1)
    
    input_bin = sys.argv[1]
    if not os.path.isfile(input_bin):
        print(f"Error: File {input_bin} not found")
        sys.exit(1)
    
    base_name = os.path.splitext(input_bin)[0]
    irom_coe = f"{base_name}_irom.coe"
    dram_coe = f"{base_name}_dram.coe"
    
    bin_to_coe_4byte(input_bin, irom_coe, dram_coe)