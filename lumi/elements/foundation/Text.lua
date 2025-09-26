-- Text element for Lumi UI
-- A basic text rendering element
-- This is a foundation element used by higher-level components

local Text = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')

-- Text class
local TextElement = Base.BaseElement:extend()

function TextElement:init()
  TextElement.__super.init(self)
  
  -- Text-specific properties
  self.className = "TextElement"
  
  -- Text properties
  self.text = ""
  self.fontSize = Theme.typography.fontSize
  self.textColor = Theme.colors.text
  self.font = nil
  self.textAlign = 'left'
  
  -- Default size
  self.w = 0
  self.h = 0
end

-- Set text content
function TextElement:setText(text)
  self.text = text or ""
  
  if self.text ~= "" then
    local TextUtil = require('lumi.core.util.text')
    self.w = TextUtil.estimateWidth(self.text)
    self.h = self.fontSize
  else
    self.w = 0
    self.h = 0
  end
  
  return self
end

-- Set font size
function TextElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
  return self
end

-- Set text color
function TextElement:setTextColor(r, g, b, a)
  if type(r) == "table" then
    self.textColor = r
  else
    self.textColor = {r or 0, g or 0, b or 0, a or 1}
  end
  return self
end

-- Set font
function TextElement:setFont(font)
  self.font = font
  return self
end

-- Set text alignment
function TextElement:setTextAlign(align)
  self.textAlign = align or 'left'
  return self
end

-- Override draw to render text
function TextElement:draw(pass)
  if not self.visible or self.text == "" then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Calculate text position - always position at the reference point
  local textX = rect.x
  local textY = rect.y + rect.h / 2
  
  -- Draw text with proper alignment
  local textColor = self.textColor
  local alpha = textColor[4] * self.alpha
  Draw.text(pass, self.text, textX, textY, self.fontSize,
    textColor[1], textColor[2], textColor[3], alpha, self.textAlign)
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Create a new Text element
function TextElement:Create()
  local instance = setmetatable({}, TextElement)
  instance:init()
  return instance
end

-- Export the class
Text.TextElement = TextElement
Text.Create = TextElement.Create

return Text