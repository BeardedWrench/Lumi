package.path = package.path .. ";./?.lua;./?/init.lua"

local UI = require('lumi')

local Panel = UI.Panel
local Stack = UI.Stack
local Label = UI.Label
local Button = UI.Button
local Input = UI.Input
local Slot = UI.Slot

local demoState = {
  inputText = "",
  buttonClicks = 0,
  panelVisible = true
}

function createDemoUI()
  
  local mainPanel = Panel:Create()
    :setTitle("Lumi UI Demo")
    :setSize(500, 600)  
    :setAnchors('center', 'center')
    :setClosable(true)
    :setDraggable(true)
    :onClose(function()
      demoState.panelVisible = false
    end)
  
  local mainStack = Stack:Create()
    :setDirection('column')
    :setGap(15)  
    :setFullWidth(true)
    :setFullHeight(true)
    :setPadding(15, 15, 15, 15)  
  
  local titleLabel = Label:Create()
    :setText("Welcome to Lumi UI!")
    :setFontSize(24)  
  
  local descLabel = Label:Create()
    :setText("This demo shows all the UI elements of the Lumi UI library for LÖVR.")
    :setWrapMode('word')
    :setFullWidth(true)
    :setMaxWidth(470)  
    :setFontSize(16)   
  
  local inputLabel = Label:Create()
    :setText("Text Input:")
    :setFontSize(18)  
  
  local textInput = Input:Create()
    :setPlaceholder("Type something here...")
    :setFullWidth(true)
    :setFontSize(16)  
    :onChange(function(text)
      demoState.inputText = text
    end)
    :onSubmit(function(text)
      print("Submitted: " .. text)
    end)
  
  local buttonLabel = Label:Create()
    :setText("Buttons:")
    :setFontSize(18)  
    
  local clickButton = Button:Create()
    :setText("Click Me!")
    :setFontSize(16)  
    :onClick(function()
      demoState.buttonClicks = demoState.buttonClicks + 1
      clickButton:setText("Clicked " .. demoState.buttonClicks .. " times!")
    end)
  
  local disabledButton = Button:Create()
    :setText("Disabled")
    :setFontSize(16)  
    :setDisabled(true)
  
    local buttonStack = Stack:Create()
    :setDirection('row')
    :setJustify('space-between')
    :setFullWidth(true)
    :setHeight(clickButton.h)
  
  local slotLabel = Label:Create()
    :setText("Slots:")
    :setFontSize(18)  
  
  local slotStack = Stack:Create()
    :setDirection('row')
    :setGap(15)  
    :setFullWidth(true)
    :setHeight(80)
  
  local slot1 = Slot:Create()
    :setSize(80, 80)  
    :setTooltip("This is a slot with a tooltip!")
    :setBackgroundColor(0.2, 0.2, 0.2, 1)
    :setBorderColor(0.5, 0.5, 0.5, 1)
  
  local slot2 = Slot:Create()
    :setSize(80, 80)  
    :setTooltip("Another slot")
    :setBackgroundColor(0.3, 0.2, 0.2, 1)
    :setBorderColor(0.7, 0.3, 0.3, 1)
  
  local slot3 = Slot:Create()
    :setSize(80, 80)  
    :setTooltip("Third slot")
    :setBackgroundColor(0.2, 0.3, 0.2, 1)
    :setBorderColor(0.3, 0.7, 0.3, 1)
  
  local statusLabel = Label:Create()
    :setText("Status: Ready")
    :setFontSize(14)  
    :setTextColor(0.7, 0.7, 0.7, 1)
    :setFullWidth(true)
  
  local instructionsLabel = Label:Create()
    :setText("Lumi UI Demo - Press ESC to exit")
    :setFontSize(18)  
    :setTextColor(1, 1, 1, 1)
    :setAnchors('left', 'bottom')
    :setPos(20, -50)  
  
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
  
  UI.setRoot(mainPanel)
  
  local root = UI.root()
  if root then
    root:addChild(instructionsLabel)
  end
  
  return mainPanel
end

function lovr.load()
  createDemoUI()
end

function lovr.update(dt)
  UI.update(dt)
  
  if demoState.panelVisible then
    local root = UI.root()
    if root then
      local statusLabel = root:getChildren()[1]:getChildren()[9] 
      if statusLabel and statusLabel.setText then
        statusLabel:setText("Status: Input='" .. demoState.inputText .. "', Clicks=" .. demoState.buttonClicks)
      end
    end
  end
end

function lovr.draw(pass)
  local w, h = lovr.system.getWindowDimensions()
  
  if demoState.panelVisible then
    UI.draw(pass, w, h)
  end
end

function lovr.keypressed(key)
  if key == 'escape' then
    lovr.event.quit()
  end
end
