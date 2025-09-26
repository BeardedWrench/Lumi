-- BaseElement Layout Module
-- Handles positioning, sizing, and layout calculations
local LayoutEngine = require('lumi.core.layout_engine')

local BaseLayout = {}

function BaseLayout:getLayoutRect()
  -- If _layoutRect exists (set by custom layout like Stack), use it
  if self._layoutRect then
    return {
      x = self._layoutRect.x,
      y = self._layoutRect.y,
      w = self._layoutRect.w,
      h = self._layoutRect.h
    }
  end
  
  -- Otherwise use the element's own position properties
  return {
    x = self.x,
    y = self.y,
    w = self.w,
    h = self.h
  }
end

function BaseLayout:getContentRect()
  return LayoutEngine.getContentArea(self)
end

function BaseLayout:getPreferredSize()
  return self.w, self.h
end

function BaseLayout:setPreferredSize(w, h)
  self.w = w
  self.h = h
  return self
end

function BaseLayout:getMinSize()
  return self.minWidth, self.minHeight
end

function BaseLayout:setMinSize(w, h)
  self.minWidth = w
  self.minHeight = h
  return self
end

function BaseLayout:getMaxSize()
  return self.maxWidth, self.maxHeight
end

function BaseLayout:setMaxSize(w, h)
  self.maxWidth = w
  self.maxHeight = h
  return self
end

function BaseLayout:getBounds()
  return self.x, self.y, self.w, self.h
end

function BaseLayout:setBounds(x, y, w, h)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  return self
end

function BaseLayout:containsPoint(x, y)
  return x >= self.x and x <= self.x + self.w and
         y >= self.y and y <= self.y + self.h
end

function BaseLayout:intersects(other)
  return not (self.x + self.w < other.x or
              other.x + other.w < self.x or
              self.y + self.h < other.y or
              other.y + other.h < self.y)
end

return BaseLayout
