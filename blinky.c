#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

#define RCC_LED1 RCC_GPIOC
#define PORT_LED1 GPIOC
#define PIN_LED1 GPIO13
#define LITTLE_BIT 800000

int main(void)
{
  rcc_periph_clock_enable(RCC_LED1);

  gpio_mode_setup(PORT_LED1, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, PIN_LED1);
  gpio_set(PORT_LED1, PIN_LED1);

  while(1) {
    for (int i = 0; i < LITTLE_BIT; i++) {
      __asm__("nop");
    }

    gpio_toggle(PORT_LED1, PIN_LED1);
  }
}

/* EOF */
