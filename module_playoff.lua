local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}
local gray = resource.create_colored_texture(0.28,0.28,0.28,1) -- gray
--local gray = resource.create_colored_texture(0.898,0.529,0,1) -- gray

--local icons = util.auto_loader({}, function(fname)
--    return fname:sub(1,4) == "gvb-"
--end)

local background = resource.load_image("brackets_scaled.png")

local open_brackets = json.decode(resource.load_file "current_brackets_open.initial.json")
local mixed_brackets = json.decode(resource.load_file "current_brackets_mixed.initial.json")
local women_brackets = json.decode(resource.load_file "current_brackets_women.initial.json")

local open_unwatch = util.file_watch("current_brackets_open.json", function(raw)
    open_brackets = json.decode(raw)
end)
local mixed_unwatch = util.file_watch("current_brackets_mixed.json", function(raw)
    mixed_brackets = json.decode(raw)
end)
local women_unwatch = util.file_watch("current_brackets_women.json", function(raw)
    women_brackets = json.decode(raw)
end)


function M.unload()
    open_unwatch()
    mixed_unwatch()
    women_unwatch()
end

function M.can_schedule(options)
    local brackets
    if options.division == 'open' then
        brackets = open_brackets
    elseif options.division == 'mixed' then
        brackets = mixed_brackets
    elseif options.division == 'women' then
        brackets = women_brackets
    end
    return string.len(brackets[1].team_1)>0
end

function M.prepare(options)
    if options.division == 'open' then
        options.top_title = 'Open'
    elseif options.division == 'mixed' then
        options.top_title = 'Mixed'
    elseif options.division == 'women' then
        options.top_title = 'Women'
    end

    return options.duration or 10, options
end

function M.run(duration, args, fn)
    local brackets
    if args.division == 'open' then
        brackets = open_brackets
    elseif args.division == 'mixed' then
        brackets = mixed_brackets
    elseif args.division == 'women' then
        brackets = women_brackets
    end

    local y = 20
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()

    local t = S
    local font_size = 40
    local font_size_small = 30
    local team_width = 240
    local score_width = 70
    local x_games = 150
    local x_standings = 1100
    local rank_width = 60
    local y_split_teams = 100

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, args.top_title .. " Division Bracket", 80, 1,1,1,1))
    y = y + 90
    local y_top = y
    t = t + 0.03

    a.add(anims.moving_image(t, E, background, 0, y, 1920, y+909, 1))


    local pos = {}
--    name     = team_1_x, team_1_y ,  team_2_x, teams_2_y (relative to team_1),  start_time / field (relative to team_1)
    pos["QF0"] = {39, 23, 0, 78, 27, 40}
    pos["QF1"] = {pos["QF0"][1], 201, pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["QF2"] = {1614, pos["QF0"][2], pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["QF3"] = {pos["QF2"][1], pos["QF1"][2], pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["SF0"] = {340, 66, 0, 173, 20, 90}
    pos["SF1"] = {1300, pos["SF0"][2], pos["SF0"][3],pos["SF0"][4],pos["SF0"][5],pos["SF0"][6]}
    pos["SF2"] = {pos["SF0"][1], 552, pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["SF3"] = {pos["SF1"][1], pos["SF2"][2], pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["Fin12"] = {660, 153, 316, 0, 220, -44}
    pos["Fin34"] = {pos["Fin12"][1], 370, pos["Fin12"][3],pos["Fin12"][4],pos["Fin12"][5],pos["Fin12"][6]}
    pos["Fin56"] = {pos["Fin12"][1], 590, pos["Fin12"][3],pos["Fin12"][4],pos["Fin12"][5],pos["Fin12"][6]}
    pos["Fin78"] = {pos["Fin12"][1], 800, pos["Fin12"][3],pos["Fin12"][4],pos["Fin12"][5],pos["Fin12"][6]}



    for idx = 1, #brackets do
        local game = brackets[idx]
        co = pos[game.name]
        if string.len(game.team_1)>0 then
            a.add(anims.my_moving_font(t, E, co[1], y+co[2], "flag:" .. game.team_1_country .. " " .. game.team_1 , font_size, 1,1,1,1))
            a.add(anims.my_moving_font(t, E, co[1]+team_width, y+co[2], string.format("%2.0f", game.team_1_score), font_size, 1,1,1,1))
        end
        if string.len(game.team_2)>0 then
            a.add(anims.my_moving_font(t, E, co[1]+co[3], y+co[2]+co[4], "flag:" .. game.team_2_country .. " " .. game.team_2 , font_size, 1,1,1,1))
            a.add(anims.my_moving_font(t, E, co[1]+co[3]+team_width, y+co[2]+co[4], string.format("%2.0f", game.team_2_score), font_size, 1,1,1,1))
        end
        if tonumber(game.field_nr) ~= nil then
            a.add(anims.my_moving_font(t, E, co[1]+co[5], y+co[2]+co[6], game.start_time .. " " .. "Field field:" .. game.field_nr, font_size_small, 1,1,1,1))
        else
            a.add(anims.my_moving_font(t, E, co[1]+co[5], y+co[2]+co[6], game.start_time .. " " .. string.sub(game.field,1,8), font_size_small, 1,1,1,1))
        end
    end
    t = t + 0.03

    fn.wait_t(0)
    Scroller.hide(E)
    Sidebar.hide(E)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
