#include <binaryMacro.h>
#include <macros.h>
#include <pinDefines.h>
#include <portpins.h>
#include <USART.h>

// ------- Preamble -------- //
#include <avr/io.h>         // Defines pins, ports, etc
#include <util/delay.h>     // Functions to waste time

#ifdef LED_PORT
#undef LED_PORT
#endif

#ifdef LED_PIN
#undef LED_PIN
#endif

#ifdef LED_DDR
#undef LED_DDR
#endif

#define DELAY_TIME 85
#define LED_PORT PORTD
#define LED_DDR DDRD

int main(void) {

    uint8_t i = 0;
    uint8_t repetitions = 0;
    uint8_t whichLED = 0;
    uint16_t randomNumber = 0x1234;

    // initialize all pins for output
    DDRD = 0xff;

    // ------ Event loop ------ //
    while (1) {

        for (i = 0; i < 8; i++)
	{
	    LED_PORT |= (1 << i);
	    _delay_ms(DELAY_TIME);
	}

	for (i = 0; i < 8; i++)
	{
	    LED_PORT &= ~(1 << i);
	    _delay_ms(DELAY_TIME);
	}

	_delay_ms(5 * DELAY_TIME);


	for (i = 7; i < 255; i--)
	{
	    LED_PORT |= (1 << i);
	    _delay_ms(DELAY_TIME);
	}

	for (i = 7; i < 255; i--)
	{
	    LED_PORT &= ~(1 << i);
	    _delay_ms(DELAY_TIME);
	}

	_delay_ms(5 * DELAY_TIME);

	for (repetitions = 0; repetitions < 75; repetitions++)
	{
	    randomNumber = 2053 * randomNumber + 13849;

	    whichLED = (randomNumber >> 8) & 0b00000111;

	    LED_PORT ^= (1 << whichLED);
	    _delay_ms(DELAY_TIME);
	}

	LED_PORT = 0;
	_delay_ms(5 * DELAY_TIME);

    }

    return (0);
}
