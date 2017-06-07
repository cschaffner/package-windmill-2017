local utils = require "utils"
local vollbg = resource.create_colored_texture(0,0,0,1)

local M = {}

local function rotated_rotating_entry_exit(S, E, obj)
    local rotate = utils.make_smooth{
        {t = S ,  val = -60},
        {t = S+1 ,val =  0, ease='step'},
        {t = E-1, val =  0},
        {t = E,   val = -90},
    }

    return function(t)
        gl.rotate(rotate(t), 0, 1, 0)
        return obj(t)
    end
end

local function rotating_entry_exit(S, E, obj)
    local rotate = utils.make_smooth{
        {t = S ,  val = -60},
        {t = S+1 ,val =   0, ease='step'},
        {t = E-1, val =   0},
        {t = E,   val = -90},
    }

    return function(t)
        gl.rotate(rotate(t), 0, 1, 0)
        return obj(t)
    end
end

local function up_down_scroll(S, E, x, y, obj)

--    local y = utils.make_smooth{
--        {t = S,   val = y},
--        {t = S+(E-S)/4,   val = y},
--        {t = S+(E-S)/2, val = y-900, ease='step'},
--        {t = S+3*(E-S)/4,   val = y, ease='step'},
--        {t = E,   val = y},
--    }

    local y = utils.make_smooth{
        {t = S,   val = y},
        {t = E-3*(E-S)/4,   val = y},
        {t = E-(E-S)/2, val = y-900, ease='step'},
        {t = E-(E-S)/4,   val = y, ease='step'},
        {t = E,   val = y},
    }

    return function(t)
        gl.translate(x, y(t))
        return obj(t)
    end

end

local function move_in_move_out(S, E, x, y, obj)
    local x = utils.make_smooth{
        {t = S,   val = x+2200},
        {t = S+1, val = x, ease='step'},
        {t = E-1, val = x},
        {t = E,   val = -2000},
    }

    local y = utils.make_smooth{
        {t = S,   val = y*3},
        {t = S+1, val = y, ease='step'},
        {t = E-1, val = y},
        {t = E,   val = 0},
    }

    return function(t)
        gl.translate(x(t), y(t))
        return obj(t)
    end
end

local function move_in_shift_move_out(S, E, x, y, xshift, obj)
    local x = utils.make_smooth{
        {t = S,   val = x+2200},
        {t = S+1, val = x, ease='step'},
        {t = E-1, val = x+xshift},
        {t = E,   val = -2000},
    }

    local y = utils.make_smooth{
        {t = S,   val = y*3},
        {t = S+1, val = y, ease='step'},
        {t = E-1, val = y},
        {t = E,   val = 0},
    }

    return function(t)
        gl.translate(x(t), y(t))
        return obj(t)
    end
end



