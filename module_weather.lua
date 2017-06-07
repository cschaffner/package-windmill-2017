local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}


local red = resource.create_colored_texture(0.9,0.32,0,1)
local blue = resource.create_colored_texture(0.12,0.56,1,1)
--local circle = resource.create_shader[[
--    varying vec2 TexCoord;
--    uniform float r, g, b;
--    uniform float width;
--    uniform float progress;
--    void main() {
--        float e = 0.003;
--        float angle = atan(TexCoord.x - 0.5, TexCoord.y - 0.5);
--        float dist = distance(vec2(0.5, 0.5), TexCoord.xy);
--        float inner = (1.0 - width) / 2.0;
--        float alpha = (smoothstep(0.5, 0.5-e, dist) - smoothstep(inner+e, inner, dist)) * smoothstep(progress-0.01, progress, angle);
--        gl_FragColor = vec4(r, g, b, alpha);
--    }
--]]
--local fill = resource.create_shader[[
--    uniform float r, g, b;
--    varying vec2 TexCoord;
--    void main() {
--        gl_FragColor = vec4(r, g, b, TexCoord.x);
--    }
--]]


local weather = json.decode(resource.load_file "weather_data.initial.json")
local rain = json.decode(resource.load_file "weather_rain.initial.json")
local radar_data = {}
local weather_pics = util.auto_loader({}, function(fname)
    return fname:sub(1,8) == "weather_"
end)

local data_unwatch = util.file_watch("weather_data.json", function(raw)
    weather = json.decode(raw)
end)
local rain_unwatch = util.file_watch("weather_rain.json", function(raw)
    rain = json.decode(raw)
end)
local radar_data_unwatch = util.file_watch("weather_radar.json", function(raw)
    radar_data = json.decode(raw)
end)

function M.unload()
    data_unwatch()
    rain_unwatch()
    radar_data_unwatch()
end

function M.can_schedule()
    return radar_data ~= {}
end

function M.prepare(options)
    return options.duration or 10
end

function M.run(duration, _, fn)
    local y = 50
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()
    print('now is '.. now)

    local t = S

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Weather @Windmill", 100, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_buienradar'], 1200, y+25, 1200+258, y+75, 0.9))
    y = y + 110
    t = t + 0.03
    local font_size = 40


    a.add(anims.moving_image(t, E, weather_pics['weather_radar_background'], 200, y, 599+200, y+420, 1))
