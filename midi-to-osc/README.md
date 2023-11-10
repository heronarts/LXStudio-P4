This allows you to control LXStudio from a MIDI controller (like the Pioneer DJ in my case). In effect, it simply gives you some knobs to twist and buttons to press.

# Setup
- MacOS should automatically recognize the pioneer DJ as a midi device. No drivers needed!
- Run `pip install python-rtmidi python-osc`
- python main.py
- Ensure LXStudio is listening to OSC (to right, there's an OSC tab, make sure RX is enabled. Pick the right ports)

