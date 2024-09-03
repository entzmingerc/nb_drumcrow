states = {}
DC_VOICES = 4
DC_FREQ_LIMIT = {114, 114, 101, 101, 114, 114, 114, 114, 114}
DC_A_LIMIT = {0, 1, 5, 10, 20, 40}
dc_caw_idx = {1,1,1,1}
dc_update_enable = {true, true, true, true}
DC_SPECIES_DNA = {
    {}, -- chromatic
    {0, 2, 4, 5, 7, 9, 11}, -- major
    {0, 2, 3, 5, 7, 9, 10}, -- minor
    {0, 3, 5, 7, 10}, -- pentatonic
    {0, -2, -5, -7, -10, -7, -5, 0, 5, 7, 12, 17, 19, 22, 19, 17, 15, 12},
    {0, 0, 2, 7, 14, 21, 28, 36, 30, 18, 12},
    {0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 14, 12, 11, 9, 7, 5, 4, 2, 0},
    {0, 7, 0, 12, 0, 19},
    {0, 0, 0, 0, -7, 0, 7, 14, 21, 28, 12, 12, 12, 12},
    {0, 11, 9, 7, 5, 4, 2, 0},
    {0, -3, -5, -7, -10, 10, 7, 5, 3, 0},
    {0, 23, 2, 21, 4, 21, 5, 19, 7, 17, 11, 16, 12, 14, 12},
    {0, 0, 2, 4, 5, 7, 9, 11, 14, -14, -10, -8, -7, -5, -3, -3, -1, 0},
    {0, 12, 24, -24, 0, 0, 0, -24, 24, 19, 12},
    {0, 2, 14, 2, 0, 5, 7, 12, 10, -2, 10, 12}
} -- 15 species discovered
dc_update_time = 0.01 --0.008 speed limit
dc_update_metro = false
dc_update_init_check = false
shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
dc_names = 
{
    'mfreq', 'note', 'dcAmp', 'pw', 'pw2', 'bit', 'splash',
    'a_mfreq', 'a_note', 'a_amp', 'a_pw', 'a_pw2', 'a_bit', 'a_cyc', 'a_sym', 'a_curve', 'a_loop', 'a_phase', 
    'l_mfreq', 'l_note', 'l_amp', 'l_pw', 'l_pw2', 'l_bit', 'l_cyc', 'l_sym', 'l_curve', 'l_loop', 'l_phase', 
    'n_mfreq', 'n_note', 'n_amp', 'n_pw', 'n_pw2', 'n_bit', 'n_cyc', 'n_sym', 'n_curve', 'n_loop', 'n_phase', 
    'transpose', 'model', 'shape',
    'a_reset', 'l_reset', 'n_reset', 'species', 'n_to_dcAmp', 'a_limit', 'caw', 'flock'
}
for ch = 1, DC_VOICES do
    states[ch] = 
    {
        mfreq = 1, note = 60, dcAmp = 0, pw = 0, pw2 = 0, bit = 0, splash = 0,
        a_mfreq = 0, a_note = 0, a_amp = 1, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 2, a_sym = -1, a_curve = 4, a_loop = 1, a_phase = 1, 
        l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 6.1, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
        n_mfreq = 0, n_note = 0, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 10, n_sym = -1, n_curve = 4, n_loop = 1, n_phase = 1, 
        transpose = 0, model = 1, shape = 2,
        a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
    }
end
-- i2c only sends 16 signed int, 32768 upper limit, max param val is 200, so 200 * 160 = 32,000 ish, divide on receive
function send_state_value_i2c(crowidx, ch, k, v)
    ii.crow[crowidx].call4(5, ch, k, v * 160)
end
function dc_synth_update_receive(new_values)
    for ch, vals in pairs(new_values) do
        if vals[1] ~= nil and vals[2] ~= nil then
            if ch >= 5 then
                crowidx, new_ch = dc_get_crow_and_channel(ch)
                ii.crow[crowidx].call4(4, new_ch, vals[1], vals[2])
            else
                dc_set_synth(ch, vals[1], vals[2])
            end
        end
    end
end
function dc_param_update_receive(new_values)
    for ch, vals in pairs(new_values) do
        for k, v in pairs(vals) do
            if ch >= 5 then
                crowidx, new_ch = dc_get_crow_and_channel(ch)
                send_state_value_i2c(crowidx, new_ch, k, v)
            else
                states[ch][dc_names[k]] = v
            end
        end
    end
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
    if ch >= 5 then
        crowidx, new_ch = dc_get_crow_and_channel(ch)
        ii.crow[crowidx].call4(4, new_ch, model, shape)
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
    states[ch].model = model
    states[ch].shape = shape
    dc_update_enable[ch] = true
    if restart_update then
        dc_update_start()
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
    phase = looping and (1 + phase) % 2 - 1 or math.min(math.max(phase, -1), 1)
    return phase
end
function dc_update_peak(ph, pw, curve)
    local value = ph < pw and (1 + ph) / (1 + pw) or ph > pw and (1 - ph) / (1 - pw) or 1
    value = value ^ curve
    return value
end
function num_to_freq(n)
    return 13.75 * (2 ^ ((n - 9) / 12))
