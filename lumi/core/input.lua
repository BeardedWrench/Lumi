-- Input handling for Lumi UI
-- Manages mouse, keyboard, and touch input state

local Input = {}
local Geom = require('lumi.core.util.geom')

-- Input state
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

-- Initialize input state
function Input.init()
  Input.state.mouse.buttons = {}
  Input.state.keyboard.keys = {}
  Input.state.keyboard.text = ""
  Input.state.focus = nil
  Input.state.hover = nil
  Input.state.pressed = nil
end

-- Update input state (called from UI.update)
function Input.update(dt)
  -- Update mouse position
  if lovr.mouse then
    Input.state.mouse.x, Input.state.mouse.y = lovr.mouse.getPosition()
  end
  
  -- Update mouse buttons
  if lovr.mouse then
    for i = 1, 3 do -- left, right, middle
      local wasPressed = Input.state.mouse.buttons[i] or false
      local isPressed = lovr.mouse.isDown(i)
      Input.state.mouse.buttons[i] = isPressed
      
      -- Handle button events
      if isPressed and not wasPressed then
        Input.onMousePress(i, Input.state.mouse.x, Input.state.mouse.y)
      elseif not isPressed and wasPressed then
        Input.onMouseRelease(i, Input.state.mouse.x, Input.state.mouse.y)
      end
    end
    
    -- Update mouse wheel
    Input.state.mouse.wheel = lovr.mouse.getWheel()
  end
  
  -- Update keyboard
  if lovr.keyboard then
    -- Handle text input
    local text = lovr.keyboard.getText()
    if text and text ~= "" then
      Input.state.keyboard.text = text
      Input.onTextInput(text)
    end
    
    -- Handle key events
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

-- Mouse event handlers
function Input.onMousePress(button, x, y)
  -- Find element under mouse
  local element = Input.findElementAt(x, y)
  if element then
    Input.state.pressed = element
    if element.onMousePress then
      element:onMousePress(button, x, y)
    end
  end
end

function Input.onMouseRelease(button, x, y)
  local element = Input.findElementAt(x, y)
  if Input.state.pressed and Input.state.pressed == element then
    -- Click event
    if element.onClick then
      element:onClick(button, x, y)
    end
  end
  
  if Input.state.pressed and Input.state.pressed.onMouseRelease then
    Input.state.pressed:onMouseRelease(button, x, y)
  end
  
  Input.state.pressed = nil
end

function Input.onMouseMove(x, y)
  local element = Input.findElementAt(x, y)
  
  -- Update hover state
  if element ~= Input.state.hover then
    if Input.state.hover and Input.state.hover.onMouseLeave then
      Input.state.hover:onMouseLeave()
    end
    
    Input.state.hover = element
    
    if element and element.onMouseEnter then
      element:onMouseEnter()
    end
  end
  
  -- Notify hovered element of mouse move
  if element and element.onMouseMove then
    element:onMouseMove(x, y)
  end
end

-- Keyboard event handlers
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

-- Find element at given coordinates
function Input.findElementAt(x, y)
  -- This will be implemented by the UI context
  -- For now, return nil
  return nil
end

-- Set focus to element
function Input.setFocus(element)
  if Input.state.focus and Input.state.focus.onBlur then
    Input.state.focus:onBlur()
  end
  
  Input.state.focus = element
  
  if element and element.onFocus then
    element:onFocus()
  end
end

-- Get current focus element
function Input.getFocus()
  return Input.state.focus
end

-- Get current hover element
function Input.getHover()
  return Input.state.hover
end

-- Check if mouse button is down
function Input.isMouseDown(button)
  return Input.state.mouse.buttons[button] or false
end

-- Check if key is down
function Input.isKeyDown(key)
  return Input.state.keyboard.keys[key] or false
end

-- Get mouse position
function Input.getMousePosition()
  return Input.state.mouse.x, Input.state.mouse.y
end

-- Get mouse wheel delta
function Input.getMouseWheel()
  return Input.state.mouse.wheel
end

return Input
