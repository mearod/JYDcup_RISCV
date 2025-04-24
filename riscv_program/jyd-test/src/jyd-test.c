#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int main() {
	if (io_read(AM_GPIO_CONFIG).present == false) return 1;
	int state = 0;
	while (1) {
		if (io_read(AM_GPIO_KEY).data & 1) state = !state;

		AM_GPIO_SW_T sw = io_read(AM_GPIO_SW);
		io_write(AM_GPIO_LED, sw.data[state]);
		io_write(AM_GPIO_SEG, {(uint8_t)sw.data[!state]});
	}
	return 0;
}
