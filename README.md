# nb_drumcrow  
This is a mod for monome norns that turns a monome crow into a synthesizer using nb. It can also be uploaded to crow to work in standalone operation using teletype to sequence it over i2c.  

### Features:
- 4 monophonic synthesizers, one for each output of crow.  
- Can trigger each individually, round robin (4 voice polysynth), or all simultaneously (monophonic 4 voice synth).  
- Can use 2 crows connected via i2c to create an 8 voice version.  
- Each output can trigger 1 or more additional voices for paired operation (v/oct & gate).  
- Can be sequenced with any norns script that supports nb, teletype, or druid.  
- Each output can be set to synthesize audio, gate/trigger, envelope, V/Oct CV signal quantized to a scale, or convert the midi note from nb to a V/Oct CV value.  
- Each output has 3 cycling envelope modulation sources which map to 7 destinations.  
- Crow output voltage quantizer used as wide ranging bitcrusher distortion.  
- Saturation, PWM, global detune, vibrato, FM, and other fun experimental crow synthesis.  

# Requirements: 
- monome crow
- monome norns (if you want to use it as nb voice)
- please install [nb](https://github.com/sixolet/nb) on your norns
- then find a norns script that supports nb (pit orchisstra, arcologies, flora, cheat codes 2, washi, rudiments, nkria, dreamsequence, seeker, ...)  
- upload the update_loop.lua file to crow for standalone use and use teletype to sequence it

# Installation  
1) Download this like you would any other script by typing `;install https://github.com/entzmingerc/nb_drumcrow` into maiden.  
2) Turn on the mod: navigate to SYSTEM > MODS > nb_drumcrow, turn enc3 to the right until you see a "+". This tells norns to load the mod at the next power on.  
3) Go to SYSTEM > RESTART, restart norns, then check your list of mods. It should have a dot "." to the left of the name indicating the mod has been loaded.  
4) Load a script that supports nb.  
5) Go to the norns params menu and select drumcrow 1, 2, 3, or 4 from your list of nb voices.  
6) Start playing notes using a script with nb support.  

# Usage
TODO Basic instructions on how to use the synthesizer

