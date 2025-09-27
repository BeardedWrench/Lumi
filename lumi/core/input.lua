local Input = {}
local Drag = require('lumi.core.drag')
local Debug = require('lumi.core.debug')
local Draw = require('lumi.core.draw')
local Cursor = require('lumi.core.cursor')
local Mouse = require('lumi.core.util.lovr-mouse')

Input.state = {
  mouse = {
    x = 0,
    y = 0,
    buttons = {},
    wheel = 0
  },
  keyboard = {
    keys = {},
    text = ""
  },
  focus = nil,
  hover = nil,
  pressed = nil
}

function Input.init()
  Input.state.mouse.buttons = {}
  Input.state.keyboard.keys = {}
  Input.state.keyboard.text = ""
  Input.state.focus = nil
  Input.state.hover = nil
  Input.state.pressed = nil
end

function Input.update(dt, context)
  local x, y = Mouse.getPosition()
  if x and y then
    Input.state.mouse.x = x
    Input.state.mouse.y = y
  end
  for i = 1, 3 do 
    local wasPressed = Input.state.mouse.buttons[i] or false
    local isPressed = Mouse.isDown(i)
    Input.state.mouse.buttons[i] = isPressed
    
    if isPressed and not wasPressed then
      Input.onMousePress(i, Input.state.mouse.x, Input.state.mouse.y, context)
    elseif not isPressed and wasPressed then
      Input.onMouseRelease(i, Input.state.mouse.x, Input.state.mouse.y, context)
    end
  end
  
  if lovr.keyboard then
    
    local text = lovr.keyboard.getText()
    if text and text ~= "" then
      Input.state.keyboard.text = text
      Input.onTextInput(text)
    end
    
    for key in pairs(Input.state.keyboard.keys) do
      local wasPressed = Input.state.keyboard.keys[key] or false
      local isPressed = lovr.keyboard.isDown(key)
      Input.state.keyboard.keys[key] = isPressed
      
      if isPressed and not wasPressed then
        Input.onKeyPress(key)
      elseif not isPressed and wasPressed then
        Input.onKeyRelease(key)
      end
    end
  end
  
  if Input.state.mouse.x and Input.state.mouse.y then
    Cursor.update(Input.state.mouse.x, Input.state.mouse.y, context, Drag)
  end
end

function Input.updateMousePosition(x, y, context)
  local oldX, oldY = Input.state.mouse.x, Input.state.mouse.y
  Input.state.mouse.x, Input.state.mouse.y = x, y
  
  if oldX and oldY and (x ~= oldX or y ~= oldY) then
    Input.onMouseMove(x, y, context)
  end
end

function Input.onMousePress(button, x, y, context)
  Input.updateMousePosition(x, y, context)
  local element = Input.findElementAt(x, y, context)
  
  if element and type(element) ~= "table" then
    element = nil
  end
  
  if element and Drag.startDrag(element, x, y, context) then
    Input.state.pressed = element
    return
  end
  
  if element and element._onMousePress and type(element._onMousePress) == "function" then
    Input.state.pressed = element
    element._onMousePress(button, x, y)
  end
end

function Input.onMouseRelease(button, x, y, context)
  Input.updateMousePosition(x, y, context)

  if Drag.isDragging() then
    Drag.stopDrag()
    Input.state.pressed = nil
    return
  end

  local element = Input.findElementAt(x, y, context)
  if Input.state.pressed and Input.state.pressed == element then
    if element and type(element) == "table" and type(element._onClick) == "function" then
      element._onClick(button, x, y)
    end
  end
  
  if Input.state.pressed and type(Input.state.pressed) == "table" and type(Input.state.pressed._onMouseRelease) == "function" then
    Input.state.pressed._onMouseRelease(button, x, y)
  end
  
  Input.state.pressed = nil
end

function Input.onMouseMove(x, y, context)
  if Drag.isDragging() then
    Drag.updateDrag(x, y, context)
    return
  end

  local element = Input.findElementAt(x, y, context)
  
  if element and element.className == "LabelElement" and element.text == "×" and element.parent and element.parent.className == "ButtonElement" then
    element = element.parent
  end
  
  if element and type(element) ~= "table" then
    element = nil
  end
  
  if element ~= Input.state.hover then
    if Input.state.hover and type(Input.state.hover) == "table" then
      if Input.state.hover._onMouseLeave and type(Input.state.hover._onMouseLeave) == "function" then
        Input.state.hover._onMouseLeave()
      end
    end
    
    if element and type(element) == "table" then
      Input.state.hover = element
      if element._onMouseEnter and type(element._onMouseEnter) == "function" then
        element._onMouseEnter()
      end
    else
      Input.state.hover = nil
    end
  end

  if element and type(element) == "table" and type(element._onMouseMove) == "function" then
    element._onMouseMove(x, y)
  end
  
  Cursor.update(x, y, context, Drag)
