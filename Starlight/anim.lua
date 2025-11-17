-- _time:      total time (except it's like... _frames/13, for framerates >= 30???)
-- _delta:     deltatime
-- _frames:    frame number
-- _rows:      counting vertically, top of the laptop to bottom, orthogonally not diagonally, every other frame is staggered. 61 on my model.
-- columns(y): how many columns per row, taking the cutout into account. 9~34 on my model.
-- init():     optional, runs once.
-- pixel(x,y): required, runs every frame. (change in Program.cs.)
_width  = 64  -- diagonal
_height = 39  -- diagonal
_xcenter = _width//2
_ycenter = _height//2



-- ASCII range 0x20-0x5F, or 32-95
font = {}
font[1] = "     █  █ █ ███ ███ ███ ███  █  ██   █  ██   █  "
font[2] = "     █  █ █ ███ ███ ███ ███  █  █     █ ███ ███ "
font[3] = "            ███ ███ ███ ███     █     █  ██  █  "
font[4] = "     █      ███ ███ ███ ███      █   ██         "

font[1] = font[1] .. "             ██ ██   █  ██  ██  █ █ ███ ███ ███ "
font[2] = font[2] .. "    ███      █  █ █ ██    █   █ █ █ █   █     █ "
font[3] = font[3] .. " █           █  █ █  █  █    ██ ███  ██ ███   █ "
font[4] = font[4] .. "██       █  ██   ██ ███ ███ ██    █ ██  ███   █ "

font[1] = font[1] .. "███ ███  █   █  ███ ███ █   ███ ███ ███ ██  ███ "
font[2] = font[2] .. "███ █ █          █       █    █ █ █ █ █ ███ █   "
font[3] = font[3] .. "█ █ ███      █    █ ███ ███     █ █ ███ █ █ █   "
font[4] = font[4] .. "███   █  █  ██               █  ██  █ █ ███ ███ "

font[1] = font[1] .. "██  ███ ███ ███ █ █ ███   █ █ █ █   ███ ██  ███ "
font[2] = font[2] .. "█ █ ██  █   █   ███  █    █ ███ █   ███ █ █ █ █ "
font[3] = font[3] .. "█ █ █   ██  █ █ █ █  █  █ █ ██  █   █ █ █ █ █ █ "
font[4] = font[4] .. "███ ███ █   ███ █ █ ███ ███ █ █ ███ █ █ █ █ ███ "

font[1] = font[1] .. "███ ███ ███ ███ ███ █ █ █ █ █ █ █ █ █ █ ███ ██  "
font[2] = font[2] .. "█ █ █ █ ███ █    █  █ █ █ █ █ █  ██ ███   █ █   "
font[3] = font[3] .. "███ ███ ██   ██  █  █ █  ██ ███ ██   █  █   █   "
font[4] = font[4] .. "█     █ █ █ ███  █  ███   █ ███ █ █  █  ███ ██  "

font[1] = font[1] .. "█    ██ ██      "
font[2] = font[2] .. " █    █ █ █     "
font[3] = font[3] .. " █    █         "
font[4] = font[4] .. "  █  ██     ███ "



-- █       ▄▀ ▄▀
-- █▀▄ █ █ █▀ █▀ ▄▀▄ █▄▀
-- █▄▀ ▀▄█ █  █  ▀█▄ █

buffer = {}
function set(x, y, value)
    buffer[y * _height + x] = value
end
function get(x, y)
    if buffer[y * _height + x] then
        return buffer[y * _height + x]
    else
        return 0
    end
end
-- set(_xcenter, _ycenter, 1)
set(_xcenter+1, _ycenter, 1)
set(_xcenter-1, _ycenter, 1)
set(_xcenter, _ycenter+1, 1)
set(_xcenter, _ycenter-1, 1)



--  ▄           ▄
-- ▀█▀ ▄▀▄ ▀▄▀ ▀█▀
--  ▀▄ ▀█▄ ▄▀▄  ▀▄

function text(text, x, y)
    -- loop through input string
    for char_i = 1, #text do -- for each char
        char = text:sub(char_i, char_i)
        drawing = {}
        ascii_code = string.byte(text, char_i, char_i)
        -- lowercase -> uppercase
        if 0x60 < ascii_code and ascii_code < 0x7F then
            ascii_code = ascii_code - 0x20
        end
        drawing[1] = font[1]:sub(ascii_code*4, ascii_code*8)
        drawing[2] = font[2]:sub(ascii_code*4, ascii_code*8)
        drawing[3] = font[3]:sub(ascii_code*4, ascii_code*8)
        drawing[4] = font[4]:sub(ascii_code*4, ascii_code*8)
        for row = 1, 4 do -- for each row
            drawing[row] = font[row]:sub(ascii_code*4, ascii_code*8)
            for col = 1, 4 do -- for each column
                if drawing[row]:sub(col) == "█" then
                    set(x + char_i*4 + col, y + row, 1)
                else
                    set(x + char_i*4 + col, y + row, 0)
                end
            end
        end
    end
end

text("HI", _xcenter, _ycenter)

--         ▀
-- █▄▀ ▄▀█ █ █▀▄
-- █   ▀▄█ █ █ █

function rain(x, y)
    -- taller sky means less frequent drops
    sky_height = 39*2
    -- random value per column, consistent across frames
    math.randomseed(x)
    local drop_y_initial = math.random(sky_height)
    math.randomseed(_frames)
    -- raindrop position in this column
    local drop_y = ((drop_y_initial % sky_height) - _frames) % (sky_height)
    -- draw a streak maybe
    if y < drop_y - 10 then return 0 end
    if y > drop_y then return 0 end
    return ((drop_y - y) / 10)
end



-- █
-- █▀▄ ▄▀▄ ▄▀▄ ▄▀▀
-- █▄▀ ▀█▄ ▀█▄ ▄█▀

function randx() return math.random(_width) end
function randy() return math.random(_height) end
beeeees = {}
dances = {
    function(bee) bee.x = bee.x + 1 end,
    function(bee) bee.x = bee.x - 1 end,
    function(bee) bee.y = bee.y + 1 end,
    function(bee) bee.y = bee.y - 1 end,
    function(bee) bee.x = bee.x + 1; bee.y = bee.y - 1 end,
    function(bee) bee.x = bee.x - 1; bee.y = bee.y + 1 end,
}
function bees( x, y )
    -- -- test that math.random() is getting seeded correctly
    -- if math.random(_width) == x and math.random(_height) == y then return 1 end
    if _frames%100 == 0 and #beeeees<10 then
        table.insert(beeeees, {dir=math.random(6), x=randx(), y=randy()})
    end
    for i,bee in ipairs(beeeees) do
        if bee.x%_width == x and bee.y%_height == y then return 1 end
        if _frames%100==0 then
            if math.random()>.5 then
                dances[bee.dir](bee)
            else
                bee.dir = (bee.dir + math.random(2)-1)%6+1
            end
        end
        -- if #beeeees > 10 and math.random()>.01 then table.remove(beeeees, i) end
    end
    return 0
end





--     ▀         █
-- █▀▄ █ ▀▄▀ ▄▀▄ █
-- █▄▀ █ ▄▀▄ ▀█▄ █
-- █
function pixel(x, y)
    -- correct the fact that the x-coordinate is offset by the cutout
    tx = x + (cols - columns(y))
    ty = y
    -- -- put the center at (0,0)
    -- tx = tx - cols//2
    -- ty = ty - _rows//2
    -- convert to diagonal coordinates by transforming
    -- input:
    -- (0,0) (1,0) (2,0) (3,0) (4,0)
    -- (0,1) (1,1) (2,1) (3,1) (4,1)
    -- (0,2) (1,2) (2,2) (3,2) (4,2)
    -- (0,3) (1,3) (2,3) (3,3) (4,3)
    -- (0,4) (1,4) (2,4) (3,4) (4,4)
    -- output:
    -- (0,0) (1,1) (2,2) (3,3) (4,4)
    -- (1,0) (2,1) (3,2) (4,3) (5,4)
    -- (1,-1) (2,0) (3,1) (4,2) (5,3)
    -- (2,-1) (3,0) (4,1) (5,2) (6,3)
    -- (2,-2) (3,-1) (4,0) (5,1) (6,2)
    dx = tx + (1+ty)//2
    dy = tx + (1-ty)//2
    return clamp(
        gamma(rain(dx,dy)) * .1
        -- + gamma(bees(dx, dy))
        + gamma(get(dx, dy))
        , 0, 1)
end

function init()
    cols = 0
    for r = 0, _rows-1 do
        cols = math.max(cols, columns(r))
    end
end

function gamma(v)
    -- if v == true then v = 0 end  -- hack so i can say like "x == 4 or sin(x)" in mycode()
    return v^2
end

function clamp(value, min, max)
    return math.max(math.min(value, max), min)
end









--[[

-- circusy pattern

function mycode(x,y,px,py)
    illuminate = false
    return illuminate or 1-math.sqrt(x^2 + y^2)/30
end

function gamma(v)
    if v == true then v = 0 end  -- hack so i can say like "x == 4 or sin(x)" in mycode()
    return v^2
end

function pixel(x, y)
    -- correct the fact that the x-coordinate is offset by the cutout
    tx = x + (cols - columns(y)) - cols//2
    ty = y - _rows//2
    if ty%2==0 then
        return gamma(mycode(tx,ty))
    else
        return 1
    end
end

]]



--[[
function init()
    -- runs once
end

function pixel(x, y)
    local w = columns(y)
    local cx = w / 2
    local t = _time or 0
    -- simple moving pulse across each row
    local v = math.sin((x - cx) * 0.5 - t * 3.0)
    return (v + 1) * 0.5 -- normalized to 0..1
end
--]]




--[[
-- Selector: "plasma", "radial", "ripple", or "rain"
local effect = "ripple"

-- Utility helpers
local clamp = function(v, a, b) if v < a then return a elseif v > b then return b else return v end end
local lerp = function(a, b, t) return a + (b - a) * t end

-- PLASMA: layered sin waves (smooth, colorful when mapped to RGB; here grayscale)
local plasma = function(x, y)
    local w = columns(y)
    local nx = x / math.max(1, w)
    local ny = y / math.max(1, _rows)
    local v = 0
    v = v + math.sin((nx + _time * 0.6) * 6.0)
    v = v + math.sin((ny - _time * 0.8) * 5.0)
    v = v + math.sin((nx + ny + math.sin(_time * 0.4)) * 4.0)
    -- normalize from [-3,3] to [0,1]
    return ((v / 0),+ 1) / 2)^2
end

-- RADIAL PULSE: moving center, pulse rings with falloff
local radial = function(x, y)
    local w = columns(y)
    local cx = w * 0.5 + math.sin(_time * 0.4) * (w * 0.25)
    local cy = _rows * 0.5 + math.cos(_time * 0.25) * (_rows * 0.2)
    local dx = x - cx
    local dy = y - cy
    local dist = math.sqrt(dx * dx + dy * dy)
    local maxd = math.sqrt((w*0.5)^2 + (_rows*0.5)^2)
    -- create a ring that moves outward
    local ring = 0.5 * (1 + math.cos(dist * 0.35 - _time * 3.0))
    -- attenuate by distance so rings fade out
    local falloff = clamp(1 - (dist / maxd), 0, 1)
    return clamp(ring * falloff, 0, 1)
end

-- RIPPLE: repeating expanding ripples from several centers
local ripple = function(x, y)
    local w = columns(y)
    local cx1 = w * 0.25
    local cy1 = _rows * 0.5
    local cx2 = w * 0.75
    local cy2 = _rows * 0.5
    local d1 = math.sqrt((x - cx1)^2 + (y - cy1)^2)
    local d2 = math.sqrt((x - cx2)^2 + (y - cy2)^2)
    local r1 = 0.5 * (1 + math.sin(d1 * 0.6 - _time * 4.0))
    local r2 = 0.5 * (1 + math.sin(d2 * 0.6 - _time * 3.2))
    -- combine and limit
    return clamp((r1 * (1 - d1/100) + r2 * (1 - d2/100)) * 0.7, 0, 1)
end

-- RAIN: falling drops per column (simple)
local rain = function(x, y)
    local w = columns(y)
    local speed = 6.0
    local phase = x * 0.6
    -- drop position floats down over time, wrap by _rows
    local dropPos = (_time * speed + phase) % (_rows + 4)
    local dist = math.abs(y - dropPos)
    -- narrow bright head plus trailing fade
    local head = clamp(1 - dist, 0, 1)
    local tail = clamp(1 - math.max(0, dist - 1) * 0.5, 0, 1) * 0.4
    return clamp(head + tail, 0, 1)
end

-- pixel() called by renderer; must return number in [0,1]
function pixel(x, y)
    if effect == "plasma" then
        return plasma(x, y)
    elseif effect == "radial" then
        return radial(x, y)
    elseif effect == "ripple" then
        return ripple(x, y)
    elseif effect == "rain" then
        return rain(x, y)
    else
        -- fallback: checker
        local cols = columns(y)
        local v = ((x + y) % 2) == 0 and 1 or 0
        return v
    end
end
--]]

