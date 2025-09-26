local Drag = {}

-- Global drag state
Drag.state = {
  dragging = false,
  element = nil,
  offsetX = 0,
  offsetY = 0,
  dragArea = nil -- The specific area that can be dragged (e.g., titlebar)
}

function Drag.init()
  Drag.state.dragging = false
  Drag.state.element = nil
  Drag.state.offsetX = 0
  Drag.state.offsetY = 0
  Drag.state.dragArea = nil
end

-- Check if an element can be dragged
function Drag.canDrag(element, x, y)
  if not element or not element.draggable then
    return false
  end
  
  -- If element has a specific drag area, check if click is within it
  if element.dragArea then
    local dragRect = element.dragArea:getLayoutRect()
    if dragRect and x >= dragRect.x and x <= dragRect.x + dragRect.w and 
       y >= dragRect.y and y <= dragRect.y + dragRect.h then
      return true
    end
    return false
  end
  
  -- If no specific drag area, the entire element can be dragged
  return true
end

-- Start dragging an element
function Drag.startDrag(element, x, y, context)
  if not Drag.canDrag(element, x, y) then
    return false
  end
  
  -- Convert screen coordinates to UI coordinates
  local scale = context.scale or 1.0
  local uiX = x / scale
  local uiY = y / scale
  
  Drag.state.dragging = true
  Drag.state.element = element
  Drag.state.offsetX = uiX - element.x
  Drag.state.offsetY = uiY - element.y
  Drag.state.dragArea = element.dragArea
  
  return true
end

-- Update drag position
function Drag.updateDrag(x, y, context)
  if not Drag.state.dragging or not Drag.state.element then
    return false
  end
  
  -- Convert screen coordinates to UI coordinates
  local scale = context.scale or 1.0
  local uiX = x / scale
  local uiY = y / scale
  
  -- Update element position
  local newX = uiX - Drag.state.offsetX
  local newY = uiY - Drag.state.offsetY
  Drag.state.element:setPos(newX, newY)
  
  return true
end

-- Stop dragging
function Drag.stopDrag()
  if Drag.state.dragging then
    Drag.state.dragging = false
    Drag.state.element = nil
    Drag.state.offsetX = 0
    Drag.state.offsetY = 0
    Drag.state.dragArea = nil
    return true
  end
  return false
end

-- Check if currently dragging
function Drag.isDragging()
  return Drag.state.dragging
end

-- Get the currently dragged element
function Drag.getDraggedElement()
  return Drag.state.element
end

return Drag
