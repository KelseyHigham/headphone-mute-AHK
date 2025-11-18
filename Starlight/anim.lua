-- _time:      total time (except it's like... _frames/13, for framerates >= 30???)
-- _delta:     deltatime
-- _frames:    frame number
-- _rows:      counting vertically, top of the laptop to bottom, orthogonally not diagonally, every other frame is staggered. 61 on my model.
-- columns(y): how many columns per row, taking the cutout into account. 9~34 on my model.
-- init():     optional, runs once.
-- pixel(x,y): required, runs every pixel, ~1000 times per frame. (change in Program.cs.)
-- frame():    optional, runs every frame.
_width  = 64  -- diagonal
_height = 39  -- diagonal
_xcenter = _width//2
_ycenter = _height//2 - 6  -- there are 6 lines below 0

function sixstep(x, y, dir, steps)
    if steps == nil then steps = 1 end
    local step = {
        {x = 1, y = 0},
        {x = 0, y = 1},
        {x = -1, y = 1},
        {x = -1, y = 0},
        {x = 0, y = -1},
        {x = 1, y = -1}
    }
    return x + step[dir].x*steps, y + step[dir].y*steps
end




-- █▀▄▀▄ ▄▀█ ▀▀█▀ ▄▀▄
-- █ █ █ ▀▄█ ▄█▄▄ ▀█▄

mazebuf = {}
maze_x = _xcenter
maze_y = _ycenter
maze_dir = math.random(6)
turning = true
advancing = true
function maze()
    -- set(_xcenter, _ycenter, 1, mazebuf)
    if turning then
        turning = false
        maze_dir = (maze_dir - 1 + math.random(3) - 2) % 6 + 1
        try_x, try_y = sixstep(maze_x, maze_y, maze_dir, 2)
        if get(try_x, try_y, mazebuf) < .1 then
            advancing = true
        else
            advancing = false
        end
    else
        turning = true
    end
    if advancing then
        maze_x, maze_y = sixstep(maze_x, maze_y, maze_dir, 1)
        set(maze_x, maze_y, 1, mazebuf)
    end
    text("x " .. string.format("%3d", maze_x) .. " y " .. string.format("%3d", maze_y), _xcenter, -5)
end
function fade(custombuf)
    for i,v in pairs(custombuf) do
        custombuf[i] = v*.9
    end
end



-- ▄▀
-- █▀ █▄▀ ▄▀█ █▀▄▀▄ ▄▀▄
-- █  █   ▀▄█ █ █ █ ▀█▄

function frame()
    buffer = {}
    maze()
    fade(mazebuf)

    -- -- This draws a white pixel at (0,0) if beeeees[] hasn't been initialized??
    -- -- That might be why maze() is giving me occasional black flashes.
    -- text("d " .. beeeees[1].dir .. " x " .. beeeees[1].x .. " y " .. beeeees[1].y)

    -- set(_xcenter+1, _ycenter)
    -- set(_xcenter-1, _ycenter)
    -- set(_xcenter, _ycenter+1)
    -- set(_xcenter, _ycenter-1)
    -- set(_xcenter, _ycenter)

    -- text("kelly", _xcenter+3, 20)
    -- text("is cool", _xcenter+4, 15)
    -- text("kelly is cool")

    -- -- calculate FPS
    -- text(string.format("%.2f - %d", _time, _frames), _xcenter, -5)

    -- -- punctuation test
    -- text("~!@#$%^&*()", _xcenter+3, 10)
    -- text("{}?+|_:<>`[]/", _xcenter+3, 5)
    -- text("=\\-;',.", _xcenter, 0)
    -- -- alphabet test
    -- text("abcdefghi", _xcenter+3, 10)
    -- text("jklmnopqr", _xcenter+3, 5)
    -- text("stuvwxyz", _xcenter, 0)
end



--         ▀
-- █▄▀ ▄▀█ █ █▀▄
-- █   ▀▄█ █ █ █

-- simple pseudo-random function for per-column raindrops
local function hash(n)
    n = (n ~ 61) ~ (n >> 16)
    n = n + (n << 3)
    n = n ~ (n >> 4)
    n = n * 0x27d4eb2d
    n = n ~ (n >> 15)
    return n & 0xFFFFFFFF
end
function rain(x, y)
    -- taller sky means less frequent drops
    sky_height = 39*2
    -- -- random value per column, consistent across frames
    -- math.randomseed(x)
    -- local drop_y_initial = math.random(sky_height)
    -- math.randomseed(os.time())
    -- raindrop position in this column
    local drop_y = ((hash(x) % sky_height) - _frames) % (sky_height)
    -- draw a streak maybe
    if y < drop_y - 10 then return 0 end
    if y > drop_y then return 0 end
    return ((drop_y - y) / 10)
end



-- █
-- █▀▄ ▄▀▄ ▄▀▄ ▄▀▀
-- █▄▀ ▀█▄ ▀█▄ ▄█▀

function randx() return math.random(_width) end
function randy() return math.random(_height)-6 end
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
    -- flash on save
    if _frames == 0 then return 1 end
    -- if get(x, y, mazebuf) == 1 then return 1 end  -- found my ghost!!
    -- correct the fact that the x-coordinate is offset by the cutout
    tx = x + (cols - columns(y))
    ty = y
    -- convert to diagonal coordinates
    dx = tx + (1+ty)//2
    dy = tx + (1-ty)//2
    if dx == 0 and dy == 0 then
        frame()
    end
    return clamp(
        gamma(rain(dx,dy)) * .1
        -- + gamma(bees(dx, dy))
        + gamma(get(dx, dy))
        + gamma(get(dx, dy, mazebuf))
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



-- █       ▄▀ ▄▀
-- █▀▄ █ █ █▀ █▀ ▄▀▄ █▄▀
-- █▄▀ ▀▄█ █  █  ▀█▄ █

buffer = {}
function set(x, y, value, custombuf)
    y = y + 6
    if value == nil then value = 1 end
    if value == true then value = 1 end
    if value == false then value = 0 end
    if custombuf then
        custombuf[y%_height * _width + x%_width] = value
    else
        buffer[y%_height * _width + x%_width] = value
    end
end
function get(x, y, custombuf)
    y = y + 6
    if not custombuf then custombuf = buffer end
    if custombuf[y * _width + x] then
        return custombuf[y%_height * _width + x%_width]
    else
        return 0
    end
end



--  ▄           ▄
-- ▀█▀ ▄▀▄ ▀▄▀ ▀█▀
--  ▀▄ ▀█▄ ▄▀▄  ▀▄

-- ASCII range 0x20-0x5F, or 32-95
font = {}
font[1] = "     #  # # ### ### ### ###  #  ##   #  ##   #  "
font[2] = "     #  # # ### ### ### ###  #  #     # ### ### "
font[3] = "            ### ### ### ###     #     #  ##  #  "
font[4] = "     #      ### ### ### ###      #   ##         "

font[1] = font[1] .. "             ## ##   #  ##  ##  # # ### ### ### "
font[2] = font[2] .. "    ###      #  # # ##    #   # ### #   #     # "
font[3] = font[3] .. " #           #  # #  #  #    ##   #  ## ###   # "
font[4] = font[4] .. "##       #  ##   ## ### ### ##    # ##  ###   # "

font[1] = font[1] .. "### ###  #   #  ### ### #   ### ### ### ##  ### "
font[2] = font[2] .. "### # #          #       #    # # # # # ### #   "
font[3] = font[3] .. "# # ###      #    # ### ###     #   ### # # #   "
font[4] = font[4] .. "###   #  #  ##               #   #  # # ### ### "

font[1] = font[1] .. "##  ### ### ### # # ###   # # # #   ### ##  ### "
font[2] = font[2] .. "# # ##  #   #   ###  #    # ### #   ### # # # # "
font[3] = font[3] .. "# # #   ##  # # # #  #  # # ##  #   # # # # # # "
font[4] = font[4] .. "### ### #   ### # # ### ### # # ### # # # # ### "

font[1] = font[1] .. "### ### ### ### ### # # # # # # # # # # ### ##  "
font[2] = font[2] .. "# # # # ### #    #  # # # # # #  ## ###   # #   "
font[3] = font[3] .. "### ### ##   ##  #  # #  ## ### ##   #  #   #   "
font[4] = font[4] .. "#     # # # ###  #  ###   # ### # #  #  ### ##  "

font[1] = font[1] .. "#    ## ##      "
font[2] = font[2] .. " #    # # #     "
font[3] = font[3] .. " #    #         "
font[4] = font[4] .. "  #  ##     ### "

-- Simplified math by treating everything as 0-indexed, and passing in "+1" to Lua functions.
function text(text, x, y)
    if x == nil then x = _xcenter end
    if y == nil then y = 0 end
    text = tostring(text)
    -- loop through input string
    for char_i = 0, #text-1 do
        char = text:sub(char_i+1, char_i+1)
        glyph = {}
        ascii_code = string.byte(text, char_i+1)
        -- lowercase -> uppercase
        if 0x60 <= ascii_code and ascii_code <= 0x7F then
            ascii_code = ascii_code - 0x20
        end
        my_code = (ascii_code - 0x20) % 0x60
        for row = 0, 3 do
            glyph[row+1] = font[row+1]:sub(my_code*4 + 1, my_code*8 + 1)
            for col = 0, 3 do
                if glyph[row+1]:sub(col+1, col+1) == "#" then
                    set(x + char_i*4 - #text/2*4 + col, y + 3-row, 1)
                else
                    set(x + char_i*4 - #text/2*4 + col, y + 3-row, 0)
                end
            end
        end
    end
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