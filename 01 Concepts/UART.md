*Universal Asynchronous Receiver Transmit*

![[uart-1.png]]

TX - Transmission
RX - Reception
Both devices should have a common ground.

It is a character oriented protocol meaning a single byte is sent at a time. (A chunk of 8 bits at a time)

UART is a PEER to PEER communication protocol - [[Topologies Of Communication]]

## Data Frame 

- Indicates the starting and ending point of the communication. 
- Helps devices to understand the pattern of talking.

![[data frame.png]]

- Initially the Tx line is high and the start bit pulls it low indicating the start of the frame.
- Then a series of 8 bits of data is transmitted.
- High is 5V - bit value 1
- Low is 0V - bit value 0
- Parity bit is optional
- Stop bit is back to high for end of frame.
- It is a 10 bit data frame and with parity bit its a 11 bit data frame.

*Note: Older devices were slow and couldn't differentiate between 2 data frames, so 2 stop bits were used to give it time to process it.*

This works at a short distance but when the distance is increased there would be electro- magnetic interference which would cause errors and that's where **RS232** comes into picture.

## RS232

- It is a 9 pin connector
![[rs232.png]]
- Its a multiple handshake - like device 1 ready to receive and device 2 is read to transmit.
- Voltage levels:
	- 1s: -3V to -25V
	- 0s: +3V to +25V
 ![[rs232 signal.png]]
- The voltage difference is constant even if there is interference. Which makes it an inbuilt error connection.
- But the voltage is too high for embedded electronics so *voltage level shifters* are used to convert the voltage level on both the sides.

## BAUD RATE

- Both transmitter and receiver should have the same baud rate.

![[baud rate.png]]

## Bit Banging

- Basic and difficult to work on.
- Normal GIPO pins are used.
- So it toggles the pins high and low start with low for 1 clock and so on.
- LSB is sent first.

![[bit banging.png]]

## UART Peripherals

- Transmit & Receive registers, each connected to a shift register.

![[uart pripheras.png]]

- Transmit register on left side loads the value into its shift register and the shift register transmits to the right sides shift register which is connected to the receive register.
- Parallel In Serial Out & Serial In Parallel Out

![[registers.png|425]]

Steps:
1. Clock Configuration
2. Data Loading
3. Data Transmission
4. Monitor Data
	1. Looping Method - Monitors the status bit until all the data is sent/received.
	2. Interrupt Method - After data is sent or received successfully an interrupt is triggered (Better than Method 1 because we can you use parallel processing)

### Advantages Of UART

1. Easy to interface.
2. Less hardware requirement - only need 2 wires for communication.
3. Less software complications - doesn't have to address slaves and is 2 device communication.

### Disadvantages Of UART

1. Synchronising Baud Rate - both devices should have to same baud rate (limited by the device max baud rate).
2. Only 2 device communication.
3. No Acknowledgement 

## Applications

Simple tasks - printers, serial monitors, command line interface


Sources:
https://www.youtube.com/watch?v=JuvWbRhhpdI&t=50s
https://www.youtube.com/watch?v=QmjKRwgddxw

Tags: #concept