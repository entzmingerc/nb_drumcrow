states = {}
DC_FREQ_LIMIT = {114, 114, 101, 101, 114, 114, 114, 114, 114}
DC_SPECIES_DNA = {
    {}, -- chromatic
    {0, 2, 4, 5, 7, 9, 11}, -- major
    {0, 2, 3, 5, 7, 9, 10}, -- minor
    {0, 3, 5, 7, 10}, -- pentatonic
    {0, -3, -5, -7, -10, -7, -5, 0, 5, 7, 12, 17, 19, 22, 19, 17, 15, 12},
    {0, 0, 2, 7, 14, 21, 28, 36, 30, 18, 12},
    {0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 14, 12, 11, 9, 7, 5, 4, 2, 0},
    {0, 7, 0, 12, 0, 19},
    {0, 0, 0, 0, -7, 0, 7, 14, 21, 28, 12, 12, 12, 12},
    {0, 11, 9, 7, 5, 4, 2, 0},
    {0, -3, -5, -7, -10, 10, 7, 5, 3, 0},
    {0, 23, 2, 21, 4, 21, 5, 19, 7, 17, 11, 16, 12, 14, 12},
    {0, 1, 2, 3, 5, 7, 9, 11, 13, -13, -11, -9, -7, -5, -3, -2, -1, 0},
    {0, 12, 24, -24, 0, 0, 0, -24, 24, 19, 12},
    {0, 2, 14, 2, 0, 5, 7, 12, 10, -2, 10, 12}
} -- 15 species discovered
dc_update_time = 0.008
dc_update_metro = false
dc_update_init_check = false
shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
for ch = 1, 4 do
    states[ch] = 
    {
        mfreq = 1, note = 60, dcAmp = 5, pw = 0, pw2 = 0, bit = 0, splash = 0,
        amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 2,  amp_symmetry = -1, amp_curve = 2,  amp_loop = 1,  amp_phase = 1, 
        lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_loop = 2,  lfo_phase = -1, 
        note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_loop = 1, note_phase = 1, 
        transpose = 0, model = 1, shape = 1,
        amp_reset = 2, lfo_reset = 1, note_reset = 2, species = 1
    }
end

function dc_param_update_receive(new_values)
    for ch, vals in pairs(new_values) do
        for k, v in pairs(vals) do
            states[ch][k] = v
        end
    end
end

function dc_set_state(ch, k, v)
    states[ch][k] = v
end

function ASL_var_saw(shape)
    return loop{
        to(dyn{dcAmp=0}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), 
        to(0-dyn{dcAmp=0}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)} 
end

function ASL_bytebeat(shape)
    return loop{
        to(dyn{x=1}:step(dyn{pw=1}):wrap(-10,10) * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end

function ASL_noise(shape)
    return loop{
        to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-5,5) * dyn{dcAmp=0}, dyn{cyc=1}, shape)} 
end

