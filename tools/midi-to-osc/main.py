import rtmidi
from pythonosc import udp_client

# Set up MIDI input
midi_in = rtmidi.MidiIn()
print('go open midi')
midi_in.open_port(0)  # Assuming your DJ board is the first MIDI device
print('opened midi')

# Set up OSC client
osc_client = udp_client.SimpleUDPClient(
    "127.0.0.1", 3030)  # OSC target IP and port

valid_ccs = [4, 7, 11, 15, 23, 19, 8, 13, 31, 48, 49, 50, 52, 53, 54]
osc_mapping = {
        4: '/lx/mixer/channel/2/fader',
        7:  '/lx/mixer/channel/3/fader',
        8:  '/lx/mixer/channel/3/pattern/1/sweepPeriod',
        11:  '/lx/mixer/channel/4/fader',
        15:  '/lx/mixer/channel/5/fader'
        }

def handle_midi_message(message, data=None):
    # print('xxgot message', message)
    control, time = message
    status, cc, value = control
    if cc in valid_ccs:
        print(cc, value)
    for osc_value, osc_path in osc_mapping.items():
        equal = cc == osc_value
        print('compare', type(cc), type(osc_value), cc, osc_value, equal)
        if equal:
            print(f'set cc: {cc} to {value}')
            osc_value = value / 127.0
            osc_client.send_message(osc_path, osc_value)


midi_in.set_callback(handle_midi_message)

try:
    while True:
        pass
except KeyboardInterrupt:
    pass
finally:
    midi_in.close_port()
