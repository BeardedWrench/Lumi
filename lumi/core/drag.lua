local Drag = {}
local Cursor = require('lumi.core.cursor')

Drag.state = {
  dragging = false,
  element = nil,
  offsetX = 0,
  offsetY = 0,
  dragArea = nil 
}

function Drag.init()
  Drag.state.dragging = false
  Drag.state.element = nil
  Drag.state.offsetX = 0
  Drag.state.offsetY = 0
  Drag.state.dragArea = nil
end

function Drag.isDragging()
  return Drag.state.dragging
end

function Drag.canDrag(element, x, y)
  if not element or not element.draggable then
    return false
  end
  
  if element.dragArea then
    local dragRect = element.dragArea:getLayoutRect()
    if dragRect and x >= dragRect.x and x <= dragRect.x + dragRect.w and 
       y >= dragRect.y and y <= dragRect.y + dragRect.h then
      return true
    end
    return false
  end
  
  return true
end

function Drag.startDrag(element, x, y, context)
  if not Drag.canDrag(element, x, y) then
    return false
  end
  
  local scale = context.scale or 1.0
  local uiX = x / scale
  local uiY = y / scale
  
  Drag.state.dragging = true
  Drag.state.element = element
  Drag.state.offsetX = uiX - element.x
  Drag.state.offsetY = uiY - element.y
  Drag.state.dragArea = element.dragArea
  
  Cursor.setState(Cursor.STATES.GRABBING)
  
  return true
end

function Drag.updateDrag(x, y, context)
  if not Drag.state.dragging or not Drag.state.element then
    return false
  end
  
  local scale = context.scale or 1.0
  local uiX = x / scale
  local uiY = y / scale
  
  local newX = uiX - Drag.state.offsetX
  local newY = uiY - Drag.state.offsetY
  local oldX = Drag.state.element.x
  local oldY = Drag.state.element.y
  local deltaX = newX - oldX
  local deltaY = newY - oldY
  
  Drag.state.element.x = newX
  Drag.state.element.y = newY
  
  if Drag.state.element._layoutRect then
    Drag.state.element._layoutRect.x = newX
    Drag.state.element._layoutRect.y = newY
  end
  
  Drag.updateChildrenPositions(Drag.state.element, deltaX, deltaY)
  
  
  return true
end

function Drag.updateChildrenPositions(element, deltaX, deltaY)
  for _, child in ipairs(element.children) do
    child.x = child.x + deltaX
    child.y = child.y + deltaY
    
    if child._layoutRect then
      child._layoutRect.x = child._layoutRect.x + deltaX
      child._layoutRect.y = child._layoutRect.y + deltaY
    end
    
    Drag.updateChildrenPositions(child, deltaX, deltaY)
  end
end

function Drag.stopDrag()
  if Drag.state.dragging then
    Drag.state.dragging = false
    Drag.state.element = nil
    Drag.state.offsetX = 0
    Drag.state.offsetY = 0
    Drag.state.dragArea = nil
    
    Cursor.setState(Cursor.STATES.DEFAULT)
    
    return true
  end
  return false
end

function Drag.getDraggedElement()
  return Drag.state.element
end

return Drag