--[[ -- pulse
function init()
    -- optional init code
end

function pixel(x, y)
    local t = _time or 0
    local cols = columns(y)
    local cx = cols / 2
    local v = math.sin(t * 2 + (x - cx) * 0.0),+ y * 0.1)
    return (v + 1) / 2 -- value in 0..1
end
--]]



--[[ -- original
function __swipe_down(x, y)
    return (10 * math.cos((x / columns(y) + _time)) * math.sin(_time)) * _delta
end

function __anim2(x, y)
    
end

function pixel(x, y)
    local width = columns(y)
    
    local cx1 = math.sin(_time / 4) * width / 6 + width / 2
    local cy1 = math.sin(_time / 8) * _rows / 6 + _rows / 2
    local cx2 = math.cos(_time / 6) * width / 6 + width / 2
    local cy2 = math.cos(_time) * _rows / 6 + _rows / 2
    
    local dx = ((x - cx1) ^ 2) // 1
    local dy = ((y - cy1) ^ 2) // 1
    
    local dx2 = ((x - cx2) ^ 2) // 1
    local dy2 = ((y - cy2) ^ 2) // 1
    
    --return 10 * ((((math.sqrt(dx + dy) // 1) ~ (math.sqrt(dx2 + dy2) // 1)) >> 4) & 1) * _delta
    return __swipe_down(x, y)
end
--]]





--[[
todo when i have LLM tokens:
- make framerate configurable from lua
- make brightness configurable from lua
- provide a list of functions in lua; read them from C#; and select from them in the context menu, by commenting Lua out
]]