-- grabbed this stuff from nb_murder <3 thank you dwtong!
local m = {}

local mod = require("core/mods")

local device_max = 2
local auto_send_max = 2
local data_dir = _path.data .. mod.this_name
local data_file = data_dir .. "/mod.state"

-- default state
local state = {
    device_count = 1,
    auto_send = 2,
}

m.key = function(n, z)
    if n == 2 and z == 1 then
        mod.menu.exit()
    end
end

m.enc = function(n, d)
    if n == 2 then
        local auto_send = util.clamp(state.auto_send + d, 1, auto_send_max)
        state.auto_send = auto_send   
    elseif n == 3 then
        local device_count = util.clamp(state.device_count + d, 1, device_max)
        state.device_count = device_count
    end
    mod.menu.redraw()
end

m.redraw = function()
    screen.clear()
    screen.font_face(1)
    screen.font_size(8)
    screen.level(15)
    screen.move(0, 10)
    screen.text("number of crows")
    screen.move(120, 10)
    screen.text(state.device_count)

    screen.move(0, 20)
    screen.text("script start upload")
    screen.move(115, 20)
    screen.text(state.auto_send == 1 and "off" or "on")
    screen.update()
end

m.init = function()
    if util.file_exists(data_file) then
        state = tab.load(data_file)
    else
        util.make_dir(data_dir)
    end
end

m.deinit = function()
    tab.save(state, data_file)
end

return m
