-- Box element for Lumi UI
-- A basic container element with background and border
-- This is a foundation element used by higher-level components

local Box = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')

-- Box class
local BoxElement = Base.BaseElement:extend()

function BoxElement:init()
  BoxElement.__super.init(self)
  
  -- Box-specific properties
  self.className = "BoxElement"
  
  -- Default visual properties
  self.backgroundColor = Theme.colors.panel
  self.borderColor = Theme.colors.border
  self.borderWidth = Theme.spacing.borderWidth
  self.borderRadius = Theme.spacing.borderRadius
  
  -- Default size
  self.w = 100
  self.h = 100
end

-- Override draw to render box
function BoxElement:draw(pass)
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
  
  -- Debug: Draw a bright red border for Panel to see exact position
  if self.className == "PanelElement" then
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 2, 1, 0, 0, 1)
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

-- Create a new Box element
function BoxElement:Create()
  local instance = setmetatable({}, BoxElement)
  instance:init()
  return instance
end

-- Export the class
Box.BoxElement = BoxElement
Box.Create = BoxElement.Create

return Box