local function move_in_scroll_move_out(S, Scroll, E, x, y, y_lift, obj)
    local x = utils.make_smooth{
        {t = S,   val = x+2200},
        {t = S+1, val = x, ease='step'},
        {t = E-1, val = x},
        {t = E,   val = -2000},
    }

    local y_timeline = {
        {t = S,   val = y*3},
        {t = S+1, val = y, ease='step'},
        {t = S+4, val = y},
        {t = S+7, val = y-y_lift, ease='step'},
        {t = S+Scroll, val = y-y_lift},
        {t = S+Scroll+3, val = y, ease='step'},
    }
    local end_scroll = S+15
    while end_scroll + Scroll+3 < E-1 do   -- keep scrolling up and down as long as time is not over
        y_timeline[#y_timeline+1] = {t = end_scroll+4, val = y}
        y_timeline[#y_timeline+1] = {t = end_scroll+7, val = y-y_lift, ease='step'}
        y_timeline[#y_timeline+1] = {t = end_scroll+Scroll, val = y-y_lift}
        y_timeline[#y_timeline+1] = {t = end_scroll+Scroll+3, val = y, ease='step'}
        end_scroll = end_scroll+15
    end
    y_timeline[#y_timeline+1] = {t = E-1, val = y}
    y_timeline[#y_timeline+1] = {t = E,   val = 0}

    local y = utils.make_smooth(y_timeline)

    return function(t)
        gl.translate(x(t), y(t))
        return obj(t)
    end
end

function M.voll(S, E, x, y)
    return move_in_move_out(S, E, x, y,
        rotating_entry_exit(S, E, function(t)
            gl.translate(150, -10)
            gl.rotate(10, 0, 0, 1)
            vollbg:draw(-5, -5, 400, 65, 0.9)
            return res.font:write(30, 0, "Full - No entry", 60, 1,0,0,0.8)
        end)
    )
end

function M.image(S, E, img, x1, y1, x2, y2, alpha)
    return move_in_move_out(S, E, x1, y1,
        rotating_entry_exit(S, E, function(t)
            return util.draw_correct(img, 0, 0, x2-x1, y2-y1, alpha)
        end)
    )
end

function M.moving_image(S, E, img, x1, y1, x2, y2, alpha)
    return move_in_move_out(S, E, x1, y1,
        rotating_entry_exit(S, E, function(t)
            return util.draw_correct(img, 0, 0, x2-x1, y2-y1, alpha)
        end)
    )
end

function M.moving_bar(S, E, color, x1, y1, x2, y2, alpha)
    return move_in_move_out(S, E, x1, y1,
        rotating_entry_exit(S, E, function(t)
            return color:draw(0, 0, x2-x1, y2-y1, alpha)
        end)
    )
end

function M.my_moving_bar(S, E, color, x1, y1, x2, y2, xmove, alpha)
    return move_in_shift_move_out(S, E, x1, y1, xmove,
        rotating_entry_exit(S, E, function(t)
            return color:draw(0, 0, x2-x1, y2-y1, alpha)
        end)
    )
end

function M.moving_font(S, E, x, y, text, size, r, g, b, a)
    return move_in_move_out(S, E, x, y,
        rotating_entry_exit(S, E, function(t)
            return res.font:write(0, 0, text, size, r, g, b, a)
        end)
    )
end

function M.rotated_moving_font(S, E, x, y, text, size, r, g, b, a)
    return move_in_move_out(S, E, x, y,
        rotated_rotating_entry_exit(S, E, function(t)
            return res.font:write(0, 0, text, size, r, g, b, a)
        end)
    )
end

function M.my_moving_font(S, E, x, y, text, size, r, g, b, a)
    return move_in_move_out(S, E, x, y,
        rotating_entry_exit(S, E, function(t)
            return utils.flag_write(res.font, 0, 0, text, size, r, g, b, a)
        end)
    )
end

function M.my_scrolling_font(S, E, x, y, text, size, r, g, b, a)
    return up_down_scroll(S, E, x, y, function(t)
--        move_in_move_out(S, E, x, y,
--            rotating_entry_exit(S, E, function(t)
                return utils.flag_write(res.font, 0, 0, text, size, r, g, b, a)
            end)
--        )
--    )
end


function M.my_scrolling_font(S, Scroll, E, x, y, y_lift, text, size, r, g, b, a)
    return move_in_scroll_move_out(S, Scroll, E, x, y, y_lift,
        rotating_entry_exit(S, E, function(t)
            return utils.flag_write(res.font, 0, 0, text, size, r, g, b, a)
        end)
    )
end

function M.scrolling_bar(S, Scroll, E, color, x1, y1, x2, y2, y_lift, alpha)
    return move_in_scroll_move_out(S, Scroll, E, x1, y1, y_lift,
        rotating_entry_exit(S, E, function(t)
            return color:draw(0, 0, x2-x1, y2-y1, alpha)
        end)
    )
end


function M.moving_font_shake(S, E, x, y, shake, text, size, r, g, b, a)
    return move_in_move_out(S, E, x, y, 
        rotating_entry_exit(S, E, function(t)
            local dx, dy
            dx = 0
            dy = 0
            if shake then 
                dx = math.sin(t*8*4)*2
                dy = math.sin(t*9*4)*2
            end
            return res.font:write(dx, dy, text, size, r, g, b, a)
        end)
    )
end

function M.moving_font_list(S, E, x, y, texts, size, r, g, b, a)
    return move_in_move_out(S, E, x, y, 
        rotating_entry_exit(S, E, function(t)
            local alpha = 1
            local text = texts[math.floor((t+0.5) % #texts + 1)]
            if #texts > 1 then
                local rot = (180 * t + 90) % 180 - 90
                alpha = math.sqrt(math.abs(math.cos(t * math.pi)))
                gl.translate(0, size/2)
                gl.rotate(rot, 1, 0, 0)
                gl.translate(0, -size/2)
            end
            return res.font:write(0, 0, text, size, r, g, b, a*alpha)
        end)
    )
end

function M.tweet_profile(S, E, x, y, img, size)
    local x = utils.make_smooth{
        {t = S+0, val = 2200},
        {t = S+1, val = 500},
        {t = S+2, val = x, ease='step'},
        {t = E-1, val = x},
        {t = E,   val = -2000},
    }

    local y = utils.make_smooth{
        {t = S+0, val = HEIGHT/2},
        {t = S+1, val = 200},
        {t = S+2, val = y, ease='step'},
        {t = E-1, val = y},
        {t = E,   val = 0},
    }

    local scale = utils.make_smooth{
        {t = S ,  val = 0},
        {t = S+1, val = 8},
        {t = S+2, val = 1, ease='step'},
        {t = E-1, val = 1},
        {t = E,   val = 8},
    }

    return function(t)
        local size = scale(t) * size
        gl.translate(x(t), y(t))
        return util.draw_correct(img, 0, 0, size, size)
    end
end


return M
