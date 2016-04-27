# Name: Makefile
# Author: Andrew Mikesell
# Copyright: Ando Coyote 2016
# License: Free for non-commercial use only

# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected.
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

INCLUDE_ROOT=c:\\WinAVR-20100110

DEVICE     = atmega328p
CLOCK      = 16000000
BAUD       = 19200
PROGRAMMER = -c arduino -P COM7 -b 19200
OBJECTS    = main.o

# Fuses for external 16mhz crystal
#FUSES = -U lfuse:w:0xFF:m -U hfuse:w:0xDE:m -U efuse:w:0x05:m

# Fuses for internal clock
FUSES = -U lfuse:w:0xE2:m -U hfuse:w:0xDF:m -U efuse:w:0x05:m

# A directory for common include files and the simple USART library.
# If you move either the current folder or the Library folder, you'll 
# need to change this path to match.
LIBDIR=\
        ../libraries/AVR-Programming-Library
#        $(INCLUDE_ROOT)\\AVR-Programming-master\\AVR-Programming-Library; \
#        $(INCLUDE_ROOT)\\avr\\include\\avr;

SOURCES = $(wildcard *.c $(LIBDIR)/*.c)
CPPFLAGS = -DBAUD=$(BAUD) -I. -I$(LIBDIR)
CFLAGS += -ffunction-sections -fdata-sections

######################################################################
######################################################################

# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
COMPILE = avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

# symbolic targets:
all:	main.hex

# make the object file from the .c file.
# %.o is the target and so is $@
# %.c is the prerequisite and so is $<
# -c means compile the source into an object file but don't link object files into an executable
# -o specifies the name of the object file to create
# this will produce main.o and this whole command will get resolved to this:
#   avr-gcc -Wall -Os -DF_CPU=16000000 -mmcu=atmega328p -ffunction-sections -fdata-sections -DBAUD=19200 -I. -I<LIBDIR macro> -c main.c -o main.o
%.o: %.c
	$(COMPILE) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

%.s: %.c
	$(COMPILE) -S $< -o $@

flash:	all
	$(AVRDUDE) -U flash:w:main.hex:i

fuse:
	$(AVRDUDE) $(FUSES)

install: flash fuse

# if you use a bootloader, change the command below appropriately:
load: all
	bootloadHID main.hex

clean:
	rm -f main.hex main.elf $(OBJECTS)

# file targets:
# this will produce main.elf and this whole command will get resolved to this:
#   avr-gcc -Wall -Os -DF_CPU=16000000 -mmcu=atmega328p -o main.elf main.o
main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS)

# The hex file is what actually gets flashed to the microcontroller
# This command will produce main.hex
main.hex: main.elf
	rm -f main.hex
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d main.elf

# Use this to write in C++ and convert to C 
cpp:
	$(COMPILE) -E main.c
