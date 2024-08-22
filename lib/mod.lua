-- nb_drumcrow voice for nb
-- turns crow into a synth
-- drumcrow author: postsolarpunk
-- drumcrow author: license 
-- nb author: sixolet
local mod = require 'core/mods'

-- dc_update_time = 0.1 -- 0.05 seems okay but too slow imo, 0.01 fast enough but lags when all 4 are running, it used to be 0.006 awhile ago
-- put this onto the update_loop, set update time to 0.005 but it spams event queue full at this rate for the "exponential" and "logarithmic" shapes
-- trying 0.008
dc_code_sent = false
dc_code_resent = false
dc_param_update_time = 0.25 -- sends message to crow to update parameters if they have changed, only send message if there's a change
dc_param_update_table = {} -- table[channel][key] param values for state matrix on crow
for j = 1, 4 do 
    dc_param_update_table[j] = {}
end
dc_param_update_table_dirty = false
dc_param_IDs = {}
dc_trig_behavior = {"individual", "round robin", "all"}
dc_param_behavior = {"individual", "all"}
dc_poly_idx = 1
dc_param_update_metro = nil
dc_models = {'var_saw','bytebeat','noise','FMstep','ASLsine','ASLharmonic','bytebeat5'}
dc_shapes = {'"linear"','"sine"','"logarithmic"','"exponential"','"now"','"wait"','"over"','"under"','"rebound"'}
dc_update_ID = {nil, nil, nil, nil}
dc_preset_names = {'init', 'perc', 'noise', 'trigger', 'envelope', 'scale'}
dc_names = {
    "mfreq", "note", "dcAmp", "pw", "pw2", "bit", "splash",
    "amp_mfreq", "amp_note", "amp_amp", "amp_pw", "amp_pw2", "amp_bit", "amp_cycle", "amp_symmetry", "amp_curve", "amp_type", "amp_phase", 
    "lfo_mfreq", "lfo_note", "lfo_amp", "lfo_pw", "lfo_pw2", "lfo_bit", "lfo_cycle", "lfo_symmetry", "lfo_curve", "lfo_type", "lfo_phase", 
    "note_mfreq", "note_note", "note_amp", "note_pw", "note_pw2", "note_bit", "note_cycle", "note_symmetry", "note_curve", "note_type", "note_phase",
    "transpose", "model", "shape"
}

function build_large_strings()
    -- build dc_param_IDs, this returns a param ID string: dc_param_IDs[i]["mfreq"]
    for i = 1, 4 do
        dc_param_IDs[i] = {}
        for j = 1, #dc_names do
            dc_param_IDs[i][dc_names[j]] = "drumcrow_"..dc_names[j].."_"..i
        end
        dc_param_IDs[i]["group"] = "dc_group_"..i
        -- dc_param_IDs[i]["on_off"] = "dc_on_off_"..i
        dc_param_IDs[i]["trig_behavior"] = "dc_trig_behavior_"..i
        dc_param_IDs[i]["param_behavior"] = "dc_param_behavior_"..i
        dc_param_IDs[i]["synth_preset"] = "dc_synth_preset_"..i
        dc_param_IDs[i]["load_preset"] = "dc_load_preset_"..i
        dc_param_IDs[i]["synth_shape"] = "dc_synth_shape_"..i
        dc_param_IDs[i]["synth_model"] = "dc_synth_model_"..i
        dc_param_IDs[i]["send_code"] = "dc_send_code_"..i
    end
end

