# nb_drumcrow  
caw caw caw  
this is a norns mod  
it turns a each output of crow into an oscillator, CV trigger, or CV envelope using nb  
`nb` is a note-playing [voice library](https://github.com/sixolet/nb) for norns.  
`nb_drumcrow` is turns each output of a monome crow into a [drumcrow oscillator](https://github.com/entzmingerc/drumcrow)  

# Installation  
1) download this like you would any other script  
2) turn on the mod: go to system > mods > find nb_drumcrow, turn enc3 to the right until you see a +. this tells norns to load the mod at the next power ON  
3) go to system > restart and then check the mods, it should have a dot . to the left of the name indicating the mod has been loaded  
4) find a script that supports nb  
5) go to your params and select drumcrow from your nb voices  
6) start playing notes using a script with nb support. (...by calling player:note_on() like you would for other nb voices)  

# nb_drumcrow parameters
see [drumcrow](https://github.com/entzmingerc/drumcrow) on lines for documentation of drumcrow parameters.  

`ON/OFF` turns the engine on or off. It is ON by default. This will remove the output from the updating loop and set the amplitude to 0.  
`synth_preset` selects between init, perc, noise, trigger, envelope, and scale presets. Press `load_preset` to load the selected preset.  
Presets:  
- init: basic sine wave oscillator with decay envelope. Use for melodic synth stuff or as a starting point.  
- perc: fast enveloped pitch sweeps for synth percussion sounds. Use for kicks by sending a midi note of like 30 and using this preset.  
- noise: fast enveloped pitch sweeps using white noise synth model. Use for snares or hats.  
- trigger: CV trigger output. Use to output triggers to modular synths. Adjust amplitude envelope parameters to shape output voltage level, trigger length, etc.  
- envelope: CV envelope output. Triggers voltage envelope. Adjust amplitude envelope parameters to shape output level, curve, rise/fall time, etc.  
- scale: Quantized CV output. Uses `bit` to quantize output voltage for 1 v/oct inputs. Adjust `bit` to browse different quantization divisions. Adjust all the modulation sources and amplitude parameters (amp_amp, lfo_amp, note_amp) to combine everything into a quantized voltage sequence. Turns the CV envelope mode into a strange arpeggiator.  

Trigger, envelope, and scale presets require the "now" shape and "var_saw" synth model to work as expected, but feel free to experiment.  

For explanation of `synth_shape`, `synth_model`, and the remaining drumcrow parameters, please refer to [drumcrow](https://github.com/entzmingerc/drumcrow) documentation.  

# nb_drumcrow scripting example  
To support nb in a norns script, refer to [nb](https://github.com/sixolet/nb) for the most up to date information. nb_drumcrow creates an nb player for each of the four outputs on crow. To add nb support in a norns script, the nb library needs to be included in the script `nb = include("lib/nb/lib/nb")`. In the init function, call `nb:init()` then `nb:add_param("nb_1", "nb_1")` to create a nb player selector parameter called "nb_1" or any name you'd like. Then call `nb:add_player_params()` to add all nb players to the nb player selector parameter. Go to "nb_1" in the parameter menu and select "drumcrow 1" as the player.  

To trigger an nb voice, call the nb player's note_on() function. The following code looks up the player selector parameter "nb_1" and returns the player currently selected. Next, the note_on() function of the player is called and passed the midi note value 60 and velocity 5.  
```
local player = params:lookup_param("nb_1"):get_player()
player:note_on(60, 5)
``` 
The above code will trigger a single note for one player. To play nb_drumcrow polyphonically using all 4 outputs of crow, create 4 player selector parameters (for example: nb_1, nb_2, nb_3, nb_4), then get each player and trigger the note_on() function on each player. Each nb_drumcrow player is monophonic, so it only plays one note at a time on a single output of crow.  

# nb_drumcrow debugging
Crow should be powered on before loading the norns script. If you're not hearing sound, try changing model and shape of the drumcrow oscillator to hopefully wake it up, CAW! If you crash crow and hear a constant tone, you'll have to turn off power to crow and turn it on again. If crow hasn't crashed, but won't stop audio, use the on/off switch to silence an output of crow.  

# nerdy rambling about how drumcrow code works that you don't need to read  
drumcrow engine works continuously updating the ASL outputs on crow. It updates the outputs roughly every 0.006 seconds. Each update applies the current value of the note, amp, and lfo modulation sources to the crow output. The standalone version of drumcrow (used with druid or teletype) seems to have smoother envelopes and lfos, whereas the nb_drumcrow version the envelopes are not updated nearly as often so the envelopes and lfo can't oscillate as fast and are steppier at higher frequencies. I'm not sure why, but ultimately the better design would be to scrap the this style of engine and try to do as much as possible inside the ASL table as possible using dynamic variables and mutators. Triggers, sequencers, step changing control rate modulation could be done from a lua updating loop, but for snappier envelopes and audio rate lfos, a solution inside of ASL would yield smoother modulation and better sounds I think. Decay envelopes can be created by multiplying decimal values less than 1. A simple rising ramp LFO could be created using mutators step and wrap.  
