-- nb_drumcrow voice for nb
-- turns crow into a synth
-- nb author: sixolet
-- drumcrow author: postsolarpunk
dc_musicutil = require("musicutil")
local mod = require 'core/mods'
local dc_models = {'var_saw','bytebeat','noise','FMstep','ASLsine','ASLharmonic','bytebeat5'}
local dc_shapes = {'"linear"','"sine"','"logarithmic"','"exponential"','"now"','"wait"','"over"','"under"','"rebound"'}

-- local DC_NUM_PARAMS = 40
local update_drumcrow_ID = {}

local dc_preset_names = {'init', 'perc', 'noise', 'trigger', 'envelope'}
dc_preset_values = {
{ -- init, oscillator, decay envelope
    mfreq = 1, note = 0, amp = 4, pw = 0, pw2 = 0, bit = 0, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10,  amp_symmetry = -1, amp_curve = 2,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
    mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
},
{ -- perc, oscillator, fast pitch modulation envelope
    mfreq = 1, note = 0, amp = 4, pw = 0.25, pw2 = 0, bit = 0, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 30.06,  amp_symmetry = -1, amp_curve = -4.3,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 4.6, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 7.5, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
    mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
},
{ -- noise, oscillator, requires "noise" model, fast amplitude cycle
    mfreq = 1, note = 0, amp = 4, pw = 0.37, pw2 = 3.44, bit = 0, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 46.63,  amp_symmetry = -1, amp_curve = 2,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 3, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 2.6, note_symmetry = -1, note_curve = 0.8, note_type = 0, note_phase = 1, 
    mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
},
{ -- CV trigger, requires "now" shape and "var_saw" model
    mfreq = 1, note = 0, amp = -5, pw = -1, pw2 = 0, bit = 0, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 101.42,  amp_symmetry = -1, amp_curve = -5,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 0, note_type = 0, note_phase = 1, 
    mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
},
{ -- CV decay envelope, requires "now" shape and "var_saw" model, use amp envelope parameters to control envelope shape
    mfreq = 1, note = 0, amp = -5, pw = -1, pw2 = 0, bit = 0, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10.11,  amp_symmetry = -1, amp_curve = 0,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 0, note_type = 0, note_phase = 1, 
    mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
},
}
local dc_names = {
    "mfreq", "note", "amp", "pw", "pw2", "bit", "splash",
    "amp_mfreq", "amp_note", "amp_amp", "amp_pw", "amp_pw2", "amp_bit", "amp_cycle", "amp_symmetry", "amp_curve", "amp_type", "amp_phase", 
    "lfo_mfreq", "lfo_note", "lfo_amp", "lfo_pw", "lfo_pw2", "lfo_bit", "lfo_cycle", "lfo_symmetry", "lfo_curve", "lfo_type", "lfo_phase", 
    "note_mfreq", "note_note", "note_amp", "note_pw", "note_pw2", "note_bit", "note_cycle", "note_symmetry", "note_curve", "note_type", "note_phase",  
    "mfreq_mod", "note_mod", "amp_mod", "pw_mod", "pw2_mod", "bit_mod", "splash_mod"
} -- only used to initialize parameters? do you need this?

-- local dc_preset_values[1] = {
--     mfreq = 1, note = 0, amp = 4, pw = 0, pw2 = 0, bit = 0, splash = 0,
--     amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10,  amp_symmetry = -1, amp_curve = 2,  amp_type = 0,  amp_phase = 1, 
--     lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
--     note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
--     mfreq_mod = 1, note_mod = 1, amp_mod = 1, pw_mod = 1, pw2_mod = 1, bit_mod = 1, splash_mod = 1,
-- } -- synth shape = 1, synth model = 1 when the param "initialize" is triggered
-- -- used in the preset function, can we read arrays from a txt file?

function drumcrow_load_preset(i, properties)
    for k, v in pairs(properties) do
            if k == "amp_phase" then params:set("drumcrow_amp_phase_"..i, 1)
        elseif k == "lfo_phase" then params:set("drumcrow_lfo_phase_"..i, -1)
        elseif k == "note_phase" then params:set("drumcrow_note_phase_"..i, 1)
        else
            params:set("drumcrow_"..k.."_"..i, v)
        end
    end
