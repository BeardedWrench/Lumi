-- Input element for Lumi UI
-- Single-line text input with cursor and selection

local Input = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local InputCore = require('lumi.core.input')

-- Input class
local InputElement = Base.BaseElement:extend()

function InputElement:init()
  InputElement.__super.init(self)
  
  -- Input-specific properties
  self.text = ""
  self.placeholder = ""
  self.fontSize = Theme.typography.fontSize
  self.maxLength = math.huge
  
  -- Cursor and selection
  self.cursorPos = 0
  self.selectionStart = 0
  self.selectionEnd = 0
  self.cursorBlinkTime = 0
  self.cursorBlinkRate = 0.5
  
  -- Colors
  self.textColor = Theme.colors.text
  self.placeholderColor = Theme.colors.textSecondary
  self.cursorColor = Theme.colors.text
  self.selectionColor = Theme.colors.primary
  
  -- Internal state
  self._focused = false
  self._dragging = false
  self._dragStartPos = 0
end

-- Input setters
function InputElement:setText(text)
  self.text = text or ""
  self.cursorPos = math.min(self.cursorPos, #self.text)
  self.selectionStart = self.cursorPos
  self.selectionEnd = self.cursorPos
  return self
end

function InputElement:setPlaceholder(placeholder)
  self.placeholder = placeholder or ""
  return self
end

function InputElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
  return self
end

function InputElement:setMaxLength(length)
  self.maxLength = length or math.huge
  return self
end

-- Color setters
function InputElement:setTextColor(r, g, b, a)
  if type(r) == "table" then
    self.textColor = r
  else
    self.textColor = {r or 0.9, g or 0.9, b or 0.9, a or 1}
  end
  return self
end

function InputElement:setPlaceholderColor(r, g, b, a)
  if type(r) == "table" then
    self.placeholderColor = r
  else
    self.placeholderColor = {r or 0.7, g or 0.7, b or 0.7, a or 1}
  end
  return self
end

function InputElement:setCursorColor(r, g, b, a)
  if type(r) == "table" then
    self.cursorColor = r
  else
    self.cursorColor = {r or 0.9, g or 0.9, b or 0.9, a or 1}
  end
  return self
end

function InputElement:setSelectionColor(r, g, b, a)
  if type(r) == "table" then
    self.selectionColor = r
  else
    self.selectionColor = {r or 0.2, g or 0.6, b or 1.0, a or 1}
  end
  return self
end

-- Override preferred size
function InputElement:preferredSize()
  local w, h = InputElement.__super.preferredSize(self)
  
  -- Minimum size for input
  w = math.max(w, 100)
  h = math.max(h, self.fontSize + 8)
  
  return w, h
end

-- Override mouse events
function InputElement:onMousePress(button, x, y)
  if button == 1 then -- Left mouse button
    local rect = self:getLayoutRect()
    if rect then
      local textX = rect.x + self.padding[4] -- left padding
      local clickX = x - textX
      
      -- Find cursor position
      local newCursorPos = self:getCursorPosFromX(clickX)
      self.cursorPos = newCursorPos
      
      if self._dragging then
        self.selectionEnd = self.cursorPos
      else
        self.selectionStart = self.cursorPos
        self.selectionEnd = self.cursorPos
        self._dragging = true
        self._dragStartPos = self.cursorPos
      end
    end
  end
  InputElement.__super.onMousePress(self, button, x, y)
end

function InputElement:onMouseRelease(button, x, y)
  if button == 1 then -- Left mouse button
    self._dragging = false
  end
  InputElement.__super.onMouseRelease(self, button, x, y)
end

function InputElement:onMouseMove(x, y)
  if self._dragging then
    local rect = self:getLayoutRect()
    if rect then
      local textX = rect.x + self.padding[4] -- left padding
      local clickX = x - textX
      
      local newCursorPos = self:getCursorPosFromX(clickX)
      self.cursorPos = newCursorPos
      self.selectionEnd = self.cursorPos
    end
  end
  InputElement.__super.onMouseMove(self, x, y)
end

-- Get cursor position from X coordinate
function InputElement:getCursorPosFromX(x)
  local text = self.text
  local pos = 0
  local currentX = 0
  
  for i = 1, #text do
    local char = text:sub(i, i)
    local charWidth = self.fontSize * 0.6 -- rough estimate
    currentX = currentX + charWidth
    
    if currentX > x then
      return i - 1
    end
    pos = i
  end
  
  return pos
end

-- Get X coordinate from cursor position
function InputElement:getXFromCursorPos(pos)
  local text = self.text:sub(1, pos)
  local x = 0
  
  for i = 1, #text do
    local char = text:sub(i, i)
    local charWidth = self.fontSize * 0.6 -- rough estimate
    x = x + charWidth
  end
  
  return x
end

-- Override focus events
function InputElement:onFocus()
  self._focused = true
  self.cursorBlinkTime = 0
  InputElement.__super.onFocus(self)
end

function InputElement:onBlur()
  self._focused = false
  InputElement.__super.onBlur(self)
end

-- Handle text input
function InputElement:onTextInput(text)
  if not self._focused then
    return
  end
  
  -- Handle selection
  if self.selectionStart ~= self.selectionEnd then
    local start = math.min(self.selectionStart, self.selectionEnd)
    local finish = math.max(self.selectionStart, self.selectionEnd)
    
    self.text = self.text:sub(1, start) .. text .. self.text:sub(finish + 1)
    self.cursorPos = start + #text
  else
    -- Insert at cursor
    if #self.text < self.maxLength then
      self.text = self.text:sub(1, self.cursorPos) .. text .. self.text:sub(self.cursorPos + 1)
      self.cursorPos = self.cursorPos + #text
    end
  end
  
  self.selectionStart = self.cursorPos
  self.selectionEnd = self.cursorPos
  
  -- Trigger onChange callback
  if self.onChange then
    self:onChange(self.text)
  end
end

-- Handle key presses
function InputElement:onKeyPress(key)
  if not self._focused then
    return
  end
  
  if key == 'backspace' then
    if self.selectionStart ~= self.selectionEnd then
      -- Delete selection
      local start = math.min(self.selectionStart, self.selectionEnd)
      local finish = math.max(self.selectionStart, self.selectionEnd)
      
      self.text = self.text:sub(1, start) .. self.text:sub(finish + 1)
      self.cursorPos = start
    elseif self.cursorPos > 0 then
      -- Delete character before cursor
      self.text = self.text:sub(1, self.cursorPos - 1) .. self.text:sub(self.cursorPos + 1)
      self.cursorPos = self.cursorPos - 1
    end
    
    self.selectionStart = self.cursorPos
    self.selectionEnd = self.cursorPos
    
    -- Trigger onChange callback
    if self.onChange then
      self:onChange(self.text)
    end
  elseif key == 'delete' then
    if self.selectionStart ~= self.selectionEnd then
      -- Delete selection
      local start = math.min(self.selectionStart, self.selectionEnd)
      local finish = math.max(self.selectionStart, self.selectionEnd)
      
      self.text = self.text:sub(1, start) .. self.text:sub(finish + 1)
      self.cursorPos = start
    elseif self.cursorPos < #self.text then
      -- Delete character after cursor
      self.text = self.text:sub(1, self.cursorPos) .. self.text:sub(self.cursorPos + 2)
    end
    
    self.selectionStart = self.cursorPos
    self.selectionEnd = self.cursorPos
    
    -- Trigger onChange callback
    if self.onChange then
      self:onChange(self.text)
    end
  elseif key == 'left' then
    if self.cursorPos > 0 then
      self.cursorPos = self.cursorPos - 1
      self.selectionStart = self.cursorPos
      self.selectionEnd = self.cursorPos
    end
  elseif key == 'right' then
    if self.cursorPos < #self.text then
      self.cursorPos = self.cursorPos + 1
      self.selectionStart = self.cursorPos
      self.selectionEnd = self.cursorPos
    end
  elseif key == 'home' then
    self.cursorPos = 0
    self.selectionStart = self.cursorPos
    self.selectionEnd = self.cursorPos
  elseif key == 'end' then
    self.cursorPos = #self.text
    self.selectionStart = self.cursorPos
    self.selectionEnd = self.cursorPos
  elseif key == 'enter' then
    -- Trigger onSubmit callback
    if self.onSubmit then
      self:onSubmit(self.text)
    end
  end
  
  self.cursorBlinkTime = 0
end

-- Override update to handle cursor blinking
function InputElement:update(dt)
  if self._focused then
    self.cursorBlinkTime = self.cursorBlinkTime + dt
    if self.cursorBlinkTime > self.cursorBlinkRate * 2 then
      self.cursorBlinkTime = 0
    end
  end
  
  InputElement.__super.update(self, dt)
end

-- Override draw to render input
function InputElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Draw input background
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderRadius, bg[1], bg[2], bg[3], alpha)
  end
  
  -- Draw input border
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local borderAlpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], borderAlpha)
  end
  
  -- Draw text
  local textX = rect.x + self.padding[4] -- left padding
  local textY = rect.y + (rect.h - self.fontSize) / 2
  
  if self.text ~= "" then
    -- Draw selection background
    if self.selectionStart ~= self.selectionEnd then
      local start = math.min(self.selectionStart, self.selectionEnd)
      local finish = math.max(self.selectionStart, self.selectionEnd)
      
      local startX = textX + self:getXFromCursorPos(start)
      local endX = textX + self:getXFromCursorPos(finish)
      
      local selectionAlpha = self.selectionColor[4] * self.alpha
      Draw.rect(pass, startX, textY, endX - startX, self.fontSize,
        self.selectionColor[1], self.selectionColor[2], self.selectionColor[3], selectionAlpha)
    end
    
    -- Draw text
    local textAlpha = self.textColor[4] * self.alpha
    Draw.text(pass, self.text, textX, textY, self.fontSize,
      self.textColor[1], self.textColor[2], self.textColor[3], textAlpha)
  elseif self.placeholder ~= "" then
    -- Draw placeholder text
    local placeholderAlpha = self.placeholderColor[4] * self.alpha
    Draw.text(pass, self.placeholder, textX, textY, self.fontSize,
      self.placeholderColor[1], self.placeholderColor[2], self.placeholderColor[3], placeholderAlpha)
  end
  
  -- Draw cursor
  if self._focused then
    local cursorVisible = (self.cursorBlinkTime % (self.cursorBlinkRate * 2)) < self.cursorBlinkRate
    if cursorVisible then
      local cursorX = textX + self:getXFromCursorPos(self.cursorPos)
      local cursorAlpha = self.cursorColor[4] * self.alpha
      
      pass:setColor(self.cursorColor[1], self.cursorColor[2], self.cursorColor[3], cursorAlpha)
      pass:line({cursorX, textY, 0, cursorX, textY + self.fontSize, 0}, 2)
    end
  end
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Export the class
Input.InputElement = InputElement
Input.Create = function() return InputElement:Create() end

return Input
