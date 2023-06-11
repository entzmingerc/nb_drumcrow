-- nb_drumcrow pseudoengine for nb
-- turns crow into a synth
-- nb framework author: sixolet
-- drumcrow author: postsolarpunk
dc_musicutil = require("musicutil")
local mod = require 'core/mods'
local dc_models = {'var_saw','bytebeat','noise','FMstep','ASLsine','ASLharmonic','bytebeat5'}
local dc_shapes = {'"linear"','"sine"','"logarithmic"','"exponential"','"now"','"wait"','"over"','"under"','"rebound"'}
local DC_NUM_PARAMS = 40
local update_drumcrow_ID = {}
local dc_names = {
    "mfreq", "note", "amp", "pw", "pw2", "bit", "splash",
    "amp_mfreq", "amp_note", "amp_amp", "amp_pw", "amp_pw2", "amp_bit", "amp_cycle", "amp_symmetry", "amp_curve", "amp_type", "amp_phase", 
    "lfo_mfreq", "lfo_note", "lfo_amp", "lfo_pw", "lfo_pw2", "lfo_bit", "lfo_cycle", "lfo_symmetry", "lfo_curve", "lfo_type", "lfo_phase", 
    "note_mfreq", "note_note", "note_amp", "note_pw", "note_pw2", "note_bit", "note_cycle", "note_symmetry", "note_curve", "note_type", "note_phase",  
    "mfreq_mod", "note_mod", "amp_mod", "pw_mod", "pw2_mod", "bit_mod", "splash_mod"
}
local dc_init = {
    mfreq = 1, note = 0, amp = 4, pw = 0, pw2 = 0, bit = 0, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10,  amp_symmetry = -1, amp_curve = 3,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 10,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
    mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
} -- synth shape = 1, synth model = 1 when the param "initialize" is triggered

local function n(i, s)
    return "drumcrow_" .. s .. "_" .. i
end

function drumcrow_load_preset(i, properties)
    for k, v in pairs(properties) do
            if k == "amp_phase"  then params:set(n(i, k),  1)
        elseif k == "lfo_phase"  then params:set(n(i, k), -1)
        elseif k == "note_phase" then params:set(n(i, k),  1)
        else
            params:set(n(i, k), v)
        end
    end
end

-- TO DO add to player? not sure where to put this, should it be local?
function drumcrow_setup_synth(i, model, shape)
    shp = dc_shapes[shape]
        if model == 1 then crow.output[i].action = string.format("loop{to(dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, %s), to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), %s)}", shp, shp)
    elseif model == 2 then crow.output[i].action = string.format("loop{to(dyn{x=1}:step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}, %s)}", shp)
    elseif model == 3 then crow.output[i].action = string.format("loop{to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-5,5) * dyn{amp=2}, dyn{cyc=1}/2, %s)}", shp)
    elseif model == 4 then crow.output[i].action = string.format("loop{to(dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, %s), to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), %s)}", shp, shp)
    elseif model == 5 then crow.output[i].action = string.format("loop{to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, %s)}", shp)
    elseif model == 6 then crow.output[i].action = string.format("loop{to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, %s)}", shp)
    elseif model == 7 then crow.output[i].action = string.format("loop{to(dyn{x=0}:step(dyn{pw=0.1}):wrap(0, 10) %% dyn{pw2=1} * dyn{amp=2}, dyn{cyc=1}, %s)}", shp)
    else
        crow.output[i].action = string.format("loop{to(dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, %s), to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), %s)}", shp, shp)
    end
    crow.output[i]()
end

local function add_drumcrow_params(i)
    params:add_group(n("group", i), "drumcrow voice "..i, 4 + 7 + 11 + 11 + 11 + 7)
    params:hide(n("group", i))
    params:add_trigger(n(i, "on_off"), "on_off")
    params:add_trigger(n(i, "initialize"), "initialize")
    params:add_option(n(i, "synth_shape"), "synth_shape", dc_shapes, 2)
    params:add_option(n(i, "synth_model"), "synth_model", dc_models, 6) -- 4

    -- TO DO better way to set up parameters: table of control specs per parameter, for loop, lookup control spec and init values per parameter label
    params:add_control(n(i, "mfreq"), "mfreq", controlspec.new(0.01,1,"lin",0.005, dc_init[dc_names[1]], "", 0.005, false))
    params:add_control(n(i, "note"), "note", controlspec.new(0,127,"lin",0.01, dc_init[dc_names[2]]))
    params:add_control(n(i, "amp"), "amp", controlspec.new(-5,5,"lin",0.01, dc_init[dc_names[3]]))
    params:add_control(n(i, "pw"), "pw", controlspec.new(-1,1,"lin",0.0005, dc_init[dc_names[4]], "", 0.002, false))
    params:add_control(n(i, "pw2"), "pw2", controlspec.new(-10,10,"lin",0.0005, dc_init[dc_names[5]], "", 0.002, false))
    params:add_control(n(i, "bit"), "bit", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[6]], "", 0.005, false))
    params:add_control(n(i, "splash"), "splash", controlspec.new(0,3,"lin",0.01, dc_init[dc_names[7]], "", 0.002, false)) -- 7

    params:add_control(n(i, "amp_mfreq"), "amp_mfreq", controlspec.new(-1,1,"lin",0.005, dc_init[dc_names[8]], "", 0.005, false))
    params:add_control(n(i, "amp_note"), "amp_note", controlspec.new(-10,10,"lin",0.001, dc_init[dc_names[9]], "", 0.002, false))
    params:add_control(n(i, "amp_amp"), "amp_amp", controlspec.new(-5,5,"lin",0.01, dc_init[dc_names[10]]))
    params:add_control(n(i, "amp_pw"), "amp_pw", controlspec.new(-2,2,"lin",0.001, dc_init[dc_names[11]], "", 0.005, false))
    params:add_control(n(i, "amp_pw2"), "amp_pw2", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[12]], "", 0.005, false))
    params:add_control(n(i, "amp_bit"), "amp_bit", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[13]], "", 0.005, false))
    params:add_control(n(i, "amp_cycle"), "amp_cycle", controlspec.new(0.1, 500, 'exp', 0, dc_init[dc_names[14]], "", 0.002, false))
    params:add_control(n(i, "amp_symmetry"), "amp_symmetry", controlspec.new(-2,2,"lin",0.01, dc_init[dc_names[15]], "", 0.005, false))
    params:add_control(n(i, "amp_curve"), "amp_curve", controlspec.new(-5,5,"lin",0.01, dc_init[dc_names[16]]))
    params:add_control(n(i, "amp_type"), "amp_type", controlspec.new(0,1,"lin",0.01, dc_init[dc_names[17]], "", 1, false))
    params:add_control(n(i, "amp_phase"), "amp_phase", controlspec.new(-1,1,"lin",0.0005, dc_init[dc_names[18]], "", 0.002, false)) -- 11

    params:add_control(n(i, "lfo_mfreq"), "lfo_mfreq", controlspec.new(-1,1,"lin",0.005, dc_init[dc_names[19]], "", 0.005, false))
    params:add_control(n(i, "lfo_note"), "lfo_note", controlspec.new(-10,10,"lin",0.001, dc_init[dc_names[20]], "", 0.002, false))
    params:add_control(n(i, "lfo_amp"), "lfo_amp", controlspec.new(-5,5,"lin",0.01, dc_init[dc_names[21]]))
    params:add_control(n(i, "lfo_pw"), "lfo_pw", controlspec.new(-2,2,"lin",0.001, dc_init[dc_names[22]], "", 0.005, false))
    params:add_control(n(i, "lfo_pw2"), "lfo_pw2", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[23]], "", 0.005, false))
    params:add_control(n(i, "lfo_bit"), "lfo_bit", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[24]], "", 0.005, false))
    params:add_control(n(i, "lfo_cycle"), "lfo_cycle", controlspec.new(0.1, 500, 'exp', 0, dc_init[dc_names[25]], "", 0.002, false))
    params:add_control(n(i, "lfo_symmetry"), "lfo_symmetry", controlspec.new(-2,2,"lin",0.01, dc_init[dc_names[26]], "", 0.005, false))
    params:add_control(n(i, "lfo_curve"), "lfo_curve", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[27]]))
    params:add_control(n(i, "lfo_type"), "lfo_type", controlspec.new(0,1,"lin",0.01, dc_init[dc_names[28]], "", 1, false))
    params:add_control(n(i, "lfo_phase"), "lfo_phase", controlspec.new(-1,1,"lin",0.0005, dc_init[dc_names[29]], "", 0.002, false)) -- 11

    params:add_control(n(i, "note_mfreq"), "note_mfreq", controlspec.new(-1,1,"lin",0.005, dc_init[dc_names[30]], "", 0.005, false))
    params:add_control(n(i, "note_note"), "note_note", controlspec.new(-10,10,"lin",0.001, dc_init[dc_names[31]], "", 0.002, false))
    params:add_control(n(i, "note_amp"), "note_amp", controlspec.new(-5,5,"lin",0.01, dc_init[dc_names[32]]))
    params:add_control(n(i, "note_pw"), "note_pw", controlspec.new(-2,2,"lin",0.001, dc_init[dc_names[33]], "", 0.005, false))
    params:add_control(n(i, "note_pw2"), "note_pw2", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[34]], "", 0.005, false))
    params:add_control(n(i, "note_bit"), "note_bit", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[35]], "", 0.005, false))
    params:add_control(n(i, "note_cycle"), "note_cycle", controlspec.new(0.1, 500, 'exp', 0, dc_init[dc_names[36]], "", 0.002, false))
    params:add_control(n(i, "note_symmetry"), "note_symmetry", controlspec.new(-2,2,"lin",0.01, dc_init[dc_names[37]], "", 0.005, false))
    params:add_control(n(i, "note_curve"), "note_curve", controlspec.new(-10,10,"lin",0.01, dc_init[dc_names[38]]))
    params:add_control(n(i, "note_type"), "note_type", controlspec.new(0,1,"lin",0.01, dc_init[dc_names[39]], "", 1, false)) 
    params:add_control(n(i, "note_phase"), "note_phase", controlspec.new(-1,1,"lin",0.0005, dc_init[dc_names[40]], "", 0.002, false)) -- 11

    -- external modulation
    params:add_control(n(i, "mfreq_mod"), "mfreq_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[41]]))
    params:add_control(n(i, "note_mod"), "note_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[42]]))
    params:add_control(n(i, "amp_mod"), "amp_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[43]]))
    params:add_control(n(i, "pw_mod"), "pw_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[44]]))
    params:add_control(n(i, "pw2_mod"), "pw2_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[45]]))
    params:add_control(n(i, "bit_mod"), "bit_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[46]]))
    params:add_control(n(i, "splash_mod"), "splash_mod", controlspec.new(0, 1, "lin", 0, dc_init[dc_names[47]])) -- 7

    -- params:hide(n(i, "mfreq_mod"))
    -- params:hide(n(i, "note_mod"))
    -- params:hide(n(i, "amp_mod"))
    -- params:hide(n(i, "pw_mod"))
    -- params:hide(n(i, "pw2_mod"))
    -- params:hide(n(i, "bit_mod"))
    -- params:hide(n(i, "splash_mod"))

    drumcrow_setup_synth(i, params:get(n(i, "synth_model")), params:get(n(i, "synth_shape")))

    params:set_action(n(i, "on_off"), function()
        if update_drumcrow_ID[i] == nil then
            update_drumcrow_start(i) 
            print("drumcrow "..i.." engine ON")
        else
            update_drumcrow_stop(i)
            print("drumcrow "..i.." engine OFF")
        end
    end)
    params:set_action(n(i, "initialize"), function() 
        drumcrow_load_preset(i, dc_init)
    end)
    params:set_action(n(i, "synth_shape"), function(s)
        drumcrow_setup_synth(i, params:get(n(i, "synth_model")), s) end)
    params:set_action(n(i, "synth_model"), function(s)
        drumcrow_setup_synth(i, s, params:get(n(i, "synth_shape"))) end)
end

-- TODO add to player?
function update_drumcrow_start(i)
    if update_drumcrow_ID[i] == nil then
        local dc_update_time = 0.006
        update_drumcrow_ID[i] = clock.run(update_drumcrow, dc_update_time, i)
    end
end

-- TODO add to player?
function update_drumcrow_stop(i)
    if update_drumcrow_ID[i] ~= nil then
        clock.cancel(update_drumcrow_ID[i])
        update_drumcrow_ID[i] = nil
        crow.output[i].dyn.amp = 0 -- should mute any model
    end
end

-- TODO add to player?
function update_drumcrow(dc_update_time, i)
    -- phase accumulation, location inside envelope /\, returns -1 ... +1
    local function acc(phase, freq, sec, looping)
        phase = phase + (freq * sec)
        phase = looping and (1 + phase) % 2 - 1 or math.max(math.min(1, phase), -1)
        return phase
    end
    
    -- phase in, value out /\, returns -1 ... +1 (uhhh I think)
    local function peak(ph, pw, curve)
        local value = ph < pw and (1 + ph) / (1 + pw) or ph > pw and (1 - ph) / (1 - pw) or 1
        value = value ^ (2 ^ curve)
        return value
    end

    -- update loop
    while true do
        -- calculate internal modulation sources
        params:set(n(i, "amp_phase"), acc(params:get(n(i, "amp_phase")), params:get(n(i, "amp_cycle")), dc_update_time, params:get(n(i, "amp_type")) > 0))
        local ampenv = peak(params:get(n(i, "amp_phase")), params:get(n(i, "amp_symmetry")), params:get(n(i, "amp_curve")))
        params:set(n(i, "lfo_phase"), acc(params:get(n(i, "lfo_phase")), params:get(n(i, "lfo_cycle")), dc_update_time, params:get(n(i, "lfo_type")) > 0))
        local lfo = peak(params:get(n(i, "lfo_phase")), params:get(n(i, "lfo_symmetry")), params:get(n(i, "lfo_curve")))
        params:set(n(i, "note_phase"), acc(params:get(n(i, "note_phase")), params:get(n(i, "note_cycle")), dc_update_time, params:get(n(i, "note_type")) > 0))
        local noteenv = peak(params:get(n(i, "note_phase")), params:get(n(i, "note_symmetry")), params:get(n(i, "note_curve")))
        
        -- calculate internal modulation of parameters
        local max_freq = params:get(n(i, "mfreq")) + (noteenv * params:get(n(i, "note_mfreq"))) + (lfo * params:get(n(i, "lfo_mfreq"))) + (ampenv * params:get(n(i, "amp_mfreq"))) 
        local note_up  = params:get(n(i, "note"))/12.7 + (noteenv * params:get(n(i, "note_note"))) + (lfo * params:get(n(i, "lfo_note"))) + (ampenv * params:get(n(i, "amp_note"))) 
        local volume   = (noteenv * params:get(n(i, "note_amp")) * params:get(n(i, "amp"))) + (lfo * params:get(n(i, "lfo_amp")) * params:get(n(i, "amp"))) + (ampenv * params:get(n(i, "amp_amp")) * params:get(n(i, "amp"))) 
        local pw       = params:get(n(i, "pw"))    + (noteenv * params:get(n(i, "note_pw")))    + (lfo * params:get(n(i, "lfo_pw")))    + (ampenv * params:get(n(i, "amp_pw")))
        local pw2      = params:get(n(i, "pw2"))   + (noteenv * params:get(n(i, "note_pw2")))   + (lfo * params:get(n(i, "lfo_pw2")))   + (ampenv * params:get(n(i, "amp_pw2")))
        local bitz     = params:get(n(i, "bit"))   + (noteenv * params:get(n(i, "note_bit")))   + (lfo * params:get(n(i, "lfo_bit")))   + (ampenv * params:get(n(i, "amp_bit")))
        local sploosh  = params:get(n(i, "splash"))
         
        -- calculate external modulation, sequence the attenuation of internal values for now, _mod range 0 ... 1
        max_freq = max_freq * params:get(n(i, "mfreq_mod"))
        note_up = note_up * params:get(n(i, "note_mod"))
        volume = volume * params:get(n(i, "amp_mod"))
        pw = pw * params:get(n(i, "pw_mod"))
        pw2 = pw2 * params:get(n(i, "pw2_mod"))
        bitz = bitz * params:get(n(i, "bit_mod"))
        sploosh = sploosh * params:get(n(i, "splash_mod"))

        -- set frequency on crow
        max_freq = math.min(math.max(max_freq, 0.01), 1)
        local cyc = 1/dc_musicutil.note_num_to_freq(math.min(math.max(note_up * 12.7, 0.01), 127 * max_freq))
        crow.output[i].dyn.cyc = sploosh > 0 and (math.random()*0.1 < cyc/0.1 and cyc + (cyc * 0.2 * math.random()*sploosh) or cyc + math.random()*0.002*sploosh) or cyc
        
        -- set amplitude on crow
        crow.output[i].dyn.amp = math.min(math.max(volume, -10), 10)
        
        -- set bitcrush on crow
        if bitz > 0 then crow.output[i].scale({}, 2, bitz * 3) else crow.output[i].scale('none') end
        
        -- set pulse width (depends on model) on crow
        pw = (math.min(math.max(pw, -1), 1) + 1) / 2
        mdl = params:get(n(i, "synth_model"))
        if mdl == 2 or mdl == 5 or mdl == 6 then 
            crow.output[i].dyn.pw = pw * pw2
        elseif mdl == 3 or mdl == 7 then
            crow.output[i].dyn.pw = pw
            crow.output[i].dyn.pw2 = pw2
        elseif mdl == 4 then
            crow.output[i].dyn.pw = pw
            crow.output[i].dyn.pw2 = pw2 / 50
        else 
            crow.output[i].dyn.pw = pw 
        end
        clock.sleep(dc_update_time)
    end
end

-- PLAYER
function add_drumcrow_player(i)
    local player = {
        timbre_modulation = 0
    }

    function player:active()
        if self.name ~= nil then
            params:show(n("group", i))
            _menu.rebuild_params()
        end
    end

    function player:inactive()
        if self.name ~= nil then
            params:hide(n("group", i))
            _menu.rebuild_params()
        end
    end

    function player:stop_all()
        if update_drumcrow_ID[i] ~= nil then
            clock.cancel(update_drumcrow_ID[i])
            update_drumcrow_ID[i] = nil
            crow.output[i].dyn.amp = 0 -- 0 amp should mute every model
        end
    end
    
    -- do I need this? not used?
    -- should I use modulate(val), modulate(key, val), or modulate_note(note, key, val) and ignore note?
    -- I need a function with (key, value), using modulate_note(), check with sixolet
    function player:modulate(val)
        self.timbre_modulation = val
    end

    function player:describe()
        return {
            name = "drumcrow "..i,
            supports_bend = false,
            supports_slew = false,
            modulate_description = "first row osc params",
            note_mod_targets = {"mfreq_mod", "note_mod", "amp_mod", "pw_mod", "pw2_mod", "bit_mod", "splash_mod"},
        }
    end
    
    -- ignores note, just uses key & value, currently 0 to 1
    function player:modulate_note(note, key, value)
        params:set(n(i, key), value)
    end

    function player:note_on(note, vel, properties)
        if properties == nil then
            properties = {}
        end

        -- set volume, note, trigger envelopes
        if params:get(n(i, "amp_phase"))  >= params:get(n(i, "amp_symmetry"))  then params:set(n(i, "amp_phase"), -1)  end
        if params:get(n(i, "note_phase")) >= params:get(n(i, "note_symmetry")) then params:set(n(i, "note_phase"), -1) end
        params:set(n(i, "amp"),  (vel/127)  * 20 - 10)
        params:set(n(i, "note"), note)
        print("drumcrow "..i.." note on triggered")
    end

    -- midi note_off, pass for perc style?
    function player:note_off(note)
        crow.output[i].dyn.amp = 0
        params:set(n(i, "amp"), 0)
    end

    function player:add_params()
        add_drumcrow_params(i)
    end

    if note_players == nil then
        note_players = {}
    end
    note_players["drumcrow "..i] = player
end

function pre_init()
    crow.reset()
    add_drumcrow_player(1)
    add_drumcrow_player(2)
    add_drumcrow_player(3)
    add_drumcrow_player(4)
end

mod.hook.register("script_pre_init", "drumcrow pre init", pre_init)