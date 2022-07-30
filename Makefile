PREFIX?=arm-none-eabi-
CC=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy

SFLAGS= --static -nostartfiles -std=c11 -g3 -Os
SFLAGS+= -fno-common -ffunction-sections -fdata-sections
SFLAGS+= -I./libopencm3/include -L./libopencm3/lib
M4FH_FLAGS= $(SFLAGS) -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16

LFLAGS+=-Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group
LFLAGS_STM32=$(LFLAGS) -T ld.stm32.basic

STM32F4_CFLAGS=$(M4FH_FLAGS) -DSTM32F4 $(LFLAGS_STM32) -lopencm3_stm32f4

all: blinky.bin

%.bin: %.elf
	@#printf "  OBJCOPY $(*).bin\n"
	$(OBJCOPY) -Obinary $(*).elf $(*).bin

blinky.elf:
	$(CC) blinky.c -o blinky.elf $(STM32F4_CFLAGS)

.PHONY: all

# EOF #
