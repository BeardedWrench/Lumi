local Button = {}
local Theme = require('lumi.core.theme')
local Label = require('lumi.elements.Label.Label')
local Box = require('lumi.elements.foundation.Box')
local TextUtil = require('lumi.core.util.text')



local ButtonElement = Box.BoxElement:extend()

function ButtonElement:init()
  ButtonElement.__super.init(self)
  
  self.className = "ButtonElement"
  self.text = "Button"
  self.fontSize = Theme.typography.fontSize
  self.disabled = false
  self.idleColor = Theme.colors.button
  self.hoverColor = Theme.colors.hover
  self.pressColor = Theme.colors.press
  self.disabledColor = Theme.colors.disabled
  self.idleTextColor = Theme.colors.text
  self.hoverTextColor = Theme.colors.text
  self.pressTextColor = Theme.colors.text
  self.disabledTextColor = Theme.colors.textDisabled
  self.padding = {Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding} 
  self._state = 'idle' 
  self._clicked = false
  self._textLabel = nil
  self.onClick = nil
  
  self._onMouseEnter = function()
    self:onMouseEnter()
  end
  
  self._onMouseLeave = function()
    self:onMouseLeave()
  end
  
  self._onMousePress = function(button, x, y)
    self:onMousePress(button, x, y)
  end
  
  self._onMouseRelease = function(button, x, y)
    self:onMouseRelease(button, x, y)
  end
  
  self._onClick = function(button, x, y)
    if self.onClick then
      self:onClick(button, x, y)
    end
  end
  
  self:_updateAppearance()
end

function ButtonElement:setText(text)
  self.text = text or "Button"
  self:setBackgroundColor(self.idleColor[1], self.idleColor[2], self.idleColor[3], self.idleColor[4])
  if self.borderColor then
    self:setBorderColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4])
  end
  self:setBorderWidth(self.borderWidth)
  self:setBorderRadius(self.borderRadius)
  
  if not self._textLabel then
    self._textLabel = Label:Create()
      :setText(self.text)
      :setFontSize(self.fontSize)
      :setTextColor(self.idleTextColor[1], self.idleTextColor[2], self.idleTextColor[3], self.idleTextColor[4])
      :setBackgroundColor(0, 0, 0, 0)  
      :setBorderWidth(0)  
      :setAnchors('center', 'center')  
      :setPos(0, 0)
    self:addChild(self._textLabel)
    
    self:_updateButtonSize()
  else
    self._textLabel:setText(self.text)
    self:_updateButtonSize()
  end
  
  return self
end

function ButtonElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
  if self._textLabel then
    self._textLabel:setFontSize(self.fontSize)
  end
  return self
end

function ButtonElement:setDisabled(disabled)
  self.disabled = disabled
  if disabled then
    self._state = 'disabled'
  else
    self._state = 'idle'
  end
  return self
end

function ButtonElement:setIdleColor(r, g, b, a)
  if type(r) == "table" then
    self.idleColor = r
  else
    self.idleColor = {r or 0.2, g or 0.2, b or 0.2, a or 1}
  end
  self:setBackgroundColor(self.idleColor[1], self.idleColor[2], self.idleColor[3], self.idleColor[4])
  return self
end

function ButtonElement:setHoverColor(r, g, b, a)
  if type(r) == "table" then
    self.hoverColor = r
  else
    self.hoverColor = {r or 0.3, g or 0.3, b or 0.3, a or 0.5}
  end
  return self
end

function ButtonElement:setPressColor(r, g, b, a)
  if type(r) == "table" then
    self.pressColor = r
  else
    self.pressColor = {r or 0.2, g or 0.2, b or 0.2, a or 0.8}
  end
  return self
end

function ButtonElement:setDisabledColor(r, g, b, a)
  if type(r) == "table" then
    self.disabledColor = r
  else
    self.disabledColor = {r or 0.2, g or 0.2, b or 0.2, a or 0.5}
  end
  return self
end

function ButtonElement:setTextColor(r, g, b, a)
  self:setIdleTextColor(r, g, b, a)
  self:setHoverTextColor(r, g, b, a)
  self:setPressTextColor(r, g, b, a)
  
  if self._textLabel then
    self._textLabel:setTextColor(r, g, b, a)
  end
  
  return self
end

