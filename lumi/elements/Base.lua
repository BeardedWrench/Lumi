local Base = {}
local Class = require('lumi.core.util.class')
local Geom = require('lumi.core.util.geom')
local Theme = require('lumi.core.theme')
local LayoutSystem = require('lumi.core.layout_system')


local BaseElement = Class:extend()

function BaseElement:init()
  
  self.x = 0
  self.y = 0
  self.w = 0
  self.h = 0
  self.minWidth = 0
  self.minHeight = 0
  self.maxWidth = math.huge
  self.maxHeight = math.huge
  
  
  self.anchorX = 'left'   
  self.anchorY = 'top'    
  self.margin = {0, 0, 0, 0} 
  self.padding = {0, 0, 0, 0} 
  
  
  self.fullWidth = false
  self.fullHeight = false
  self.flexGrow = 0
  self.flexShrink = 1
  self.flexBasis = 'auto'
  
  
  self.visible = true
  self.alpha = 1.0
  self.enabled = true
  self.zIndex = Theme.zLayers.content
  
  
  self.backgroundColor = nil
  self.borderColor = nil
  self.borderWidth = Theme.spacing.borderWidth
  self.borderRadius = Theme.spacing.borderRadius
  
  
  self.parent = nil
  self.children = {}
  
  
  self.tooltip = nil
  
  
  self.onClick = nil
  self.onHover = nil
  self.onMouseEnter = nil
  self.onMouseLeave = nil
  self.onMouseMove = nil
  self.onMousePress = nil
  self.onMouseRelease = nil
  self.onFocus = nil
  self.onBlur = nil
  self.onKeyPress = nil
  self.onKeyRelease = nil
  self.onTextInput = nil
  
  
  self._layoutRect = nil
  self._hovered = false
  self._focused = false
  self._pressed = false
end


function BaseElement:setPos(x, y)
  self.x = x or 0
  self.y = y or 0
  return self
end

function BaseElement:setSize(w, h)
  self.w = w or 0
  self.h = h or 0
  return self
end

function BaseElement:setWidth(w)
  self.w = w or 0
  return self
end

function BaseElement:setHeight(h)
  self.h = h or 0
  return self
end

function BaseElement:setMinSize(w, h)
  self.minWidth = w or 0
  self.minHeight = h or 0
  return self
end

function BaseElement:setMaxSize(w, h)
  self.maxWidth = w or math.huge
  self.maxHeight = h or math.huge
  return self
end




function BaseElement:setAnchors(anchorX, anchorY)
  self.anchorX = anchorX or 'left'
  self.anchorY = anchorY or 'top'
  
  
  self.anchor = self.anchorY .. '-' .. self.anchorX
  if self.anchorX == 'center' and self.anchorY == 'center' then
    self.anchor = 'center'
  end
  
  return self
end

function BaseElement:setMargin(top, right, bottom, left)
  if type(top) == "table" then
    self.margin = top
  else
    self.margin = {top or 0, right or top or 0, bottom or top or 0, left or right or top or 0}
  end
  return self
end

function BaseElement:setPadding(top, right, bottom, left)
  if type(top) == "table" then
    self.padding = top
  else
    self.padding = {top or 0, right or top or 0, bottom or top or 0, left or right or top or 0}
  end
  return self
end


function BaseElement:setFullWidth(fullWidth)
  self.fullWidth = fullWidth
  return self
end

function BaseElement:setFullHeight(fullHeight)
  self.fullHeight = fullHeight
  return self
end

function BaseElement:setFlexGrow(grow)
  self.flexGrow = grow or 0
  return self
end

function BaseElement:setFlexShrink(shrink)
  self.flexShrink = shrink or 1
  return self
end

function BaseElement:setFlexBasis(basis)
  self.flexBasis = basis or 'auto'
  return self
end


function BaseElement:setVisible(visible)
  self.visible = visible
  return self
end

function BaseElement:setAlpha(alpha)
  self.alpha = alpha or 1.0
  return self
end

function BaseElement:setEnabled(enabled)
  self.enabled = enabled
  return self
end

function BaseElement:setZIndex(zIndex)
  self.zIndex = zIndex or Theme.zLayers.content
  return self
end


function BaseElement:setBackgroundColor(r, g, b, a)
  if type(r) == "table" then
    self.backgroundColor = r
  else
    self.backgroundColor = {r or 0, g or 0, b or 0, a or 1}
  end
  return self