dc_preset_values = {
{ -- init, oscillator, decay envelope VCA, sine shape, var_saw model
    mfreq = 1, note = 60, dcAmp = -5, pw = 0, pw2 = 0, bit = -0.0069445, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 0.5,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 2,  amp_symmetry = -1, amp_curve = 2,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
    transpose = 0
},
{ -- perc, oscillator, fast pitch modulation envelope, any shape, var_saw model
    mfreq = 1, note = 60, dcAmp = -5, pw = 0.15, pw2 = 0, bit = -0.0069445, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 30.06,  amp_symmetry = -1, amp_curve = -4.3,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 3, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 7.5, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
    transpose = 0
},
{ -- noise, oscillator, fast amplitude cycle, noise model, any shape, noise model
    mfreq = 1, note = 60, dcAmp = -5, pw = 0.37, pw2 = 3.44, bit = -0.0069445, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 46.63,  amp_symmetry = -1, amp_curve = 2,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 3, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 2.6, note_symmetry = -1, note_curve = 0.8, note_type = 0, note_phase = 1, 
    transpose = 0
},
{ -- CV trigger, requires "now" shape and "var_saw" model
    mfreq = 1, note = 60, dcAmp = -5, pw = -1, pw2 = 0, bit = -0.0069445, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 101.42,  amp_symmetry = -1, amp_curve = -5,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 0, note_type = 0, note_phase = 1, 
    transpose = 0
},
{ -- CV decay envelope, requires "now" shape and "var_saw" model, use amp envelope parameters to control envelope shape
    mfreq = 1, note = 60, dcAmp = -5, pw = -1, pw2 = 0, bit = -0.0069445, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10.11,  amp_symmetry = -1, amp_curve = 0,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 6.1,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 0, note_type = 0, note_phase = 1, 
    transpose = 0
},
{ -- scale, requires "now" shape and "var_saw" model, specifically calculated bitcrush value for quantizing output (bit = 0.05555...)
-- use with v/oct input on another oscillator, create arpeggios with slow LFOs and small amplitude modulation values (amp_amp, lfo_amp, note_amp)
    mfreq = 1, note = 60, dcAmp = -5, pw = -1, pw2 = 0, bit = 0.0555555, splash = 0,
    amp_mfreq = 0,  amp_note = 0,  amp_amp = 0.2,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 6.27,  amp_symmetry = -1, amp_curve = 0,  amp_type = 0,  amp_phase = 1, 
    lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0.4,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 0.75,  lfo_symmetry = 0,  lfo_curve = -1,  lfo_type = 1,  lfo_phase = -1, 
    note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 0, note_type = 0, note_phase = 1, 
    transpose = 0
},
}

function dc_load_preset(i, properties)
    preset_selection = params:get(dc_param_IDs[i]["synth_preset"])
    if preset_selection == 1 then
        preset_model = 1
        preset_shape = 2 -- init, var_saw, sine
    elseif preset_selection == 2 then
        preset_model = 1
        preset_shape = 9 -- perc, var_saw, rebound
    elseif preset_selection == 3 then
        preset_model = 3
        preset_shape = 1 -- noise, noise, linear
    elseif preset_selection == 4 then
        preset_model = 1
        preset_shape = 5 -- trigger, var_saw, now
    elseif preset_selection == 5 then
        preset_model = 1
        preset_shape = 5 -- trigger, var_saw, now
    elseif preset_selection == 6 then
        preset_model = 1
        preset_shape = 5 -- trigger, var_saw, now
    end

    if params:get(dc_param_IDs[i]["param_behavior"]) == 1 then
        for k, v in pairs(properties) do
            if     k == "amp_phase"  then params:set(dc_param_IDs[i]["amp_phase"],  1)
            elseif k == "lfo_phase"  then params:set(dc_param_IDs[i]["lfo_phase"], -1)
            elseif k == "note_phase" then params:set(dc_param_IDs[i]["note_phase"], 1)
            else
                params:set(dc_param_IDs[i][k], v)
                dc_param_update_table[i][k] = v
            end
            dc_param_update_table_dirty = true
            dc_param_update_loop() -- update immediately
        end
        params:set(dc_param_IDs[i]["synth_model"], preset_model, false)
        params:set(dc_param_IDs[i]["synth_shape"], preset_shape, false)
        crow.dc_set_synth(i, preset_model, preset_shape)
    else
        for k, v in pairs(properties) do
            if     k == "amp_phase"  then params:set(dc_param_IDs[i]["amp_phase"],  1)
            elseif k == "lfo_phase"  then params:set(dc_param_IDs[i]["lfo_phase"], -1)
            elseif k == "note_phase" then params:set(dc_param_IDs[i]["note_phase"], 1)
            else
                for j = 1, 4 do
                    params:set(dc_param_IDs[j][k], v)
                    dc_param_update_table[j][k] = v
                end
            end
            dc_param_update_table_dirty = true
            dc_param_update_loop() -- update immediately
        end
        for j = 1, 4 do
            params:set(dc_param_IDs[j]["synth_model"], preset_model, false)
            params:set(dc_param_IDs[j]["synth_shape"], preset_shape, false)
            crow.dc_set_synth(j, preset_model, preset_shape)
        end
    end
    dc_param_update_table_dirty = true
