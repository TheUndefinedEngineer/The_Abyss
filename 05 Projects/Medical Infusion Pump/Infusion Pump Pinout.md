*02/04/2026*

![[rpi_pinout.png]]
## Encoder 1 - Flow rate
| RPI_GPIO | RPI_PIN | ENCODER |
| :------: | :-----: | :-----: |
|   3V3    |    1    |   V+    |
|  Ground  |    6    |   G-    |
|    17    |   11    |   CLK   |
|    27    |   13    |   DT    |
|    22    |   15    |   SW    |
## Encoder 2 - Fault injection
| RPI_GPIO | RPI_PIN | ENCODER |
| :------: | :-----: | :-----: |
|   3V3    |    1    |   V+    |
|  Ground  |    6    |   G-    |
|    23    |   16    |   CLK   |
|    24    |   18    |   DT    |
|    25    |   22    |   SW    |
## Led 1 - Fault Detected
| RPI_GPIO | RPI_PIN |   LED   |
| :------: | :-----: | :-----: |
|    12    |   32    |  Anode  |
|  Ground  |    6    | Cathode |
## Led 2 - Normal Operation
| RPI_GPIO | RPI_PIN |   LED   |
| :------: | :-----: | :-----: |
|    13    |   33    |  Anode  |
|  Ground  |    6    | Cathode |
## Led 3 - Motor Status
| RPI_GPIO | RPI_PIN |   LED   |
| :------: | :-----: | :-----: |
|    16    |   36    |  Anode  |
|  Ground  |    6    | Cathode |


Source:
1. https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio

Tags: #reference  