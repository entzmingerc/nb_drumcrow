# nb_drumcrow  
caw caw caw  

This norns mod can set each output of a monome crow to be an oscillator, CV trigger, or CV envelope using nb.  
`nb` is a note-playing [voice library](https://github.com/sixolet/nb) for norns.  
`nb_drumcrow` is turns each output of a monome crow into a [drumcrow oscillator](https://github.com/entzmingerc/drumcrow).  

# Installation  
1) Download this like you would any other script by typing `;install https://github.com/entzmingerc/nb_drumcrow` into maiden.  
2) Turn on the mod: navigate to SYSTEM > MODS > nb_drumcrow, turn enc3 to the right until you see a "+". This tells norns to load the mod at the next power on.  
3) Go to SYSTEM > RESTART, restart norns, then check your list of mods. It should have a dot "." to the left of the name indicating the mod has been loaded.  
4) Find a script that supports nb. Might I suggest [dreamsequence](https://github.com/dstroud/dreamsequence)?  
5) Go to the norns params menu and select drumcrow 1, 2, 3, or 4 from your list of nb voices.  
6) Start playing notes using a script with nb support.  

# nb_drumcrow parameters
See [drumcrow](https://github.com/entzmingerc/drumcrow) on lines for documentation of drumcrow parameters.  

`ON/OFF` turns the engine on or off. It is ON by default. This will remove the output from the updating loop and set the amplitude to 0.  
`synth_preset` selects between init, perc, noise, trigger, envelope, and scale presets. Press `load_preset` to load the selected preset.  

### Presets  
- init: Basic sine wave oscillator with decay envelope. Use for melodic synth stuff or as a starting point.  
- perc: Fast enveloped pitch sweeps for synth percussion sounds. Use for kicks by sending a midi note of like 30 and using this preset.  
- noise: Fast enveloped pitch sweeps using white noise synth model. Use for snares or hats.  
- trigger: CV trigger output. Use to output triggers to modular synths. Adjust amplitude envelope parameters to shape output voltage level, trigger length, etc.  
- envelope: CV envelope output. Triggers voltage envelope. Adjust amplitude envelope parameters to shape output level, curve, rise/fall time, etc.  
- scale: Quantized CV output. Uses `bit` to quantize output voltage to 12 sections per 1V for 1 v/oct inputs. Adjust `bit` slightly to browse different quantization divisions. Adjust all the modulation sources and amplitude parameters (amp_amp, lfo_amp, note_amp) to combine everything into a quantized voltage sequence. Turns the CV envelope preset into a strange arpeggiator.  

Trigger, envelope, and scale presets require the "now" shape and "var_saw" synth model to work as expected, but feel free to experiment.  

For explanation of `synth_shape`, `synth_model`, and the remaining drumcrow parameters, please refer to [drumcrow](https://github.com/entzmingerc/drumcrow) documentation.  

# nb_drumcrow scripting example  
This section is an example of how to support nb in a norns script.  

To support nb in a norns script, refer to [nb](https://github.com/sixolet/nb) for the most up to date information. nb_drumcrow creates an nb player for each of the four outputs on crow. Use `nb:add_param("nb_1", "nb_1")` to create a nb voice selector parameter called "nb_1" or any name you'd like. The following code looks up the player selector parameter "nb_1" and returns the player currently selected. Next, the note_on() function of the player is called and passed the midi note value 60 and velocity 5.  
```
local player = params:lookup_param("nb_1"):get_player()
player:note_on(60, 5)
``` 
The above code will trigger a single note for one player. To play nb_drumcrow polyphonically using all 4 outputs of crow, create 4 nb voice selector parameters (for example: nb_1, nb_2, nb_3, nb_4), set each to drumcrow 1, 2, 3, and 4, then get each player, then trigger the note_on() function on each player. Each nb_drumcrow player is monophonic, so it only plays one note at a time on a single output of crow.  

# nb_drumcrow debugging
Crow should be powered on before loading the norns script. Crow should be connected to norns via USB. If you're not hearing sound, try changing model and shape of the drumcrow oscillator to hopefully wake it up. If you crash crow and hear a constant tone, you'll have to turn off power to crow and turn it on again. If crow hasn't crashed, but won't stop audio, use the on/off parameter to silence an output of crow. This will stop the update loop from running. If a norns script uses crow for different functionality, the script may overwrite the nb_drumcrow setup of the crow outputs. Currently, nb_drumcrow is set up to use all 4 outputs of crow upon initialization of the mod. You can selectively remove an output from nb_drumcrow setup. For example, removing the `add_drumcrow_player(3)` line from the mod.lua file in the pre_init function would skip that crow output. Then, outputs 1, 2, and 4 could be used for nb_drumcrow, and output 3 is free to use for any purpose.  
