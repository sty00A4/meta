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
                if event[1] == "mouse_click" then
                    if type(self.action) == "function" then
                        local mx, my = event[3], event[4]
                        local x, y = self.components.position.x, self.components.position.y
                        local w, h = #self.components.text.content + 2, 1
                        if (mx >= x and my >= y) and (mx < x + w and my < y + h) then
                            return self:action(event, page, app)
                        end
                        return
                    end
                end
                for _, c in pairs(self.components) do
                    if metatype(c.event) == "function" then c:event(self, event, page, app) end
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
            clear = function(self)
                term.reset()
                term.setBackgroundColor(self.pages[self.current].color)
                term.clear()
            end,
            draw = function(self)
                self.pages[self.current]:draw(self)
            end,
            update = function(self)
                self.pages[self.current]:update(self)
            end,
            pullEvent = function(self)
                local event = { os.pullEventsRaw({"key", "char", "mouse_click", "mouse_scroll", "terminate"}) }
                if event[1] == "terminate" then
                    if metatype(self.context._TERMINATE) == "function" then self.context._TERMINATE(self)
                    else error() end
                end
                return event
            end,
            event = function(self, event)
                self.pages[self.current]:event(event, self)
            end,
            loop = function(self, clear)
                if clear == nil then clear = true end
                expect("clear", clear, "boolean")
                self.run = true
                while self.run do
                    if clear then self:clear() end
                    self:update()
                    self:draw()
                    local event = self:pullEvent()
                    self:event(event)
                end
            end
        },{ __name = "gui.page" })
    end,
    demos = {
        buttonHunt = function()
            return gui.app(
                {
                    main = gui.page({
                        gui.button(
                            gui.position.absolute(1, 1),
                            gui.text("button", colors.white, colors.black),
                            function(self, page, app)
                                local w, h = term.getSize()
                                self.components.position.x = math.random(1, w - #self.components.text.content - 1)
                                self.components.position.y = math.random(1, h)
                            end
                        ),
                    })
                },
                "main",
                { version = "0.1", __TERMINATE = function(_) os.shutdown() end }
            )
        end
    },
    metatype = metatype,
    expect = expect,
    range = range,
}