end

function Input.onKeyPress(key)
  if Input.state.focus and Input.state.focus.onKeyPress then
    Input.state.focus:onKeyPress(key)
  end
end

function Input.onKeyRelease(key)
  if Input.state.focus and Input.state.focus.onKeyRelease then
    Input.state.focus:onKeyRelease(key)
  end
end

function Input.onTextInput(text)
  if Input.state.focus and Input.state.focus.onTextInput then
    Input.state.focus:onTextInput(text)
  end
end

function Input.findElementAt(x, y, context)
  local success, result = pcall(function()
    local root = context:getRoot()
  
    if not root then
      return nil
    end
    
    local scale = context.scale or 1.0
    local uiX = x / scale
    local uiY = y / scale
    
    local element = Input._findElementAtRecursive(root, uiX, uiY)
    
    if element and element.className == "LabelElement" and element.text == "×" then
      if element.parent and element.parent.className == "ButtonElement" then
        return element.parent
      end
    end
    
    if element and element.parent and element.parent.draggable and element.parent.dragArea then
      if element.parent.dragArea then
        local dragRect = element.parent.dragArea:getLayoutRect()
        if dragRect and uiX >= dragRect.x and uiX <= dragRect.x + dragRect.w and 
           uiY >= dragRect.y and uiY <= dragRect.y + dragRect.h then
          return element.parent
        end
      else
        return element.parent
      end
    end
    
    return element
  end)
  
  if not success then
    return nil
  end
  
  return result
end

function Input._findElementAtRecursive(element, x, y)
  if not element or not element.visible then
    return nil
  end
  
  local layoutRect = element:getLayoutRect()
  if not layoutRect then
    return nil
  end
  
  if type(layoutRect) ~= "table" then
    return nil
  end
  
  element._debugLayoutRect = layoutRect
  
  if x >= layoutRect.x and x <= layoutRect.x + layoutRect.w and
     y >= layoutRect.y and y <= layoutRect.y + layoutRect.h then
    
    for i = #element.children, 1, -1 do
      local child = element.children[i]
      local found = Input._findElementAtRecursive(child, x, y)
      if found then
        -- Special case: If we found a LabelElement with text "×", check if its parent is a ButtonElement
        if found.className == "LabelElement" and found.text == "×" and element.className == "ButtonElement" then
          return element
        end
        -- If the found element is a Label or Box, check if this element is a Button
        if (found.className == "LabelElement" or found.className == "BoxElement") and element.className == "ButtonElement" then
          return element
        end
        return found
      end
    end
    
    return element
  end
  
  return nil
end

function Input.drawDebugOverlays(pass, context)
  local debugState = Debug.getState()
  if not debugState.enabled or not debugState.showBounds then
    return
  end
  
  local root = context:getRoot()
  
  if not root then
    return
  end
  
  Input._drawDebugOverlaysRecursive(root, pass)
end

function Input._drawDebugOverlaysRecursive(element, pass)
  if not element or not element.visible then
    return
  end
  
  local rect = element:getLayoutRect()
  if rect then
    local color = {1, 0, 0, 0.5}
    
    if element.text == "×" then
      color = {0, 1, 0, 0.8} 
    end
    
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 2, color[1], color[2], color[3], color[4])
  end
  
  if element.children then
    for i = 1, #element.children do
      Input._drawDebugOverlaysRecursive(element.children[i], pass)
    end
  end
end

function Input.setFocus(element)
  if Input.state.focus and Input.state.focus.onBlur then
    Input.state.focus:onBlur()
  end
  
  Input.state.focus = element
  
  if element and element.onFocus then
    element:onFocus()
  end
end

function Input.getFocus()
  return Input.state.focus
end

function Input.getHover()
  return Input.state.hover
end

function Input.isMouseDown(button)
  return Input.state.mouse.buttons[button] or false
end

function Input.isKeyDown(key)
  return Input.state.keyboard.keys[key] or false
end

function Input.getMousePosition()
  return Input.state.mouse.x, Input.state.mouse.y
end

function Input.getMouseWheel()
  return Input.state.mouse.wheel
end

return Input
