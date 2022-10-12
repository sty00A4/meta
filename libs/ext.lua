if not term.isColor() then
    colors.red = colors.lightGray
    colors.green = colors.lightGray
    colors.brown = colors.lightGray
    colors.blue = colors.lightGray
    colors.cyan = colors.lightGray
    colors.pink = colors.white
    colors.lime = colors.lightGray
    colors.yellow = colors.white
    colors.lightBlue = colors.white
    colors.magenta = colors.white
    colors.orange = colors.lightGray
end
table.contains = function(t, e)
    for _, v in pairs(t) do
        if v == e then return true end
    end
    return false
end
table.join = function(t, sep)
    local str = ""
    for _, v in pairs(t) do
        str = str .. tostring(v) .. sep
    end
    if #str > 0 then str = str:sub(1,#str-#sep) end
    return str
end
table.containsKey = function(t, key)
    for k, _ in pairs(t) do
        if k == key then return true end
    end
    return false
end
string.split = function(s, sep)
    local t = {}
    local temp = ""
    for i = 1, #s do
        local c = s:sub(i,i)
        if c == sep then
            if #temp > 0 then table.insert(t, temp) end
            temp = ""
        else if temp then temp = temp .. c else temp = c end end
    end
    if #temp > 0 then table.insert(t, temp) end
    return t
end
string.splits = function(s, seps)
    local t = {}
    local temp = ""
    for i = 1, #s do
        local c = s:sub(i,i)
        if table.contains(seps, c) then
            if #temp > 0 then table.insert(t, temp) end
            temp = ""
        else if temp then temp = temp .. c else temp = c end end
    end
    if #temp > 0 then table.insert(t, temp) end
    return t
end
string.splitKeep = function(s, sep)
    local t = {}
    local temp = ""
    for i = 1, #s do
        local c = s:sub(i,i)
        if c == sep then
            if #temp > 0 then table.insert(t, temp); table.insert(t, c) end
            temp = ""
        else if temp then temp = temp .. c else temp = c end end
    end
    if #temp > 0 then table.insert(t, temp) end
    return t
end
string.splitsKeep = function(s, seps)
    local t = {}
    local temp = ""
    for i = 1, #s do
        local c = s:sub(i,i)
        if table.contains(seps, c) then
            if #temp > 0 then table.insert(t, temp); table.insert(t, c) end
            temp = ""
        else if temp then temp = temp .. c else temp = c end end
    end
    if #temp > 0 then table.insert(t, temp) end
    return t
end
os.pullEventsRaw = function(events)
    while true do
        local event, p1, p2, p3, p4, p5, p6 = os.pullEventRaw()
        if table.contains(events, event) then return event, p1, p2, p3, p4, p5, p6 end
    end
end
os.pullEvents = function(events)
    while true do
        local event, p1, p2, p3, p4, p5, p6 = os.pullEvent()
        if table.contains(events, event) then return event, p1, p2, p3, p4, p5, p6 end
    end
end
rednet.receiveFrom = function(sender, timeout, protocol)
    local id, msg, prot
    local receive = function()
        while not (id == sender) do
            id, msg, prot = rednet.receive(protocol)
        end
    end
    local time = function()
        sleep(timeout)
    end
    parallel.waitForAny(receive, time)
    return msg
end
term.reset = function()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end
term.save = { [0] = {} }
term.save[0].cursorX, term.save[0].cursorY = term.getCursorPos()
term.save[0].bgColor = term.getBackgroundColor()
term.save[0].fgColor = term.getTextColor()
term.push = function()
    table.insert(term.save, {})
    term.save[#term.save].cursorX, term.save[#term.save].cursorY = term.getCursorPos()
    term.save[#term.save].bgColor = term.getBackgroundColor()
    term.save[#term.save].fgColor = term.getTextColor()
end
term.pop = function()
    local stack = table.remove(term.save)
    term.setCursorPos(stack.cursorX, stack.cursorY)
    term.setBackgroundColor(stack.bgColor)
    term.setTextColor(stack.fgColor)
end
function metatype(t)
    local meta = getmetatable(t)
    if meta then if type(meta.__name) == "string" then return tostring(meta.__name) end end
    return type(t)
end
---@param label string
---@param type string
function expect(label, value, ...)
    local types = {...}
    local typ = metatype(value)
    local path = typ:split(".")
    local matches = false
    for _, t in ipairs(types) do
        local match = true
        local type_path = t:split(".")
        for i, name in ipairs(type_path) do
            if name ~= path[i] then match = false break end
        end
        if match then matches = true break end
    end
    if not matches then error("expected "..label.." to be of type "..table.join(types, "|")..", not "..typ, 3) end
end
---@param label string
---@param type string
---@param value number
---@param min number
---@param max number
function range(label, value, min, max)
    if metatype(value) then error("expected "..label.." to be of type "..type..", not "..metatype(value), 3) end
    if value >= min and value <= max then error("expected "..label.." to be "..tostring(min).."-"..tostring(max)..", got "..tostring(value), 3) end
end