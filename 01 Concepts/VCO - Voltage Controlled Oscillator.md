*09-04-2026* 

It is a oscillator whose frequency can be controller by external voltage.

To change frequency in a normal oscillator we need to change values of passive components either resistor, capacitors or inductor. Using variable resistor and capacitors this is achieved.

Easier to tune than regular oscillators

![[vco block diagram.png]]

- Frequency range varies from few Hz to tens of GHz.
---
## Applications
- Phase lock loop - [[PLL — Phase Lock Loop]]
- Modulation and Demodulation Circuits
- Frequency Synthesizers
- Function Generators
---
## Types of VCO's
1. Harmonic Oscillators:
	1. RC Oscillators
	2. LC Oscillators
	3. Crystal Oscillators
	- Any of these can be converted into VCO's by changing the capacitors or resistors with **Varactor Diode** - [[Varactor Diode]]
![[types_example vco.png]]
$$
\large
\begin{align}
\text{RC Osicllator} = f \propto \frac{1}{\sqrt{RC}} \\\\
\text{LC Osicllator} = f \propto \frac{1}{\sqrt{LC}}
\end{align}
$$
- As voltage is increased the capacitance of the *Varactor Diode* will reduce, therefore increasing the control voltage increases the oscillation frequency.
![[freq vs control voltage.png|437]]
$$
\large
f(t) = f_o + K V_c(t)
$$
$$
\large
\text{K is the tuning sensitivity of the VCO} = \frac{Hz}{V} 
$$
1. Relaxation Oscillators: Changing the charging current of capacitor changes the frequency.
$$
\large
I_{ref} \propto V_{Tune}
$$
![[relaxation oscillator.png]]
- Many VCO's use this.
- Uses schmitt trigger - [[Schmitt Trigger]]
---
## Specifications
- Tuning range
- Tuning gain / Tuning Sensitivity : Hz/V
- Supply pushing : Change in the output frequency with the change in the supply voltage - Hz/V
- Load pushing : Change in the output frequency with the change in the load. Maximum deviation form the nominal frequency.
- Spectral Purity : 
	- In frequency domain : Phase noise
	- In time domain : Jitter

---
## !
Sources:
1. https://www.youtube.com/watch?v=EeYL6lJsNT8

Tags: #concept #microcontroller 