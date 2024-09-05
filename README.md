# nb_drumcrow  
This is a mod for monome norns that turns a monome crow into a synthesizer using nb. It can also be uploaded to crow to work in standalone operation using teletype to sequence it over i2c.  

### Features:
- 4 monophonic synthesizers, one for each output of crow.  
- Can be sequenced with any norns script that supports nb, teletype, or druid.  
- Each output can be set to synthesize audio, gate/trigger, envelope, a V/Oct CV signal, or a CV signal quantized to a scale.  
- Each output can be triggered individually, round robin, or all simultaneously. Each output can be set to trigger only itself or an additional output for paired operation.  
- Each output has 3 cycling envelope modulation sources.

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

# Parameters
channel, output, player, voice

## Settings

Default parameter values are the values loaded using the init preset.  

| Parameter | Description | Range | Default |
|-----------|-------------|-------|---------|
| resend code to crow | (GLOBAL) reuploads audio engine code to run on crow | BUTTON | not pressed |
| param behavior | (GLOBAL) set this player or all players when changing a value | individual, all | individual |
| trigger behavior | (GLOBAL) controls how all drumcrow nb players deal with note on | individual, round robin, all | individual |
| synth preset | selects which preset to load | see synth presets | init |
| load preset | loads the synth preset | BUTTON | not pressed |

## Oscillator
| Parameter | Description | Range | Default |
|-----------|-------------|-------|---------|
| synth shape | affects tone, sets voltage path between to() calls in ASL model | 1-9 | sine |
| synth model | different ASL models that are oscillating | 1-7 | var_saw |
| birdsong | The transposition sequence, stepped each note on | see species | off (corvix) |
| flock size | number of voices triggered during note on | 1-4 | 1 |
| midi note -> amp | Converts midi note to amplitude for outputting v/oct | off, on | off |
| max freq | limits the maximum oscillator frequency | 0.01, 1 | 1 |
| transpose | offsets the midi note | -120, 120 | 120 |
| pulse width | functionality changes with ASL model | -1, 1 | 0 |
| pulse width 2 | functionality changes with ASL model | -10, 10 | 0 |
| ^^bitcrush | crow output scaling amount, volts per octave | -10, 60 | 0 |
| ^^corvus | scale to quantize output voltage to | see species | chromatic (corvix) |
| ^^amp limit pre-bit | limits amplitude before bitcrusher | ±0, ±1, ±5, ±10, ±20, ±40 | ±10 |
| splash | amount of randomness applied to the frequency | 0, 3 | 0 |

## Envelopes (Amp, LFO, Note)
| Parameter | Description | Range | Default |
|-----------|-------------|-------|---------|
| amp -> max freq | modulation depth of maximum frequency | -1, 1 | 0 |
| amp -> osc note | modulation depth of oscillator frequency | -10, 10 | 0 |
| amp -> amplitude | modulation depth of amplitude | -5, 5 | 1 for amp only |
| amp -> pulse width | modulation depth of pulse width | -2, 2 | 0 |
| amp -> pulse width 2 | modulation depth of pulse width 2 | -10, 10 | 0 |
| amp -> bitcrush | modulation depth of bitcrush | -10, 60 | 0 |
| amp cycle freq | how quickly the envelope rises and falls | 0.1, 200 | various |
| amp symmetry | ratio between rise time and fall time, 0 is 50/50 | -2, 2 | amp & note: -1, lfo 0 |
| amp curve | shape of the rise and fall stages | 0.03125, 32 | amp & note: 4, lfo 1 |
| amp loop | if on: envelope begins again after fall is complete | off, on | amp & note: off, lfo on |
| amp reset | if on: envelope resets from the start of rise during note on | off, on | amp & note: on, lfo off |

Each drumcrow output has 3 envelopes. The 3 envelopes, `amp`, `lfo`, and `note` are functionally identical, but have different values when loading the init preset. init `amp` modulates amplitude by 1.0, loop is off, and reset is on. init `lfo` loop is on and reset is off. init `note` loop is off and reset is on.  

Each envelope has the same set of modulation targets, modulation depth ranges, and envelope parameters. The modulation depth adds to the current value of the parameter it is modulating (except for amplitude). For example: pulse width at 0.4, lfo -> pulse width modulation depth at 0.2, then you'll hear pulse width modulate back and forth between 0.4 and 0.6. For modulation depth -0.8, you'd hear 0.4 to -0.4. For amplitude, if amplitude modulation depth is 0 for all envelopes then you'll hear silence.  

The `cycle freq` value isn't literally the frequency. Low values are longer cycle times, high values are shorter cycle times.  

TODO curve plots

TODO symmetry plots

TODO loop plots

TODO reset plots

## Bitcrusher

15 species of drumcorvus have been discovered so far.  

