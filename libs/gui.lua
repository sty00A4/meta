require("meta.libs.ext")

return {
    position = {
        absolute = function(x, y, w, h)
            expect("x", x, "number")
            expect("y", y, "number")
            return setmetatable({ x = x, y = y }, { __name = "gui.component.position.absolute" })
        end,
        relative = function(x, y, w, h)
            expect("x", x, "number") range("x", x, 0, 1)
            expect("y", y, "number") range("y", y, 0, 1)
            return setmetatable({
                x = x, y = y
            }, { __name = "gui.component.position.relative" })
        end,
    },
    text = function(content, fg, bg)
        expect("content", content, "string")
        expect("fg", fg, "number")
        expect("bg", bg, "number")
        return setmetatable({
            content = content, fg = fg, bg = bg,
            draw = function(self, element, page, app)
                term.push()
                if metatype(element.components.position) == "gui.component.position.absolute" then
                    term.setCursorPos(element.components.position.x, element.components.position.y)
                end
                term.setTextColor(self.fg) term.setBackgroundColor(self.bg)
                term.write(self.content)
                term.pop()
            end,
        }, { __name = "gui.component.text" })
    end,
    button = function(position, text, action, color)
        if color == nil then color = colors.gray end
        expect("position", position, "gui.component.position")
        expect("text", text, "gui.component.text")
        expect("action", action, "function", "nil")
        expect("color", color, "number")
        return setmetatable({
            components = { position = position, text = text }, color = color, action = action,
            draw = function(self, page, app)
                term.push()
                if metatype(self.components.position) == "gui.component.position.absolute" then
                    term.setCursorPos(self.components.position.x, self.components.position.y)
                end
                term.setBackgroundColor(self.components.text.bg)
                term.setTextColor(self.color) term.write("[")
                term.setTextColor(self.components.text.fg) term.write(self.components.text.content)
                term.setTextColor(self.color) term.write("]")
                term.pop()
            end,
            event = function(self, event, page, app)
                if type(self.action) == "function" then
                    if event[1] == "mouse_click" then
                        local mx, my = event[3], event[4]
                        local x, y = self.components.position.x, self.components.position.y
                        local w, h = #self.components.text.content + 2, 1
                        if (mx >= x and my >= y) and (mx < x + w and my < y + h) then
                            return self:action(event, page, app)
                        end
                    end
                end
            end
        },{ __name = "gui.element.button" })
    end,
    element = function(components)
        expect("components", components, "table")
        local t = { components = components }
        if metatype(components.draw) ~= "function" then
            t.draw = function(self, page, app)
                for _, c in pairs(self.components) do
                    if metatype(c.draw) == "function" then c:draw(self, page, app) end
                end
            end
        end
        if metatype(components.update) ~= "function" then
            t.update = function(self, page, app)
                for _, c in pairs(self.components) do
                    if metatype(c.update) == "function" then c:update(self, page, app) end
                end
            end
        end
        if metatype(components.event) ~= "function" then
            t.event = function(self, event, page, app)
                for _, c in pairs(self.components) do
                    if metatype(c.event) == "function" then c:event(self, event, page, app) end
                end
            end
        end
        for k, v in pairs(components) do expect(k, v, "gui.component") end
        return setmetatable(t, { __name = "gui.element.custom" })
    end,
    page = function(elements, context, color)
        if color == nil then color = colors.black end
        if context == nil then context = {} end
        expect("elements", elements, "table")
        expect("context", context, "table")
        expect("color", color, "number")
        for k, e in pairs(elements) do expect("elements."..tostring(k), e, "gui.element") end
        return setmetatable({
            context = context, elements = elements, color = color,
            draw = function(self, app)
                for _, e in pairs(self.elements) do
                    if metatype(e.draw) == "function" then e:draw(self, app) end
                end
            end,
            update = function(self, app)
                for _, e in pairs(self.elements) do 
                    if metatype(e.update) == "function" then e:update(self, app) end
                    end
            end,
            event = function(self, event, app)
                for _, e in pairs(self.elements) do
                    if metatype(e.event) == "function" then e:event(event, self, app) end
                end
            end,
        },{ __name = "gui.page" })
    end,
    app = function(pages, start, context)
        if context == nil then context = {} end
        expect("pages", pages, "table")
        expect("start", start, "string")
        expect("context", context, "table")
        for k, p in pairs(pages) do expect("pages."..tostring(k), p, "gui.page") end
        return setmetatable({
            current = start, pages = pages, start = start, context = context, run = false,
            draw = function(self)
                for _, p in ipairs(self.pages) do
                    if metatype(p.draw) == "function" then p:draw(self.pages[self.current], self) end
                end
            end,
            update = function(self)
                for _, p in ipairs(self.pages) do 
                    if metatype(p.update) == "function" then p:update(self.pages[self.current], self) end
                    end
            end,
            event = function(self, event)
                for _, p in ipairs(self.pages) do
                    if metatype(p.event) == "function" then p:event(event, self.pages[self.current], self) end
                end
            end,
            loop = function(self)
                self.run = true
                local W, H = term.getSize()
                while self.run do
                    term.reset()
                    term.setBackgroundColor(self.pages[self.current].color)
                    term.clear()
                    self.pages[self.current]:update(self)
                    self.pages[self.current]:draw(self)
                    local event = { os.pullEvents({"key", "char", "mouse_click", "mouse_scroll"}) }
                    self.pages[self.current]:event(event, self)
                end
            end
        },{ __name = "gui.page" })
    end,
    metatype = metatype,
    expect = expect,
    range = range,
}