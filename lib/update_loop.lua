local st = {}
local DC_VOICES = 4
local FREQ_LIMIT = {5919, 5919, 2793, 2793, 5919, 5919, 5919, 5919, 5919}
local A_MAX = {0, 1, 5, 10, 20, 40}
local bird_idx = {1,1,1,1}
local min_, max_, rnd_, flr_, abs_ = math.min, math.max, math.random, math.floor, math.abs
local scale_ = {output[1].scale, output[2].scale, output[3].scale, output[4].scale}
local dc_update_enable = {true, true, true, true}
local DNA = {}
DNA[1] = {} -- chromatic, off
DNA[2] = {0, 2, 4, 5, 7, 9, 11} -- major, cornix
DNA[3] = {0, 2, 3, 5, 7, 9, 10} -- minor, orru
DNA[4] = {0, 3, 5, 7, 10, 12, 15} -- pentatonic, kubaryi
DNA[5] = {0, 11, 9, 7, 5, 4, 2} -- rev major, corone
DNA[6] = {0, 7, 12, 5, 0, 5, 12} -- levaillantii
DNA[7] = {0, 7, 12, 24, -12, 0, 12} -- culminatus
DNA[8] = {0, 24, 5, 22, 7, 19, 12} -- edithae
DNA[9] = {0, 17, -17, 0, -17, 17, 12} -- florensis
DNA[10] = {0, -7, -10, 12, 24, 17, 12} -- brachyrhynchos
local NEUTRAL = {0, 2, 4, 6, 8, 10, 12}
local mut_scale = {}
for x = 1, 4 do mut_scale[x] = {0, 2, 4, 6, 8, 10, 12} end
local dc_update_time = 0.01 --0.008 speed limit
local dc_update_metro = false
local dc_update_init_check = false
local shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
local dc_names = 
{
    'mfreq', 'note', 'dcAmp', 'pw', 'pw2', 'bit', 'splash',
    'a_mfreq', 'a_note', 'a_amp', 'a_pw', 'a_pw2', 'a_bit', 'a_cyc', 'a_sym', 'a_curve', 'a_loop', 'a_phase',
    'l_mfreq', 'l_note', 'l_amp', 'l_pw', 'l_pw2', 'l_bit', 'l_cyc', 'l_sym', 'l_curve', 'l_loop', 'l_phase',
    'n_mfreq', 'n_note', 'n_amp', 'n_pw', 'n_pw2', 'n_bit', 'n_cyc', 'n_sym', 'n_curve', 'n_loop', 'n_phase',
    'transpose', 'model', 'shape',
    'a_reset', 'l_reset', 'n_reset', 'species', 'n_to_dcAmp', 'a_limit', 'birdsong', 'flock',
    'mut', 'a_mut', 'l_mut', 'n_mut', 'detune'
}
for ch = 1, DC_VOICES do
    st[ch] = 
    {
        mfreq = 1, note = 60, dcAmp = 0, pw = 0, pw2 = 0, bit = 0, splash = 0,
        a_mfreq = 0, a_note = 0, a_amp = 1, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 3, a_sym = -1, a_curve = 2, a_loop = 1, a_phase = 1, 
        l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 2.5, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
        n_mfreq = 0, n_note = 0, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 10, n_sym = -1, n_curve = 4, n_loop = 1, n_phase = 1, 
        transpose = 0, model = 1, shape = 2,
        a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, birdsong = 1, flock = 1,
        mut = 1, a_mut = 0, l_mut = 0, n_mut = 0, detune = 1
    }
end

function dc_synth_update_receive(new_values)
    for ch, vals in pairs(new_values) do
        if vals[1] ~= nil and vals[2] ~= nil then
            if ch >= 5 then
                ii.crow[1].call4(3, ch - 4, vals[1], vals[2])
            else
                dc_set_synth(ch, vals[1], vals[2])
            end
        end
    end
end
-- i2c only sends 16 signed int, 32768 upper limit, multiply by 100 to send 0.01 as 1
function dc_param_update_receive(new_values)
    for ch, vals in pairs(new_values) do
        for k, v in pairs(vals) do
            if ch >= 5 then
                ii.crow[1].call4(2, ch - 4, k, v * 100)
            else
                st[ch][dc_names[k]] = v
            end
        end
    end
