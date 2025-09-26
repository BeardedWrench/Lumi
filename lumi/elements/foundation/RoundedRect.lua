local RoundedRect = {}
local Base = require('lumi.elements.Base.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')


local RoundedRectElement = Base:extend()

function RoundedRectElement:init()
  RoundedRectElement.__super.init(self)
  
  self.className = "RoundedRectElement"
  self.backgroundColor = Theme.colors.panel
  self.borderColor = Theme.colors.border
  self.borderWidth = Theme.spacing.borderWidth
  self.borderRadius = Theme.spacing.borderRadius
  self.w = 100
  self.h = 100
end

function RoundedRectElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderRadius, bg[1], bg[2], bg[3], alpha)
  end
  
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local borderAlpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], borderAlpha)
  end
  
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

function RoundedRectElement:Create()
  local instance = setmetatable({}, RoundedRectElement)
  instance:init()
  return instance
end

RoundedRect.RoundedRectElement = RoundedRectElement
RoundedRect.Create = RoundedRectElement.Create

return RoundedRect