function ButtonElement:setIdleTextColor(r, g, b, a)
  if type(r) == "table" then
    self.idleTextColor = r
  else
    self.idleTextColor = {r or 0.9, g or 0.9, b or 0.9, a or 1}
  end
  return self
end

function ButtonElement:setHoverTextColor(r, g, b, a)
  if type(r) == "table" then
    self.hoverTextColor = r
  else
    self.hoverTextColor = {r or 0.9, g or 0.9, b or 0.9, a or 1}
  end
  return self
end

function ButtonElement:setPressTextColor(r, g, b, a)
  if type(r) == "table" then
    self.pressTextColor = r
  else
    self.pressTextColor = {r or 0.9, g or 0.9, b or 0.9, a or 1}
  end
  return self
end

function ButtonElement:setDisabledTextColor(r, g, b, a)
  if type(r) == "table" then
    self.disabledTextColor = r
  else
    self.disabledTextColor = {r or 0.4, g or 0.4, b or 0.4, a or 1}
  end
  return self
end

function ButtonElement:_updateButtonSize()
  if not self._textLabel then
    return
  end
  
  local textWidth = TextUtil.estimateWidth(self.text)
  local textHeight = self.fontSize  
  
  local horizontalPadding = self.padding[2] + self.padding[4]  
  local verticalPadding = self.padding[1] + self.padding[3]   
  
  local buttonWidth = textWidth + horizontalPadding
  local buttonHeight = textHeight + verticalPadding
  
  if not self._explicitWidth then
    self.w = buttonWidth
  end
  if not self._explicitHeight then
    self.h = buttonHeight
  end
end

function ButtonElement:setCallback(callback)
  self.onClick = callback
  return self
end

function ButtonElement:onClick(callback)
  self.onClick = callback
  return self
end

function ButtonElement:setPadding(padding)
  if type(padding) == "number" then
    self.padding = {padding, padding, padding, padding}
  elseif type(padding) == "table" then
    self.padding = padding
  else
    self.padding = {Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding}
  end
  if self.text and self.text ~= "" then
    self:setText(self.text) 
  end
  return self
end

function ButtonElement:setSize(w, h)
  self._explicitWidth = w ~= nil
  self._explicitHeight = h ~= nil
  return ButtonElement.__super.setSize(self, w, h)
end

function ButtonElement:preferredSize()
  local w, h = ButtonElement.__super.preferredSize(self)
  if self.text ~= "" then
    local textWidth = 0
    for i = 1, #self.text do
      textWidth = textWidth + self.fontSize * 0.6 
    end
    w = math.max(w, textWidth + 16) 
    h = math.max(h, self.fontSize + 8) 
  end
  return w, h
end

function ButtonElement:onMouseEnter()
  if not self.disabled then
    self._state = 'hover'
    self:_updateAppearance()
  end
end

function ButtonElement:onMouseLeave()
  if not self.disabled then
    self._state = 'idle'
    self:_updateAppearance()
  end
end

function ButtonElement:onMousePress(button, x, y)
  if button == 1 and not self.disabled then 
    self._state = 'press'
    self._clicked = true
    self:_updateAppearance()
  end
end

function ButtonElement:onMouseRelease(button, x, y)
  if button == 1 and not self.disabled then 
    if self._clicked then
      self._state = 'hover'
      self._clicked = false
      self:_updateAppearance()
      if self.onClick then
        self:onClick(button, x, y)
      end
    end
  end
end

function ButtonElement:_updateAppearance()
  local bgColor
  if self.disabled then
    bgColor = self.disabledColor
  elseif self._state == 'hover' then
    bgColor = self.hoverColor
  elseif self._state == 'press' then
    bgColor = self.pressColor
  else
    bgColor = self.idleColor
  end
  
  self:setBackgroundColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
  
  if self._textLabel then
    local textColor
    if self.disabled then
      textColor = self.disabledTextColor
    elseif self._state == 'hover' then
      textColor = self.hoverTextColor
    elseif self._state == 'press' then
      textColor = self.pressTextColor
    else
      textColor = self.idleTextColor
    end
    
    self._textLabel:setTextColor(textColor[1], textColor[2], textColor[3], textColor[4])
  end
end

function ButtonElement:draw(pass)
  if not self.visible then
    return
  end
  
  self:_updateAppearance()
  
  ButtonElement.__super.draw(self, pass)
end

Button.ButtonElement = ButtonElement
Button.Create = function() return ButtonElement:Create() end

return Button