end
function dc_update_loop_maths(i)
    local s = states[i]
    s.a_phase   = dc_update_acc( s.a_phase, s.a_cyc, dc_update_time, s.a_loop == 2)
    local a_env = dc_update_peak(s.a_phase, s.a_sym, s.a_curve)
    s.l_phase   = dc_update_acc( s.l_phase, s.l_cyc, dc_update_time, s.l_loop == 2)
    local l_env = dc_update_peak(s.l_phase, s.l_sym, s.l_curve)
    s.n_phase   = dc_update_acc( s.n_phase, s.n_cyc, dc_update_time, s.n_loop == 2)
    local n_env = dc_update_peak(s.n_phase, s.n_sym, s.n_curve)
    local max_freq = s.mfreq   + (n_env * s.n_mfreq) + (l_env * s.l_mfreq) + (a_env * s.a_mfreq)
    local note_up  = s.note/12 + (n_env * s.n_note)  + (l_env * s.l_note)  + (a_env * s.a_note)
    local volume   = (n_env * s.n_amp * s.dcAmp) + (l_env * s.l_amp * s.dcAmp) + (a_env * s.a_amp * s.dcAmp) 
    local pw       = s.pw  + (n_env * s.n_pw)  + (l_env * s.l_pw)  + (a_env * s.a_pw)
    local pw2      = s.pw2 + (n_env * s.n_pw2) + (l_env * s.l_pw2) + (a_env * s.a_pw2)
    local bitz     = s.bit + (n_env * s.n_bit) + (l_env * s.l_bit) + (a_env * s.a_bit)
    local sploosh  = s.splash * 0.5
    max_freq = math.min(math.max(max_freq, 0.01), 1)
    local cyc = 1/num_to_freq(math.min(math.max(note_up * 12, 0.01) + s.transpose, DC_FREQ_LIMIT[s.shape] * max_freq))
    cyc = cyc * 0.97655 -- for correct tuning
    output[i].dyn.cyc = sploosh > 0 and (math.random()*0.1 < cyc/0.1 and cyc + (cyc * 0.2 * math.random()*sploosh) or cyc + math.random()*0.002*sploosh) or cyc
    if bitz > 0 then
        output[i].scale(DC_SPECIES_DNA[s.species], 12, bitz)
    else
        output[i].scale('none')
    end
    volume = s.n_to_dcAmp == 2 and note_up + s.transpose / 12 + volume or volume
    output[i].dyn.dcAmp = math.min(math.max(volume, -1 * DC_A_LIMIT[s.a_limit]), DC_A_LIMIT[s.a_limit])
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
    for i = 1, DC_VOICES do
        if dc_update_enable[i] and dc_check_ASL(i) then
            dc_update_loop_maths(i)
        else
            off_count = off_count + 1
        end
    end
    if off_count == DC_VOICES then
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
    if ch >= 5 then
        crowidx, new_ch = dc_get_crow_and_channel(ch)
        ii.crow[crowidx].call4(1, new_ch, nt, vel)
        return
    end
    if dc_update_init_check == false then
        dc_update_init()
    end
    if dc_check_ASL(ch) == false then
        dc_set_synth(ch, states[ch].model, states[ch].shape)
    end
    if states[ch].a_reset == 2 and states[ch].a_phase >= states[ch].a_sym then
        states[ch].a_phase = -1
    end
    if states[ch].l_reset == 2 and states[ch].l_phase >= states[ch].l_sym then
        states[ch].l_phase = -1
    end
    if states[ch].n_reset == 2 and states[ch].n_phase >= states[ch].n_sym then
        states[ch].n_phase = -1
    end
    if states[ch].caw == 1 then
        states[ch].note = nt
    else
        states[ch].note = nt + DC_SPECIES_DNA[states[ch].caw][(dc_caw_idx[ch] - 1) % #DC_SPECIES_DNA[states[ch].caw] + 1]
        dc_caw_idx[ch] = dc_caw_idx[ch] % #DC_SPECIES_DNA[states[ch].caw] + 1
    end
    states[ch].dcAmp = vel * 5
    dc_update_start()
end

function dc_get_crow_and_channel(ch)
    if ch > 0 and ch <= 4 then
        return 1, ch
    elseif ch > 4 and ch <= 8 then
        return 1, ch - 4
    elseif ch > 8 and ch <= 12 then
        return 2, ch - 8
    elseif ch > 12 and ch <= 16 then
        return 3, ch - 12
    else
        return 1, 1
    end
end

ii.self.call1 = function(a)
    print("call1: "..a)
end

ii.self.call3 = function(a, b, c)
    print("call3: "..a.." "..b.." "..c)
end

ii.self.call4 = function(func, arg1, arg2, arg3)
    if func == 1 then -- (ch, nt, vel)
        dc_note_on(arg1, arg2, arg3)
    elseif func == 2 then -- (ch, key, val) key is int 1-49, v XXXX.0
        states[arg1][dc_names[arg2]] = arg3
    elseif func == 3 then -- (ch, key, val) key is int 1-49, add v = 0.XXXX to states value
        states[arg1][dc_names[arg2]] = states[arg1][dc_names[arg2]] + (arg3 * 0.0001)
    elseif func == 4 then  -- (ch, model, shape)
        dc_set_synth(arg1, arg2, arg3)
    elseif func == 5 then 
        states[arg1][dc_names[arg2]] = arg3 / 160
    elseif func == 8 then  -- debug
        ii.crow[1].call1(arg1)
    else
        print("CAW: call4")
    end
end