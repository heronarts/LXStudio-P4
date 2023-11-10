This allows you to control LXStudio from a MIDI controller (like the Pioneer DJ in my case). In effect, it simply gives you some knobs to twist and buttons to press.

# Setup
- MacOS should automatically recognize the pioneer DJ as a midi device. No drivers needed!
- Run `pip install python-rtmidi python-osc`
- python main.py
- Ensure LXStudio is listening to OSC (to right, there's an OSC tab, make sure RX is enabled. Pick the right ports)

# Other Notes
There's a CLI application that allows you to send OSC commands that I also got working, which is worth mentioning:
- Install: `brew install liblo`
- Usage: `oscsend localhost 3030 /lx/mixer/channel/6/pattern/1/motion/periodfast f 0.9`
