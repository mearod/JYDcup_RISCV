#include <common.h>
#include <getopt.h>
#include <unistd.h>
#include <memory.h>

#ifdef DIFFTEST
void init_difftest(char *ref_so_file, long immg_size, int port, mem_t *mem_arr, uint32_t total_mem);
#endif

static char *img_file = NULL;
static char *diff_so_file = NULL;
long img_size = 0;
void set_batch_mode();

static long load_img() {
	if (img_file == NULL) {
		printf("No image is given. Use the default build-in image.\n");
		return 4096;
	}

	FILE *fp = fopen(img_file, "rb");
	if (fp == NULL) {
		printf("\nopen file \"%s\" failed\n", img_file);
		assert(0);
	}

	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);

	fseek(fp, 0, SEEK_SET);
	int ret = fread(guest2host(MEM_BASE), size, 1, fp);
	if (ret != 1) {
		printf("\nread file \"%s\" failed", img_file);
		assert(0);
	}

	fclose(fp);

	printf("\nload file \"%s\", size: %d bytes\n", img_file, size);

	return size;
}

static int parse_args(int argc, char **argv) {
	const struct option table[] = {
		{"batch"    , no_argument      , NULL, 'b'},
		{"diff"     , required_argument, NULL, 'd'},
		{"img"      , required_argument, NULL, 'g'},
		{0          , 0                , NULL,  0 },
	};
	int o;
	while ( (o = getopt_long(argc, argv, "-bd:g:", table, NULL)) != -1) {
		switch (o) {
			case 'b': set_batch_mode(); break;
			case 'd': diff_so_file = optarg; break;
			case 'g': img_file = optarg; break;
		}
	}
	return 0;
}

void init_monitor(int argc, char **argv) {
	parse_args(argc, argv);

	init_memory();

	img_size = load_img();

#ifdef DIFFTEST
	init_difftest(diff_so_file, img_size, 1234, mem_arr, total_mem);
#endif
}
