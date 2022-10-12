require("libs.ext")
expect("gui", _G.gui, "table")
term.reset()
local app = gui.app(
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
app:loop()