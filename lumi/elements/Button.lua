-- Button element for Lumi UI
-- Interactive button with text and various states

local Button = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Input = require('lumi.core.input')

-- Button class
local ButtonElement = Base.BaseElement:extend()

function ButtonElement:init()
  ButtonElement.__super.init(self)
  
  -- Button-specific properties
  self.text = "Button"
  self.fontSize = Theme.typography.fontSize
  self.disabled = false
  
  -- State colors
  self.idleColor = Theme.colors.button
  self.hoverColor = Theme.colors.hover
  self.pressColor = Theme.colors.press
  self.disabledColor = Theme.colors.disabled
  
  self.idleTextColor = Theme.colors.text
  self.hoverTextColor = Theme.colors.text
  self.pressTextColor = Theme.colors.text
  self.disabledTextColor = Theme.colors.textDisabled
  
  -- Internal state
  self._state = 'idle' -- idle, hover, press, disabled
  self._clicked = false
end

-- Button setters
function ButtonElement:setText(text)
  self.text = text or "Button"
  return self
end

function ButtonElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
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

-- Color setters
function ButtonElement:setIdleColor(r, g, b, a)
  if type(r) == "table" then
    self.idleColor = r
  else
    self.idleColor = {r or 0.2, g or 0.2, b or 0.2, a or 1}
  end
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

-- Text color setters
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

-- Override preferred size to account for text
function ButtonElement:preferredSize()
  local w, h = ButtonElement.__super.preferredSize(self)
  
  if self.text ~= "" then
    -- Estimate text width
    local textWidth = 0
    for i = 1, #self.text do
      textWidth = textWidth + self.fontSize * 0.6 -- rough estimate
    end
    
    w = math.max(w, textWidth + 16) -- add padding
    h = math.max(h, self.fontSize + 8) -- add padding
  end
  
  return w, h
end

-- Override mouse events
function ButtonElement:onMouseEnter()
  if not self.disabled then
    self._state = 'hover'
  end
  ButtonElement.__super.onMouseEnter(self)
end

function ButtonElement:onMouseLeave()
  if not self.disabled then
    self._state = 'idle'
  end
  ButtonElement.__super.onMouseLeave(self)
end

function ButtonElement:onMousePress(button, x, y)
  if button == 1 and not self.disabled then -- Left mouse button
    self._state = 'press'
    self._clicked = true
  end
  ButtonElement.__super.onMousePress(self, button, x, y)
end

function ButtonElement:onMouseRelease(button, x, y)
  if button == 1 and not self.disabled then -- Left mouse button
    if self._clicked then
      self._state = 'hover'
      self._clicked = false
      
      -- Trigger click callback
      if self.onClick then
        self:onClick(button, x, y)
      end
    end
  end
  ButtonElement.__super.onMouseRelease(self, button, x, y)
end

-- Override draw to render button
function ButtonElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Get current state colors
  local bgColor, textColor
  
  if self.disabled then
    bgColor = self.disabledColor
    textColor = self.disabledTextColor
  elseif self._state == 'hover' then
    bgColor = self.hoverColor
    textColor = self.hoverTextColor
  elseif self._state == 'press' then
    bgColor = self.pressColor
    textColor = self.pressTextColor
  else
    bgColor = self.idleColor
    textColor = self.idleTextColor
  end
  
  -- Draw button background
  local alpha = bgColor[4] * self.alpha
  Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
    self.borderRadius, bgColor[1], bgColor[2], bgColor[3], alpha)
  
  -- Draw button border
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local borderAlpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], borderAlpha)
  end
  
  -- Draw button text
  if self.text ~= "" then
    local textAlpha = textColor[4] * self.alpha
    local textX = rect.x + rect.w / 2
    local textY = rect.y + (rect.h - self.fontSize) / 2
    
    Draw.text(pass, self.text, textX, textY, self.fontSize,
      textColor[1], textColor[2], textColor[3], textAlpha, 'center')
  end
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Export the class
Button.ButtonElement = ButtonElement
Button.Create = function() return ButtonElement:Create() end

return Button