--    a.add(function(t)
--        if t > 1 and t < E-1 then
--            return util.draw_correct(radar_pics['weather_radar_00'], 200, y, 200+600, y+420, 1)
--        end
--    end)

    a.add(function(t)
        if t > 1 and t < E-1 then
            idx = math.ceil(t/E*#radar_data.times)
            return util.draw_correct(weather_pics[radar_data.times[idx].filename], 200, y, 200+600, y+420, 1)
        end
    end)

    a.add(function(t)
        if t > 1 and t < E-1 then
            idx = math.ceil(t/E*#radar_data.times)
            return res.font:write(200+20, y+20, radar_data.times[idx].actual_time, 60, 1, 1, 1, 1)
        end
    end)


    local y_rain = HEIGHT-200
    local x_rain = 100
    if rain.no_rain then
        a.add(anims.moving_font(t, E, x_rain+100, y_rain-150, "no rain expected", 60, 0.12,0.56,1,1))
        a.add(anims.moving_font(t, E, x_rain+100, y_rain-90, "during next two hours", 60, 0.12,0.56,1,1))
    else
        for idx = 1, #rain.forecasts do
            local x = x_rain + idx*20
            local rain_point = rain.forecasts[idx]
    --        a.add(anims.moving_font(t, E, 50, y_rain, rain_point.mm_per_h , font_size, 1,1,1,1))
            if (idx % 8 == 1) then
                a.add(anims.rotated_moving_font(t, E, x, y_rain, rain_point.time , font_size, 1,1,1,1))
            end
            a.add(anims.moving_bar(S, E, blue, x, y_rain-rain_point.value*3, x+15, y_rain,1))
        end
    end
--    a.add(anims.my_moving_bar(S, E, red, x_rain, y_rain-250, x_rain+5, y_rain, 400, 1))

    a.add(anims.moving_font(t, E, 900, 150, "now:  " .. weather.Schiphol.temperature .. "°C  " .. weather.Schiphol.precipitationmm .. "mm   " .. weather.Schiphol.winddirection .. weather.Schiphol.windspeedBft, 70, 1,1,1,1))
    local title_width = font:width("now:  " .. weather.Schiphol.temperature .. "°C  " .. weather.Schiphol.precipitationmm .. "mm   " .. weather.Schiphol.winddirection .. weather.Schiphol.windspeedBft, 70)
    a.add(anims.moving_image(t, E, weather_pics['weather_wind_'..weather.Schiphol.winddirection], 900+title_width, 150, 900+title_width+80, 150+80, 1))

    local today_x = 900
    local dayspace = 200
    local tom_x = 900 + dayspace
    local aftertom_x = tom_x + dayspace
    local afteraftertom_x = aftertom_x + dayspace
    local dayname_y = 280
    local icon_y = 360
    local temp_max_y = 450
    local temp_min_y = 520
    local rainbar_y = 750
    local rainday_y = 780
    local windicon_y = 830
    local windday_y = 930

--    today's data'
    a.add(anims.moving_font(t, E, today_x, dayname_y, weather.Halfweg.day_names[1], 70, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_'..weather.Halfweg.days[1].iconcode], today_x+dayspace/8, icon_y, today_x+dayspace/8+60, icon_y+60, 1))
    a.add(anims.moving_font(t, E, today_x, temp_max_y, weather.Halfweg.days[1].maxtemperature .. "°", 60, 0.9,0.32,0,1))
--    a.add(anims.moving_font(t, E, today_x+dayspace/2, temp_min_y, weather.Halfweg.days[1].mintemperature .. "°", 60, 0.12,0.56,1,1))
    a.add(anims.moving_font(t, E, today_x, rainday_y, string.format("%3.1f", weather.Halfweg.days[1].precipitationmm) .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_bar(S, E, blue, today_x, rainbar_y-weather.Halfweg.days[1].precipitationmm*150/30, today_x+100, rainbar_y,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_wind_'..weather.Halfweg.days[1].winddirection], today_x+dayspace/8, windicon_y, today_x+dayspace/8+80, windicon_y+80, 1))
    a.add(anims.moving_font(t, E, today_x+dayspace/8, windday_y, weather.Halfweg.days[1].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))
    t = t + 0.03

    a.add(anims.moving_font(t, E, tom_x, dayname_y, weather.Halfweg.day_names[2], 70, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_'..weather.Halfweg.days[2].iconcode], tom_x+dayspace/8, icon_y, tom_x+dayspace/8+60, icon_y+60, 1))
    a.add(anims.moving_font(t, E, tom_x, temp_max_y, weather.Halfweg.days[2].maxtemperature .. "°", 60, 0.9,0.32,0,1))
    a.add(anims.moving_font(t, E, tom_x-dayspace/2, temp_min_y, weather.Halfweg.days[2].mintemperature .. "°", 60, 0.12,0.56,1,1))
    a.add(anims.moving_font(t, E, tom_x, rainday_y, weather.Halfweg.days[2].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, tom_x, windday_y, weather.Halfweg.days[2].winddirection .. weather.Halfweg.days[2].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_wind_'..weather.Halfweg.days[2].winddirection], tom_x, windicon_y, tom_x+80, windicon_y+80, 1))
    a.add(anims.moving_bar(S, E, blue, tom_x, rainbar_y-weather.Halfweg.days[2].precipitationmm*150/30, tom_x+100, rainbar_y,1))
    t = t + 0.03

    a.add(anims.moving_font(t, E, aftertom_x, dayname_y, weather.Halfweg.day_names[3], 70, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_'..weather.Halfweg.days[3].iconcode], aftertom_x+dayspace/8, icon_y, aftertom_x+dayspace/8+60, icon_y+60, 1))
    a.add(anims.moving_font(t, E, aftertom_x, temp_max_y, weather.Halfweg.days[3].maxtemperature .. "°", 60, 0.9,0.32,0,1))
    a.add(anims.moving_font(t, E, aftertom_x-dayspace/2, temp_min_y, weather.Halfweg.days[3].mintemperature .. "°", 60, 0.12,0.56,1,1))
    a.add(anims.moving_font(t, E, aftertom_x, rainday_y, weather.Halfweg.days[3].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, aftertom_x, windday_y, weather.Halfweg.days[3].winddirection .. weather.Halfweg.days[3].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_wind_'..weather.Halfweg.days[2].winddirection], aftertom_x, windicon_y, aftertom_x+80, windicon_y+80, 1))
    a.add(anims.moving_bar(S, E, blue, aftertom_x, rainbar_y-weather.Halfweg.days[3].precipitationmm*150/30, aftertom_x+100, rainbar_y,1))
    t = t + 0.03

    a.add(anims.moving_font(t, E, afteraftertom_x, dayname_y, weather.Halfweg.day_names[4], 70, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_'..weather.Halfweg.days[4].iconcode], afteraftertom_x+dayspace/8, icon_y, afteraftertom_x+dayspace/8+60, icon_y+60, 1))
    a.add(anims.moving_font(t, E, afteraftertom_x, temp_max_y, weather.Halfweg.days[4].maxtemperature .. "°", 60, 0.9,0.32,0,1))
    a.add(anims.moving_font(t, E, afteraftertom_x-dayspace/2, temp_min_y, weather.Halfweg.days[4].mintemperature .. "°", 60, 0.12,0.56,1,1))
    a.add(anims.moving_font(t, E, afteraftertom_x, rainday_y, weather.Halfweg.days[4].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, afteraftertom_x, windday_y, weather.Halfweg.days[4].winddirection .. weather.Halfweg.days[3].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_image(t, E, weather_pics['weather_wind_'..weather.Halfweg.days[2].winddirection], afteraftertom_x, windicon_y, afteraftertom_x+80, windicon_y+80, 1))
    a.add(anims.moving_bar(S, E, blue, afteraftertom_x, rainbar_y-weather.Halfweg.days[4].precipitationmm*150/30, afteraftertom_x+100, rainbar_y,1))



--    -- temperature curves
--    local function temp_to_y(temp)
--        return temp_min_y - (temp-weather.Halfweg.min_temp) * (temp_min_y-temp_max_y) / (weather.Halfweg.max_temp-weather.Halfweg.min_temp)
--    end
----    local current_temp = weather.Schiphol.temperature
--    for idx = 1, #weather.Halfweg.hours do
--        local hour = weather.Halfweg.hours[idx]
--        local cur_x = today_x + idx*12
--        a.add(anims.moving_bar(S, E, red, cur_x, temp_to_y(hour.temperature), cur_x+10, temp_to_y(hour.temperature)+10,1))
----        current_temp = hour.temperature
--    end

    fn.wait_t(0)
    Sidebar.hide(E-1)


    for now in fn.upto_t(E) do

        a.draw(now)
    end

    return true
end

return M
