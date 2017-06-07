local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}

local team_idx = 0
local gray = resource.create_colored_texture(0.28,0.28,0.28,1)

--local black = resource.create_colored_texture(0,0,0,1)

local teams = {}

local teams_unwatch = util.file_watch("current_teams.json", function(raw)
    teams = json.decode(raw)
end)

function M.unload()
    teams_unwatch()
end

function M.can_schedule(options)
    print("number of teams: " .. #teams)
    return #teams > 0
end

function M.prepare(options)
    repeat
        options.team, team_idx = utils.cycled(teams, team_idx)
    until options.team.division == options.division
    return options.duration or 10, options
end

function M.run(duration, args, fn)
    local text_size = 40
    local text_small = 30
    local text_big = 50
    local S = 0.0
    local E = duration

--    local text_w = res.font:width(args.text, text_size)
    local a = utils.Animations()

    local y = 100
    a.add(anims.my_moving_font(S,E, 200, y, "flag:".. args.team.country .. " " .. args.team.name, 80, 1,1,1,1))
    y = y + 80 + 20
    a.add(anims.my_moving_font(S,E, 200, y, "Division: ".. args.team.division, text_size, 1,1,1,1))
    a.add(anims.my_moving_font(S,E, 650, y, "Current rank: ".. args.team.current_standing.ranking, text_size, 1,1,1,1))
    y = y + text_size + 10

    if args.team.city ~= "" then
        a.add(anims.my_moving_font(S,E, 200, y, "City: ".. args.team.city, text_size, 1,1,1,1))
    end
    a.add(anims.my_moving_font(S,E, 650, y, "Current Swiss Score: ".. args.team.current_standing.num_swiss_score, text_size, 1,1,1,1))
    if args.team.current_standing.swiss_opponent_score_avg then
        a.add(anims.my_moving_font(S,E, 1100, y, "Avg Opp Swiss Score: ".. args.team.current_standing.swiss_opponent_score_avg, text_size, 1,1,1,1))
    end
    y = y + text_size + 10

    y = y + 50
    a.add(anims.my_moving_font(S,E, 200, y, "Games:", text_big, 1,1,1,1))
    y = y + text_big + 20
    a.add(anims.my_moving_font(S, E, 200, y, "Round:  Score", text_small, 1,1,1,1))
    a.add(anims.my_moving_font(S, E, 450, y, "Opponent", text_small, 1,1,1,1));
    a.add(anims.my_moving_font(S, E, 740, y, "Opp Rank", text_small, 1,1,1,1));
    a.add(anims.my_moving_font(S, E, 900, y, "GameScoreDiff", text_small, 1,1,1,1));
    a.add(anims.my_moving_font(S, E, 1140, y, "SwissScoreDiff", text_small, 1,1,1,1));
    S = S + 0.1
    y = y + text_size + 20
    for idx = 1, #args.team.games do
        local game = args.team.games[idx]
--        print(game)
        if (idx % 2 == 1) then
            a.add(anims.moving_bar(S, E, gray, 200, y, 1300, y+text_size,1))
        end

        if game.is_final then
            a.add(anims.my_moving_font(S, E, 200, y, "R " .. game.round_number .. ":   " .. string.format("%2.0f", game.own_score) .. " - " .. string.format("%2.0f", game.opponent_score), text_size, 1,1,1,1))
        else
            a.add(anims.my_moving_font(S, E, 200, y, "R " .. game.round_number .. ":   " .. string.format("%2.0f", game.own_score) .. " *- " .. string.format("%2.0f", game.opponent_score), text_size, 1,1,1,1))
        end
        a.add(anims.my_moving_font(S, E, 450, y, "flag:" .. game.opponent_country .. game.opponent, text_size, 1,1,1,1));
        if game.opponent_standing.ranking then
            a.add(anims.my_moving_font(S, E, 780, y, string.format("%2.0f", game.opponent_standing.ranking), text_size, 1,1,1,1));
        end
        if game.score_diff then
            a.add(anims.my_moving_font(S, E, 950, y, game.score_diff, text_size, 1,1,1,1));
        end
        if game.swiss_score_diff then
            a.add(anims.my_moving_font(S, E, 1150, y, game.swiss_score_diff, text_size, 1,1,1,1));
        end
        S = S + 0.1
        y = y + text_size + 20
    end

    fn.wait_t(0)
--    Sidebar.hide(E-1)

    for now in fn.upto_t(E) do
        a.draw(now)
    end
    return true

end

return M