`nb` is a note-playing [voice library](https://github.com/sixolet/nb) for norns.  
`nb_drumcrow` is an nb voice that turns each output of a monome crow into a monophonic synthesizer.  
Each output of crow can be triggered individually, in a round robin way as a 4 voice polyphonic synth, or all at once.  
Any output could be set as a CV Trigger, CV Envelope, or CV LFO with optional quantization for pitch sequences.

TODO how do set up 

# Parameters

## Settings

Default parameter values are the values loaded using the init preset.  
TODO global detune, trigger behavior, param behavior  

| Parameter | Description | Range | Default |
|-----------|-------------|-------|---------|
| resend code to crow | (GLOBAL) reuploads audio engine code to run on crow | BUTTON | not pressed |
| param behavior | (GLOBAL) set this player or all players when changing a value | individual, all | individual |
| trigger behavior | (GLOBAL) controls what to do with note on trigger | individual, round robin, all | individual |
| global detune | (GLOBAL) multiplier to all channel frequencies, channel 1 frequency | -0.5, 1.0 | 0 |
| synth preset | selects which preset to load | see synth presets | init |
| load preset | loads the synth preset | BUTTON | not pressed |

## Oscillator

TODO  birdsong, flock size, midi note -> amp, etc all the others, list the modulation destinations here

| Parameter | Description | Range | Default |
|-----------|-------------|-------|---------|
| synth shape | affects tone, sets voltage path between to() calls in ASL model | 1-9 | sine |
| synth model | different ASL models that are oscillating | 1-7 | var_saw |
| birdsong | The transposition sequence, stepped each note on | see species | off |
| flock size | number of voices triggered during note on | 1-4 | 1 |
| midi note -> amp | Converts midi note to amplitude for outputting v/oct | off, on | off |
| max freq | limits the maximum oscillator frequency | 0.01, 1 | 1 |
| transpose | offsets the midi note | -120, 120 | 120 |
| pulse width | functionality changes with ASL model | -1, 1 | 0 |
| pulse width 2 | functionality changes with ASL model | -10, 10 | 0 |
| ^^bitcrush (v/oct) | crow output scaling amount, volts per octave | -10, 60 | 0 |
| ^^mutate | multiplier of each value in corvus scale | -5, 5 | 1 |
| ^^corvus | scale to quantize output voltage to | see species | off (chromatic) |
| ^^amp limit pre-bit | limits amplitude before bitcrusher | ±0, ±1, ±5, ±10, ±20, ±40 | ±10 |
| splash | amount of randomness applied to the frequency | 0, 3 | 0 |

## Envelopes (Amp, LFO, Note)

The 3 envelopes, `amp`, `lfo`, and `note` are functionally identical, but have different values when loading the init preset.  
`amp` modulates amplitude by 1.0, loop is off, and reset is on. `lfo` loop is on and reset is off. `note` loop is off and reset is on.  

| Parameter | Description | Range | Default |
|-----------|-------------|-------|---------|
| amp -> max freq | modulation depth of maximum frequency | -1, 1 | 0 |
| amp -> osc note | modulation depth of oscillator frequency | -5, 5 | 0 |
| amp -> amplitude | modulation depth of amplitude | -5, 5 | 1 for amp only |
| amp -> pulse width | modulation depth of pulse width | -2, 2 | 0 |
| amp -> pulse width 2 | modulation depth of pulse width 2 | -10, 10 | 0 |
| amp -> bitcrush | modulation depth of bitcrush | -10, 60 | 0 |
| amp -> mutate | modulation depth of bitcrush | -10, 10 | 0 |
| amp cycle freq | how quickly the envelope rises and falls | 0.1, 200 | various |
| amp symmetry | ratio rise time to fall time | -1, 1 | amp & note: -1, lfo 0 |
| amp curve | shape of rise & fall, -5 square, 0 linear, 5 exponential | -5, 5 | amp 1, lfo 0, note 4 |
| amp loop | if on: envelope begins again after fall is complete | off, on | amp & note: off, lfo on |
| amp reset | if on: envelope resets from the start of rise during note on | off, on | amp & note: on, lfo off |

![symmetry and curve](https://github.com/entzmingerc/nb_drumcrow/blob/main/pics/envelope_properties.png?raw=true)  

Each envelope has the same set of modulation targets, modulation depth ranges, and envelope parameters. The modulation depth adds to the current value of the parameter it is modulating (except for amplitude). For example: pulse width at 0.4, lfo -> pulse width modulation depth at 0.2, then you'll hear pulse width modulate back and forth between 0.4 and 0.6. For modulation depth -0.8, you'd hear 0.4 to -0.4. For amplitude, if amplitude modulation depth is 0 for all envelopes then you'll hear silence.  

TODO symmetry, curve, loop, resetz


## Bitcrusher

9 species of drumcorvus have been discovered so far.  

| Species | Scale |
|-----------|-------------|
| off | (chromatic) |
| cornix | 0, 2, 4, 5, 7, 9, 11 (major) |
| orru | 0, 2, 3, 5, 7, 9, 10 (minor) |
| kubaryi | 0, 3, 5, 7, 10, 12, 15 (minor pentatonic) |
| corone | 0, 11, 9, 7, 5, 4, 2 |
| levaillantii | 0, 7, 12, 5, 0, 5, 12 |
| culminatus | 0, 7, 12, 24, -12, 0, 12 |
| edithae | 0, 24, 5, 22, 7, 19, 12 |
| florensis | 0, 17, -17, 0, -17, 17, 12 |
| brachyrhynchos | 0, -7, -10, 12, 24, 17, 12 |

![bitcrush](https://github.com/entzmingerc/nb_drumcrow/blob/main/pics/bitcrush.png?raw=true)  

The bitcrusher uses crow output [quantizer](https://monome.org/docs/crow/reference/#quantize-to-scales) to do distortion. The bitcrush value is the scaling variable, so a value of 1.0 results in 1 volt per octave quantization of the output voltage. Any oscillator with bitcrush at 1.0 when slowed down could be used as a v/oct sequence. Temperament is fixed to 12. The scale used for quantization is chosen from the species list. The first 4 species are chromatic, major, minor, and minor pentatonic. Scale values can be out of order to create arpeggios, but also scales can be much longer than 12 notes and have note values well outside the range 0 - 12.  

The range of voltage for each octave is defined by bitcrush. Each octave is divided evenly into a number of sections equal to the number of notes in the scale. For any given voltage, first you find the section it is in, then crow calculates the quantized voltage based on the note. Metaphorically, it applies the shape of the scale across the v/oct range. For example, the shape of the stairstep voltage waveform that occurs between 0V and 1V when quantizing to a major scale if bitcrush is 1 v/oct would be stretched across the voltage range 0V and 5V if bitcrush is set to 5 v/oct. For this reason, a variety of scales can be used to significantly change the tone of the bitcrushing. Feel free to alter the scales yourself, but there needs to be a strict length of 7 values in the scale!  

An amplitude modulation depth of 1 for maximum velocity results in an oscillator amplitude of ±5 V. Crow hardware is limited to -5 V and 10 V. The `amp limit pre-bit` parameter sets the maximum range of voltage that drumcrow will request. It defaults to ±10 V. By increasing the amplitude modulation depth to 2, you can increase the oscillator amplitude to ±10 V and crow will clip the bottom part of the waveform. By setting `amp limit pre-bit` parameter to ±20 V or ±40 V and increasing the amplitude modulation depth even more, you can clip both the top and bottom parts of the waveform for a more overdriven tone. The combination of multiple envelopes modulation amplitude and bitcrush values between 0 and 5 can generate a lot of varied distortion tones.  

![mutate](https://github.com/entzmingerc/nb_drumcrow/blob/main/pics/mutate.png?raw=true)  

Mutate is used with bitcrush and corvus. Mutate will multiply all values of the corvus species scale up to a value of +/- 24. At mutate = 1, the values of the corvus scale are unchanged. At mutate = 0, the scale values are evenly distributed across the v/oct range. If mutate multiplies a scale value to above 24, it will start to decrease negatively below 24 by 4 times the rate. Similarly values below -24 will increase positively at 4 times the rate. This creates a lot of variation in the distortion tone when using high mutate values or when modulating mutate. Modulating between -1 and +1 there will be a small change in tone but not much change in distortion. Modulating to values above 1 or below -1 will give dramatically more distortion and interesting tones. Try using LFO to slowly modulate mutate to hear "wavetable" type tones.  

Synth shapes `logarithmic` and `exponential` shapes have unique mutate behavior. This will multiply the absolute value of mutate and the temperament (12) of the quantizer. So when mutate approaches zero, there's an interesting spike in distortion as the temperament of the quantizer approaches 0. Try modulating mutate through 0 to hear the bitcrush amount swell in and out with distortion.  

## Synth Shapes

These are the shapes from the [crow reference](https://monome.org/docs/crow/reference/#shaping-cv). These are also known as "easing functions". 

| Shapes | Description |
| ------ | ----------- |
| linear | triangle, saw, connect the dots /\/ |
| sine | sine, looks like half a sine wave (default) |
| logarithmic | fast rise, slow settle |
| exponential | slow rise, fast settle |
| now | square, go instantly to the destination then wait |
| wait | square, wait at the current level, then go to the destination |
| over | move toward the destination and overshoot, before landing |
| under | move away from the destination, then smoothly ramp up |
| rebound | emulate a bouncing ball toward the destination |

![shapes](https://github.com/entzmingerc/nb_drumcrow/blob/main/pics/synth_shape.png?raw=true)  

Using the `var_saw` synth model in the init preset, it's easy to hear how shape affects the tone of the oscillator. Linear is a triangle wave, and using `pulse width` it can be turned into sawtooth wave. Sine is a sine wave. Now and wait are both square waves but have opposite polarity. Rebound introduces higher frequency components with the extra bounces in the waveform.  

The `var_saw` ASL model can be turned into a constant voltage source using `now` shape and `pulse width` set to 1. Then, the amplitude of the oscillator can be used to sequence CV for triggers, envelopes, and v/oct signals. 

## Synth Models

Each drumcrow oscillator must have a `dyn{dcAmp=0}` in its ASL model. Other dyns like `cyc`, `pw`, and `pw2` are used as well to create the ASL models. These are the parameters being updated by the 3 modulation envelopes. Each ASL model is built around the `loop{ <asl> }` construct which restarts the sequence once it's complete. The primitive `to( destination, time, shape )` is used to construct each section of the ASL model. By setting time to a small enough value using `cyc`, the output voltage of crow can oscillate at audio rates. Oscillator frequency, splash, transpose, and max frequency are used to calculate the value of `cyc`. Amplitude interacts with `dcAmp`. Pulse width interacts with `pw`. Pulse width 2 interacts with `pw2`. Lua updates the dyn variables at a rate of approximately 100 Hz, but crow synthesizes the audio at 48 kHz. 

| Dyns | Description |
| ----- | --------- |
| dcAmp | Controls amplitude of the voltage |
| cyc | Controls update rate of the ASL loop |
| pw | pulse width, function changes with each ASL model |
| pw2 | pulse width 2, function changes with each ASL model |

![shapes](https://github.com/entzmingerc/nb_drumcrow/blob/main/pics/synth_models.png?raw=true)  

**var_saw**  
```
loop{
    to(  dyn{dcAmp=0}, dyn{cyc=1/440} *    dyn{pw=1/2} , shape), 
    to(0-dyn{dcAmp=0}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)
}
```
To understand drumcrow is to understand var_saw. This is the default ASL model. It's an [LFO](https://github.com/monome/crow/blob/main/lua/asllib.lua) with pulse width and dynamic variables. Use shape to adjust waveform: linear is triangle, sine is sine, now or wait is square. Select any shape 1-9 to hear different tones. A `pulse width` value of 1 will result in a time of 0 sec for the second `to{}` in the ASL model, thus it will only output a constant positive voltage. Similarly, if `pulse width` is -1 then it will be a negative voltage.  

**bytebeat**  
```
loop{ 
    to(dyn{x=1}:step(dyn{pw=1}):wrap(-10,10) * dyn{dcAmp=0}, dyn{cyc=1}, shape)
}
```  
Output voltage is stepped by `pw` each loop and wrapped between -10 ... 10. Crow hardware limit is -5 to +10V. `cyc` determines how often the ASL model loops. `pw` determines how much the voltage changes each time the ASL loops. Thus, both `pw` and `cyc` affect the resulting oscillation frequency. `pw` is calculated by multiplying the `pulse width` and `pulse width 2` param values.  

**noise**  
```
loop{
    to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-5,5) * dyn{dcAmp=0}, dyn{cyc=1}, shape)
}
```  
This is an [LCG](https://en.wikipedia.org/wiki/Linear_congruential_generator) used to create a sequence of pseudorandom numbers. This implements the equation: `x(n+1) = ((x * pw2) + pw) % 10`. Set `pw` to 0.5 and `pw2` to a value around 5 to get some noise. Small positive values of both `pw` and `pw2` can yield some interesting sounds near zero. Use transpose or higher pitches to generate higher frequency noises. Use short amplitude envelope cycle times for high hats and snares. Use low frequency values for a stream of random CV voltages.  

**FMstep**  
```
loop{
    to(  dyn{dcAmp=0}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
    to(0-dyn{dcAmp=0}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)
}
```  
This expands the `var_saw` model to multiply `cyc` by `x` that sweeps between 1 and 2 at a speed set by `pw2`. Low `pw2` values modulate the frequency slowly, high `pw2` values results in a more FM type sound.  

**ASLsine**  
```
loop{
    to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{dcAmp=0}, dyn{cyc=1}, shape)
}
```  
This is a root-product sine wave approximation y = x + 0.101321(x)^3. The `var_saw` model creates a waveform by picking two voltage points to move between. If we wanted to step through a custom waveform, we would have to make 100 ASL stages and step through them all. Instead, we can loop one ASL stage, and step `x` by `pw` and wrap it between -pi and +pi. This roughly traces out a sine wave. `x` is stepped each time it's referenced in the ASL model. The time it takes to step `x` to its next value is determined by `cyc`.  

**ASLharmonic**  
```
loop{
    to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{dcAmp=0}, dyn{cyc=1}, shape)
}
```  
Same as ASLsine but we add a `mul(-1)` to `x` so each time `x` is called, the polarity flips. Slightly more chaotic, try exploring `pw2` values to hear different tones.  

**bytebeat5**  
```
loop{
    to(dyn{x=0}:step(dyn{pw=0.1}):wrap(0, 10) % dyn{pw2=1} * dyn{dcAmp=0}, dyn{cyc=1}, shape)
}
```
Another bytebeat model. `pw` sets the step rate. `pw2` sets the modulo range. `cyc` is the "sample rate" of the bytebeat shape.  

## Synth Presets  

In the param menu, navigate to synth preset to select the preset you'd like to load. Then navigate to `load preset` and press KEY 3 to load the selected preset. `init` is a sine wave oscillator with a short decay envelope oscillating between +/- 5 V. This is the default preset loaded to all outputs. Kick transposes down -24 steps and utilizes the note envelope to quickly sweep the oscillator frequency from high to low emulating a kick drum sound. Snare and hihat both utilize the noise synth model and have short amplitude decay envelopes.  

The CV presets allow drumcrow to be used as a CV source. Each utilizes var_saw with a pulse width of 1 to create a constant voltage output, then uses the envelopes to modulate the amplitude of the synth model. CV Trigger is set up to be a short square ish trigger or gate if the amp cycle freq is lengthened. CV Envelope is a rise / fall envelope. CV Scale sets bitcrush to 1 v/oct and maps the midi note to the amplitude of the synth model. All 3 envelopes can be used simultaenously for making various modulation signals. Try combining looping envelopes each modulating amplitude at different rates using CV Scale to create quantized chromatic lfos, or pick a scale to quantize to using ^^corvus.  

| Preset | Description |
| ----- | -------- |
| init | Sine wave oscillator with decay envelope |
| kick | Basic synth kick drum, useful for bass patches too |
| snare | Digital noise snare drum |
| hihat | Short noise pluck |
| CV trigger | CV gate / trigger, use amp cycle freq for gate length |
| CV envelope | rise / fall envelope using all 3 envelopes |
| CV scale | voltages quantized to 1 v/oct |

TODO more explanation  

## Teletype Operation  

It's just `CROW.C4`. Many params require decimal values, but teletype and crow don't seem to send decimal values over i2c. To get around this, I decided to multiply each value I send by 100, so a decimal value 0.01 becomes 1. Then when crow receives the value, it divides it by 100. On teletype, the parameter value (Z) for the function (2) when setting a param value, multiply any value you want to send by 100 and it will be set correctly on crow. For example, to send the number 5.4 you'd use 540 for Z in the CROW.C4 OP.  
 
```
CROW.C4 W X Y Z 

W is function: 1, 2, or 3

Function 1: Note On!
X is crow output (1, 2, 3, 4)
Y is note (0 - 127)
Z is velocity (always set this to 1 for now)

Function 2: Set Parameter Value!
X is crow output (1, 2, 3, 4)
Y is parameter index (1 - 51)
Z is parameter value (to send 5.4, you'd type 540)

Function 3: Set Synth Model and Shape!
X is crow output (1, 2, 3, 4)
Y is synth model (1 - 7)
Z is synth shape (1 - 9)
```

For function 2, here are the parameter index numbers. Listed in same order as norns param menu. 

global detune = 56  
synth shape = 43,  
synth model = 42,  
birdsong = 50,  
flock size = 51,  
midi note -> amp = 48,  
max freq = 1,  
note = 2, (hidden from menu)  
amplitude = 3, (hidden from menu)  
transpose = 41,  
pulse width = 4,  
pulse width 2 = 5,  
^^bitcrush (v/oct) = 6,  
^^mutuate = 52,  
^^corvus = 47,  
^^amp limit pre-bit = 49,  
splash = 7,  
amp -> max freq = 8,  
amp -> osc note = 9,  
amp -> amplitude = 10,  
amp -> pulse width = 11,  
amp -> pwlse width 2 = 12,  
amp -> bitcrush = 13,  
amp -> mutate = 53,  
amp cycle freq = 14,  
amp symmetry = 15,  
amp curve = 16,  
amp loop = 17,  
amp reset = 44,  
amp phase = 18, (hidden)  

lfo -> max freq = 19,  
lfo -> osc note = 20,  
lfo -> amplitude = 21,  
lfo -> pulse width = 22,  
lfo -> pwlse width 2 = 23,  
lfo -> bitcrush = 24,  
lfo -> mutate = 54,  
lfo cycle freq = 25,  
lfo symmetry = 26,  
lfo curve = 27,  
lfo loop = 28,  
lfo reset = 45,  
lfo phase = 29, (hidden)  

note -> max freq = 30,  
note -> osc note = 31,  
note -> amplitude = 32,  
note -> pulse width = 33,  
note -> pwlse width 2 = 34,  
note -> bitcrush = 35,  
note -> mutate = 55,  
note cycle freq = 36,  
note symmetry = 37,  
note curve = 38,  
note loop = 39,  
note reset = 46,  
note phase = 40, (hidden)  

TODO make this nicer  

## Druid Operation

Similar to teletype operation, you can call the `ii.self.call4(a, b, c, d)` function directly on crow to access the same functions described in the teletype operation section. You'll have to use Z * 100 when setting a parameter value. There is no built-in sequencer currently, so I'm not sure what you're planning on doing with druid.  

## Usage
Basic instructions on how to use.

## Examples
Provide some example settings or presets.
