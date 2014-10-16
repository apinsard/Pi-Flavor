# Distributed under the terms of the GNU General Public License v2

CC ?= arm-none-eabi
LD ?= $(CC)-ld
AS ?= $(CC)-as

BUILD  = build
SOURCE = src
TARGET = kernel.img
LIST   = kernel.list
MAP    = kernel.map
LINKER = kernel.ld

OBJECTS := $(patsubst $(SOURCE)/%.s,$(BUILD)/%.o,$(wildcard $(SOURCE)/*.s))

all: $(TARGET) $(LIST)

$(LIST): $(BUILD)/output.elf
	$(CC)-objdump -d $< > $@

$(TARGET): $(BUILD)/output.elf
	$(CC)-objcopy $< -O binary $@

$(BUILD)/output.elf: $(OBJECTS) $(LINKER)
	$(LD) --no-undefined $< -Map $(MAP) -o $@ -T $(LINKER)

$(BUILD)/%.o: $(SOURCE)/%.s
	$(AS) -I $(SOURCE) $< -o $@

clean:
	rm -f $(BUILD)/*.o

mrproper: clean
	rm -f $(TARGET)
	rm -f $(LIST)
	rm -f $(MAP)