end

local function ASL_var_saw(shape)
    return loop{
        to(dyn{dcAmp=0}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), 
        to(0-dyn{dcAmp=0}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)} 
end
local function ASL_bytebeat(shape)
    return loop{
        to(dyn{x=1}:step(dyn{pw=1}):wrap(-10,10) * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end
local function ASL_noise(shape)
    return loop{
        to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-5,5) * dyn{dcAmp=0}, dyn{cyc=1}, shape)} 
end
local function ASL_FMstep(shape) 
    return loop{
        to(  dyn{dcAmp=0}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
        to(0-dyn{dcAmp=0}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)}
end
local function ASL_sine(shape)
    return loop{
        to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end
local function ASL_harmonic(shape)
    return loop{
        to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end
local function ASL_bytebeat5(shape)
    return loop{
        to(dyn{x=0}:step(dyn{pw=0.1}):wrap(0, 10) % dyn{pw2=1} * dyn{dcAmp=0}, dyn{cyc=1}, shape)}
end

function dc_update_stop()
    if dc_update_metro == true then
        dc_update_metro = false
        metro[8]:stop()
    end
end

function dc_set_synth(ch, model, shape)
    if ch >= 5 then
        ii.crow[1].call4(3, ch - 4, model, shape)
        return
    end
    local restart_update = false
    if dc_update_metro == true then
        dc_update_stop()
        restart_update = true
    end
    dc_update_enable[ch] = false
    output[ch].volts = 0
    if     model == 1 then output[ch](ASL_var_saw(shapes[shape]))
    elseif model == 2 then output[ch](ASL_bytebeat(shapes[shape]))
    elseif model == 3 then output[ch](ASL_noise(shapes[shape]))
    elseif model == 4 then output[ch](ASL_FMstep(shapes[shape]))
    elseif model == 5 then output[ch](ASL_sine(shapes[shape]))
    elseif model == 6 then output[ch](ASL_harmonic(shapes[shape])) 
    elseif model == 7 then output[ch](ASL_bytebeat5(shapes[shape])) 
    else output[ch](ASL_var_saw(shapes[shape]))
    end
    st[ch].model = model
    st[ch].shape = shape
    dc_update_enable[ch] = true
    if restart_update then
        dc_update_start()
    end
end

local function dc_check_ASL(ch)
    msg = output[ch].asl.dyn._names
    if msg.dcAmp ~= nil then return true else return false end
end

local function dc_update_acc(phase, freq, sec, looping)
    phase = phase + (freq * sec)
    phase = looping and (1 + phase) % 2 - 1 or min_(max_(phase, -1), 1)
    return phase
end

local function dc_update_peak(ph, pw, curve)
    local value = ph < pw and (1 + ph) / (1 + pw) or ph > pw and (1 - ph) / (1 - pw) or 1
    value = value ^ curve
    return value
end

local function dc_update_loop_maths(i)
    local s = st[i]
    s.a_phase = dc_update_acc(s.a_phase, s.a_cyc, dc_update_time, s.a_loop == 2)
    local a_env = dc_update_peak(s.a_phase, s.a_sym, s.a_curve)
    s.l_phase = dc_update_acc(s.l_phase, s.l_cyc, dc_update_time, s.l_loop == 2)
    local l_env = dc_update_peak(s.l_phase, s.l_sym, s.l_curve)
    s.n_phase = dc_update_acc(s.n_phase, s.n_cyc, dc_update_time, s.n_loop == 2)
    local n_env = dc_update_peak(s.n_phase, s.n_sym, s.n_curve)
    local max_freq = s.mfreq + (n_env * s.n_mfreq) + (l_env * s.l_mfreq) + (a_env * s.a_mfreq)
    local note_up = s.note/12 + (n_env * s.n_note) + (l_env * s.l_note)  + (a_env * s.a_note)
    local volume = (n_env * s.n_amp * s.dcAmp) + (l_env * s.l_amp * s.dcAmp) + (a_env * s.a_amp * s.dcAmp) 
    local pw = s.pw + (n_env * s.n_pw) + (l_env * s.l_pw) + (a_env * s.a_pw)
    local pw2 = s.pw2 + (n_env * s.n_pw2) + (l_env * s.l_pw2) + (a_env * s.a_pw2)
    local bitz = s.bit + (n_env * s.n_bit) + (l_env * s.l_bit) + (a_env * s.a_bit)
    local splish = s.splash * 0.5
    local mut_amt = s.mut + (n_env * s.n_mut) + (l_env * s.l_mut) + (a_env * s.a_mut)
    max_freq = min_(max_(max_freq, 0.01), 1)
    local cyc = note_up * 12 + s.transpose
    cyc = 13.75 * (2 ^ ((cyc - 9) / 12)) -- midi num to freq to sec
    cyc = 1/(min_(max_(cyc * 1.023996 * s.detune, 0.1), FREQ_LIMIT[s.shape] * max_freq)) -- for correct (de)tuning
    output[i].dyn.cyc = splish > 0 and (rnd_()*0.1 < cyc/0.1 and cyc + (cyc * 0.2 * rnd_()*splish) or cyc + rnd_()*0.002*splish) or cyc
    if bitz > 0 then
        if s.species >= 2 and s.shape ~= 3 and s.shape ~= 4 then
            local x = 0
            for idx = 1, 7 do
                x = NEUTRAL[idx] + (DNA[s.species][idx] - NEUTRAL[idx]) * mut_amt
                x = x > 24 and -3 * x + 96 or x < -24 and -3 * x - 96 or x
                mut_scale[i][idx] = s.n_to_dcAmp == 1 and x or flr_(x)
            end
            scale_[i](mut_scale[i], 12, bitz)
        elseif s.species >= 2 then -- log and exp shapes
            scale_[i](DNA[s.species], 12 * abs_(mut_amt), bitz)
        else
            scale_[i](DNA[s.species], 12, bitz)
        end
    else
        scale_[i]('none')
    end
    volume = s.n_to_dcAmp == 2 and note_up + s.transpose / 12 + volume or volume
    output[i].dyn.dcAmp = min_(max_(volume, -1 * A_MAX[s.a_limit]), A_MAX[s.a_limit])
    pw = (min_(max_(pw, -1), 1) + 1) / 2
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
    for i = 1, DC_VOICES do
        if dc_update_enable[i] and dc_check_ASL(i) then
            dc_update_loop_maths(i)
        else
            off_count = off_count + 1
        end
    end
    if off_count == DC_VOICES then dc_update_stop() end
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
    if ch >= 5 then
        ii.crow[1].call4(1, ch - 4, nt, vel * 100)
        return
    end
    if dc_update_init_check == false then
        dc_update_init()
    end
    if dc_check_ASL(ch) == false then
        dc_set_synth(ch, st[ch].model, st[ch].shape)
    end
    if st[ch].a_reset == 2 and st[ch].a_phase >= st[ch].a_sym then st[ch].a_phase = -1 end
    if st[ch].l_reset == 2 and st[ch].l_phase >= st[ch].l_sym then st[ch].l_phase = -1 end
    if st[ch].n_reset == 2 and st[ch].n_phase >= st[ch].n_sym then st[ch].n_phase = -1 end
    if st[ch].birdsong == 1 then
        st[ch].note = nt
    else
        st[ch].note = nt + DNA[st[ch].birdsong][(bird_idx[ch] - 1) % #DNA[st[ch].birdsong] + 1]
        bird_idx[ch] = bird_idx[ch] % #DNA[st[ch].birdsong] + 1
    end
    st[ch].dcAmp = vel * 5
    dc_update_start()
end

function set_crow_address(x) ii.address = x end

ii.self.call4 = function(func, a, b, c)
    if func == 1 then dc_note_on(a, b, c / 100) -- (ch, nt, vel)
    elseif func == 2 then st[a][dc_names[b]] = c / 100 -- (ch, k, v)
    elseif func == 3 then dc_set_synth(a, b, c) -- (ch, model, shape)
    else print("CAW: call4") end
end
