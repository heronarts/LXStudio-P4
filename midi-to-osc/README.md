- MacOS should automatically recognize the pioneer DJ as a midi device. No drivers needed!
- Run `pip install python-rtmidi python-osc`
- python main.py
- Ensure LXStudio is listening to OSC (to right, there's an OSC tab, make sure RX is enabled. Pick the right ports)

This should read from the PioneerDJ, print stuff out, and in some cases send to LXStudio via OSC. YAY!
