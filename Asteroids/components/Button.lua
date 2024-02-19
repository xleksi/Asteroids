local love = require "love"

local Text = require "components/Text"

function Button(func, textColor, buttonColor, width, height, text, textAlign, fontSize, button_x, button_y, text_x, text_y)
    local btn_text = {}
    func = func or function() print("This button has no function attached") end

    if text_y then
        btn_text.y = text_y + button_y
    else
        btn_text.y = button_y
    end

    if text_x then
        btn_text.x = text_x + button_x
    else
        btn_text.x = button_x
    end
    return {
        textColor = textColor or { r = 1, g = 1, b = 1 },
        buttonColor = buttonColor or { r = 0, g = 0, b = 0 },
        width = width or 100,
        height = height or 100,
        text = text or "No text added",
        text_x = text_x or button_x or 0,
        text_y = text_y or button_y or 0,
        button_x = button_x or 0,
        button_y = button_y or 0,
        textComponent = Text(
            text, 
            btn_text.x,
            btn_text.y,
            fontSize,
            false,
            false,
            width,
            textAlign,
            1
        ),

        setButtonColor = function (self, red, green, blue)
            self.buttonColor = { r = red, g = green, b = blue}
        end,

        setTextColor = function (self, red, green, blue)
            self.textColor = { r = red, g = green, b = blue}
        end,

        checkHover = function (self, mouse_x, mouse_y, cursorRadius)
            if (mouse_x + cursorRadius >= self.button_x) and (mouse_x - cursorRadius <= self.button_x + self.width) then
                if (mouse_y + cursorRadius >= self.button_y) and (mouse_y - cursorRadius <= self.button_y + self.height) then
                    return true
                end
            end

            return false
        end,

        click = function (self)
            func()
        end,

        draw = function (self)
            love.graphics.setColor(self.buttonColor["r"], self.buttonColor["g"], self.buttonColor["b"])
            love.graphics.rectangle("fill", self.button_x, self.button_y, self.width, self.height)
        
            self.textComponent:setColor(self.textColor["r"], self.textColor["g"], self.textColor["b"])
            self.textComponent:draw()
        
            love.graphics.setColor(1, 1, 1)
        end,

        getPos = function (self)
            return self.button_x, self.button_y
        end,

        getTextPos = function (self)
            return self.text_x, self.text_y
        end
    }
end

return Button