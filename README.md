# nb_drumcrow  
This is a mod for monome norns that turns a monome crow into a synthesizer using nb. 

`nb` is a note-playing [voice library](https://github.com/sixolet/nb) for norns.  
`nb_drumcrow` is an nb voice that turns each output of a monome crow into a monophonic synthesizer.  
Each output of crow can be triggered individually, in a round robin way as a 4 voice polyphonic synth, or all at once.  
Any output could be set as a CV Trigger, CV Envelope, or CV LFO with optional quantization for pitch sequences.

Requirements: 
- monome norns
- monome crow
- please install [nb](https://github.com/sixolet/nb) on your norns
- then find a norns script that supports nb (pit orchisstra, arcologies, flora, cheat codes 2, washi, rudiments, nkria, dreamsequence, seeker, ...)  

# Installation  
1) Download this like you would any other script by typing `;install https://github.com/entzmingerc/nb_drumcrow` into maiden.  
2) Turn on the mod: navigate to SYSTEM > MODS > nb_drumcrow, turn enc3 to the right until you see a "+". This tells norns to load the mod at the next power on.  
3) Go to SYSTEM > RESTART, restart norns, then check your list of mods. It should have a dot "." to the left of the name indicating the mod has been loaded.  
4) Load a script that supports nb.  
5) Go to the norns params menu and select drumcrow 1, 2, 3, or 4 from your list of nb voices.  
6) Start playing notes using a script with nb support.  

# nb_drumcrow parameters
See [drumcrow](https://github.com/entzmingerc/drumcrow) on lines for documentation of drumcrow parameters.  




Trigger, envelope, and scale presets require the "now" shape and "var_saw" synth model to work as expected, but feel free to experiment.  

For explanation of `synth_shape`, `synth_model`, and the remaining drumcrow parameters, please refer to [drumcrow](https://github.com/entzmingerc/drumcrow) documentation.  

resend code to crow
trigger behavior = {"individual", "round robin", "all"}
param behavior = {"individual", "all"}

synth presets = {'init', 'kick', 'snare', 'hihat', 'CV trigger', 'CV envelope', 'CV scale'}
`synth_preset` selects between init, perc, noise, trigger, envelope, and scale presets. Press `load_preset` to load the selected preset.  
### Presets  
- init: Basic sine wave oscillator with decay envelope. Use for melodic synth stuff or as a starting point.  
- perc: Fast enveloped pitch sweeps for synth percussion sounds. Use for kicks by sending a midi note of like 30 and using this preset.  
- noise: Fast enveloped pitch sweeps using white noise synth model. Use for snares or hats.  
- trigger: CV trigger output. Use to output triggers to modular synths. Adjust amplitude envelope parameters to shape output voltage level, trigger length, etc.  
- envelope: CV envelope output. Triggers voltage envelope. Adjust amplitude envelope parameters to shape output level, curve, rise/fall time, etc.  
- scale: Quantized CV output. Uses `bit` to quantize output voltage to 12 sections per 1V for 1 v/oct inputs. Adjust `bit` slightly to browse different quantization divisions. Adjust all the modulation sources and amplitude parameters (amp_amp, lfo_amp, note_amp) to combine everything into a quantized voltage sequence. Turns the CV envelope preset into a strange arpeggiator.

load preset
synth shape
synth model
max freq
transpose
pulse width
pulse width 2
bitcrush
^^ corvus
splash

amp -> max freq
amp -> osc note
amp -> amplitude
amp -> pulse width
amp -> pulse width 2
amp -> bitcrush
amp cycle time
amp symmetry
amp curve
amp loop
amp reset

lfo -> max freq
lfo -> osc note
lfo -> amplitude
lfo -> pulse width
lfo -> pulse width 2
lfo -> bitcrush
lfo cycle time
lfo symmetry
lfo curve
lfo loop
lfo reset

note -> max freq
note -> osc note
note -> amplitude
note -> pulse width
note -> pulse width 2
note -> bitcrush
note cycle time
note symmetry
note curve
note loop
note reset
