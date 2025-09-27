local Label = {}
local Text = require('lumi.elements.foundation.Text')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local TextUtil = require('lumi.core.util.text')

local LabelElement = Text.TextElement:extend()

function LabelElement:init()
  LabelElement.__super.init(self)
  self.className = "LabelElement"
  self.text = ""
  self.fontSize = Theme.typography.fontSize
  self.textColor = Theme.colors.text
  self.textAlign = 'left'  
  self.font = nil
  self.wrapMode = 'none'
  self.ellipsis = false
  self.maxWidth = math.huge
  self.w = 0
  self.h = 0
end

function LabelElement:setText(text)
  self.text = text or ""
  
  if self.text ~= "" then
    self.w = TextUtil.estimateWidth(self.text)
    self.h = self.fontSize
  else
    self.w = 0
    self.h = 0
  end
  
  return self
end

function LabelElement:setFontSize(size)
  self.fontSize = size or Theme.typography.fontSize
  if self.text and self.text ~= "" then
    self.w = TextUtil.estimateWidth(self.text)
    self.h = self.fontSize
  end
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

function LabelElement:setFont(font)
  self.font = font
  return self
end

function LabelElement:setWrapMode(mode)
  self.wrapMode = mode or 'none'
  return self
end

function LabelElement:setEllipsis(ellipsis)
  self.ellipsis = ellipsis or false
  return self
end

function LabelElement:setMaxWidth(width)
  self.maxWidth = width or math.huge
  return self
end

function LabelElement:draw(pass)
  local rect = self:getLayoutRect()
  if rect then
    if self.backgroundColor then
      local bg = self.backgroundColor
      local alpha = bg[4] * self.alpha
      Draw.rect(pass, rect.x, rect.y, rect.w, rect.h, bg[1], bg[2], bg[3], alpha)
    end
  end
  LabelElement.__super.draw(self, pass)
end

function LabelElement:Create()
  local instance = setmetatable({}, LabelElement)
  instance:init()
  return instance
end

Label.LabelElement = LabelElement
Label.Create = function() return LabelElement:Create() end

return Label
