-- Lumi UI Demo for LÖVR
-- Shows all UI elements and layout capabilities

-- Add current directory to package path so we can require 'lumi'
package.path = package.path .. ";./?.lua;./?/init.lua"

local UI = require('lumi')

local Panel = UI.Panel
local Stack = UI.Stack
local Label = UI.Label
local Button = UI.Button
local Input = UI.Input
local Slot = UI.Slot

-- Demo state
local demoState = {
  inputText = "",
  buttonClicks = 0,
  panelVisible = true
}

-- Create demo UI
function createDemoUI()
  -- Main panel - positioned to be visible on screen with better sizing
  local mainPanel = Panel:Create()
    :setTitle("Lumi UI Demo")
    :setSize(500, 600)  -- Larger size
    :setAnchors('left', 'top')
    :setPos(100, 100)   -- Better positioning
    :setClosable(true)
    :setDraggable(true)
    :onClose(function()
      demoState.panelVisible = false
    end)
  
  -- Main stack
  local mainStack = Stack:Create()
    :setDirection('column')
    :setGap(15)  -- Larger gap
    :setFullWidth(true)
    :setPadding(15, 15, 15, 15)  -- Larger padding
    :setPos(0, 0)  -- Position at top-left of panel content area
  
  -- Title label
  local titleLabel = Label:Create()
    :setText("Welcome to Lumi UI!")
    :setFontSize(24)  -- Larger font
    :setTextAlign('center')
    :setFullWidth(true)
  
  -- Description label
  local descLabel = Label:Create()
    :setText("This demo shows all the UI elements and layout capabilities of the Lumi UI library for LÖVR.")
    :setWrapMode('word')
    :setFullWidth(true)
    :setMaxWidth(470)  -- Adjusted for larger panel
    :setFontSize(16)   -- Larger font
  
  -- Input section
  local inputLabel = Label:Create()
    :setText("Text Input:")
    :setFontSize(18)  -- Larger font
  
  local textInput = Input:Create()
    :setPlaceholder("Type something here...")
    :setFullWidth(true)
    :setFontSize(16)  -- Larger font
    :onChange(function(text)
      demoState.inputText = text
    end)
    :onSubmit(function(text)
      print("Submitted: " .. text)
    end)
  
  -- Button section
  local buttonLabel = Label:Create()
    :setText("Buttons:")
    :setFontSize(18)  -- Larger font
  
  local buttonStack = Stack:Create()
    :setDirection('row')
    :setGap(15)  -- Larger gap
    :setFullWidth(true)
  
  local clickButton = Button:Create()
    :setText("Click Me!")
    :setFlexGrow(1)
    :setFontSize(16)  -- Larger font
    :onClick(function()
      demoState.buttonClicks = demoState.buttonClicks + 1
      clickButton:setText("Clicked " .. demoState.buttonClicks .. " times!")
    end)
  
  local disabledButton = Button:Create()
    :setText("Disabled")
    :setFlexGrow(1)
    :setFontSize(16)  -- Larger font
    :setDisabled(true)
  
  -- Slot section
  local slotLabel = Label:Create()
    :setText("Slots:")
    :setFontSize(18)  -- Larger font
  
  local slotStack = Stack:Create()
    :setDirection('row')
    :setGap(15)  -- Larger gap
    :setFullWidth(true)
  
  local slot1 = Slot:Create()
    :setSize(80, 80)  -- Larger slots
    :setTooltip("This is a slot with a tooltip!")
    :setBackgroundColor(0.2, 0.2, 0.2, 1)
    :setBorderColor(0.5, 0.5, 0.5, 1)
  
  local slot2 = Slot:Create()
    :setSize(80, 80)  -- Larger slots
    :setTooltip("Another slot")
    :setBackgroundColor(0.3, 0.2, 0.2, 1)
    :setBorderColor(0.7, 0.3, 0.3, 1)
  
  local slot3 = Slot:Create()
    :setSize(80, 80)  -- Larger slots
    :setTooltip("Third slot")
    :setBackgroundColor(0.2, 0.3, 0.2, 1)
    :setBorderColor(0.3, 0.7, 0.3, 1)
  
  -- Status label
  local statusLabel = Label:Create()
    :setText("Status: Ready")
    :setFontSize(14)  -- Larger font
    :setTextColor(0.7, 0.7, 0.7, 1)
    :setFullWidth(true)
  
  -- Instructions label - positioned at bottom but visible
  local instructionsLabel = Label:Create()
    :setText("Lumi UI Demo - Press ESC to exit")
    :setFontSize(18)  -- Larger font
    :setTextColor(1, 1, 1, 1)
    :setAnchors('left', 'bottom')
    :setPos(20, -50)  -- Better positioning
  
  -- Assemble UI
  buttonStack:addChild(clickButton)
  buttonStack:addChild(disabledButton)
  
  slotStack:addChild(slot1)
  slotStack:addChild(slot2)
  slotStack:addChild(slot3)
  
  mainStack:addChild(titleLabel)
  mainStack:addChild(descLabel)
  mainStack:addChild(inputLabel)
  mainStack:addChild(textInput)
  mainStack:addChild(buttonLabel)
  mainStack:addChild(buttonStack)
  mainStack:addChild(slotLabel)
  mainStack:addChild(slotStack)
  mainStack:addChild(statusLabel)
  
  mainPanel:addChild(mainStack)
  
  -- Set as root
  UI.setRoot(mainPanel)
  
  -- Add instructions label to root as well
  local root = UI.root()
  if root then
    root:addChild(instructionsLabel)
  end
  
  return mainPanel
end

-- Initialize demo
function lovr.load()
  createDemoUI()
end

-- Update demo
function lovr.update(dt)
  UI.update(dt)
  
  -- Update status label
  if demoState.panelVisible then
    local root = UI.root()
    if root then
      local statusLabel = root:getChildren()[1]:getChildren()[9] -- Navigate to status label
      if statusLabel and statusLabel.setText then
        statusLabel:setText("Status: Input='" .. demoState.inputText .. "', Clicks=" .. demoState.buttonClicks)
      end
    end
  end
end

-- Draw demo
function lovr.draw(pass)
  -- Get window dimensions
  local w, h = lovr.system.getWindowDimensions()
  
  -- Draw UI
  if demoState.panelVisible then
    UI.draw(pass, w, h)
  end
end

-- Handle key presses
function lovr.keypressed(key)
  if key == 'escape' then
    lovr.event.quit()
  end
end