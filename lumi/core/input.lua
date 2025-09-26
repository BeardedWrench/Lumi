local Input = {}
local Geom = require('lumi.core.util.geom')

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

function Input.update(dt)
  -- Since lovr.mouse is not available, we'll track mouse position from events
  -- This is a fallback approach - we'll update mouse position when we get mouse events
  
  if lovr.mouse then
    for i = 1, 3 do 
      local wasPressed = Input.state.mouse.buttons[i] or false
      local isPressed = lovr.mouse.isDown(i)
      Input.state.mouse.buttons[i] = isPressed
      
      if isPressed and not wasPressed then
        Input.onMousePress(i, Input.state.mouse.x, Input.state.mouse.y)
      elseif not isPressed and wasPressed then
        Input.onMouseRelease(i, Input.state.mouse.x, Input.state.mouse.y)
      end
    end
    
    Input.state.mouse.wheel = lovr.mouse.getWheel()
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
end

function Input.updateMousePosition(x, y)
  local oldX, oldY = Input.state.mouse.x, Input.state.mouse.y
  Input.state.mouse.x, Input.state.mouse.y = x, y
  
  -- Handle mouse movement for hover events
  if oldX and oldY and (x ~= oldX or y ~= oldY) then
    Input.onMouseMove(x, y)
  end
end

function Input.onMousePress(button, x, y)
  Input.updateMousePosition(x, y)
  local element = Input.findElementAt(x, y)
  
  -- Ensure element is a valid table before proceeding
  if element and type(element) ~= "table" then
    element = nil
  end
  
  if element and element._onMousePress and type(element._onMousePress) == "function" then
    Input.state.pressed = element
    element._onMousePress(button, x, y)
  end
end

function Input.onMouseRelease(button, x, y)
  Input.updateMousePosition(x, y)
  local element = Input.findElementAt(x, y)
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


function Input.onMouseMove(x, y)
  local element = Input.findElementAt(x, y)
  
  -- Special case for close button - if we found a LabelElement with "×" text, return its ButtonElement parent
  if element and element.className == "LabelElement" and element.text == "×" and element.parent and element.parent.className == "ButtonElement" then
    element = element.parent
  end
  
  -- Ensure element is a valid table before proceeding
  if element and type(element) ~= "table" then
    element = nil
  end
  
  -- Check if we need to change hover state
  if element ~= Input.state.hover then
    if Input.state.hover and type(Input.state.hover) == "table" then
      if Input.state.hover._onMouseLeave and type(Input.state.hover._onMouseLeave) == "function" then
        Input.state.hover._onMouseLeave()
      end
    end
    
    -- Only set hover to valid table elements
    if element and type(element) == "table" then
      Input.state.hover = element
      if element._onMouseEnter and type(element._onMouseEnter) == "function" then
        element._onMouseEnter()
      end
    else
      Input.state.hover = nil
    end
  end

  -- Call _onMouseMove on current element
  if element and type(element) == "table" and type(element._onMouseMove) == "function" then
    element._onMouseMove(x, y)
  end
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

function Input.findElementAt(x, y)
  local success, result = pcall(function()
    -- Get the UI context to find the root element
    local UI = require('lumi')
    local context = UI.getContext()
    local root = context:getRoot()
  
    if not root then
      return nil
    end
    
    -- Convert screen coordinates to UI coordinates
    local scale = context.scale or 1.0
    local uiX = x / scale
    local uiY = y / scale
    
    -- Find the topmost element at the given coordinates
    local element = Input._findElementAtRecursive(root, uiX, uiY)
    
    -- Special case: If we found a LabelElement with text "×", check if its parent is a ButtonElement
    if element and element.className == "LabelElement" and element.text == "×" then
      if element.parent and element.parent.className == "ButtonElement" then
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
  
  -- Check if layoutRect is a table
  if type(layoutRect) ~= "table" then
    return nil
  end
  
  -- Store layout rect for debug drawing
  element._debugLayoutRect = layoutRect
  
  -- Check if point is within element bounds
  if x >= layoutRect.x and x <= layoutRect.x + layoutRect.w and
     y >= layoutRect.y and y <= layoutRect.y + layoutRect.h then
    
    -- Check children first (they're drawn on top)
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
    
    -- If no child was found, return this element
    return element
  end
  
  return nil
end

function Input.drawDebugOverlays(pass)
  -- Check if debug is enabled
  local Debug = require('lumi.core.debug')
  local debugState = Debug.getState()
  if not debugState.enabled or not debugState.showBounds then
    return
  end
  
  -- Get the UI context to find the root element
  local UI = require('lumi')
  local context = UI.getContext()
  local root = context:getRoot()
  
  if not root then
    return
  end
  
  -- Draw debug overlays for all elements
  Input._drawDebugOverlaysRecursive(root, pass)
end

function Input._drawDebugOverlaysRecursive(element, pass)
  if not element or not element.visible then
    return
  end
  
  -- Get layout rect for this element
  local rect = element:getLayoutRect()
  if rect then
    local color = {1, 0, 0, 0.5} -- Red with transparency
    
    -- Special color for close button
    if element.text == "×" then
      color = {0, 1, 0, 0.8} -- Green for close button
    end
    
    -- Draw rectangle outline using Draw.rectBorder
    local Draw = require('lumi.core.draw')
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 2, color[1], color[2], color[3], color[4])
  end
  
  -- Recursively draw children
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
