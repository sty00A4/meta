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
---returns `true` if object `e` was found in the table `t`
---@param t table
---@param e any
---@return boolean
table.contains = function(t, e)
    for _, v in pairs(t) do
        if v == e then return true end
    end
    return false
end
---joins table's contents to a string seperated by `sep`
---@param t table
---@param sep string
---@return string
table.join = function(t, sep)
    local str = ""
    for _, v in pairs(t) do
        str = str .. tostring(v) .. sep
    end
    if #str > 0 then str = str:sub(1,#str-#sep) end
    return str
end
---returns `true` if the field `key` is inside of the table `t`
---@param t table
---@param key string
---@return boolean
table.containsKey = function(t, key)
    for k, _ in pairs(t) do
        if k == key then return true end
    end
    return false
end
---returns a table containing the parts of the string `s` split by the seperator `sep`
---@param s string
---@param seps string
---@return table
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
---returns a table containing the parts of the string `s` split by the seperators in `seps`
---@param s string
---@param seps table
---@return table
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
---returns a table containing the parts of the string `s` split by the seperator `sep` which is kept
---@param s string
---@param sep string
---@return table
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
---returns a table containing the parts of the string `s` split by the seperators in `seps` which are kept
---@param s string
---@param seps table
---@return table
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
---like `os.pullEventRaw` but you can search for multiple events
---@param events table
os.pullEventsRaw = function(events)
    while true do
        local event, p1, p2, p3, p4, p5, p6 = os.pullEventRaw()
        if table.contains(events, event) then return event, p1, p2, p3, p4, p5, p6 end
    end
end
---like `os.pullEvent` but you can search for multiple events
---@param events table
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
---returns the object's type, if it is a metatable and has a string stored in the meta attribute `__name` than that'll be returned.
---@param t any
---@return string
function metatype(t)
    local meta = getmetatable(t)
    if meta then if type(meta.__name) == "string" then return tostring(meta.__name) end end
    return type(t)
end
---checks for metatype paths with `.` if any of the `...` metatypes are headers of the `value` object's metatype:
---`a.b.c` would match with `a.b.c`, `a.b` and also just `a`, but not `a.e.c`
---@param type1 string
---@param type2 string
---@return boolean
function metaequal(type1, type2)
    local match = true
    local type1_path = type1:split(".")
    local type2_path = type2:split(".")
    for i, name in ipairs(type2_path) do
        if name ~= type1_path[i] then match = false break end
    end
    return match
end
---throws an error if the `value` object's metatype doesn't match any in `...`.
---Also checks for metatype paths with `.` if any of the `...` metatypes are headers of the `value` object's metatype:
---`a.b.c` would match with `a.b.c`, `a.b` and also just `a`, but not `a.e.c`
---@param label string
---@param type string
---@param ... string
function expect(label, value, ...)
    local types = {...}
    local typ = metatype(value)
    local path = typ:split(".")
    local matches = false
    for _, t in ipairs(types) do
        if metaequal(typ, t) then matches = true break end
    end
    if not matches then error("expected "..label.." to be of type "..table.join(types, "|")..", not "..typ, 3) end
end
---throws an error if `value` is not between `min` and `max`
---@param label string
---@param value number
---@param min number
---@param max number
function range(label, value, min, max)
    if metatype(value) then error("expected "..label.." to be of type "..type..", not "..metatype(value), 3) end
    if not (value >= min and value <= max) then error("expected "..label.." to be "..tostring(min).."-"..tostring(max)..", got "..tostring(value), 3) end
end