function ASL_FMstep(shape) 
    return loop{
        to(  dyn{dcAmp=0}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
        to(0-dyn{dcAmp=0}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)}
end

function ASL_sine(shape)
    return loop{
        to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end

function ASL_harmonic(shape)
    return loop{
        to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end

function ASL_bytebeat5(shape)
    return loop{
        to(dyn{x=0}:step(dyn{pw=0.1}):wrap(0, 10) % dyn{pw2=1} * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end

function dc_set_synth(ch, model, shape)
    states[ch].model = model
    states[ch].shape = shape
    if     model == 1 then output[ch](ASL_var_saw(shapes[shape]))
    elseif model == 2 then output[ch](ASL_bytebeat(shapes[shape]))
    elseif model == 3 then output[ch](ASL_noise(shapes[shape]))
    elseif model == 4 then output[ch](ASL_FMstep(shapes[shape]))
    elseif model == 5 then output[ch](ASL_sine(shapes[shape]))
    elseif model == 6 then output[ch](ASL_harmonic(shapes[shape])) 
    elseif model == 7 then output[ch](ASL_bytebeat5(shapes[shape])) 
    else output[ch](ASL_var_saw(shapes[shape]))
    end
end

function dc_update_stop()
    if dc_update_metro == true then
        dc_update_metro = false
        metro[8]:stop()
    end
end

function dc_check_ASL(ch)
    msg = output[ch].asl.dyn._names
    if msg.dcAmp ~= nil then
        return true
    else 
        return false
    end
end

function dc_update_acc(phase, freq, sec, looping)
    phase = phase + (freq * sec)
    phase = looping and (1 + phase) % 2 - 1 or math.max(math.min(1, phase), -1)
    return phase
end

function dc_update_peak(ph, pw, curve)
    local value = ph < pw and (1 + ph) / (1 + pw) or ph > pw and (1 - ph) / (1 - pw) or 1
    value = value ^ (2 ^ curve)
    return value
end

function num2freq(n)
    return 13.75 * (2 ^ ((n - 9) / 12))
end

function dc_update_loop_maths(i)
    local s = states[i]
    s.amp_phase   = dc_update_acc(s.amp_phase, s.amp_cycle, dc_update_time, s.amp_loop == 2)
    local ampenv  = dc_update_peak(s.amp_phase, s.amp_symmetry, s.amp_curve)
    s.lfo_phase   = dc_update_acc(s.lfo_phase, s.lfo_cycle, dc_update_time, s.lfo_loop == 2)
    local lfo     = dc_update_peak(s.lfo_phase, s.lfo_symmetry, s.lfo_curve)
    s.note_phase  = dc_update_acc(s.note_phase, s.note_cycle, dc_update_time, s.note_loop == 2)
    local noteenv = dc_update_peak(s.note_phase, s.note_symmetry, s.note_curve)
    local max_freq = s.mfreq     + (noteenv * s.note_mfreq) + (lfo * s.lfo_mfreq) + (ampenv * s.amp_mfreq)
    local note_up  = s.note/12.7 + (noteenv * s.note_note)  + (lfo * s.lfo_note)   + (ampenv * s.amp_note)
    local volume   = (noteenv * s.note_amp * s.dcAmp) + (lfo * s.lfo_amp * s.dcAmp) + (ampenv * s.amp_amp * s.dcAmp) 
    local pw       = s.pw  + (noteenv * s.note_pw)  + (lfo * s.lfo_pw)  + (ampenv * s.amp_pw)
    local pw2      = s.pw2 + (noteenv * s.note_pw2) + (lfo * s.lfo_pw2) + (ampenv * s.amp_pw2)
    local bitz     = s.bit + (noteenv * s.note_bit) + (lfo * s.lfo_bit) + (ampenv * s.amp_bit)
    local sploosh  = s.splash
    
    max_freq = math.min(math.max(max_freq, 0.01), 1)
    local cyc = 1/num2freq(math.min(math.max(note_up * 12.7, 0.01) + s.transpose, DC_FREQ_LIMIT[s.shape] * max_freq))
    cyc = cyc * 0.97655 -- for correct tuning
    output[i].dyn.cyc = sploosh > 0 and (math.random()*0.1 < cyc/0.1 and cyc + (cyc * 0.2 * math.random()*sploosh) or cyc + math.random()*0.002*sploosh) or cyc
    
    output[i].dyn.dcAmp = math.min(math.max(volume, -10), 10)
    
    if bitz > 0 then
        output[i].scale(DC_SPECIES_DNA[s.species], 12, bitz)
    else
        output[i].scale('none') 
    end

    pw = (math.min(math.max(pw, -1), 1) + 1) / 2
    if s.model == 2 or s.model == 5 or s.model == 6 then
        output[i].dyn.pw = pw * pw2
    elseif s.model == 3 or s.model == 7 then
        output[i].dyn.pw = pw
        output[i].dyn.pw2 = pw2
    elseif s.model == 4 then
        output[i].dyn.pw = pw
        output[i].dyn.pw2 = pw2 / 50
    else
        output[i].dyn.pw = pw
    end    
end

function dc_update_loop()
    local off_count = 0
    for i = 1, 4 do
        if dc_check_ASL(i) then
            dc_update_loop_maths(i)
        else
            off_count = off_count + 1
        end
    end

    if off_count == 4 then
        dc_update_stop()
    end

end

function dc_update_start()
    if dc_update_metro == false then
        metro[8]:start()
        dc_update_metro = true
    end
end

function dc_update_init()
    dc_update_init_check = true
    metro[8].event = dc_update_loop
    metro[8].time = dc_update_time
end

function dc_note_on(ch, nt, vel)
    if dc_update_init_check == false then
        dc_update_init()
    end
    if dc_check_ASL(ch) == false then
        dc_set_synth(ch, states[ch].model, states[ch].shape)
    end
    if states[ch].amp_reset == 2 and states[ch].amp_phase >= states[ch].amp_symmetry then
        states[ch].amp_phase = -1
    end
    if states[ch].lfo_reset == 2 and states[ch].lfo_phase >= states[ch].lfo_symmetry then
        states[ch].lfo_phase = -1
    end
    if states[ch].note_reset == 2 and states[ch].note_phase >= states[ch].note_symmetry then
        states[ch].note_phase = -1
    end
    states[ch].dcAmp = vel * 5
    states[ch].note = nt
    dc_update_start()
end