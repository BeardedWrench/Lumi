local BaseProperties = {}

function BaseProperties:initProperties()
  -- Position and size
  self.x = 0
  self.y = 0
  self.w = 0
  self.h = 0
  self.minWidth = 0
  self.minHeight = 0
  self.maxWidth = math.huge
  self.maxHeight = math.huge
  
  -- Layout properties
  self.anchorX = 'left'   
  self.anchorY = 'top'    
  self.margin = {0, 0, 0, 0} 
  self.padding = {0, 0, 0, 0} 
  
  -- Flex properties
  self.fullWidth = false
  self.fullHeight = false
  self.flexGrow = 0
  self.flexShrink = 1
  self.flexBasis = 'auto'
  
  -- Visual properties
  self.visible = true
  self.alpha = 1.0
  self.enabled = true
  self.zIndex = 1
  
  -- Drag properties
  self.draggable = false
  self.dragArea = nil
  
  -- Style properties
  self.backgroundColor = nil
  self.borderColor = nil
  self.borderWidth = 1
  self.borderRadius = 0
  
  -- Hierarchy
  self.parent = nil
  self.children = {}
  
  -- Interaction
  self.tooltip = nil
  self.onClick = nil
  self.onHover = nil
  self.onMouseEnter = nil
  self.onMouseLeave = nil
  self.onMouseMove = nil
  self.onMousePress = nil
  self.onMouseRelease = nil
  self.onKeyPress = nil
  self.onKeyRelease = nil
  self.onTextInput = nil
  self.onFocus = nil
  self.onBlur = nil
end

-- Position and size setters
function BaseProperties:setPos(x, y)
  self.x = x
  self.y = y
  return self
end

function BaseProperties:setSize(w, h)
  self.w = w
  self.h = h
  return self
end

function BaseProperties:setWidth(w)
  self.w = w
  return self
end

function BaseProperties:setHeight(h)
  self.h = h
  return self
end

-- Layout setters
function BaseProperties:setAnchors(anchorX, anchorY)
  self.anchorX = anchorX
  self.anchorY = anchorY
  return self
end

function BaseProperties:setMargin(top, right, bottom, left)
  if type(top) == "number" then
    if right then
      self.margin = {top, right, bottom or top, left or right}
    else
      self.margin = {top, top, top, top}
    end
  end
  return self
end

function BaseProperties:setPadding(top, right, bottom, left)
  if type(top) == "number" then
    if right then
      self.padding = {top, right, bottom or top, left or right}
    else
      self.padding = {top, top, top, top}
    end
  end
  return self
end

-- Flex setters
function BaseProperties:setFullWidth(fullWidth)
  self.fullWidth = fullWidth
  return self
end

function BaseProperties:setFullHeight(fullHeight)
  self.fullHeight = fullHeight
  return self
end

function BaseProperties:setFlexGrow(grow)
  self.flexGrow = grow
  return self
end

function BaseProperties:setFlexShrink(shrink)
  self.flexShrink = shrink
  return self
end

function BaseProperties:setFlexBasis(basis)
  self.flexBasis = basis
  return self
end

-- Visual setters
function BaseProperties:setVisible(visible)
  self.visible = visible
  return self
end

function BaseProperties:setAlpha(alpha)
  self.alpha = alpha
  return self
end

function BaseProperties:setEnabled(enabled)
  self.enabled = enabled
  return self
end

function BaseProperties:setZIndex(zIndex)
  self.zIndex = zIndex
  return self
end

-- Style setters
function BaseProperties:setBackgroundColor(r, g, b, a)
  self.backgroundColor = {r, g, b, a or 1.0}
  return self
end

function BaseProperties:setBorderColor(r, g, b, a)
  self.borderColor = {r, g, b, a or 1.0}
  return self
end

function BaseProperties:setBorderWidth(width)
  self.borderWidth = width
  return self
end

function BaseProperties:setBorderRadius(radius)
  self.borderRadius = radius
  return self
end

-- Drag setters
function BaseProperties:setDraggable(draggable)
  self.draggable = draggable
  return self
end

function BaseProperties:setDragArea(area)
  self.dragArea = area
  return self
end

-- Event setters
function BaseProperties:onClick(callback)
  self._onClick = callback
  return self
end

function BaseProperties:onHover(callback)
  self._onHover = callback
  return self
end

function BaseProperties:onMouseEnter(callback)
  self._onMouseEnter = callback
  return self
end

function BaseProperties:onMouseLeave(callback)
  self._onMouseLeave = callback
  return self
end

function BaseProperties:onMouseMove(callback)
  self._onMouseMove = callback
  return self
end

function BaseProperties:onMousePress(callback)
  self._onMousePress = callback
  return self
end

function BaseProperties:onMouseRelease(callback)
  self._onMouseRelease = callback
  return self
end

function BaseProperties:onKeyPress(callback)
  self._onKeyPress = callback
  return self
end

function BaseProperties:onKeyRelease(callback)
  self._onKeyRelease = callback
  return self
end

function BaseProperties:onTextInput(callback)
  self._onTextInput = callback
  return self
end

function BaseProperties:onFocus(callback)
  self._onFocus = callback
  return self
end

function BaseProperties:onBlur(callback)
  self._onBlur = callback
  return self
end

return BaseProperties
