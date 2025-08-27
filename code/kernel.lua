-- CC:T Kernel.
if zyra then
  panic("Multiple Zyra Sessions Running! Can't keep up!")
end
local zyra.pullEvent = os.pullEvent
local zyra.pullEventRaw = os.pullEventRaw
os.pullEvent = os.pullEventRaw
zyra = {}
screen = {}
gpu = term
screen.size = {gpu.getSize()}  -- store as {width, height}
term = ""  -- placeholder / disabling direct terminal access
io = ""
print = ""
shell = zyra
panictime = 9999
zyra.panic = function(s)
  while true do 
    print("PANIC: "..s) 
    sleep(panictime) end
end
function zyra.getChar()
local event, char = zyra.pullEventRaw()
if event = "char" then
  return char
  else
    return
  end
end
zyra.fs = {}
zyra.permissions = {
    ["/kernel.lua"] = "none"
}

function zyra.fs.read(path)
    local perm = zyra.permissions[path] or "readwrite"
    if perm == "none" then error("Permission denied") end
    if not fs.exists(path) then return nil end
    local f = fs.open(path,"r")
    local data = f.readAll()
    f.close()
    return data
end

function zyra.fs.write(path,data)
    local perm = zyra.permissions[path] or "readwrite"
    if perm ~= "readwrite" then error("Permission denied") end
    local f = fs.open(path,"w")
    f.write(data)
    f.close()
end
fs = ""
fs = zyra.fs
-- Initialize virtual screen table
screen.data = {}
for y = 1, screen.size[2] do
    screen.data[y] = {}
    for x = 1, screen.size[1] do
        screen.data[y][x] = {char = " ", color = colors.white}
    end
end

-- Function to set a cell
function screen.set(x, y, char, color)
    if x >= 1 and x <= screen.size[1] and y >= 1 and y <= screen.size[2] then
        screen.data[y][x] = {char = char, color = color or colors.white}
    end
end

-- Function to render the screen
function screen.render()
    gpu.clear()
    for y = 1, screen.size[2] do
        gpu.setCursorPos(1, y)
        for x = 1, screen.size[1] do
            local cell = screen.data[y][x]
            gpu.setTextColor(cell.color)
            gpu.write(cell.char)
        end
    end
end
zyra.print = function(...)
    local args = {...}
    local text = table.concat(args, " ")  -- combine all arguments into a string

    -- Example: write to top-left corner (expand later for scrolling)
    screen.set(1,1,text, colors.white)
    screen.render()
end

-- Optional: override global print to force kernel-safe print
print = function(...)
    zyra.print(...)
end
-- Example usage:
function zyra.processlog(...)
  print("process: "...)
end