end

function BaseElement:setBorderColor(r, g, b, a)
  if type(r) == "table" then
    self.borderColor = r
  else
    self.borderColor = {r or 0, g or 0, b or 0, a or 1}
  end
  return self
end

function BaseElement:setBorderWidth(width)
  self.borderWidth = width or Theme.spacing.borderWidth
  return self
end

function BaseElement:setBorderRadius(radius)
  self.borderRadius = radius or Theme.spacing.borderRadius
  return self
end


function BaseElement:setParent(parent)
  if self.parent then
    self.parent:removeChild(self)
  end
  
  self.parent = parent
  
  if parent then
    parent:addChild(self)
  end
  
  return self
end

function BaseElement:addChild(child)
  if child then
    child.parent = self
    table.insert(self.children, child)
  end
  return self
end

function BaseElement:removeChild(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil
      break
    end
  end
  return self
end

function BaseElement:getChildren()
  return self.children
end

function BaseElement:getParent()
  return self.parent
end


function BaseElement:setTooltip(text)
  self.tooltip = {text = text}
  return self
end


function BaseElement:onClick(callback)
  self.onClick = callback
  return self
end

function BaseElement:onHover(callback)
  self.onHover = callback
  return self
end

function BaseElement:onMouseEnter(callback)
  self.onMouseEnter = callback
  return self
end

function BaseElement:onMouseLeave(callback)
  self.onMouseLeave = callback
  return self
end

function BaseElement:onMouseMove(callback)
  self.onMouseMove = callback
  return self
end

function BaseElement:onMousePress(callback)
  self.onMousePress = callback
  return self
end

function BaseElement:onMouseRelease(callback)
  self.onMouseRelease = callback
  return self
end

function BaseElement:onFocus(callback)
  self.onFocus = callback
  return self
end

function BaseElement:onBlur(callback)
  self.onBlur = callback
  return self
end

function BaseElement:onKeyPress(callback)
  self.onKeyPress = callback
  return self
end

function BaseElement:onKeyRelease(callback)
  self.onKeyRelease = callback
  return self
end

function BaseElement:onTextInput(callback)
  self.onTextInput = callback
  return self
end


function BaseElement:preferredSize()
  return self.w, self.h
end

function BaseElement:layout(rect)
  
  return LayoutSystem.layoutElement(self, rect)
end

function BaseElement:getLayoutRect()
  return self._layoutRect
end


function BaseElement:layoutChildren()
  LayoutSystem.layoutChildren(self)
end


function BaseElement:hitTest(x, y)
  if not self.visible or not self.enabled then
    return nil
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return nil
  end
  
  if Geom.pointInRect(x, y, rect) then
    
    for i = #self.children, 1, -1 do
      local child = self.children[i]
      local hit = child:hitTest(x, y)
      if hit then
        return hit
      end
    end
    return self
  end
  
  return nil
end


function BaseElement:update(dt)
  
  for _, child in ipairs(self.children) do
    child:update(dt)
  end
end


function BaseElement:draw(pass)
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
    
  end
  
  
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local alpha = border[4] * self.alpha
    
  end
  
  
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end


function BaseElement:getAbsolutePos()
  local x, y = self.x, self.y
  local parent = self.parent
  
  while parent do
    local parentRect = parent:getLayoutRect()
    if parentRect then
      x = x + parentRect.x
      y = y + parentRect.y
    end
    parent = parent.parent
  end
  
  return x, y
end


function BaseElement:getContentRect()
  return LayoutSystem.getContentArea(self)
end


function BaseElement:isHovered()
  return self._hovered
end


function BaseElement:isFocused()
  return self._focused
end


function BaseElement:isPressed()
  return self._pressed
end


function BaseElement:setHovered(hovered)
  if self._hovered ~= hovered then
    self._hovered = hovered
    if hovered and self.onMouseEnter then
      self:onMouseEnter()
    elseif not hovered and self.onMouseLeave then
      self:onMouseLeave()
    end
  end
end


function BaseElement:setFocused(focused)
  if self._focused ~= focused then
    self._focused = focused
    if focused and self.onFocus then
      self:onFocus()
    elseif not focused and self.onBlur then
      self:onBlur()
    end
  end
end


function BaseElement:setPressed(pressed)
  self._pressed = pressed
end


Base.BaseElement = BaseElement
Base.Create = function() return BaseElement:Create() end

return Base