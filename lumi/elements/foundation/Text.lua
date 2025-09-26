local Text = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')


local TextElement = Base.BaseElement:extend()

function TextElement:init()
  TextElement.__super.init(self)
  
  
  self.className = "TextElement"
  
  
  self.text = ""
  self.fontSize = Theme.typography.fontSize
  self.textColor = Theme.colors.text
  self.font = nil
  self.textAlign = 'left'
  
  
  self.w = 0
  self.h = 0
end


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


function TextElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
  return self
end


function TextElement:setTextColor(r, g, b, a)
  if type(r) == "table" then
    self.textColor = r
  else
    self.textColor = {r or 0, g or 0, b or 0, a or 1}
  end
  return self
end


function TextElement:setFont(font)
  self.font = font
  return self
end


function TextElement:setTextAlign(align)
  self.textAlign = align or 'left'
  return self
end


function TextElement:draw(pass)
  if not self.visible or self.text == "" then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  
  local textX = rect.x
  local textY = rect.y + rect.h / 2
  
  
  local textColor = self.textColor
  local alpha = textColor[4] * self.alpha
  Draw.text(pass, self.text, textX, textY, self.fontSize,
    textColor[1], textColor[2], textColor[3], alpha, self.textAlign)
  
  
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end


function TextElement:Create()
  local instance = setmetatable({}, TextElement)
  instance:init()
  return instance
end


Text.TextElement = TextElement
Text.Create = TextElement.Create

return Text