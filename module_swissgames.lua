local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}
local gray = resource.create_colored_texture(0.28,0.28,0.28,1)
local white = resource.create_colored_texture(1,1,1,1)

--local gray = resource.create_colored_texture(0.898,0.529,0,1) -- gray

--local icons = util.auto_loader({}, function(fname)
--    return fname:sub(1,4) == "gvb-"
--end)

local open_data = json.decode(resource.load_file "current_games_open.initial.json")
local mixed_data = json.decode(resource.load_file "current_games_mixed.initial.json")
local women_data = json.decode(resource.load_file "current_games_women.initial.json")

local open_unwatch = util.file_watch("current_games_open.json", function(raw)
    open_data = json.decode(raw)
end)
local mixed_unwatch = util.file_watch("current_games_mixed.json", function(raw)
    mixed_data = json.decode(raw)
end)
local women_unwatch = util.file_watch("current_games_women.json", function(raw)
    women_data = json.decode(raw)
end)

function M.unload()
    open_unwatch()
    mixed_unwatch()
    women_unwatch()
end

function M.can_schedule()
    return true
end

function M.prepare(options)
    if options.division == 'open' then
        options.font_size = 50
        options.y_lift = 300
        options.top_title = 'Open'
        options.line_break_fraction_games = 2
        options.line_break_fraction_standings = 7
    elseif options.division == 'mixed' then
        options.font_size = 42
        options.y_lift = 800
        options.top_title = 'Mixed'
        options.line_break_fraction_games = 20
        options.line_break_fraction_standings = 8
    elseif options.division == 'women' then
        options.font_size = 50
        options.y_lift = 0
        options.top_title = 'Women'
        options.line_break_fraction_games = 2
        options.line_break_fraction_standings = 4
    end
    return options.duration or 10, options
end

function M.run(duration, args, fn)
    local game_data
    if args.division == 'open' then
        game_data = open_data
    elseif args.division == 'mixed' then
        game_data = mixed_data
    elseif args.division == 'women' then
        game_data = women_data
    end

    local y = 20
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()
    print('now is '.. now)

    local remaining_min = (game_data.start_time_unix - now) / 60
    local remaining_text = ""
    if 0 < remaining_min and remaining_min < 99 then
        remaining_text = " (in " .. math.ceil(remaining_min) .. " min)"
    elseif -99 < remaining_min and remaining_min < -1 then
        remaining_text = " (" .. math.floor(-remaining_min) .. " min ago)"
    elseif -1 <= remaining_min and remaining_min <= 1 then
        remaining_text = " (now)"
    end

    local t = S
    local font_size = args.font_size
    local field_nr_width = 80
    local team_width = 300
    local score_width = 65
    local divider_width = 25
    local x_games = 150
    local x_standings = 1080
    local rank_width = 60
    local y_lift = args.y_lift -- for scrolling the standings

    -- HEADER
    local top_title_width = res.font:width(args.top_title, 80)
    a.add(anims.moving_font(t, E, 150, y, args.top_title, 80, 1,1,1,1))
    a.add(anims.moving_font(t, E, 150+top_title_width+30, y+15, game_data.round_name .. "  " .. game_data.start_time .. remaining_text, 50, 1,1,1,1))
    y = y + 100
    local y_top = y
    t = t + 0.03

    curx = x_games
    a.add(anims.my_moving_font(t, E, x_games, y, "Field   Team", font_size, 1,1,1,1))
    curx = curx + field_nr_width
    curx = curx + team_width + score_width/4
    a.add(anims.my_moving_font(t, E, curx, y, "Score     Team", font_size, 1,1,1,1))
    y = y + font_size + math.floor(font_size/args.line_break_fraction_games)
----    a.add(anims.moving_bar(t, E, white, x_games, y, x_games+field_nr_width+2*(team_width+score_width)+20, y+3,1))
--    y = y + 6
    t = t + 0.03

    for idx = 1, #game_data.games do
        local game = game_data.games[idx]

        if (idx % 2 == 1) then
            a.add(anims.moving_bar(t, E, gray, x_games, y, x_games+field_nr_width+2*(team_width+score_width)+40, y+font_size,1))
        end
        curx = x_games
        if tonumber(game.field_nr) ~= nil then
            a.add(anims.my_moving_font(t, E, x_games, y, "field:" .. game.field_nr, font_size, 1,1,1,1))
        else
            a.add(anims.my_moving_font(t, E, x_games, y, game.field_nr, font_size, 1,1,1,1))
        end
        curx = curx + field_nr_width
        a.add(anims.my_moving_font(t, E, curx, y, "flag:" .. game.team_1_country .. " " .. game.team_1 , font_size, 1,1,1,1))
        curx = curx + team_width
        a.add(anims.my_moving_font(t, E, curx, y, string.format("%2.0f", game.team_1_score), font_size, 1,1,1,1))
        curx = curx + score_width
        if game.is_final then
            a.add(anims.my_moving_font(t, E, curx, y, "-", font_size, 1,1,1,1))
        else
            a.add(anims.my_moving_font(t, E, curx-divider_width/2, y, "*-", font_size, 1,1,1,1))
        end
        curx = curx + divider_width
        a.add(anims.my_moving_font(t, E, curx, y, string.format("%2.0f", game.team_2_score) , font_size, 1,1,1,1))
        curx = curx + score_width
        a.add(anims.my_moving_font(t, E, curx, y, game.team_2 .. " flag:" .. game.team_2_country, font_size, 1,1,1,1))
        y = y + font_size + math.floor(font_size/args.line_break_fraction_games)
        t = t + 0.03

--        if y > HEIGHT - 100 then
--            break
--        end
    end

    y = y_top - 120
    local nr_teams = #game_data.standings
    for idx = 1, #game_data.standings do
        local standing = game_data.standings[idx]
        local scroll_time = t + 8 + (nr_teams-idx)*0.09
--        print("" .. idx .. standing.ranking .. standing.team_name)

        if (idx % 2 == 1) then
            a.add(anims.scrolling_bar(t, scroll_time, E, gray, x_standings, y, x_standings+rank_width+team_width+font_size*3, y+font_size, y_lift, 1))
        end

        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings, y, y_lift, string.format("%2.0f", standing.ranking) , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings+rank_width, y, y_lift, standing.team_name , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings+rank_width+team_width+(font_size-45)*2, y, y_lift, standing.swiss_score, font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+score_width, y, "-", font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+score_width+20, y, "" .. game.team_2_score , font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+2*score_width+20, y, game.team_2 .. " flag:" .. game.team_1_country, font_size, 1,1,1,1))
        y = y + font_size + math.floor(font_size/args.line_break_fraction_standings)
        t = t + 0.03
--
--        if y > HEIGHT - 100 then
--            break
--        end
    end

--    a.add(anims.moving_image(S+1, E, icons['gvb-icon'], 1000, 400, 1000+300, 400+300, 1))

    fn.wait_t(0)
    Scroller.hide(E)
--    Sidebar.hide(E)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