end


local function add_drumcrow_params(i)
    -- create drumcrow parameter menu for nb to show/hide
    params:add_group(dc_param_IDs[i]["group"], "drumcrow voice "..i, 7 + 7 + 1 + 11 + 11 + 11) -- number of entries in the dc_group_ menu
    params:hide(dc_param_IDs[i]["group"])
    params:add_trigger(dc_param_IDs[i]["send_code"], "resend code to crow")
    params:set_action(dc_param_IDs[i]["send_code"], function() dc_resend_code() end)

    params:add_option(dc_param_IDs[i]["trig_behavior"], "trigger behavior", dc_trig_behavior, 1)
    params:set_action(dc_param_IDs[i]["trig_behavior"], function(x) 
        for j = 1, 4 do
            if i ~= j then
                params:set(dc_param_IDs[j]["trig_behavior"], x) -- set all 4 params to this value
            end
        end
    end)

    params:add_option(dc_param_IDs[i]["param_behavior"], "param behavior", dc_param_behavior, 1)
    params:set_action(dc_param_IDs[i]["param_behavior"], function(x) 
        for j = 1, 4 do
            if i ~= j then
                params:set(dc_param_IDs[j]["param_behavior"], x) -- set all 4 params to this value
            end
        end
        if dc_code_sent == false then 
            print("CAW: resend code to crow!")
            return 
        else
            crow("dc_param_behavior = " .. x)
        end
    end)
    params:add_option(dc_param_IDs[i]["synth_preset"], "synth preset", dc_preset_names, 1)
    params:add_trigger(dc_param_IDs[i]["load_preset"], "load preset")
    params:add_option(dc_param_IDs[i]["synth_shape"], "synth shape", dc_shapes, 2)
    params:add_option(dc_param_IDs[i]["synth_model"], "synth model", dc_models, 1) -- 7 params

    -- oscillator parameters
    params:add_control(dc_param_IDs[i]["mfreq"], "max freq", controlspec.new(0.01,1,"lin",0.005, dc_preset_values[1][dc_names[1]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["mfreq"], function(x) dc_param_update_add(i, dc_names[1], x) end)
    params:add_control(dc_param_IDs[i]["note"], "osc note", controlspec.new(0,127,"lin",0.01, dc_preset_values[1][dc_names[2]])) -- hide, set by note_on
    params:hide(dc_param_IDs[i]["note"])
    params:add_control(dc_param_IDs[i]["transpose"], "transpose", controlspec.new(-120,120,"lin",1, dc_preset_values[1][dc_names[41]], "", 1/240, false))
    params:set_action( dc_param_IDs[i]["transpose"], function(x) dc_param_update_add(i, dc_names[41], x) end)
    params:add_control(dc_param_IDs[i]["dcAmp"], "amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[3]])) -- hide, set by note_on
    params:hide(dc_param_IDs[i]["dcAmp"])
    params:add_control(dc_param_IDs[i]["pw"], "pulse width", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[4]], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["pw"], function(x) dc_param_update_add(i, dc_names[4], x) end)
    params:add_control(dc_param_IDs[i]["pw2"], "pulse width 2", controlspec.new(-10,10,"lin",0.0005, dc_preset_values[1][dc_names[5]], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["pw2"], function(x) dc_param_update_add(i, dc_names[5], x) end)
    params:add_control(dc_param_IDs[i]["bit"], "bitcrush", controlspec.new(-9.7569445,9.7430555,"lin",0.0000005, dc_preset_values[1][dc_names[6]], "", 0.00125, false))
    params:set_action( dc_param_IDs[i]["bit"], function(x) dc_param_update_add(i, dc_names[6], x) end) -- 7 params
        -- magic bit numbers
        -- crow.output[i].scale({}, 2, bitz * 3) here's the bitcrush quantization
        -- if bitz is 0.0555555555, then there's 2 steps per "octave = bitz * 3 = 0.1666666V". Then if you multiply 0.166666V by 6, you get 0.999999 V which is 6 chunks with 2 steps each
        -- this is close to 1 V/octave scaling, perhaps this is just intonation or something close to that
        -- using step size of 0.00125 we can get multiples of 0.05555555 as the bit value, and some inbetween values for quantizing output voltage
        -- to set bitcrush off, bit should be less than 0, so I subtracted 0.0125 until it's less than 0 as the "default value" = -0.0069445
        -- min and max limits are calculated as values "close to -10 .. +10" using 0.00125 as a step size from -0.0069445. 
    params:add_control(dc_param_IDs[i]["splash"], "splash", controlspec.new(0,3,"lin",0.01, dc_preset_values[1][dc_names[7]], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["splash"], function(x) dc_param_update_add(i, dc_names[7], x) end) -- 1 params

    -- amplitude envelope parameters
    params:add_control(dc_param_IDs[i]["amp_mfreq"], "amp -> max freq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1][dc_names[8]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["amp_mfreq"], function(x) dc_param_update_add(i, dc_names[8], x) end)
    params:add_control(dc_param_IDs[i]["amp_note"], "amp -> osc note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1][dc_names[9]], "", 0.001, false))
    params:set_action( dc_param_IDs[i]["amp_note"], function(x) dc_param_update_add(i, dc_names[9], x) end)
    params:add_control(dc_param_IDs[i]["amp_amp"], "amp -> amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[10]]))
    params:set_action( dc_param_IDs[i]["amp_amp"], function(x) dc_param_update_add(i, dc_names[10], x) end)
    params:add_control(dc_param_IDs[i]["amp_pw"], "amp -> pulse width", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1][dc_names[11]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["amp_pw"], function(x) dc_param_update_add(i, dc_names[11], x) end)
    params:add_control(dc_param_IDs[i]["amp_pw2"], "amp -> pulse width 2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[12]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["amp_pw2"], function(x) dc_param_update_add(i, dc_names[12], x) end)
    params:add_control(dc_param_IDs[i]["amp_bit"], "amp -> bitcrush", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[13]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["amp_bit"], function(x) dc_param_update_add(i, dc_names[13], x) end)
    params:add_control(dc_param_IDs[i]["amp_cycle"], "amp cycle time", controlspec.new(0.1, 200, 'exp', 0, dc_preset_values[1][dc_names[14]], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["amp_cycle"], function(x) dc_param_update_add(i, dc_names[14], x) end)
    params:add_control(dc_param_IDs[i]["amp_symmetry"], "amp symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1][dc_names[15]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["amp_symmetry"], function(x) dc_param_update_add(i, dc_names[15], x) end)
    params:add_control(dc_param_IDs[i]["amp_curve"], "amp curve", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[16]])) -- not sure why this is -5/+5 but I think it had something to do with amplitude
    params:set_action( dc_param_IDs[i]["amp_curve"], function(x) dc_param_update_add(i, dc_names[16], x) end)
    params:add_control(dc_param_IDs[i]["amp_type"], "amp loop on/off", controlspec.new(0,1,"lin",0.01, dc_preset_values[1][dc_names[17]], "", 1, false))
    params:set_action( dc_param_IDs[i]["amp_type"], function(x) dc_param_update_add(i, dc_names[17], x) end)
    params:add_control(dc_param_IDs[i]["amp_phase"], "amp_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[18]], "", 0.002, false)) -- 11 params
    params:set_action( dc_param_IDs[i]["amp_phase"], function(x) dc_param_update_add(i, dc_names[18], x) end)
    params:hide(dc_param_IDs[i]["amp_phase"])

    -- LFO parameters
    params:add_control(dc_param_IDs[i]["lfo_mfreq"], "lfo -> max freq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1][dc_names[19]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["lfo_mfreq"], function(x) dc_param_update_add(i, dc_names[19], x) end)
    params:add_control(dc_param_IDs[i]["lfo_note"], "lfo -> osc note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1][dc_names[20]], "", 0.001, false))
    params:set_action( dc_param_IDs[i]["lfo_note"], function(x) dc_param_update_add(i, dc_names[20], x) end)
    params:add_control(dc_param_IDs[i]["lfo_amp"], "lfo -> amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[21]]))
    params:set_action( dc_param_IDs[i]["lfo_amp"], function(x) dc_param_update_add(i, dc_names[21], x) end)
    params:add_control(dc_param_IDs[i]["lfo_pw"], "lfo -> pulse width", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1][dc_names[22]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["lfo_pw"], function(x) dc_param_update_add(i, dc_names[22], x) end)
    params:add_control(dc_param_IDs[i]["lfo_pw2"], "lfo -> pulse width 2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[23]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["lfo_pw2"], function(x) dc_param_update_add(i, dc_names[23], x) end)
    params:add_control(dc_param_IDs[i]["lfo_bit"], "lfo -> bitcrush", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[24]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["lfo_bit"], function(x) dc_param_update_add(i, dc_names[24], x) end)
    params:add_control(dc_param_IDs[i]["lfo_cycle"], "lfo cycle time", controlspec.new(0.1, 200, 'exp', 0, dc_preset_values[1][dc_names[25]], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["lfo_cycle"], function(x) dc_param_update_add(i, dc_names[25], x) end)
    params:add_control(dc_param_IDs[i]["lfo_symmetry"], "lfo symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1][dc_names[26]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["lfo_symmetry"], function(x) dc_param_update_add(i, dc_names[26], x) end)
    params:add_control(dc_param_IDs[i]["lfo_curve"], "lfo curve", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[27]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["lfo_curve"], function(x) dc_param_update_add(i, dc_names[27], x) end)
    params:add_control(dc_param_IDs[i]["lfo_type"], "lfo loop on/off", controlspec.new(0,1,"lin",0.01, dc_preset_values[1][dc_names[28]], "", 1, false))
    params:set_action( dc_param_IDs[i]["lfo_type"], function(x) dc_param_update_add(i, dc_names[28], x) end)
    params:add_control(dc_param_IDs[i]["lfo_phase"], "lfo_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[29]], "", 0.002, false)) -- 11 params
    params:hide(dc_param_IDs[i]["lfo_phase"])

    -- note envelope parameters
    params:add_control(dc_param_IDs[i]["note_mfreq"], "note -> max freq", controlspec.new(-1,1,"lin",0.005, dc_preset_values[1][dc_names[30]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["note_mfreq"], function(x) dc_param_update_add(i, dc_names[30], x) end)
    params:add_control(dc_param_IDs[i]["note_note"], "note -> osc note", controlspec.new(-10,10,"lin",0.001, dc_preset_values[1][dc_names[31]], "", 0.001, false))
    params:set_action( dc_param_IDs[i]["note_note"], function(x) dc_param_update_add(i, dc_names[31], x) end)
    params:add_control(dc_param_IDs[i]["note_amp"], "note -> amplitude", controlspec.new(-5,5,"lin",0.01, dc_preset_values[1][dc_names[32]]))
    params:set_action( dc_param_IDs[i]["note_amp"], function(x) dc_param_update_add(i, dc_names[32], x) end)
    params:add_control(dc_param_IDs[i]["note_pw"], "note -> pulse width", controlspec.new(-2,2,"lin",0.001, dc_preset_values[1][dc_names[33]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["note_pw"], function(x) dc_param_update_add(i, dc_names[33], x) end)
    params:add_control(dc_param_IDs[i]["note_pw2"], "note -> pulse width 2", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[34]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["note_pw2"], function(x) dc_param_update_add(i, dc_names[34], x) end)
    params:add_control(dc_param_IDs[i]["note_bit"], "note -> bitcrush", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[35]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["note_bit"], function(x) dc_param_update_add(i, dc_names[35], x) end)
    params:add_control(dc_param_IDs[i]["note_cycle"], "note cycle time", controlspec.new(0.1, 200, 'exp', 0, dc_preset_values[1][dc_names[36]], "", 0.002, false))
    params:set_action( dc_param_IDs[i]["note_cycle"], function(x) dc_param_update_add(i, dc_names[36], x) end)
    params:add_control(dc_param_IDs[i]["note_symmetry"], "note symmetry", controlspec.new(-2,2,"lin",0.01, dc_preset_values[1][dc_names[37]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["note_symmetry"], function(x) dc_param_update_add(i, dc_names[37], x) end)
    params:add_control(dc_param_IDs[i]["note_curve"], "note curve", controlspec.new(-10,10,"lin",0.01, dc_preset_values[1][dc_names[38]], "", 0.005, false))
    params:set_action( dc_param_IDs[i]["note_curve"], function(x) dc_param_update_add(i, dc_names[38], x) end)
    params:add_control(dc_param_IDs[i]["note_type"], "note loop on/off", controlspec.new(0,1,"lin",0.01, dc_preset_values[1][dc_names[39]], "", 1, false)) 
    params:set_action( dc_param_IDs[i]["note_type"], function(x) dc_param_update_add(i, dc_names[39], x) end)
    params:add_control(dc_param_IDs[i]["note_phase"], "note_phase", controlspec.new(-1,1,"lin",0.0005, dc_preset_values[1][dc_names[40]], "", 0.002, false)) -- 11 params
    params:hide(dc_param_IDs[i]["note_phase"])

    params:set_action(dc_param_IDs[i]["load_preset"], function() 
        if dc_code_sent == false then 
            print("CAW: resend code to crow!")
            return 
        end
        dc_load_preset(i, dc_preset_values[params:get(dc_param_IDs[i]["synth_preset"])])
    end)
    params:set_action(dc_param_IDs[i]["synth_shape"], function(s)
        if dc_code_sent == false then 
            print("CAW: resend code to crow!")
            return 
        end
        crow.dc_set_synth(i, params:get(dc_param_IDs[i]["synth_model"]), s) -- set this player

        if params:get(dc_param_IDs[i]["param_behavior"]) ~= 1 then -- set other players
            for j = 1, 4 do
                if i ~= j and params:get(dc_param_IDs[j]["synth_shape"]) ~= s then
                    params:set(dc_param_IDs[j]["synth_shape"], s, true)
                    crow.dc_set_synth(j, params:get(dc_param_IDs[j]["synth_model"]), s)
                end
            end
        end
    end)

    params:set_action(dc_param_IDs[i]["synth_model"], function(s)
        if dc_code_sent == false then 
            print("CAW: resend code to crow!")
            return 
        end
        crow.dc_set_synth(i, s, params:get(dc_param_IDs[i]["synth_shape"])) -- set this player

        if params:get(dc_param_IDs[i]["param_behavior"]) ~= 1 then -- set other players
            for j = 1, 4 do
                if i ~= j and params:get(dc_param_IDs[j]["synth_model"]) ~= s then
                    params:set(dc_param_IDs[j]["synth_model"], s, true)
                    crow.dc_set_synth(j, s, params:get(dc_param_IDs[j]["synth_shape"]))
                end
            end
        end
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
    -- crow.kill() -- clear VM and outputs and stuff on crow, doesn't clear uploaded script

    -- norns.crow.loadscript("nb_drumcrow/lib/update_loop.lua", false, false) -- if true, it uploads the script, if false, it loads to current memory
    -- I can't get norns.crow.loadscript to work
    -- below is a modified version of norns.crow.loadscript
    -- TODO does ...os.clock overflow back to 0? highly unlikely we'd run into that

    -- make the event to catch upload completion before we continue?
    norns.crow.public.discovered = function() 
        print("CAW: code uploaded! READY!") 
        dc_code_sent = true

        if dc_code_resent == true then -- reset norns param menu
            params:set(dc_param_IDs[1]["param_behavior"], 2, false) -- change behavior to all to reset parameters
            dc_load_preset(1, dc_preset_values[params:get(dc_param_IDs[1]["synth_preset"])]) -- load a preset
            params:set(dc_param_IDs[1]["param_behavior"], 1, false) -- change behavior back to individual
            dc_code_resent = false
        end
    end

    file = "nb_drumcrow/lib/update_loop.lua"
    is_persistent = false

    local abspath = norns.crow.findscript(file, is_persistent)
    if not abspath then
        print("CAW: crow.loadscript: can't find file "..file)
        return
    end

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
    -- https://github.com/monome/crow/blob/7027d2971a5491b021d8b309101cf2f75a7b5787/lib/caw.c#L104
end
    
    -- local function upload(file)
    --     -- TODO refine these clock.sleep(). can likely be reduced.
    --     norns.crow.send("^^s")
    --     clock.sleep(0.2)
    --     for line in io.lines(file) do
    --         norns.crow.send(line)
    --         clock.sleep(0.01)
    --     end
    --     clock.sleep(0.2)
    --     norns.crow.send(is_persistent and "^^w" or "^^e") -- what is ^^w or ^^e?
    --     -- if cont then
    --     --     clock.sleep(is_persistent and 0.5 or 0.2) -- ensure flash is complete
    --     --     cont() -- call continuation function
    --     -- end
    -- end

    -- print("CAW: crow loading: ".. file)
    -- clock.run(upload, abspath, is_persistent)

    -- dc_code_sent = true -- should only be set true when we get norns.crow.public.ready() event trigger


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
        -- crow.dc_update_stop()
    end
    
    function player:modulate(val)
        -- currently unsupported, use crow.dc_set_state(channel, key, value) to set drumcrow parameters
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
        -- used for midi keyboard per note modulation, currently unimplemented
    end

    function player:note_on(note, vel, properties)
        -- print(note)
        if dc_code_sent == false then 
            print("CAW: resend code to crow!")
            return 
        end
        local b = params:get(dc_param_IDs[i]["trig_behavior"])
        if b == 1 then -- individual
            crow.dc_note_on(i, note, vel)
        elseif b == 2 then -- round robin
            dc_poly_idx = dc_poly_idx % 4 + 1
            crow.dc_note_on(dc_poly_idx, note, vel)
        else -- all
            for j = 1, 4 do crow.dc_note_on(j, note, vel) end
        end
    end

    function player:note_off(note)
        -- player:play_note will trigger note_on then delay a note_off call
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

function dc_param_update_add(ch, k, val)
    dc_param_update_table[ch][k] = val
    if params:get(dc_param_IDs[ch]["param_behavior"]) ~= 1 then
        for j = 1, 4 do
            if ch ~= j then
                params:set(dc_param_IDs[j][k], val, true) -- update all the other params, don't trigger their actions please
                dc_param_update_table[j][k] = val
            end
        end
    end
    dc_param_update_table_dirty = true
end

function dc_param_update_loop() -- called every param_update_time seconds, called directly when loading presets
    if dc_param_update_table_dirty == true and dc_code_sent == true then
        crow.dc_param_update_receive(dc_param_update_table)
        for j = 1, 4 do dc_param_update_table[j] = {} end -- clear table
        dc_param_update_table_dirty = false
    end
end

function dc_pre_init() -- called before norns script init
    dc_code_sent = false -- init to false so things don't explode

    -- norns.crow.init() -- ...what ...does this do? it's not an environmental command
    -- crow.reset() -- this doesn't seem to clear the VM code, so I want to kill then send code
    -- dc_crow_code_send() -- uploading code risks interruption due to norns script trying to init crow, try post init
    build_large_strings() -- cook up larger strings instead of dynamically creating them during runtime
    add_drumcrow_player(1) -- add 4 nb players to note_players, one player for each output on crow
    add_drumcrow_player(2)
    add_drumcrow_player(3)
    add_drumcrow_player(4)
end

function dc_post_init()
    dc_crow_code_send() -- put update loop computations onto crow hardware
    dc_param_update_init()
end

mod.hook.register("script_pre_init", "drumcrow pre init", dc_pre_init) -- add 4 nb players to note_players, one player for each output on crow
mod.hook.register("script_post_init", "drumcrow post init", dc_post_init) -- add 4 nb players to note_players, one player for each output on crow



-- 1 update loop for all 4 outputs, check dyns first
-- BUG: midi note 60 = 261.63 Hz, the denominator above is 261.625 Hz
-- however, using sine shape, var_saw model, I measure 255.5 Hz oscillator on the output of crow
-- I checked a bunch of notes and they're all about -41 cents detuned for each frequency requested
-- so maybe 261.625 Hz / 255.5 Hz = 1.02399 multiplier to frequency for a patch? I have no idea why this happens
-- 2 - 1.02399 = 0.9760078, but that's still +1 cents so 0.97655 I guess and checked
-- cyc = cyc * 0.97655
-- magical splash function (I just messed around with math.random until it sounded cool, if drumcrow_splash_ <= 0 it just skips this) 

-- automatically turn off update flag if dcAmp is not there

-- design constraints
-- uses metro 8 on crow
-- FREQ_LIMIT = {114, 114, 101, 101, 114, 114, 114, 114, 114} based on the shape used
-- exponential and logarithmic shapes cost more CPU and thus require a lower max frequency limit
-- tested all 4 oscillators set to exponential and turned up transpose until errors started spamming matron, ended up at 101
-- 114 = 5919 Hz, 101 = 2793 Hz
-- code is sent post norns script init() and will reset all crow initialization or reset all code previously sent to crow 
-- resending code will reset crow and thus reset the behaviors of crow inputs 1 and 2 (example: dreamsequence uses in 2)
