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
  
  if lovr.mouse then
    Input.state.mouse.x, Input.state.mouse.y = lovr.mouse.getPosition()
  end
  
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

function Input.onMousePress(button, x, y)
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
  
  if element ~= Input.state.hover then
    if Input.state.hover and Input.state.hover.onMouseLeave then
      Input.state.hover:onMouseLeave()
    end
    Input.state.hover = element
    if element and element.onMouseEnter then
      element:onMouseEnter()
    end
  end
  
  if element and element.onMouseMove then
    element:onMouseMove(x, y)
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
  return nil
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
