# Makefile for the STM32L071 skeletion
#
# John Berg @ netbasenext.nl
#

PROJECT = firmware

# Project Structure
SRCDIR = src
BINDIR = bin
OBJDIR = obj
INCDIR = include
COMDIR = common

# Project target
CPU = cortex-m0plus

# Sources
SRC = $(wildcard $(SRCDIR)/*.c) $(wildcard $(COMDIR)/src/*.c) 
CPPSRC = $(wildcard $(SRCDIR)/*.cpp) $(wildcard $(COMDIR)/src/*.cpp)
ASM = $(wildcard $(SRCDIR)/*.s) $(wildcard $(COMDIR)/src/*.s)

#defines
DEFINE = -DSTM32L071xx

# Include directories
INCLUDE  = -I$(INCDIR) -I$(COMDIR)/include -I$(COMDIR)/cmsis

# Linker
LSCRIPT = STM32L071.ld

# C/C++ Flags
CCOMMONFLAGS = -Wall -Os -g -fno-common -mthumb -mcpu=$(CPU) --specs=nosys.specs --specs=nano.specs

# Generate dependency information
CDEPFLAGS += -MMD -MP -MF $(@:%.o=%.d)

# C Flags
GCFLAGS  = -std=c++14 -Wa,-ahlms=$(addprefix $(OBJDIR)/,$(notdir $(<:.c=.lst)))
GCFLAGS += $(CCOMMONFLAGS) $(INCLUDE) $(DEFINE) $(CDEPFLAGS)
LDFLAGS += -T$(LSCRIPT) -mthumb -mcpu=$(CPU) --specs=nosys.specs --specs=nano.specs -Wl,-Map,$(BINDIR)/$(PROJECT).map -Wl,--gc-sections
ASFLAGS += -mcpu=$(CPU)

# CPP Flags
CPPFLAGS = -fno-exceptions -fno-rtti

# Tools
CC = arm-none-eabi-gcc
CP = arm-none-eabi-g++
AS = arm-none-eabi-as
AR = arm-none-eabi-ar
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size --format=SysV -x
OBJDUMP = arm-none-eabi-objdump

RM = rm -rf

## Build process
OBJ := $(addprefix $(OBJDIR)/, $(notdir $(SRC:.c=.o)))
OBJ += $(addprefix $(OBJDIR)/, $(notdir $(ASM:.s=.o)))
CPPOBJ := $(addprefix $(OBJDIR)/, $(notdir $(CPPSRC:.cpp=.o)))


all:: $(BINDIR)/$(PROJECT).bin $(BINDIR)/$(PROJECT).hex

Build: $(BINDIR)/$(PROJECT).bin

macros:
	$(CP) $(GCFLAGS) -dM -E - < /dev/null

cleanBuild: clean

clean:
	$(RM) $(BINDIR)
	$(RM) $(OBJDIR)

size:
	$(SIZE) $(BINDIR)/$(PROJECT).elf

makedebug:
	@echo $(OBJ)
	@echo $(CPPOBJ)

#convert to hex
$(BINDIR)/$(PROJECT).hex: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -O ihex $(BINDIR)/$(PROJECT).elf $(BINDIR)/$(PROJECT).hex

#convert to bin
$(BINDIR)/$(PROJECT).bin: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -O binary $(BINDIR)/$(PROJECT).elf $(BINDIR)/$(PROJECT).bin

# linking
$(BINDIR)/$(PROJECT).elf: $(OBJ) $(CPPOBJ) $(LSCRIPT)
	@mkdir -p $(dir $@)
	$(CP) $(OBJ) $(CPPOBJ) $(LDFLAGS) -o $(BINDIR)/$(PROJECT).elf
	$(OBJDUMP) -D $(BINDIR)/$(PROJECT).elf > $(BINDIR)/$(PROJECT).lst
	$(SIZE) $(BINDIR)/$(PROJECT).elf

# Compilation
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CP) $(GCFLAGS) $(CPPFLAGS) -c $< -o $@
	@echo -e ""

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CP) $(GCFLAGS) $(CPPFLAGS) -c $< -o $@
	@echo -e ""

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<
	@echo -e ""

$(OBJDIR)/%.o: $(COMDIR)/src/%.c
	@mkdir -p $(dir $@)
	$(CP) $(GCFLAGS) $(CPPFLAGS) -c $< -o $@
	@echo -e ""

$(OBJDIR)/%.o: $(COMDIR)/src/%.cpp
	@mkdir -p $(dir $@)
	$(CP) $(GCFLAGS) $(CPPFLAGS) -c $< -o $@
	@echo -e ""

$(OBJDIR)/%.o: $(COMDIR)/src/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ): Makefile

-include $(wildcard $(OBJDIR)/*.d)