end

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
    params:add_group("drumcrow_group_"..i, "drumcrow voice "..i, 5 + 7 + 11 + 11 + 11 + 7)
    params:hide("drumcrow_group_"..i)
    params:add_trigger("drumcrow_on_off_"..i, "on_off")
    params:add_option("drumcrow_synth_preset_"..i, "synth_preset", dc_preset_names, 1)
    params:add_trigger("drumcrow_load_preset_"..i, "load_preset")
    params:add_option("drumcrow_synth_shape_"..i, "synth_shape", dc_shapes, 2)
    params:add_option("drumcrow_synth_model_"..i, "synth_model", dc_models, 1) -- 5

    -- TO DO better way to set up parameters: table of control specs per parameter, for loop, lookup control spec and init values per parameter label
    params:add_control("drumcrow_mfreq_"..i, "mfreq", controlspec.new(0.01,1,"lin",0.005, dc_preset_values[1][dc_names[1]], "", 0.005, false))
    params:add_control("drumcrow_note_"..i, "note", controlspec.new(0,127,"lin",0.01, dc_preset_values[1][dc_names[2]]))
    params:add_control("drumcrow_amp_"..i, "amp", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[3]]))
    params:add_control("drumcrow_pw_"..i, "pw", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[4]], "", 0.002, false))
    params:add_control("drumcrow_pw2_"..i, "pw2", controlspec.new(-10,10,"lin",0.0005, dc_preset_values[1][dc_names[5]], "", 0.002, false))
    params:add_control("drumcrow_bit_"..i, "bit", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[6]], "", 0.005, false))
    params:add_control("drumcrow_splash_"..i, "splash", controlspec.new(0,3,"lin",0.01, dc_preset_values[1][dc_names[7]], "", 0.002, false)) -- 7

    params:add_control("drumcrow_amp_mfreq_"..i, "amp_mfreq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1][dc_names[8]], "", 0.005, false))
    params:add_control("drumcrow_amp_note_"..i, "amp_note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1][dc_names[9]], "", 0.002, false))
    params:add_control("drumcrow_amp_amp_"..i, "amp_amp", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[10]]))
    params:add_control("drumcrow_amp_pw_"..i, "amp_pw", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1][dc_names[11]], "", 0.005, false))
    params:add_control("drumcrow_amp_pw2_"..i, "amp_pw2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[12]], "", 0.005, false))
    params:add_control("drumcrow_amp_bit_"..i, "amp_bit", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[13]], "", 0.005, false))
    params:add_control("drumcrow_amp_cycle_"..i, "amp_cycle", controlspec.new(0.1, 500, 'exp', 0, dc_preset_values[1][dc_names[14]], "", 0.002, false))
    params:add_control("drumcrow_amp_symmetry_"..i, "amp_symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1][dc_names[15]], "", 0.005, false))
    params:add_control("drumcrow_amp_curve_"..i, "amp_curve", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[16]]))
    params:add_control("drumcrow_amp_type_"..i, "amp_type", controlspec.new(0,1,"lin",0.01, dc_preset_values[1][dc_names[17]], "", 1, false))
    params:add_control("drumcrow_amp_phase_"..i, "amp_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[18]], "", 0.002, false)) -- 11

    params:add_control("drumcrow_lfo_mfreq_"..i, "lfo_mfreq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1][dc_names[19]], "", 0.005, false))
    params:add_control("drumcrow_lfo_note_"..i, "lfo_note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1][dc_names[20]], "", 0.002, false))
    params:add_control("drumcrow_lfo_amp_"..i, "lfo_amp", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[21]]))
    params:add_control("drumcrow_lfo_pw_"..i, "lfo_pw", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1][dc_names[22]], "", 0.005, false))
    params:add_control("drumcrow_lfo_pw2_"..i, "lfo_pw2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[23]], "", 0.005, false))
    params:add_control("drumcrow_lfo_bit_"..i, "lfo_bit", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[24]], "", 0.005, false))
    params:add_control("drumcrow_lfo_cycle_"..i, "lfo_cycle", controlspec.new(0.1, 500, 'exp', 0, dc_preset_values[1][dc_names[25]], "", 0.002, false))
    params:add_control("drumcrow_lfo_symmetry_"..i, "lfo_symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1][dc_names[26]], "", 0.005, false))
    params:add_control("drumcrow_lfo_curve_"..i, "lfo_curve", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[27]]))
    params:add_control("drumcrow_lfo_type_"..i, "lfo_type", controlspec.new(0,1,"lin",0.01, dc_preset_values[1][dc_names[28]], "", 1, false))
    params:add_control("drumcrow_lfo_phase_"..i, "lfo_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[29]], "", 0.002, false)) -- 11

    params:add_control("drumcrow_note_mfreq_"..i, "note_mfreq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1][dc_names[30]], "", 0.005, false))
    params:add_control("drumcrow_note_note_"..i, "note_note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1][dc_names[31]], "", 0.002, false))
    params:add_control("drumcrow_note_amp_"..i, "note_amp", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[32]]))
    params:add_control("drumcrow_note_pw_"..i, "note_pw", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1][dc_names[33]], "", 0.005, false))
    params:add_control("drumcrow_note_pw2_"..i, "note_pw2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[34]], "", 0.005, false))
    params:add_control("drumcrow_note_bit_"..i, "note_bit", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[35]], "", 0.005, false))
    params:add_control("drumcrow_note_cycle_"..i, "note_cycle", controlspec.new(0.1, 500, 'exp', 0, dc_preset_values[1][dc_names[36]], "", 0.002, false))
    params:add_control("drumcrow_note_symmetry_"..i, "note_symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1][dc_names[37]], "", 0.005, false))
    params:add_control("drumcrow_note_curve_"..i, "note_curve", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[38]]))
    params:add_control("drumcrow_note_type_"..i, "note_type", controlspec.new(0,1,"lin",0.01, dc_preset_values[1][dc_names[39]], "", 1, false)) 
    params:add_control("drumcrow_note_phase_"..i, "note_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[40]], "", 0.002, false)) -- 11

    -- external modulation
    params:add_control("drumcrow_mfreq_mod_"..i, "mfreq_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[41]]))
    params:add_control("drumcrow_note_mod_"..i, "note_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[42]]))
    params:add_control("drumcrow_amp_mod_"..i, "amp_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[43]]))
    params:add_control("drumcrow_pw_mod_"..i, "pw_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[44]]))
    params:add_control("drumcrow_pw2_mod_"..i, "pw2_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[45]]))
    params:add_control("drumcrow_bit_mod_"..i, "bit_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[46]]))
    params:add_control("drumcrow_splash_mod_"..i, "splash_mod", controlspec.new(0, 1, "lin", 0, dc_preset_values[1][dc_names[47]])) -- 7

    -- params:hide("drumcrow_mfreq_mod")
    -- params:hide("drumcrow_note_mod")
    -- params:hide("drumcrow_amp_mod")
    -- params:hide("drumcrow_pw_mod")
    -- params:hide("drumcrow_pw2_mod")
    -- params:hide("drumcrow_bit_mod")
    -- params:hide("drumcrow_splash_mod")

    drumcrow_setup_synth(i, params:get("drumcrow_synth_model_"..i), params:get("drumcrow_synth_shape_"..i))

    params:set_action("drumcrow_on_off_"..i, function()
        if update_drumcrow_ID[i] == nil then
            update_drumcrow_start(i) 
        else
            update_drumcrow_stop(i)
        end
    end)
    params:set_action("drumcrow_load_preset_"..i, function() 
        drumcrow_load_preset(i, dc_preset_values[params:get("drumcrow_synth_preset_"..i)])
    end)
    params:set_action("drumcrow_synth_shape_"..i, function(s)
        drumcrow_setup_synth(i, params:get("drumcrow_synth_model_"..i), s) end)
    params:set_action("drumcrow_synth_model_"..i, function(s)
        drumcrow_setup_synth(i, s, params:get("drumcrow_synth_shape_"..i)) end)
end

function update_drumcrow_start(i)
    if update_drumcrow_ID[i] == nil then
        local dc_update_time = 0.006
        update_drumcrow_ID[i] = clock.run(update_drumcrow, dc_update_time, i)
        print("drumcrow "..i.." engine ON")
    end
end

function update_drumcrow_stop(i)
    if update_drumcrow_ID[i] ~= nil then
        clock.cancel(update_drumcrow_ID[i])
        update_drumcrow_ID[i] = nil
        crow.output[i].dyn.amp = 0 -- should mute any model
        print("drumcrow "..i.." engine OFF")
    end
end

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
        params:set("drumcrow_amp_phase_"..i, acc(params:get("drumcrow_amp_phase_"..i), params:get("drumcrow_amp_cycle_"..i), dc_update_time, params:get("drumcrow_amp_type_"..i) > 0))
        local ampenv = peak(params:get("drumcrow_amp_phase_"..i), params:get("drumcrow_amp_symmetry_"..i), params:get("drumcrow_amp_curve_"..i))
        params:set("drumcrow_lfo_phase_"..i, acc(params:get("drumcrow_lfo_phase_"..i), params:get("drumcrow_lfo_cycle_"..i), dc_update_time, params:get("drumcrow_lfo_type_"..i) > 0))
        local lfo = peak(params:get("drumcrow_lfo_phase_"..i), params:get("drumcrow_lfo_symmetry_"..i), params:get("drumcrow_lfo_curve_"..i))
        params:set("drumcrow_note_phase_"..i, acc(params:get("drumcrow_note_phase_"..i), params:get("drumcrow_note_cycle_"..i), dc_update_time, params:get("drumcrow_note_type_"..i) > 0))
        local noteenv = peak(params:get("drumcrow_note_phase_"..i), params:get("drumcrow_note_symmetry_"..i), params:get("drumcrow_note_curve_"..i))
        
        -- calculate internal modulation of parameters
        local max_freq = params:get("drumcrow_mfreq_"..i) + (noteenv * params:get("drumcrow_note_mfreq_"..i)) + (lfo * params:get("drumcrow_lfo_mfreq_"..i)) + (ampenv * params:get("drumcrow_amp_mfreq_"..i)) 
        local note_up  = params:get("drumcrow_note_"..i)/12.7 + (noteenv * params:get("drumcrow_note_note_"..i)) + (lfo * params:get("drumcrow_lfo_note_"..i)) + (ampenv * params:get("drumcrow_amp_note_"..i)) 
        local volume   = (noteenv * params:get("drumcrow_note_amp_"..i) * params:get("drumcrow_amp_"..i)) + (lfo * params:get("drumcrow_lfo_amp_"..i) * params:get("drumcrow_amp_"..i)) + (ampenv * params:get("drumcrow_amp_amp_"..i) * params:get("drumcrow_amp_"..i)) 
        local pw       = params:get("drumcrow_pw_"..i)    + (noteenv * params:get("drumcrow_note_pw_"..i))    + (lfo * params:get("drumcrow_lfo_pw_"..i))    + (ampenv * params:get("drumcrow_amp_pw_"..i))
        local pw2      = params:get("drumcrow_pw2_"..i)   + (noteenv * params:get("drumcrow_note_pw2_"..i))   + (lfo * params:get("drumcrow_lfo_pw2_"..i))   + (ampenv * params:get("drumcrow_amp_pw2_"..i))
        local bitz     = params:get("drumcrow_bit_"..i)   + (noteenv * params:get("drumcrow_note_bit_"..i))   + (lfo * params:get("drumcrow_lfo_bit_"..i))   + (ampenv * params:get("drumcrow_amp_bit_"..i))
        local sploosh  = params:get("drumcrow_splash_"..i)
         
        -- calculate external modulation, sequence the attenuation of internal values for now, _mod range 0 ... 1
        max_freq = max_freq * params:get("drumcrow_mfreq_mod_"..i)
        note_up = note_up * params:get("drumcrow_note_mod_"..i)
        volume = volume * params:get("drumcrow_amp_mod_"..i)
        pw = pw * params:get("drumcrow_pw_mod_"..i)
        pw2 = pw2 * params:get("drumcrow_pw2_mod_"..i)
        bitz = bitz * params:get("drumcrow_bit_mod_"..i)
        sploosh = sploosh * params:get("drumcrow_splash_mod_"..i)

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
        mdl = params:get("drumcrow_synth_model_"..i)
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
            params:show("drumcrow_group_"..i)
            _menu.rebuild_params()
        end
    end

    function player:inactive()
        if self.name ~= nil then
            params:hide("drumcrow_group_"..i)
            _menu.rebuild_params()
        end
    end

    function player:stop_all()
        if update_drumcrow_ID[i] ~= nil then
            clock.cancel(update_drumcrow_ID[i])
            update_drumcrow_ID[i] = nil
            crow.output[i].dyn.amp = 0 -- should mute itself
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
        params:set("drumcrow_"..key.."_"..i, value)
    end

    function player:note_on(note, vel, properties)
        if properties == nil then
            properties = {}
        end

        -- set volume, note, trigger envelopes
        if params:get("drumcrow_amp_phase_"..i)  >= params:get("drumcrow_amp_symmetry_"..i)  then params:set("drumcrow_amp_phase_"..i, -1)  end
        if params:get("drumcrow_note_phase_"..i) >= params:get("drumcrow_note_symmetry_"..i) then params:set("drumcrow_note_phase_"..i, -1) end
        params:set("drumcrow_amp_"..i,  (vel/127)  * 20 - 10)
        params:set("drumcrow_note_"..i, note)
        print("drumcrow "..i.." note on triggered")
    end

    function player:note_off(note)
        -- I think I just want note_on() and stop_all() as a backup, it's an AD envelope, not ASR
        -- crow.output[i].dyn.amp = 0
        -- params:set("drumcrow_amp_"..i, 0)
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