All the Ascension Pod code and instructions are in this repo and the sibling repo here: https://github.com/theicfire/artnet-play. There's a variety of READMEs in various folders.

# LXStudio
Getting started with LXStudio was a struggle, but now that I understand how it works, I'm a big fan! Some quick things worth noting:
- There are two ways to run LXStudio -- via the IDE or via Processing. This uses the Processing direction, because we couldn't figure out how to get the IDE version working. Here are the relevant instructions:
  - LX Studio runs on top of Processing 4. [Download and install Processing 4 &rarr;](https://processing.org/download/)
  - Download LXStudio-P4 and then clone this repo.
  - You may need to install Java as well to get Processing to run.
  - Next, open the LXStudio.pde project in Processing 4 and click Run.
- Some LXStudio references:
  - [LX Studio Wiki &rarr;](https://github.com/heronarts/LXStudio/wiki)
  - [LX Studio API reference &rarr;](http://lx.studio/api/)
  - [Core LXStudio Code](https://github.com/heronarts/LX)
## Notes and Gotchas
- I made a [walkthrough/getting started video](https://www.youtube.com/watch?v=6oLdXEgbOgQ)!
- I don't know where all the LXStudio code is. I.e. I don't know where the UI code is. Maybe it's not open source?
- Note that this repo simply has some pre-built JARs that are used. The only compilation that's running is the patterns you write.
- The LXStudio interface is largely about "live" VJing. You could in theory have this run on a Raspberry Pi, and have a sibling application control it. Probably through OSC? See the midi-to-osc folder on how to do that. I'm not sure what the typically recommended way to do it is.

# Chroma Tech Controller Initial setup
- Plug in power, leds, ethernet, and micro usb cable according to the [datasheet/wiring diagram](https://www.dropbox.com/scl/fi/zt8h76kfujvkiadot2hft/angio-8-spec-sheet_2023-06-26.pdf?rlkey=1cgoomvrvl1kbumfncs4wq463&dl=0)
    
- Share your macbook internet connection
    - Your macbook will probably need an ethernet dongle
    - Go here:

    ![image](https://github.com/cstigler/LXStudio-AscensionPod/assets/442311/6aa6ce7e-c67c-4cce-9d76-f3c690ea5b4e)
    
    - Before turning “internet sharing” on, configure it like this:
        
    ![image](https://github.com/cstigler/LXStudio-AscensionPod/assets/442311/725223e0-e2c6-4d40-8635-267be443baeb)

- Plug in micro usb to the controller
- Now go to [https://config.chroma.tech/config](https://config.chroma.tech/config)
    - connect to the device
    - netstate tab should show ethernet is connected
        - it should give you an ip address. Use that to send data to LX Studio
    - Select the right chipset in the leds tab (Ws2815) .. I picked length 170 but I’m not sure yet if that’s right
    - ethernet needs the following custom config:
        - ip: first: 10.42.0.2, second: 10.42.0.3
        - subnet: 255.255.255.0
        - gateway: 10.42.0.1
    - configure artnet like this:  
      ![image](https://github.com/cstigler/LXStudio-AscensionPod/assets/442311/661cce52-8a67-4b0b-9ca7-672ab3aeb9f4)
    - note: The numbers here are off-by-one from the spec. i.e. “out 1” on the spec is channel 0 on the config UI.
    - note: each power supply is only distributed to 4 ports. You need 2 power supplies to handle 8 LED strips.
    - note: to reset the microcontroller (if it’s hanging or when changing settings just in case), you need to unplug both the microusb and both power supplies. Otherwise it’ll stay on.
    - note: I'm not sure if the length is the number of LED pixels, or the number of channels (3* LED pixels for r, g, b). I presume it's the latter, so you'll actually want to set these to 512 instead.
    - Optional: Set up wifi
    - globals tab
        - brightness - 255
        - target_fps - 60 .. I’m not sure what this does though, this is a guess
- Run LXStudio and you should see the LEDs light up!

# Misc Notes
Charlie's computer couldn't get the custom LXStudio UI working for some reason, so there's a branch called charlie/fix-locally that removes these.
