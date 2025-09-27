local Cursor = {}
local Mouse = require('lumi.core.util.lovr-mouse')

Cursor.STATES = {
  DEFAULT = "default",
  GRAB = "grab", 
  GRABBING = "grabbing"
}

Cursor.currentState = Cursor.STATES.DEFAULT

Cursor.cursors = {}

function Cursor.init()
  Cursor.cursors.arrow = Mouse.getSystemCursor('arrow')
  Cursor.cursors.hand = Mouse.getSystemCursor('hand')
  Cursor.setState(Cursor.STATES.DEFAULT)
end

function Cursor.setState(state)
  if Cursor.currentState == state then
    return 
  end
  
  Cursor.currentState = state
  
  if state == Cursor.STATES.GRAB then
    if Cursor.cursors.hand then
      Mouse.setCursor(Cursor.cursors.hand)
    else
      Mouse.setCursor(nil)
    end
  elseif state == Cursor.STATES.GRABBING then
    Mouse.setCursor(Cursor.cursors.hand)
  else
    if Cursor.cursors.arrow then
      Mouse.setCursor(Cursor.cursors.arrow)  
    else
      Mouse.setCursor(nil)
    end
  end
end

function Cursor.getState()
  return Cursor.currentState
end

function Cursor.getPosition()
  return lovr.system.getMousePosition()
end

function Cursor.isOverDraggable(element, x, y)
  if not element or not element.draggable then
    return false
  end
  
  if element.dragArea then
    local dragRect = element.dragArea:getLayoutRect()
    return x >= dragRect.x and x <= dragRect.x + dragRect.w and 
           y >= dragRect.y and y <= dragRect.y + dragRect.h
  end
  
  local rect = element:getLayoutRect()
  return x >= rect.x and x <= rect.x + rect.w and 
         y >= rect.y and y <= rect.y + rect.h
end

function Cursor.update(x, y, context, drag)
  if drag.isDragging() then
    Cursor.setState(Cursor.STATES.GRABBING)
    return
  end
  
  local element = nil
  if context and context.getElementAt then
    element = context:getElementAt(x, y)
  end
  
  if element and Cursor.isOverDraggable(element, x, y) then
    Cursor.setState(Cursor.STATES.GRAB)
  else
    Cursor.setState(Cursor.STATES.DEFAULT)
  end
end

function Cursor.setEnabled(enabled)
  -- Native cursors are always enabled
end

function Cursor.setSize(size)
  -- Native cursors use system size
end

function Cursor.setOffset(x, y)
  -- Native cursors don't need offset
end

return Cursor
