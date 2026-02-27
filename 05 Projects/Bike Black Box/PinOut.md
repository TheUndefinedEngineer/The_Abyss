
## MPU6050(IMU)

| MPU Pin | Connects To STM32  |
| :-----: | :----------------: |
|   VCC   |        3.3V        |
|   GND   |        GND         |
|   SDA   |        PB7         |
|   SCL   |        PB6         |
|   INT   |   PA0(Optional)    |
|   AD0   | 3.3V(Address 0x69) |
## NEO-6M GPS

| GPS Pin | Connects To STM32 |
| :-----: | :---------------: |
|   VCC   |       3.3V        |
|   GND   |        GND        |
|   TX    |        PA3        |
|   RX    |        PA2        |
|   PPS   |     Optional      |
## DS3231 RTC Module

| RTC  Pin | Connects To STM32 |
| :------: | :---------------: |
|   VCC    |       3.3V        |
|   GND    |        GND        |
|   SDA    |        PB7        |
|   SCL    |        PB6        |
|   SQW    |     Optional      |
|   32K    |   Not required    |
## SSD1306 OLED

| OLED Pin | Connects To STM32 |
| :------: | :---------------: |
|   VCC    |       3.3V        |
|   GND    |        GND        |
|   SDA    |        PB7        |
|   SCL    |        PB6        |
## MicroSD Card Module

| SD Pin | Connects To STM32 |
| :----: | :---------------: |
|  VCC'  |       3.3V        |
|  GND   |        GND        |
|  CLK   |        PA5        |
|  MISO  |        PA6        |
|  MOSI  |        PA7        |
|   CS   |        PA4        |
## Ignition Detection

|   Divider Ouput   | Connects To STM32 |
| :---------------: | :---------------: |
| Middle of 33k/10k |        PB9        |
## Power Pins

| Input Pins  | Output Pins |
| :---------: | :---------: |
|    12V+     | TP4056 IN+  |
|    12V-     | TP4056 IN-  |
|  TP4056 B+  |   18650 +   |
|  TP4056 B-  |   18650 -   |
| TP4056 OUT+ | LM2596 IN+  |
| TP4056 OUT- | LM2596 IN-  |
| LM2596 OUT+ | STM32-3.3V  |
| LM2596 OUT- |  STM32-GND  |
