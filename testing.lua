function make_smooth(timeline)
    assert(#timeline >= 1)

    local function find_span(t)
        local lo, hi = 1, #timeline
        while lo <= hi do
            local mid = math.floor((lo+hi)/2)
            if timeline[mid].t > t then
                hi = mid - 1
            else
                lo = mid + 1
            end
        end
        return math.max(1, lo-1)
    end

    local function get_value(t)
        local t1 = find_span(t)
        local t0 = math.max(1, t1-1)
        local t2 = math.min(#timeline, t1+1)
        local t3 = math.min(#timeline, t1+2)

        local p0 = timeline[t0]
        local p1 = timeline[t1]
        local p2 = timeline[t2]
        local p3 = timeline[t3]

        local v0 = p0.val
        local v1 = p1.val
        local v2 = p2.val
        local v3 = p3.val

        local progress = 0.0
        if p1.t ~= p2.t then
            progress = math.min(1, math.max(0, 1.0 / (p2.t - p1.t) * (t - p1.t)))
        end

        if p1.ease == "linear" then 
            return (v1 * (1-progress) + (v2 * progress)) 
        elseif p1.ease == "step" then
            return v1
        elseif p1.ease == "inout" then
            return -(v2-v1) * progress*(progress-2) + v1
        else
            local d1 = p2.t - p1.t
            local d0 = p1.t - p0.t

            local bias = 0.5
            local tension = 0.8
            local mu = progress
            local mu2 = mu * mu
            local mu3 = mu2 * mu
            local m0 = (v1-v0)*(1+bias)*(1-tension)/2 + (v2-v1)*(1-bias)*(1-tension)/2
            local m1 = (v2-v1)*(1+bias)*(1-tension)/2 + (v3-v2)*(1-bias)*(1-tension)/2

            m0 = m0 * (2*d1)/(d0+d1)
            m1 = m1 * (2*d0)/(d0+d1)
            local a0 =  2*mu3 - 3*mu2 + 1
            local a1 =    mu3 - 2*mu2 + mu
            local a2 =    mu3 -   mu2
            local a3 = -2*mu3 + 3*mu2
            return a0*v1+a1*m0+a2*m1+a3*v2
        end
    end

    return get_value
end

local function move_in_scroll_move_out(S, Scroll, E, x, y, y_lift, obj)
    local x = make_smooth{
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
--    local end_scroll = S+15
--    while end_scroll + 15 < E-4 do   -- keep scrolling up and down as long as time is not over
--        y_timeline[#y_timeline+1] = {t = end_scroll+4, val = y}
--        y_timeline[#y_timeline+1] = {t = end_scroll+7, val = y-y_lift, ease='step'}
--        y_timeline[#y_timeline+1] = {t = end_scroll+Scroll, val = y-y_lift}
--        y_timeline[#y_timeline+1] = {t = end_scroll+Scroll+3, val = y, ease='step'}
--        end_scroll = end_scroll+15
--    end
    y_timeline[#y_timeline+1] = {t = E-1, val = y}
    y_timeline[#y_timeline+1] = {t = E,   val = 0}
--    print(y_timeline)
--
    local y = make_smooth(y_timeline)

    return function(t)
        print(x(t), y(t))
    end
end

local function testing(timeline)
    print(#timeline)
end

local E=20

local function minutes_from_t(t)
    minutes = 120*t/E
    minutes = 10 * math.floor(minutes/10)
    minutes = minutes - 60
    return minutes
end

print(string.format("%+2.0f", minutes_from_t(12)))
