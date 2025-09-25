-- Label element for Lumi UI
-- Displays text with various formatting options

local Label = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Text = require('lumi.core.util.text')

-- Label class
local LabelElement = Base.BaseElement:extend()

function LabelElement:init()
  LabelElement.__super.init(self)
  
  -- Text properties
  self.text = ""
  self.fontSize = Theme.typography.fontSize
  self.textColor = Theme.colors.text
  self.textAlign = 'left' -- left, center, right
  self.wrapMode = 'none' -- none, word, char
  self.ellipsis = false
  self.maxWidth = math.huge
  
  -- Internal state
  self._wrappedLines = {}
  self._textWidth = 0
  self._textHeight = 0
end

-- Text setters
function LabelElement:setText(text)
  self.text = text or ""
  self:_updateTextLayout()
  return self
end

function LabelElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
  self:_updateTextLayout()
  return self
end

function LabelElement:setTextColor(r, g, b, a)
  if type(r) == "table" then
    self.textColor = r
  else
    self.textColor = {r or 1, g or 1, b or 1, a or 1}
  end
  return self
end

function LabelElement:setTextAlign(align)
  self.textAlign = align or 'left'
  return self
end

function LabelElement:setWrapMode(mode)
  self.wrapMode = mode or 'none'
  self:_updateTextLayout()
  return self
end

function LabelElement:setEllipsis(ellipsis)
  self.ellipsis = ellipsis
  self:_updateTextLayout()
  return self
end

function LabelElement:setMaxWidth(width)
  self.maxWidth = width or math.huge
  self:_updateTextLayout()
  return self
end

-- Update text layout
function LabelElement:_updateTextLayout()
  if self.text == "" then
    self._wrappedLines = {}
    self._textWidth = 0
    self._textHeight = 0
    return
  end
  
  local maxWidth = math.min(self.maxWidth, self.w > 0 and self.w or math.huge)
  
  if self.wrapMode == 'none' then
    self._wrappedLines = {self.text}
    self._textWidth = Text.estimateWidth(self.text, self.fontSize)
    self._textHeight = self.fontSize * Theme.typography.lineHeight
  else
    self._wrappedLines = Text.wrap(self.text, maxWidth, self.fontSize, self.wrapMode)
    self._textWidth = 0
    for _, line in ipairs(self._wrappedLines) do
      local lineWidth = Text.estimateWidth(line, self.fontSize)
      self._textWidth = math.max(self._textWidth, lineWidth)
    end
    self._textHeight = #self._wrappedLines * self.fontSize * Theme.typography.lineHeight
  end
  
  -- Apply ellipsis if needed
  if self.ellipsis and self._textWidth > maxWidth then
    local truncatedText = Text.truncate(self.text, maxWidth, self.fontSize)
    self._wrappedLines = {truncatedText}
    self._textWidth = Text.estimateWidth(truncatedText, self.fontSize)
    self._textHeight = self.fontSize * Theme.typography.lineHeight
  end
end

-- Override preferred size to account for text
function LabelElement:preferredSize()
  local w, h = LabelElement.__super.preferredSize(self)
  
  if self.text ~= "" then
    w = math.max(w, self._textWidth)
    h = math.max(h, self._textHeight)
  end
  
  return w, h
end

-- Override layout to update text layout
function LabelElement:layout(rect)
  local layoutRect = LabelElement.__super.layout(self, rect)
  
  -- Update text layout with new width
  self:_updateTextLayout()
  
  return layoutRect
end

-- Override draw to render text
function LabelElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Draw background if set
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderRadius, bg[1], bg[2], bg[3], alpha)
  end
  
  -- Draw border if set
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local alpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], alpha)
  end
  
  -- Draw text
  if self.text ~= "" and #self._wrappedLines > 0 then
    local textColor = self.textColor
    local alpha = textColor[4] * self.alpha
    
    -- Calculate text position
    local textX = rect.x
    local textY = rect.y
    
    -- Apply padding
    textX = textX + self.padding[4] -- left padding
    textY = textY + self.padding[1] -- top padding
    
    -- Apply text alignment
    if self.textAlign == 'center' then
      textX = textX + (rect.w - self.padding[4] - self.padding[2] - self._textWidth) / 2
    elseif self.textAlign == 'right' then
      textX = textX + (rect.w - self.padding[4] - self.padding[2] - self._textWidth)
    end
    
    -- Draw each line
    for i, line in ipairs(self._wrappedLines) do
      local lineY = textY + (i - 1) * self.fontSize * Theme.typography.lineHeight
      
      -- Apply line alignment
      local lineX = textX
      if self.textAlign == 'center' then
        local lineWidth = Text.estimateWidth(line, self.fontSize)
        lineX = textX + (self._textWidth - lineWidth) / 2
      elseif self.textAlign == 'right' then
        local lineWidth = Text.estimateWidth(line, self.fontSize)
        lineX = textX + (self._textWidth - lineWidth)
      end
      
      Draw.text(pass, line, lineX, lineY, self.fontSize,
        textColor[1], textColor[2], textColor[3], alpha, self.textAlign)
    end
  end
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Export the class
Label.LabelElement = LabelElement
Label.Create = function() return LabelElement:Create() end

return Label
