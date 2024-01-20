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
osc_mapping1 = {
    4: '/lx/mixer/channel/1/fader',
    7:  '/lx/mixer/channel/2/fader',
    8:  '/lx/mixer/channel/5/pattern/1/sweepPeriod', # to the side
    11:  '/lx/mixer/channel/3/fader',
    15:  '/lx/mixer/channel/6/fader', # m1
    23: '/lx/mixer/channel/9/fader', # m2
    # 19: '/lx/mixer/channel/12/fader', # m3
    13: '/lx/mixer/channel/12/fader', # m3
}

osc_mapping2 = {
    4: '/lx/mixer/channel/15/fader', # m3.3
    7:  '/lx/mixer/channel/16/fader',
    # 8:  '/lx/mixer/channel/16/fader',
    11:  '/lx/mixer/channel/19/fader',
    15:  '/lx/mixer/channel/20/fader',
    23: '/lx/mixer/channel/21/fader',
    19: '/lx/mixer/channel/13/fader', # m3.1
    13: '/lx/mixer/channel/12/fader', # m3
}
osc_mappings = [osc_mapping1, osc_mapping2]
osc_index = 0

SWITCH_CC = 64

def handle_midi_message(message, data=None):
    global osc_index
    # print('xxgot message', message)
    control, time = message
    status, cc, value = control
    print(cc, value)
    if cc == SWITCH_CC:
        print('Possibly switch sides!')
        if value == 1:
            osc_index = 1
        else:
            osc_index = 0
        return
    # print('hi')
    # import pdb; pdb.set_trace()
    # print(len(osc_mappings[osc_index]))
    # print('there')
    # if cc in valid_ccs:
        # print(cc, value)
    for osc_value, osc_path in osc_mappings[osc_index].items():
        equal = cc == osc_value
        if equal:
            print(f'set cc: {osc_path} to {value}')
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
