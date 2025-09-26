local Slot = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')


local SlotElement = Base.BaseElement:extend()

function SlotElement:init()
  SlotElement.__super.init(self)
  
  
  self.iconPath = nil
  self.iconColor = {1, 1, 1, 1}
  self.borderColor = Theme.colors.border
  self.hoverBorderColor = Theme.colors.borderHover
  self.pressBorderColor = Theme.colors.press
  
  
  self._hovered = false
  self._pressed = false
end


function SlotElement:setIcon(path)
  self.iconPath = path
  return self
end

function SlotElement:setIconColor(r, g, b, a)
  if type(r) == "table" then
    self.iconColor = r
  else
    self.iconColor = {r or 1, g or 1, b or 1, a or 1}
  end
  return self
end

function SlotElement:setBorderColor(r, g, b, a)
  if type(r) == "table" then
    self.borderColor = r
  else
    self.borderColor = {r or 0.3, g or 0.3, b or 0.3, a or 1}
  end
  return self
end

function SlotElement:setHoverBorderColor(r, g, b, a)
  if type(r) == "table" then
    self.hoverBorderColor = r
  else
    self.hoverBorderColor = {r or 0.5, g or 0.5, b or 0.5, a or 1}
  end
  return self
end

function SlotElement:setPressBorderColor(r, g, b, a)
  if type(r) == "table" then
    self.pressBorderColor = r
  else
    self.pressBorderColor = {r or 0.2, g or 0.2, b or 0.2, a or 0.8}
  end
  return self
end


function SlotElement:preferredSize()
  local w, h = SlotElement.__super.preferredSize(self)
  
  
  w = math.max(w, 64)
  h = math.max(h, 64)
  
  return w, h
end


function SlotElement:onMouseEnter()
  self._hovered = true
  SlotElement.__super.onMouseEnter(self)
end

function SlotElement:onMouseLeave()
  self._hovered = false
  SlotElement.__super.onMouseLeave(self)
end

function SlotElement:onMousePress(button, x, y)
  if button == 1 then 
    self._pressed = true
  end
  SlotElement.__super.onMousePress(self, button, x, y)
end

function SlotElement:onMouseRelease(button, x, y)
  if button == 1 then 
    self._pressed = false
  end
  SlotElement.__super.onMouseRelease(self, button, x, y)
end


function SlotElement:draw(pass)
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
  
  
  local borderColor = self.borderColor
  if self._pressed then
    borderColor = self.pressBorderColor
  elseif self._hovered then
    borderColor = self.hoverBorderColor
  end
  
  if borderColor and self.borderWidth > 0 then
    local borderAlpha = borderColor[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, borderColor[1], borderColor[2], borderColor[3], borderAlpha)
  end
  
  
  if self.iconPath then
    local iconAlpha = self.iconColor[4] * self.alpha
    Draw.icon(pass, rect.x, rect.y, rect.w, rect.h, self.iconPath,
      self.iconColor[1], self.iconColor[2], self.iconColor[3], iconAlpha)
  end
  
  
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end


Slot.SlotElement = SlotElement
Slot.Create = function() return SlotElement:Create() end

return Slot
