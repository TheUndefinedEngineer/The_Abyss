*04-04-2026* 

Setup:
```
Encoder 1:  CLK=17  DT=27    → Flow rate
Encoder 2:  CLK=23  DT=24    → Fault injection
LED Red:    GPIO 12          → Fault indicator
LED Green:  GPIO 13          → Normal / active stack
LED Blue:   GPIO 16          → Motor status + takeover blink
```

Architecture - 7 Process:
```
main                → spawns everything, sets up APS
arbiter             → Priority 55, watches both stacks
├── calc_primary    → Priority 20, AP: primary
├── verify_primary  → Priority 30, AP: primary  
├── sensor_primary  → Priority 40, AP: primary
├── calc_standby    → Priority 20, AP: standby
├── verify_standby  → Priority 30, AP: standby
└── sensor_standby  → Priority 40, AP: standby
```

Demo Flow:
```
Start    → Green ON, Blue ON, Red OFF
           Terminal: PRIMARY STACK ACTIVE

Rotate E1 → Flow: 42.3 mL/hr (PRIMARY)

Rotate E2 → Dosage tamper detected
  >5 steps → FAULT → Red ON, others OFF
  Log: response time in µs

Stop E1    → Flow blocked 3s → PRIMARY FAULT
           → Blue blinks twice
           → STANDBY PROMOTED
           → Green still ON
           → Rotate E1 again
           → Flow: 42.3 mL/hr (STANDBY→PRIMARY)
```

---
## !
Sources:

Tags: