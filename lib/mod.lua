-- nb_drumcrow voice for nb
-- turns crow into a synth
-- drumcrow author: postsolarpunk
-- drumcrow author: license
-- nb author: sixolet

-- BITCRUSHER SCALE PRESETS
-- 1) go to update_loop.lua and add a new DNA sequence to DC_SPECIES_DNA
-- 2) add species of crow to dc_species_names https://en.wikipedia.org/wiki/Crow
-- ~~~~~ DNA Sequence Notes ~~~~~
-- bitcrush amount == number of volts per octave
-- DNA sequence == the quantizer scale that is applied across each octave
-- fixed to 12 step temperament so that low frequency output values get quantized to melodic sequences when bitcrush = 1.0
-- start DNA sequence with 0 so that high bitcrush values don't result in constant DC offset
-- 0 is start of octave, 12 is end of octave, nice to end sequence on 12 for smooth transition
-- max DNA sequence length of 20 ish? I tried 30 and it gets a bit glitchy
-- larger numbers mean louder signal with higher bitcrush values, 36 is roughly useful maximum
-- WMD geiger counter wavetables for inspiration https://cdn.shopify.com/s/files/1/0977/3366/files/GeigerCounterWaveTables-hires.pdf?v=1678297681
-- easing functions for inspiration https://easings.net/
dc_species_names = {
    'cornix', 'albus', 'orru', 'kubaryi', 'brachyrhynchos', 
    'culminatus', 'bennetti', 'levaillantii', 'torquatus', 'corone',
    'capensis', 'edithae', 'enca', 'florensis', 'fuscicapillus'
} -- 15 species discovered

-- SYNTH PRESETS
-- 1) add the name to dc_preset_names
-- 2) make a new entry in the correct location in dc_preset_values
-- 3) make sure each param has a value, use 'init' values for default values
dc_preset_names = {'init', 'kick', 'snare', 'hihat', 'CV trigger', 'CV envelope', 'CV scale'}
dc_preset_values = {
{ -- init, oscillator, decay envelope VCA, var_saw model, sine shape
    mfreq = 1, note = 60, dcAmp = 0, pw = 0, pw2 = 0, bit = 0, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 1, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 2, a_sym = -1, a_curve = 4, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 6.1, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
    n_mfreq = 0, n_note = 0, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 10, n_sym = -1, n_curve = 4, n_loop = 1, n_phase = 1, 
    transpose = 0, model = 1, shape = 2,
    a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
},
{ -- kick, oscillator, fast pitch modulation envelope, var_saw model, rebound shape
    mfreq = 1, note = 60, dcAmp = 0, pw = 0, pw2 = 0, bit = 0, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 1, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 10.06, a_sym = -1, a_curve = 0.125, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 6.1, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
    n_mfreq = 0, n_note = 5, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 4.02, n_sym = -1, n_curve = 16, n_loop = 1, n_phase = 1, 
    transpose = -24, model = 1, shape = 9,
    a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
},
{ -- snare, oscillator, fast amplitude cycle, noise model, linear shape
    mfreq = 1, note = 60, dcAmp = 0, pw = 0.39, pw2 = 3.08, bit = 0, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 0.6, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 6.87, a_sym = -1, a_curve = 2, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 6.1, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
    n_mfreq = 0, n_note = 3, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 2.6, n_sym = -1, n_curve = 1, n_loop = 1, n_phase = 1, 
    transpose = 24, model = 3, shape = 2,
    a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
},
{ -- hihat, oscillator, fast amplitude cycle, noise model, rebound shape
    mfreq = 1, note = 60, dcAmp = 0, pw = 0.66, pw2 = 3.44, bit = 0, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 0.6, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 30.94, a_sym = -1, a_curve = 4, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 6.1, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
    n_mfreq = 0, n_note = 3, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 2.6, n_sym = -1, n_curve = 1, n_loop = 1, n_phase = 1, 
    transpose = 24, model = 3, shape = 9,
    a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
},
{ -- CV trigger, requires "var_saw" model and "now" shape, a_cyc controls gate length
    mfreq = 1, note = 60, dcAmp = 0, pw = 1, pw2 = 0, bit = 0, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 1, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 101, a_sym = -1, a_curve = 0.03125, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 6.1, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
    n_mfreq = 0, n_note = 0, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 10, n_sym = -1, n_curve = 1, n_loop = 1, n_phase = 1, 
    transpose = 0, model = 1, shape = 5,
    a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
},
{ -- CV decay envelope, requires "var_saw" model and "now" shape, modulate amplitude to control envelope shape
    mfreq = 1, note = 60, dcAmp = 0, pw = 1, pw2 = 0, bit = 0, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 1, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 1.11, a_sym = -1, a_curve = 1, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 4.05, l_sym = 0, l_curve = 1, l_loop = 2, l_phase = -1, 
    n_mfreq = 0, n_note = 0, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 1.09, n_sym = -1, n_curve = 1, n_loop = 1, n_phase = 1, 
    transpose = 0, model = 1, shape = 5,
    a_reset = 2, l_reset = 1, n_reset = 2, species = 1, n_to_dcAmp = 1, a_limit = 4, caw = 1, flock = 1
},
{ -- scale, requires "var_saw" model and "now" shape, n_to_dcAmp ON which maps midi note to 1/12 V per note. bitcrush at 1 and species at 1 for chromatic scale
-- modulating amplitude with internal envelopes will wiggle the selected note around while quantized to the selected species scale. Try various species. 
    mfreq = 1, note = 60, dcAmp = 0, pw = 1, pw2 = 0, bit = 1, splash = 0,
    a_mfreq = 0, a_note = 0, a_amp = 0, a_pw = 0, a_pw2 = 0, a_bit = 0, a_cyc = 0.5, a_sym = 1, a_curve = 1, a_loop = 1, a_phase = 1, 
    l_mfreq = 0, l_note = 0, l_amp = 0, l_pw = 0, l_pw2 = 0, l_bit = 0, l_cyc = 0.5, l_sym = 0, l_curve = 1, l_loop = 1, l_phase = -1, 
    n_mfreq = 0, n_note = 0, n_amp = 0, n_pw = 0, n_pw2 = 0, n_bit = 0, n_cyc = 0.5, n_sym = -1, n_curve = 1, n_loop = 1, n_phase = 1, 
    transpose = 0, model = 1, shape = 5,
    a_reset = 1, l_reset = 0, n_reset = 1, species = 1, n_to_dcAmp = 2, a_limit = 4, caw = 1, flock = 1
},
}

-- nb_drumcrow code ------------------------------------------------------------

local mod = require 'core/mods'

-- dc_update_time = 0.008, "exponential" and "logarithmic" shapes required lower max freq
DC_VOICES = 8
dc_code_sent = false
dc_code_resent = false
dc_param_update_time = 0.25 -- sends message to crow to update parameters if they have changed, only send message if there's a change
dc_param_update_table = {} -- table[channel][key] param values for state matrix on crow
dc_synth_update_table = {}
for j = 1, DC_VOICES do 
    dc_param_update_table[j] = {}
    dc_synth_update_table[j] = {}
end
dc_param_update_table_dirty = false
dc_synth_update_table_dirty = false
dc_param_IDs = {}
dc_trig_behavior = {"individual", "round robin", "all"}
dc_param_behavior = {"individual", "all"}
dc_robin_idx = 1
dc_param_update_metro = nil
dc_models = {'var_saw','bytebeat','noise','FMstep','ASLsine','ASLharmonic','bytebeat5'}
dc_shapes = {'"linear"','"sine"','"logarithmic"','"exponential"','"now"','"wait"','"over"','"under"','"rebound"'}
dc_update_ID = {nil, nil, nil, nil}
dc_names = {
    "mfreq", "note", "dcAmp", "pw", "pw2", "bit", "splash",
    "a_mfreq", "a_note", "a_amp", "a_pw", "a_pw2", "a_bit", "a_cyc", "a_sym", "a_curve", "a_loop", "a_phase",
    "l_mfreq", "l_note", "l_amp", "l_pw", "l_pw2", "l_bit", "l_cyc", "l_sym", "l_curve", "l_loop", "l_phase",
    "n_mfreq", "n_note", "n_amp", "n_pw", "n_pw2", "n_bit", "n_cyc", "n_sym", "n_curve", "n_loop", "n_phase",
    "transpose", "model", "shape",
    "a_reset", "l_reset", "n_reset", "species", "n_to_dcAmp", "a_limit", "caw", "flock"
} -- 51 params, use to convert param idx number to a string
dc_idx = {
    mfreq = 1, note = 2, dcAmp = 3, pw = 4, pw2 = 5, bit = 6, splash = 7,
    a_mfreq = 8,  a_note = 9,  a_amp = 10, a_pw = 11, a_pw2 = 12, a_bit = 13, a_cyc = 14, a_sym = 15, a_curve = 16, a_loop = 17, a_phase = 18, 
    l_mfreq = 19, l_note = 20, l_amp = 21, l_pw = 22, l_pw2 = 23, l_bit = 24, l_cyc = 25, l_sym = 26, l_curve = 27, l_loop = 28, l_phase = 29, 
    n_mfreq = 30, n_note = 31, n_amp = 32, n_pw = 33, n_pw2 = 34, n_bit = 35, n_cyc = 36, n_sym = 37, n_curve = 38, n_loop = 39, n_phase = 40, 
    transpose = 41, model = 42, shape = 43,
    a_reset = 44, l_reset = 45, n_reset = 46, species = 47, n_to_dcAmp = 48, a_limit = 49, caw = 50, flock = 51
} -- use to convert param string to a number idx

-- build dc_param_IDs, this returns a param ID string: dc_param_IDs[i]["mfreq"]
function build_dc_param_IDs()
    for i = 1, DC_VOICES do
        dc_param_IDs[i] = {}
        for j = 1, #dc_names do
            dc_param_IDs[i][dc_names[j]] = "drumcrow_"..dc_names[j].."_"..i
        end
        dc_param_IDs[i]["group"] = "dc_group_"..i
        dc_param_IDs[i]["trig_behavior"] = "dc_trig_behavior_"..i
        dc_param_IDs[i]["param_behavior"] = "dc_param_behavior_"..i
        dc_param_IDs[i]["preset"] = "dc_preset_"..i
        dc_param_IDs[i]["load_preset"] = "dc_load_preset_"..i
        dc_param_IDs[i]["send_code"] = "dc_send_code_"..i
    end
end

function build_flock_size()
    t = {}
    for j = 1, DC_VOICES do t[j] = j end
    return t
end

-- takes data from dc_preset_values and sets norns params menu and sets states on crow
-- if param_behavior == 2, then we call this once for each voice
function dc_load_preset(i, preset_values)
    for name, v in pairs(preset_values) do
        if name ~= "model" and name ~= "shape" then
            params:set(dc_param_IDs[i][name], v) -- set norns
            dc_param_update_table[i][dc_idx[name]] = v -- set crow
            dc_param_update_table_dirty = true
            dc_param_update_loop() -- update immediately
        end
    end
    params:set(dc_param_IDs[i]["model"], preset_values["model"], true) -- set norns
    params:set(dc_param_IDs[i]["shape"], preset_values["shape"], true)
    dc_synth_update_table[i][1] = preset_values["model"] -- set crow
    dc_synth_update_table[i][2] = preset_values["shape"]
    dc_synth_update_table_dirty = true
    dc_param_update_loop() -- update immediately
end

-- function dc_load_preset(i, preset_values)
--     for name, v in pairs(preset_values) do
--         if name ~= "model" and name ~= "shape" then
--             params:set(dc_param_IDs[i][name], v, true) -- set norns param
--             dc_param_update_add(i, dc_idx[name], v) -- set crow param
--             dc_param_update_loop() -- update immediately
--         end
--     end
--     dc_synth_update_model_and_shape(i, preset_values["model"], preset_values["shape"])
-- end

-- create drumcrow parameter menu for nb to show/hide
local function add_drumcrow_params(i)
    params:add_group(dc_param_IDs[i]["group"], "drumcrow voice "..i, 8 + 12 + 12 + 12 + 12) -- keep track number of params for the group
    params:hide(dc_param_IDs[i]["group"])
    params:add_trigger(dc_param_IDs[i]["send_code"], "resend code to crow")
    params:set_action( dc_param_IDs[i]["send_code"], function() dc_resend_code() end)
    params:add_option( dc_param_IDs[i]["param_behavior"], "param behavior", dc_param_behavior, 1)
    params:set_action( dc_param_IDs[i]["param_behavior"], function(x) 
        for j = 1, DC_VOICES do
            if i ~= j then
                params:set(dc_param_IDs[j]["param_behavior"], x) -- set all 4 params to this value
            end
        end
    end)
    params:add_option( dc_param_IDs[i]["trig_behavior"], "trigger behavior", dc_trig_behavior, 1)
    params:set_action( dc_param_IDs[i]["trig_behavior"], function(x) 
        for j = 1, DC_VOICES do
            if i ~= j then
                params:set(dc_param_IDs[j]["trig_behavior"], x) -- set all 4 params to this value
            end
        end
    end)
    params:add_option( dc_param_IDs[i]["preset"], "synth preset", dc_preset_names, 1)
    params:add_trigger(dc_param_IDs[i]["load_preset"], "load preset")
    params:add_option( dc_param_IDs[i]["shape"], "synth shape", dc_shapes, 2)
    params:add_option( dc_param_IDs[i]["model"], "synth model", dc_models, 1)
    params:add_option( dc_param_IDs[i]["flock"], "flock size", build_flock_size(), 1)
    params:set_action( dc_param_IDs[i]["flock"], function(x)
        if params:get(dc_param_IDs[i]["param_behavior"]) == 2 then
            for j = 1, DC_VOICES do
                if i ~= j then
                    params:set(dc_param_IDs[j]["flock"], x) -- set all 4 params to this value
                end
            end
        end
    end) -- 8 params

    -- oscillator parameters
    params:add_option( dc_param_IDs[i]["caw"], "birdsong", dc_species_names, 1)
    params:set_action( dc_param_IDs[i]["caw"], function(x) dc_param_update_add(i, dc_idx["caw"], x) end)
    params:add_option( dc_param_IDs[i]["n_to_dcAmp"], "midi note -> amp", {"off", "on"}, 1)
    params:set_action( dc_param_IDs[i]["n_to_dcAmp"], function(x) dc_param_update_add(i, dc_idx["n_to_dcAmp"], x) end)
    params:add_control(dc_param_IDs[i]["mfreq"], "max freq", controlspec.new(0.01,1,"lin",0.005, dc_preset_values[1]["mfreq"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["mfreq"], function(x) dc_param_update_add(i, dc_idx["mfreq"], x) end)
    params:add_control(dc_param_IDs[i]["note"], "osc note", controlspec.new(0,127,"lin",0.01, dc_preset_values[1]["note"])) -- hide, set by note_on
    params:hide(dc_param_IDs[i]["note"])
    params:add_control(dc_param_IDs[i]["transpose"], "transpose", controlspec.new(-120,120,"lin",1, dc_preset_values[1]["transpose"], "", 1/240, false))
    params:set_action( dc_param_IDs[i]["transpose"], function(x) dc_param_update_add(i, dc_idx["transpose"], x) end)
    params:add_control(dc_param_IDs[i]["dcAmp"], "amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1]["dcAmp"])) -- hide, set by note_on
    params:hide(dc_param_IDs[i]["dcAmp"])
    params:add_control(dc_param_IDs[i]["pw"], "pulse width", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1]["pw"], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["pw"], function(x) dc_param_update_add(i, dc_idx["pw"], x) end)
    params:add_control(dc_param_IDs[i]["pw2"], "pulse width 2", controlspec.new(-10,10,"lin",0.0005, dc_preset_values[1]["pw2"], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["pw2"], function(x) dc_param_update_add(i, dc_idx["pw2"], x) end)
    params:add_control(dc_param_IDs[i]["bit"], "^^bitcrush", controlspec.new(-10,60,"lin",0.1, dc_preset_values[1]["bit"], "", 1/700, false))
    params:set_action( dc_param_IDs[i]["bit"], function(x) dc_param_update_add(i, dc_idx["bit"], x) end)
    params:add_option( dc_param_IDs[i]["species"], "^^corvus", dc_species_names, 1)
    params:set_action( dc_param_IDs[i]["species"], function(x) dc_param_update_add(i, dc_idx["species"], x) end)
    params:add_option( dc_param_IDs[i]["a_limit"], "^^amp limit pre-bit", {"± 0 V", "± 1 V", "± 5 V", "± 10 V", "± 20 V", "± 40 V"}, 4)
    params:set_action( dc_param_IDs[i]["a_limit"], function(x) dc_param_update_add(i, dc_idx["a_limit"], x) end)
    params:add_control(dc_param_IDs[i]["splash"], "splash", controlspec.new(0,3,"lin",0.01, dc_preset_values[1]["splash"], "", 1/600, false))
    params:set_action( dc_param_IDs[i]["splash"], function(x) dc_param_update_add(i, dc_idx["splash"], x) end) -- 12 params

    -- amplitude envelope parameters
    params:add_control(dc_param_IDs[i]["a_mfreq"], "amp -> max freq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1]["a_mfreq"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["a_mfreq"], function(x) dc_param_update_add(i, dc_idx["a_mfreq"], x) end)
    params:add_control(dc_param_IDs[i]["a_note"], "amp -> osc note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1]["a_note"], "", 0.001, false))
    params:set_action( dc_param_IDs[i]["a_note"], function(x) dc_param_update_add(i, dc_idx["a_note"], x) end)
    params:add_control(dc_param_IDs[i]["a_amp"], "amp -> amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1]["a_amp"]))
    params:set_action( dc_param_IDs[i]["a_amp"], function(x) dc_param_update_add(i, dc_idx["a_amp"], x) end)
    params:add_control(dc_param_IDs[i]["a_pw"], "amp -> pulse width", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1]["a_pw"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["a_pw"], function(x) dc_param_update_add(i, dc_idx["a_pw"], x) end)
    params:add_control(dc_param_IDs[i]["a_pw2"], "amp -> pulse width 2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1]["a_pw2"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["a_pw2"], function(x) dc_param_update_add(i, dc_idx["a_pw2"], x) end)
    params:add_control(dc_param_IDs[i]["a_bit"], "amp -> bitcrush", controlspec.new(-20,20,"lin",0.01, dc_preset_values[1]["a_bit"], "", 0.0025, false))
    params:set_action( dc_param_IDs[i]["a_bit"], function(x) dc_param_update_add(i, dc_idx["a_bit"], x) end)
    params:add_control(dc_param_IDs[i]["a_cyc"], "amp cycle freq", controlspec.new(0.1, 200, 'exp', 0, dc_preset_values[1]["a_cyc"], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["a_cyc"], function(x) dc_param_update_add(i, dc_idx["a_cyc"], x) end)
    params:add_control(dc_param_IDs[i]["a_sym"], "amp symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1]["a_sym"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["a_sym"], function(x) dc_param_update_add(i, dc_idx["a_sym"], x) end)
    params:add_control(dc_param_IDs[i]["a_curve"], "amp curve", controlspec.new(0.03125,32,"exp", 0.01, dc_preset_values[1]["a_curve"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["a_curve"], function(x) dc_param_update_add(i, dc_idx["a_curve"], x) end)
    params:add_option( dc_param_IDs[i]["a_loop"], "amp loop", {"off", "on"}, 1)
    params:set_action( dc_param_IDs[i]["a_loop"], function(x) dc_param_update_add(i, dc_idx["a_loop"], x) end)
    params:add_option( dc_param_IDs[i]["a_reset"], "amp reset", {"off", "on"}, 2)
    params:set_action( dc_param_IDs[i]["a_reset"], function(x) dc_param_update_add(i, dc_idx["a_reset"], x) end)
    params:add_control(dc_param_IDs[i]["a_phase"], "a_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1]["a_phase"], "", 0.002, false)) -- 12 params
    params:hide(dc_param_IDs[i]["a_phase"])

    -- LFO parameters
    params:add_control(dc_param_IDs[i]["l_mfreq"], "lfo -> max freq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1]["l_mfreq"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["l_mfreq"], function(x) dc_param_update_add(i, dc_idx["l_mfreq"], x) end)
    params:add_control(dc_param_IDs[i]["l_note"], "lfo -> osc note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1]["l_note"], "", 0.001, false))
    params:set_action( dc_param_IDs[i]["l_note"], function(x) dc_param_update_add(i, dc_idx["l_note"], x) end)
    params:add_control(dc_param_IDs[i]["l_amp"], "lfo -> amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1]["l_amp"]))
    params:set_action( dc_param_IDs[i]["l_amp"], function(x) dc_param_update_add(i, dc_idx["l_amp"], x) end)
    params:add_control(dc_param_IDs[i]["l_pw"], "lfo -> pulse width", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1]["l_pw"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["l_pw"], function(x) dc_param_update_add(i, dc_idx["l_pw"], x) end)
    params:add_control(dc_param_IDs[i]["l_pw2"], "lfo -> pulse width 2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1]["l_pw2"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["l_pw2"], function(x) dc_param_update_add(i, dc_idx["l_pw2"], x) end)
    params:add_control(dc_param_IDs[i]["l_bit"], "lfo -> bitcrush", controlspec.new(-20,20,"lin",0.01, dc_preset_values[1]["l_bit"], "", 0.0025, false))
    params:set_action( dc_param_IDs[i]["l_bit"], function(x) dc_param_update_add(i, dc_idx["l_bit"], x) end)
    params:add_control(dc_param_IDs[i]["l_cyc"], "lfo cycle freq", controlspec.new(0.1, 200, 'exp', 0, dc_preset_values[1]["l_cyc"], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["l_cyc"], function(x) dc_param_update_add(i, dc_idx["l_cyc"], x) end)
    params:add_control(dc_param_IDs[i]["l_sym"], "lfo symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1]["l_sym"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["l_sym"], function(x) dc_param_update_add(i, dc_idx["l_sym"], x) end)
    params:add_control(dc_param_IDs[i]["l_curve"], "lfo curve", controlspec.new(0.03125,32,"exp", 0.01, dc_preset_values[1]["l_curve"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["l_curve"], function(x) dc_param_update_add(i, dc_idx["l_curve"], x) end)
    params:add_option( dc_param_IDs[i]["l_loop"], "lfo loop", {"off", "on"}, 2)
    params:set_action( dc_param_IDs[i]["l_loop"], function(x) dc_param_update_add(i, dc_idx["l_loop"], x) end)
    params:add_option( dc_param_IDs[i]["l_reset"], "lfo reset", {"off", "on"}, 1)
    params:set_action( dc_param_IDs[i]["l_reset"], function(x) dc_param_update_add(i, dc_idx["l_reset"], x) end)
    params:add_control(dc_param_IDs[i]["l_phase"], "l_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1]["l_phase"], "", 0.002, false)) -- 12 params
    params:hide(dc_param_IDs[i]["l_phase"])

    -- note envelope parameters
    params:add_control(dc_param_IDs[i]["n_mfreq"], "note -> max freq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1]["n_mfreq"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["n_mfreq"], function(x) dc_param_update_add(i, dc_idx["n_mfreq"], x) end)
    params:add_control(dc_param_IDs[i]["n_note"], "note -> osc note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1]["n_note"], "", 0.001, false))
    params:set_action( dc_param_IDs[i]["n_note"], function(x) dc_param_update_add(i, dc_idx["n_note"], x) end)
    params:add_control(dc_param_IDs[i]["n_amp"], "note -> amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1]["n_amp"]))
    params:set_action( dc_param_IDs[i]["n_amp"], function(x) dc_param_update_add(i, dc_idx["n_amp"], x) end)
    params:add_control(dc_param_IDs[i]["n_pw"], "note -> pulse width", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1]["n_pw"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["n_pw"], function(x) dc_param_update_add(i, dc_idx["n_pw"], x) end)
    params:add_control(dc_param_IDs[i]["n_pw2"], "note -> pulse width 2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1]["n_pw2"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["n_pw2"], function(x) dc_param_update_add(i, dc_idx["n_pw2"], x) end)
    params:add_control(dc_param_IDs[i]["n_bit"], "note -> bitcrush", controlspec.new(-20,20,"lin",0.01, dc_preset_values[1]["n_bit"], "", 0.0025, false))
    params:set_action( dc_param_IDs[i]["n_bit"], function(x) dc_param_update_add(i, dc_idx["n_bit"], x) end)
    params:add_control(dc_param_IDs[i]["n_cyc"], "note cycle freq", controlspec.new(0.1, 200, 'exp', 0, dc_preset_values[1]["n_cyc"], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["n_cyc"], function(x) dc_param_update_add(i, dc_idx["n_cyc"], x) end)
    params:add_control(dc_param_IDs[i]["n_sym"], "note symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1]["n_sym"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["n_sym"], function(x) dc_param_update_add(i, dc_idx["n_sym"], x) end)
    params:add_control(dc_param_IDs[i]["n_curve"], "note curve", controlspec.new(0.03125,32,"exp", 0.01, dc_preset_values[1]["n_curve"], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["n_curve"], function(x) dc_param_update_add(i, dc_idx["n_curve"], x) end)
    params:add_option( dc_param_IDs[i]["n_loop"], "note loop", {"off", "on"}, 1)
    params:set_action( dc_param_IDs[i]["n_loop"], function(x) dc_param_update_add(i, dc_idx["n_loop"], x) end)
    params:add_option( dc_param_IDs[i]["n_reset"], "note reset", {"off", "on"}, 2)
    params:set_action( dc_param_IDs[i]["n_reset"], function(x) dc_param_update_add(i, dc_idx["n_reset"], x) end)
    params:add_control(dc_param_IDs[i]["n_phase"], "n_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1]["n_phase"], "", 0.002, false)) -- 12 params
    params:hide(dc_param_IDs[i]["n_phase"])

    params:set_action(dc_param_IDs[i]["load_preset"], function() 
        if dc_code_sent == false then
            print("CAW: resend code to crow! load preset")
            return 
        end
        if params:get(dc_param_IDs[i]["param_behavior"]) == 2 then
            for j = 1, DC_VOICES do
                dc_load_preset(j, dc_preset_values[params:get(dc_param_IDs[i]["preset"])]) -- set jth voice to this preset
                params:set(dc_param_IDs[j]["preset"], params:get(dc_param_IDs[i]["preset"])) -- set jth preset selection to this preset
            end
        else
            dc_load_preset(i, dc_preset_values[params:get(dc_param_IDs[i]["preset"])])
        end
    end)

    params:set_action(dc_param_IDs[i]["shape"], function(s)
        if dc_code_sent == false then 
            print("CAW: resend code to crow! synth shape")
            return 
        end
        dc_synth_update_model_and_shape(i, params:get(dc_param_IDs[i]["model"]), s)
    end)

    params:set_action(dc_param_IDs[i]["model"], function(m)
        if dc_code_sent == false then 
            print("CAW: resend code to crow! synth model")
            return 
        end
        dc_synth_update_model_and_shape(i, m, params:get(dc_param_IDs[i]["shape"]))
    end)
end

function dc_resend_code()
    dc_code_sent = false
    dc_crow_code_send()
    dc_code_resent = true -- for reinitializing norns params in the public.discovered event
end

function dc_crow_code_send()
    if dc_code_sent == true then
        print("CAW: code already sent to crow!")
        return
    end
    -- norns.crow.loadscript("nb_drumcrow/lib/update_loop.lua", false, false) -- if true, it uploads the script, if false, it loads to current memory
    -- I can't get norns.crow.loadscript to work
    -- below is a version of norns.crow.loadscript modified to not run in an asynchronous coroutine
    -- approximately 0.04 delta between os.clock() value every 1 second in maiden
    -- TODO 
    --     does ...os.clock overflow back to 0? highly unlikely we'd run into that issue
    --     do I need the busy wait while loops? using them as pseudo delay for crow to process received command
    -- https://github.com/monome/crow/blob/7027d2971a5491b021d8b309101cf2f75a7b5787/lib/caw.c#L104

    -- make the event to catch upload completion before we continue
    norns.crow.public.discovered = function() 
        print("CAW: code uploaded! READY!") 
        dc_code_sent = true

        -- get current values of norns param menu and send to crow
        if dc_code_resent == true then 
            -- first update the state table on crow (excluding model and shape)
            for j = 1, DC_VOICES do -- for each output
                for _, k in pairs(dc_names) do
                    if k ~= "model" and k ~= "shape" then
                        dc_param_update_table[j][dc_idx[k]] = params:get(dc_param_IDs[j][k]) -- get the current param value
                        dc_param_update_table_dirty = true
                        dc_param_update_loop() -- update immediately
                    end
                end
            end

            -- then get model and shape, send to crow
            for j = 1, DC_VOICES do
                dc_synth_update_table[j][1] = params:get(dc_param_IDs[j]["model"])
                dc_synth_update_table[j][2] = params:get(dc_param_IDs[j]["shape"])
                dc_synth_update_table_dirty = true
                dc_param_update_loop() -- update immediately, 8 simultaneous ASL calls seems to break
            end
            dc_code_resent = false
        end
    end

    -- now let's send crow the code, first find the file to send
    file = "nb_drumcrow/lib/update_loop.lua"
    is_persistent = false
    local abspath = norns.crow.findscript(file, is_persistent)
    if not abspath then
        print("CAW: crow.loadscript: can't find file "..file)
        return
    end

    -- send code line by line to crow
    print("CAW: crow loading: ".. abspath)
    norns.crow.send("^^s")
    -- clock.sleep(0.2), os.clock() roughly 0.04 delta per second, so 0.008 per 0.2 sec?
    local start_time = os.clock()
    while os.clock() - start_time < 0.008 do 
    end 
    for line in io.lines(abspath) do
        norns.crow.send(line)
        -- clock.sleep(0.01) os.clock() roughly 0.04 delta per second, so 0.0004 per 0.01 sec?
        start_time = os.clock()
        while os.clock() - start_time < 0.0004 do 
        end 
    end
    -- clock.sleep(0.2), os.clock() roughly 0.04 delta per second, so 0.008 per 0.2 sec?
    start_time = os.clock()
    while os.clock() - start_time < 0.008 do 
    end 
    norns.crow.send("^^e") -- end upload, trigger norns.crow.public.discovered() after the init() on crow is called
    while os.clock() - start_time < 0.008 do 
    end 
    
end

-- nb player
function add_drumcrow_player(i)
    local player = {}

    function player:active()
        if self.name ~= nil then
            params:show(dc_param_IDs[i]["group"])
            _menu.rebuild_params() 
        end
    end

    function player:inactive()
        if self.name ~= nil then
            params:hide(dc_param_IDs[i]["group"])
            _menu.rebuild_params()
        end
    end

    function player:stop_all()
        -- currently unsupported
    end
    
    function player:modulate(val)
        -- currently unsupported
    end

    function player:describe()
        return {
            name = "drumcrow "..i,
            supports_bend = false,
            supports_slew = false,
            modulate_description = "none",
            note_mod_targets = {"unsupported"},
        }
    end
    
    function player:modulate_note(note, key, value)
        -- currently unsupported
    end

    function player:note_on(note, vel, properties)
        -- expected: note 0..127, vel 0..1
        function check_flock(bird)
            if params:get(dc_param_IDs[bird]["flock"]) >= 2 then
                for j = 1, (params:get(dc_param_IDs[bird]["flock"]) - 1) do
                    crow.dc_note_on((bird + j - 1) % DC_VOICES + 1, note, vel)
                end
            end
        end

        if dc_code_sent == false then 
            print("CAW: resend code to crow! note on")
            return 
        end
        local b = params:get(dc_param_IDs[i]["trig_behavior"])
        if b == 1 then -- individual
            crow.dc_note_on(i, note, vel)
            check_flock(i)
        elseif b == 2 then -- round robin
            dc_robin_idx = dc_robin_idx % DC_VOICES + 1
            crow.dc_note_on(dc_robin_idx, note, vel)
            check_flock(dc_robin_idx)
        else -- all
            for j = 1, DC_VOICES do 
                crow.dc_note_on(j, note, vel)
            end
        end
    end

    function player:note_off(note)
        -- player:play_note will trigger note_on then delay a note_off call
        -- can't set dcAmp to 0 because I don't know if it will be there when note_off triggers
        -- amplitude envelope always decays and each crow output is monophonic, so no need for note_off
    end

    function player:add_params()
        add_drumcrow_params(i) -- called by nb, adds parameters to parameter menu
    end

    if note_players == nil then
        note_players = {} 
    end
    note_players["drumcrow "..i] = player -- name of nb voice in voice selector list
end

function dc_param_update_init()
    dc_param_update_metro = metro.init()
    dc_param_update_metro.event = dc_param_update_loop
    dc_param_update_metro.time  = dc_param_update_time
    dc_param_update_metro:start()
end

function dc_param_update_stop()
    if dc_param_update_metro then
        dc_param_update_metro:stop()
        metro.free(dc_param_update_metro)
    end
end

function dc_synth_update_model_and_shape(ch, m, s)
    params:set(dc_param_IDs[ch]["model"], m, true)
    params:set(dc_param_IDs[ch]["shape"], s, true)
    dc_synth_update_table[ch][1] = m
    dc_synth_update_table[ch][2] = s
    if params:get(dc_param_IDs[ch]["param_behavior"]) == 2 then
        for j = 1, DC_VOICES do
            if ch ~= j then
                params:set(dc_param_IDs[j]["model"], m, true)
                params:set(dc_param_IDs[j]["shape"], s, true)
                dc_synth_update_table[j][1] = m
                dc_synth_update_table[j][2] = s
            end
        end
    end
    dc_synth_update_table_dirty = true
end

-- add value to dc_param_update_table to send to crow state table
function dc_param_update_add(ch, k, val) -- k is number
    dc_param_update_table[ch][k] = val
    if params:get(dc_param_IDs[ch]["param_behavior"]) == 2 then
        for j = 1, DC_VOICES do
            if ch ~= j then -- update all the other params
                params:set(dc_param_IDs[j][dc_names[k]], val, true)
                dc_param_update_table[j][k] = val
            end
        end
    end
    dc_param_update_table_dirty = true
end

function dc_param_update_loop() -- called every param_update_time seconds, called directly when loading presets
    if dc_param_update_table_dirty == true and dc_code_sent == true then
        crow.dc_param_update_receive(dc_param_update_table)
        for j = 1, DC_VOICES do dc_param_update_table[j] = {} end -- clear table
        dc_param_update_table_dirty = false
    end
    if dc_synth_update_table_dirty == true and dc_code_sent == true then
        crow.dc_synth_update_receive(dc_synth_update_table)
        for j = 1, DC_VOICES do dc_synth_update_table[j] = {} end -- clear table
        dc_synth_update_table_dirty = false
    end
end

function dc_pre_init() -- called before norns script init
    dc_code_sent = false -- init to false so things don't explode
    build_dc_param_IDs() -- cook up larger strings instead of dynamically creating them during runtime
    for idx = 1, DC_VOICES do
        add_drumcrow_player(idx) -- add 4 nb players to note_players, one player for each output on crow
    end
end

function dc_post_init()
    dc_crow_code_send() -- put update loop computations onto crow hardware
    dc_param_update_init()
end

mod.hook.register("script_pre_init", "drumcrow pre init", dc_pre_init) -- add 4 nb players to note_players, one player for each output on crow
mod.hook.register("script_post_init", "drumcrow post init", dc_post_init) -- add 4 nb players to note_players, one player for each output on crow

-- NOTES:

-- 1 update loop for all 4 outputs, check dyns first
-- BUG: midi note 60 = 261.63 Hz, the denominator above is 261.625 Hz
-- however, using sine shape, var_saw model, I measure 255.5 Hz oscillator on the output of crow
-- I checked a bunch of notes and they're all about -41 cents detuned for each frequency requested
-- so maybe 261.625 Hz / 255.5 Hz = 1.02399 multiplier to frequency for a patch? I have no idea why this happens
-- 2 - 1.02399 = 0.9760078, but that's still +1 cents so 0.97655 I guess and checked
-- cyc = cyc * 0.97655

-- design constraints
-- uses metro 8 on crow
-- FREQ_LIMIT = {114, 114, 101, 101, 114, 114, 114, 114, 114} based on the shape used
-- exponential and logarithmic shapes cost more CPU and thus require a lower max frequency limit
-- tested all 4 oscillators set to exponential and turned up transpose until errors started spamming matron, ended up at 101
-- 114 = 5919 Hz, 101 = 2793 Hz
-- code is sent post norns script init() and will reset all crow initialization or reset all code previously sent to crow 
-- resending code will reset crow and thus reset the behaviors of crow inputs 1 and 2 (example: dreamsequence uses in 2)
-- automatically turn off update flag if dcAmp is not there
-- magical splash function (I just messed around with math.random until it sounded cool, if splash <= 0 it just skips this)
-- amp, lfo, note curve parameter is limited from 2^-5 to 2^5

-- GRAVEYARD
-- k_idx = 
-- {
--     'mfreq', 'note', 'dcAmp', 'pw', 'pw2', 'bit', 'splash',
--     'a_mfreq', 'a_note', 'a_amp', 'a_pw', 'a_pw2', 'a_bit', 'a_cyc', 'a_sym', 'a_curve', 'a_loop', 'a_phase', 
--     'l_mfreq', 'l_note', 'l_amp', 'l_pw', 'l_pw2', 'l_bit', 'l_cyc', 'l_sym', 'l_curve', 'l_loop', 'l_phase', 
--     'n_mfreq', 'n_note', 'n_amp', 'n_pw','n_pw2', 'n_bit', 'n_cyc', 'n_sym', 'n_curve', 'n_loop', 'n_phase', 
--     'transpose', 'model', 'shape',
--     'a_reset', 'l_reset', 'n_reset', 'species'
-- }

-- k_idx = 
-- {
-- mfreq = {1, 0.01, 1},
-- note = {2, 0, 127},
-- dcAmp = {3, -10, 10},
-- pw = {4, -1, 1},
-- pw2 = {5, -10, 10},
-- bit = {6, -10, 180},
-- splash = {7, 0, 3},
-- a_mfreq = {8, -1, 1},
-- a_note = {9, -10, 10},
-- a_amp = {10, -5, 5},
-- a_pw = {11, -2, 2},
-- a_pw2 = {12, -10, 10},
-- a_bit = {13, -20, 20},
-- a_cyc = {14, 0.1, 200},
-- a_sym = {15, -2, 2},
-- a_curve = {16, -5, 5},
-- a_loop = {17, 1, 2},
-- a_phase = {18, -1, 1},
-- l_mfreq = {19, -1, 1},
-- l_note = {20, -10, 10},
-- l_amp = {21, -5, 5},
-- l_pw = {22, -2, 2},
-- l_pw2 = {23, -10, 10},
-- l_bit = {24, -20, 20},
-- l_cyc = {25, 0.1, 200},
-- l_sym = {26, -2, 2},
-- l_curve = {27, -10, 10},
-- l_loop = {28, 1, 2},
-- l_phase = {29, -1, 1},
-- n_mfreq = {30, -1, 1},
-- n_note = {31, -10, 10},
-- n_amp = {32, -5, 5},
-- n_pw = {33, -2, 2},
-- n_pw2 = {34, -10, 10},
-- n_bit = {35, -20, 20},
-- n_cyc = {36, 0.1, 200},
-- n_sym = {37, -2, 2},
-- n_curve = {38, -10, 10},
-- n_loop = {39, 1, 2},
-- n_phase = {40, -1, 1},
-- transpose = {41, -120, 120},
-- model = {42, 1, 7},
-- shape = {43, 1, 9},
-- a_reset = {44, 1, 2},
-- l_reset = {45, 1, 2},
-- n_reset = {46, 1, 2},
-- species = {47, 1, 15}
-- }

-- function rerange(val, in_min, in_max, t_min, t_max)
--     local new_val = ((val - in_min) / (in_max - in_min)) * (t_max - t_min) + t_min
--     if t_max == 255 then
--         return math.floor(new_val)
--     else
--         return new_val
--     end
-- end

-- function param2number(in_str)
--     for k, v in pairs(k_idx) do
--         if in_str == k then 
--             return k_idx[k][1] 
--         end
--     end
-- end

-- function number2param(in_num)
--     for k, v in pairs(k_idx) do
--         if in_num == k_idx[k][1] then 
--             return k 
--         end
--     end
-- end
-- function iitesting(a,b)
--     ii.crow[1].call2(a,b)
-- end

-- ii.self.call2 = function(ch, k) -- get state
--     asdf = 1
--     for i = 1, k do
--         ii.crow[1].call1(asdf)
--         asdf = asdf + 1
--     end
-- end

-- ii.self.call1 = function(v) -- rx and print
--     print("iiCAW: "..v)
-- end
-- value = value ^ (2 ^ curve)
-- crow.dc_set_synth(i, preset_model, preset_shape)  -- set crow model and shape

--     if params:get(dc_param_IDs[i]["param_behavior"]) == 1 then
--         for k, v in pairs(preset_values) do
--             if k ~= "model" and k ~= "shape" then
--                 print(i, k, v)
--                 params:set(dc_param_IDs[i][k], v, true) -- set norns param
--                 dc_param_update_table[i][k] = v -- set crow state
--                 dc_param_update_table_dirty = true
--                 dc_param_update_loop() -- update immediately, one value at a time
--             end
--         end
--         -- params:set(dc_param_IDs[i]["model"], preset_model) -- set norns model
--         -- params:set(dc_param_IDs[i]["shape"], preset_shape) -- set norns shape
--         -- dc_synth_update_table[i][1] = preset_model
--         -- dc_synth_update_table[i][2] = preset_shape
--     else
--         for j = 1, DC_VOICES do
--             for k, v in pairs(preset_values) do
--                 if k ~= "model" and k ~= "shape" then
--                     print(i, k, v)
--                     params:set(dc_param_IDs[j][k], v, true) -- set norns param
--                     dc_param_update_table[j][k] = v -- set crow state
--                     dc_param_update_table_dirty = true
--                     dc_param_update_loop() -- update immediately, one value at a time
--                 end
--             end
--         end
--         -- for j = 1, DC_VOICES do
--         --     dc_synth_update_model(j, preset_model)
--         --     dc_synth_update_shape(j, preset_shape)
--         --     -- params:set(dc_param_IDs[j]["model"], preset_model)
--         --     -- params:set(dc_param_IDs[j]["shape"], preset_shape)
--         --     -- dc_synth_update_table[j][1] = preset_model
--         --     -- dc_synth_update_table[j][2] = preset_shape
--         -- end
--     end
--     dc_synth_update_model(i, preset_model)
--     dc_synth_update_shape(i, preset_shape)
--     -- dc_param_update_table_dirty = true
--     -- dc_synth_update_table_dirty = true
-- end

-- -- v is +/-9999.9999, split into 2 msg each 4 digits, i2c only sends 16 signed int
-- function send_state_value_i2c(crowidx, ch, k, v)
--     local new_v = 0
--     if v < 0 then
--         new_v = v * -1
--         new_v = new_v % 10000
--         ii.crow[crowidx].call4(2, ch, k, math.floor(new_v) * -1)
--         ii.crow[crowidx].call4(3, ch, k, math.floor((new_v % 1) * 10000) * -1)
--     else
--         new_v = v % 10000
--         ii.crow[crowidx].call4(2, ch, k, math.floor(new_v))
--         ii.crow[crowidx].call4(3, ch, k, math.floor((new_v % 1) * 10000))
--     end
-- end