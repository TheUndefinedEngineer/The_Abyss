## Why do we need them?

Used for controlling:
- Speed 
- Torque

But the GPIO pins of micro-controllers and SBC(s) can't power them directly so motor driver with _Mosfets_ is need to control them. 
## Types

1. Unidirectional
2. Bidirectional H-Bridge Single channel
3. Bidirectional H-Bridge Dual channel


## Workings

![[Pasted image 20260305092616.png]]
_H-Bridge simple diagram._

![[Pasted image 20260305095412.png|469]]

![[Pasted image 20260305100433.png|592]]


## Definitions

**1. Flyback protection**: refers to measures taken to prevent damage caused by **flyback voltage**, a high-voltage spike that occurs when the current through an inductive load (like a relay coil, solenoid, or motor) is suddenly interrupted.  This voltage spike arises due to the inductor's attempt to maintain current flow, which can cause arcing, component damage, or electrical noise.

**2. Source**: The terminal through which charge carriers (electrons in n-channel, holes in p-channel) enter the channel. It is the origin of current flow in the MOSFET. 

**3. Drain**: The terminal through which charge carriers exit the channel. It is the destination of current flow, and a voltage applied between drain and source drives current through the channel. 

**4. Gate**: The terminal that controls the conductivity of the channel between source and drain. By applying a voltage to the gate, an electric field is created that modulates the channel's charge carrier density, enabling or restricting current flow. The gate is electrically insulated from the channel by a dielectric layer (e.g., silicon dioxide), resulting in extremely high input impedance and negligible gate current.
### 1. Unidirectional 

Hardware used:
- SI 2300 N-Channel Mosfet (Alternates: SI 2302, SI 2304)
- 10K ohm pull down resistor
- Switching diode for fly back protection - Anode connects to mosfet's drain pin. (check polarity using multi-meter in diode mode)
- Small perf-board

![[Pasted image 20260304223427.png|378]]

*Note:* The left pin is the source pin (ground), the top is the drain (power) ,the right pin is the gate pin (signal)

![[Pasted image 20260304225517.png|596]]


### 2. Bidirectional H-Bridge Single CH

**Drives a single motor in both directions.**

Hardware used:
- SI 2300 N-Channel Mosfets
- SI 2301 P-Channel Mosfets (Alternate: SI 2305, RM3401(A19T))
- BC847B (3904) NPN Transistors (Alternates: MMBT2222A(1P))
- 1N4148 Switching Diodes (Flyback)
- 10K ohm resistors
- 1K ohm resistors
- 100 ohm resistors
- 270 ohm resistors

![[Pasted image 20260305092413.png|342]]


![[Pasted image 20260305092343.png|592]]


### 3. Bidirectional H-Bridge Dual CH

**Drives 2 motors in bidirectional with 1 board/circuit**

Hardware used:
- SI 2300 N-Channel Mosfets
- SI 2301 P-Channel Mosfets
- BC847B NPN Transistors
- 1N4148 Switching Diodes (Flyback)
- 10K ohm resistors
- 1K ohm resistors
- 100 ohm resistors


## Higher powered components for H-Bridge

![[Pasted image 20260305094134.png|441]]


Sources:
1. https://www.youtube.com/watch?v=xW2Nwg_RX84&list=TLPQMDQwMzIwMjaJVe-keTEU5w&index=2
2. https://search.brave.com/search?q=source+drain+gate&summary=1&conversation=08cee557f8b53daf8e074664626eb20de40f
3. https://search.brave.com/search?q=what+is+fly+back+protection&summary=1&conversation=08ce94a575904ebf99e0dd4218da412e40ab


#concept