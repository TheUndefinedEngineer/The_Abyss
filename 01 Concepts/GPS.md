## **How does GPS work?**

GPS (Global Positioning System) is a satellite-based navigation system that helps your phone or GPS device figure out exactly where you are on Earth.

There are at least 24 special satellites orbiting Earth in the GPS constellation. These satellites constantly broadcast radio signals down to Earth. Each signal contains two important pieces of information: the satellite’s exact position in space and the precise time when the signal was sent.

Your GPS device listens for these signals coming from the satellites. When your device receives a signal, it calculates how long it took that signal to travel from the satellite to your device. Since radio waves travel at the speed of light, your device can use that time to figure out how far away each satellite is.

Here’s where it gets interesting! By knowing its distance from at least three different satellites, your GPS device can pinpoint your location through a process called **Trilateration**. Think of it this way: each distance measurement creates an imaginary sphere around each satellite. Your location is the exact point where all these spheres intersect.

![How GPS Works - Trilateration Process](https://lastminuteengineers.com/wp-content/uploads/arduino/how-gps-works-trilateration-process.png)

In real-world GPS systems, a fourth satellite is usually included for even better accuracy. This extra satellite helps correct any timing errors in your device’s internal clock. Even microsecond timing mistakes can throw off your position by hundreds of feet! With four satellites working together, your GPS can tell you not just where you are on a map (latitude and longitude), but also your altitude—how high above sea level you are.

Source: https://lastminuteengineers.com/neo6m-gps-arduino-tutorial/

#concept