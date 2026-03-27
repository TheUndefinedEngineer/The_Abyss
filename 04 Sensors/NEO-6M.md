### NEO-6M GPS Chip

At the heart of the module is a GPS chip from U-blox, the NEO-6M.

![[NEO-6M-GPS-Module-Chip.jpg]]

This powerful chip can track up to 22 satellites and handle up to 50 tracking channels simultaneously. It achieves the industry’s highest level of tracking sensitivity (-161 dB), which means it can detect very weak satellite signals.

The chip offers decent performance, with different startup times depending on its state:

- **Cold start** (when it has no saved data): about 27 seconds to get your location
- **Warm start** (when it has some saved data): about 25 seconds
- **Hot start** (when it was recently used): just a second or so, which means it can quickly find your location again after a brief power-down

The module communicates with microcontrollers using UART communication. It supports a wide range of communication speeds, from 4800 bps up to 230400 bps, with 9600 bps as the default.

## Technical Specifications

| Specifications               |                                 |
| ---------------------------- | ------------------------------- |
| Chipset                      | u-blox NEO-6M                   |
| Receiver Type                | 50 channels, GPS L1(1575.42Mhz) |
| Horizontal Position Accuracy | 2.5m                            |
| Navigation Update Rate       | 1HZ (5Hz maximum)               |
| Capture Time                 | Cool start: 27sHot start: 1s    |
| Navigation Sensitivity       | -161dBm                         |
| Communication Protocol       | NMEA, UBX Binary, RTCM          |
| Serial Baud Rate             | 4800-230400 (default 9600)      |
| Operating Temperature        | -40°C ~ 85°C                    |
| Operating Voltage            | 2.7V ~ 3.6V                     |
| Operating Current            | 45mA                            |
| TXD/RXD Impedance            | 510Ω                            |
| Communication                | Serial TTL (UART)               |
| Power Consumption            | 22mW to 111mW                   |

### Position Fix LED Indicator

The module has a small LED that shows you the GPS status:

- **No blinking**: The module is still searching for satellites
- **Blinking once every second**: A position fix has been found (the module can see enough satellites to know your exact location)

![[NEO-6M-GPS-Module-Position-Fix-LED-Indicator.jpg]]

### Power Supply

The NEO-6M chip needs between 2.7 and 3.6 volts to operate. Fortunately, the module includes a MICREL MIC5205 Ultra-Low Dropout 3.3V regulator. Even better, the logic pins on the module are 5V-tolerant, which means you can connect it directly to an Arduino or any other 5V microcontroller without needing a level shifter.

![[NEO-6M-GPS-Module-3.3V-Voltage-Regulator.jpg]]

The module uses about 45 mA of current during normal operation. However, it also has a feature called Power Save Mode (PSM), which lets it turn off parts of the chip when they’re not needed. In PSM, it can use as little as 11 mA, making it perfect for battery-powered devices like GPS watches or trackers.

### Battery & EEPROM

The module includes a 4KB HK24C32 EEPROM chip and a small rechargeable button battery.

![NEO 6M GPS Module Battery and EEPROM](https://lastminuteengineers.com/wp-content/uploads/arduino/NEO-6M-GPS-Module-Battery-and-EEPROM.jpg)

Together, they help save important information like real-time clock data, last known satellite positions, and configuration settings.

This saved information allows the module to perform a “hot start” on reboot. Without the battery, the GPS always has to do a “cold start,” which takes longer to find your location initially.

The battery charges by itself when the module is powered on and can keep the saved data for about two weeks even without power.

### Antenna

To receive satellite signals, the module comes with a ceramic patch antenna.

![[NEO-6M-Patch-Antenna.jpg]]

You can easily attach this antenna to the small U.FL connector located on the module.

![[NEO-6M-GPS-Module-u.fl-Connector.jpg]]

This antenna works well outdoors or in open skies. However, if you’re using the module in cities (urban canyons) or indoors, you might want to consider using a stronger external active GPS antenna instead.

## NEO-6M GPS Module Pinout

The NEO-6M GPS module has four pins:

![[Ublox-NEO-6M-GPS-Module-Pinout.png]]

GND is the ground pin.

TxD (Transmitter) is the output from the GPS module that sends serial data (such as NMEA sentences). It should be connected to the RX (receive) pin of your microcontroller.

RxD (Receiver) is used to receive commands from the microcontroller. However, it is optional and not usually needed for basic GPS functions. If you want to use it, connect it to the TX (transmit) pin of your microcontroller.

VCC supplies power to the module. You can connect it directly to the 5V pin on your Arduino.

|Pin Name|Description|
|---|---|
|VCC|Power supply (3.3V to 5V)|
|GND|Ground|
|TX|Transmit pin (connect to RX)|
|RX|Receive pin (connect to TX)|
|PPS|Pulse per second (time pulse)|

## Usage Instructions

### How to Use the Component in a Circuit

1. **Power Connection:** Connect the VCC pin to a 3.3V or 5V power supply and the GND pin to the ground.
2. **Data Connection:** Connect the TX pin of the GPS module to the RX pin of the microcontroller and the RX pin to the TX pin.
3. **Antenna:** Ensure the GPS antenna is properly connected and has a clear view of the sky for optimal performance.

[[UART]]
[[GPS]]

Source:
https://docs.cirkitdesigner.com/component/579238e7-31ac-4c6f-b168-27574dc1cefb/gps-neo-6m
https://lastminuteengineers.com/neo6m-gps-arduino-tutorial/

Tags: #concept 