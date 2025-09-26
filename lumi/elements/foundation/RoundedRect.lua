-- RoundedRect element for Lumi UI
-- A basic rounded rectangle element with background and border
-- This is a foundation element used by higher-level components

local RoundedRect = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')

-- RoundedRect class
local RoundedRectElement = Base.BaseElement:extend()

function RoundedRectElement:init()
  RoundedRectElement.__super.init(self)
  
  -- RoundedRect-specific properties
  self.className = "RoundedRectElement"
  
  -- Default visual properties
  self.backgroundColor = Theme.colors.panel
  self.borderColor = Theme.colors.border
  self.borderWidth = Theme.spacing.borderWidth
  self.borderRadius = Theme.spacing.borderRadius
  
  -- Default size
  self.w = 100
  self.h = 100
end

-- Override draw to render rounded rectangle
function RoundedRectElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Draw background
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderRadius, bg[1], bg[2], bg[3], alpha)
  end
  
  -- Draw border
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local borderAlpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], borderAlpha)
  end
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Create a new RoundedRect element
function RoundedRectElement:Create()
  local instance = setmetatable({}, RoundedRectElement)
  instance:init()
  return instance
end

-- Export the class
RoundedRect.RoundedRectElement = RoundedRectElement
RoundedRect.Create = RoundedRectElement.Create

return RoundedRect