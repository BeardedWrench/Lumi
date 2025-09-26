-- Button element for Lumi UI
-- Interactive button with text and various states

local Button = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Input = require('lumi.core.input')
local Label = require('lumi.elements.Label')
local Box = require('lumi.elements.foundation.Box')

-- Button class
local ButtonElement = Box.BoxElement:extend()

function ButtonElement:init()
  ButtonElement.__super.init(self)
  
  -- Element identification
  self.className = "ButtonElement"
  
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
  
  -- Layout properties
  self.padding = {Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding} -- top, right, bottom, left
  
  -- Internal state
  self._state = 'idle' -- idle, hover, press, disabled
  self._clicked = false
  
  -- Create label for text
  self._textLabel = nil
end

-- Button setters
function ButtonElement:setText(text)
  self.text = text or "Button"
  
  -- Set button background colors
  self:setBackgroundColor(self.idleColor[1], self.idleColor[2], self.idleColor[3], self.idleColor[4])
  if self.borderColor then
    self:setBorderColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4])
  end
  self:setBorderWidth(self.borderWidth)
  self:setBorderRadius(self.borderRadius)
  
  -- Create or update text label
  if not self._textLabel then
    self._textLabel = Label:Create()
      :setText(self.text)
      :setFontSize(self.fontSize)
      :setTextColor(self.idleTextColor[1], self.idleTextColor[2], self.idleTextColor[3], self.idleTextColor[4])
      :setBackgroundColor(0, 0, 0, 0)  -- Transparent background
      :setBorderWidth(0)  -- No border
      :setAnchors('center', 'center')  -- Use dual anchor system
      :setPos(0, 0)
    self:addChild(self._textLabel)
  else
    self._textLabel:setText(self.text)
  end
  
  -- Auto-size button to fit text + padding
  local TextUtil = require('lumi.core.util.text')
  local textWidth = TextUtil.estimateWidth(self.text)
  local textHeight = self.fontSize
  
  -- Add padding to text dimensions (left + right, top + bottom)
  local buttonWidth = textWidth + self.padding[4] + self.padding[2]  -- left + right
  local buttonHeight = textHeight + self.padding[1] + self.padding[3]  -- top + bottom
  
  
  -- Only auto-size if no explicit size was set
  if not self._explicitWidth then
    self.w = buttonWidth
  end
  if not self._explicitHeight then
    self.h = buttonHeight
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

-- Color setters
function ButtonElement:setIdleColor(r, g, b, a)
  if type(r) == "table" then
    self.idleColor = r
  else
    self.idleColor = {r or 0.2, g or 0.2, b or 0.2, a or 1}
  end
  
  -- Update button's own background
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

-- Text color setters
function ButtonElement:setTextColor(r, g, b, a)
  -- Set all text colors to the same value for simplicity
  self:setIdleTextColor(r, g, b, a)
  self:setHoverTextColor(r, g, b, a)
  self:setPressTextColor(r, g, b, a)
  
  -- Update label color
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

function ButtonElement:setPadding(padding)
  if type(padding) == "number" then
    -- Single number: apply to all sides
    self.padding = {padding, padding, padding, padding}
  elseif type(padding) == "table" then
    -- Table: {top, right, bottom, left}
    self.padding = padding
  else
    -- Default padding
    self.padding = {Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding, Theme.spacing.padding}
  end
  
  -- Recalculate size if we have text
  if self.text and self.text ~= "" then
    self:setText(self.text) -- This will trigger auto-sizing
  end
  return self
end

-- Override setSize to track explicit sizing
function ButtonElement:setSize(w, h)
  self._explicitWidth = w ~= nil
  self._explicitHeight = h ~= nil
  return ButtonElement.__super.setSize(self, w, h)
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

-- Override draw to use atomic elements
function ButtonElement:draw(pass)
  if not self.visible then
    return
  end
  
  -- Update button background color based on state
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
  
  -- Update text label color based on state
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
  
  -- Draw debug rectangle
  local layoutRect = self:getLayoutRect()
  if layoutRect then
    local Draw = require('lumi.core.draw')
    Draw.rect(pass, layoutRect.x, layoutRect.y, layoutRect.w, layoutRect.h, 0, 1, 0, 1)  -- BRIGHT GREEN
  end
  
  -- Draw button background (from Box parent)
  ButtonElement.__super.draw(self, pass)
  
  -- Draw children (text label)
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Export the class
Button.ButtonElement = ButtonElement
Button.Create = function() return ButtonElement:Create() end

return Button
