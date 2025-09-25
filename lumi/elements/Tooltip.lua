-- Tooltip element for Lumi UI
-- Simple anchored popup with smart positioning

local Tooltip = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Text = require('lumi.core.util.text')

-- Tooltip class
local TooltipElement = Base.BaseElement:extend()

function TooltipElement:init()
  TooltipElement.__super.init(self)
  
  -- Tooltip-specific properties
  self.text = ""
  self.maxWidth = Theme.spacing.tooltipMaxWidth
  self.fontSize = Theme.typography.fontSizeSmall
  self.padding = Theme.spacing.tooltipPadding
  
  -- Colors
  self.backgroundColor = Theme.colors.tooltip
  self.textColor = Theme.colors.tooltipText
  self.borderColor = Theme.colors.border
  
  -- Internal state
  self._wrappedLines = {}
  self._textWidth = 0
  self._textHeight = 0
  self._targetElement = nil
  self._targetX = 0
  self._targetY = 0
end

-- Tooltip setters
function TooltipElement:setText(text)
  self.text = text or ""
  self:_updateTextLayout()
  return self
end

function TooltipElement:setMaxWidth(width)
  self.maxWidth = width or Theme.spacing.tooltipMaxWidth
  self:_updateTextLayout()
  return self
end

function TooltipElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSizeSmall
  self:_updateTextLayout()
  return self
end

function TooltipElement:setPadding(padding)
  self.padding = padding or Theme.spacing.tooltipPadding
  return self
end

-- Color setters
function TooltipElement:setBackgroundColor(r, g, b, a)
  if type(r) == "table" then
    self.backgroundColor = r
  else
    self.backgroundColor = {r or 0.05, g or 0.05, b or 0.05, a or 0.95}
  end
  return self
end

function TooltipElement:setTextColor(r, g, b, a)
  if type(r) == "table" then
    self.textColor = r
  else
    self.textColor = {r or 0.9, g or 0.9, b or 0.9, a or 1}
  end
  return self
end

function TooltipElement:setBorderColor(r, g, b, a)
  if type(r) == "table" then
    self.borderColor = r
  else
    self.borderColor = {r or 0.3, g or 0.3, b or 0.3, a or 1}
  end
  return self
end

-- Update text layout
function TooltipElement:_updateTextLayout()
  if self.text == "" then
    self._wrappedLines = {}
    self._textWidth = 0
    self._textHeight = 0
    return
  end
  
  -- Simple word wrapping
  local words = {}
  for word in self.text:gmatch("%S+") do
    table.insert(words, word)
  end
  
  local lines = {}
  local currentLine = ""
  
  for _, word in ipairs(words) do
    local testLine = currentLine
    if currentLine ~= "" then
      testLine = testLine .. " " .. word
    else
      testLine = word
    end
    
    if Text.estimateWidth(testLine, self.fontSize) <= self.maxWidth then
      currentLine = testLine
    else
      if currentLine ~= "" then
        table.insert(lines, currentLine)
        currentLine = word
      else
        table.insert(lines, word)
        currentLine = ""
      end
    end
  end
  
  if currentLine ~= "" then
    table.insert(lines, currentLine)
  end
  
  self._wrappedLines = lines
  
  -- Calculate dimensions
  self._textWidth = 0
  for _, line in ipairs(lines) do
    local lineWidth = Text.estimateWidth(line, self.fontSize)
    self._textWidth = math.max(self._textWidth, lineWidth)
  end
  
  self._textHeight = #lines * self.fontSize * Theme.typography.lineHeight
end

-- Set target element and position
function TooltipElement:setTarget(element, x, y)
  self._targetElement = element
  self._targetX = x or 0
  self._targetY = y or 0
  return self
end

-- Override preferred size
function TooltipElement:preferredSize()
  local w = self._textWidth + self.padding * 2
  local h = self._textHeight + self.padding * 2
  return w, h
end

-- Override layout to position tooltip
function TooltipElement:layout(rect)
  local layoutRect = TooltipElement.__super.layout(self, rect)
  
  -- Position tooltip relative to target
  if self._targetElement then
    local targetRect = self._targetElement:getLayoutRect()
    if targetRect then
      -- Position below target by default
      local x = targetRect.x + (targetRect.w - layoutRect.w) / 2
      local y = targetRect.y + targetRect.h + 5
      
      -- Adjust to stay on screen (simple bounds checking)
      if x < 0 then
        x = 5
      elseif x + layoutRect.w > 1920 then -- assuming 1920x1080 for now
        x = 1920 - layoutRect.w - 5
      end
      
      if y + layoutRect.h > 1080 then
        y = targetRect.y - layoutRect.h - 5
      end
      
      layoutRect.x = x
      layoutRect.y = y
    end
  end
  
  return layoutRect
end

-- Override draw to render tooltip
function TooltipElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Draw tooltip background
  local bg = self.backgroundColor
  local alpha = bg[4] * self.alpha
  Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
    self.borderRadius, bg[1], bg[2], bg[3], alpha)
  
  -- Draw tooltip border
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local borderAlpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], borderAlpha)
  end
  
  -- Draw tooltip text
  if self.text ~= "" and #self._wrappedLines > 0 then
    local textColor = self.textColor
    local textAlpha = textColor[4] * self.alpha
    
    local textX = rect.x + self.padding
    local textY = rect.y + self.padding
    
    -- Draw each line
    for i, line in ipairs(self._wrappedLines) do
      local lineY = textY + (i - 1) * self.fontSize * Theme.typography.lineHeight
      Draw.text(pass, line, textX, lineY, self.fontSize,
        textColor[1], textColor[2], textColor[3], textAlpha)
    end
  end
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Export the class
Tooltip.TooltipElement = TooltipElement
Tooltip.Create = function() return TooltipElement:Create() end

return Tooltip