| Species | Scale |
|-----------|-------------|
| cornix | (chromatic) |
| albus | 0, 2, 4, 5, 7, 9, 11 (major) |
| orru | 0, 2, 3, 5, 7, 9, 10 (minor) |
| kubaryi | 0, 3, 5, 7, 10 (minor pentatonic) |
| brachyrhynchos | 0, 0, -5, -7, -10, -7, -5, 0, 5, 7, 12, 17, 19, 24, 19, 17, 15, 12 |
| culminatus | 0, 0, 2, 7, 14, 21, 28, 36, 30, 18, 12 |
| bennetti | 0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 14, 12, 11, 9, 7, 5, 4, 2, 0 |
| levaillantii | 0, 7, 0, 12, 0, 19 |
| torquatus | 0, 0, 0, 0, -7, 0, 7, 14, 21, 28, 12, 12, 12, 12 |
| corone | 0, 11, 9, 7, 5, 4, 2, 0 |
| capensis | 0, -3, -5, -7, -10, 11, 7, 5, 2, 0 |
| edithae | 0, 23, 2, 21, 4, 21, 5, 19, 7, 17, 11, 16, 12, 14, 12 |
| enca | 0, 0, 2, 4, 5, 7, 9, 11, 14, -14, -10, -8, -7, -5, -3, -3, -1, 0 |
| florensis | 0, 12, 24, -24, 0, 0, 0, -24, 24, 19, 12 |
| fuscicapillus | 0, 2, 14, 2, 0, 5, 7, 12, 10, -2, 10, 12 |

TODO bitcrusher diagram

The bitcrusher uses crow output [quantizer](https://monome.org/docs/crow/reference/#quantize-to-scales) to do distortion. The bitcrush value is the scaling variable, so a value of 1.0 results in 1 volt per octave quantization of the output voltage. Any oscillator with bitcrush at 1.0 when slowed down could be used as a v/oct sequence. Temperament is fixed to 12. The scale used for quantization is chosen from the species list. The first 4 species are chromatic, major, minor, and minor pentatonic. Scale values can be out of order to create arpeggios, but also scales can be much longer than 12 notes and have note values well outside the range 0 - 12.  

The range of voltage for each octave is defined by bitcrush. Each octave is divided evenly into a number of sections equal to the number of notes in the scale. For any given voltage, first you find the section it is in, then crow calculates the quantized voltage based on the note. Metaphorically, it applies the shape of the scale across the v/oct range. For example, the shape of the stairstep voltage waveform that occurs between 0V and 1V when quantizing to a major scale if bitcrush is 1 v/oct would be stretched across the voltage range 0V and 5V if bitcrush is set to 5 v/oct. For this reason, a variety of scales can be used to significantly change the tone of the bitcrushing. Feel free to alter the scales yourself!  

An amplitude modulation depth of 1 for maximum velocity results in an oscillator amplitude of ±5 V. Crow hardware is limited to -5 V and 10 V. The `amp limit pre-bit` parameter sets the maximum range of voltage that drumcrow will request. It defaults to ±10 V. By increasing the amplitude modulation depth to 2, you can increase the oscillator amplitude to ±10 V and crow will clip the bottom part of the waveform. By setting `amp limit pre-bit` parameter to ±20 V or ±40 V and increasing the amplitude modulation depth even more, you can clip both the top and bottom parts of the waveform for a more overdriven tone. The combination of multiple envelopes modulation amplitude and bitcrush values between 0 and 5 can generate a lot of varied distortion tones.  

## Synth Shapes

These are the shapes from the [crow reference](https://monome.org/docs/crow/reference/#shaping-cv). These are also known as "easing functions". 

| Shapes | Description |
| ------ | ----------- |
| linear | connect the dots /\/ |
| sine | looks like half a sine wave (default) |
| logarithmic | rise quickly, settle slowly |
| exponential | rise slowly, settle quickly |
| now | go instantly to the destination then wait |
| wait | wait at the current level, then go to the destination |
| over | move toward the destination and overshoot, before landing |
| under | move away from the destination, then smoothly ramp up |
| rebound | emulate a bouncing ball toward the destination |

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

For function 2, here are the parameter index numbers for each parameter.  

dc_idx = {  
    mfreq = 1, note = 2, dcAmp = 3, pw = 4, pw2 = 5, bit = 6, splash = 7,  
    a_mfreq = 8,  a_note = 9,  a_amp = 10, a_pw = 11, a_pw2 = 12, a_bit = 13, a_cyc = 14, a_sym = 15, a_curve = 16, a_loop = 17, a_phase = 18,  
    l_mfreq = 19, l_note = 20, l_amp = 21, l_pw = 22, l_pw2 = 23, l_bit = 24, l_cyc = 25, l_sym = 26, l_curve = 27, l_loop = 28, l_phase = 29,  
    n_mfreq = 30, n_note = 31, n_amp = 32, n_pw = 33, n_pw2 = 34, n_bit = 35, n_cyc = 36, n_sym = 37, n_curve = 38, n_loop = 39, n_phase = 40,  
    transpose = 41, model = 42, shape = 43,  
    a_reset = 44, l_reset = 45, n_reset = 46, species = 47, n_to_dcAmp = 48, a_limit = 49, birdsong = 50, flock = 51  
}  

TODO make this nicer  

## Druid Operation

Similar to teletype operation, you can call the `ii.self.call4(a, b, c, d)` function directly on crow to access the same functions described in the teletype operation section. You'll have to use Z * 100 when setting a parameter value. There is no built-in sequencer currently, so I'm not sure what you're planning on doing with druid.  