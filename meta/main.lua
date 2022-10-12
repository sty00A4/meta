require("libs.ext")
expect("gui", _G.gui, "table")

local app = gui.app(
    {
        main = gui.page({
            gui.button(
                gui.position.absolute(1, 1),
                gui.text("button", colors.white, colors.black),
                function(self, page, app)
                    self.components.position.x = self.components.position.x + 1
                end
            ),
        })
    },
    "main",
    {version = "0.1"}
)
app:loop()