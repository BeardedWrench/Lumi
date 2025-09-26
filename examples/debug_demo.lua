package.path = package.path .. ";./?.lua;./?/init.lua"

local UI = require('lumi')

local Panel = UI.Panel
local Stack = UI.Stack
local Label = UI.Label
local Button = UI.Button

local demoState = {
  panelVisible = true,
  inputText = "",
  debugEnabled = false
}

function createDemoUI()
  local mainPanel = Panel:Create()
    :setTitle("Debug Test Panel")
    :setSize(400, 300)
    :setAnchors('center', 'center')
    :setClosable(true)
    :setDraggable(true)

  
  local testStack = Stack:Create()
    :setDirection('column')
    :setGap(10)
    :setPadding(20, 20, 20, 20)
    :setPos(0, 0)

  
  local testLabel1 = Label:Create()
    :setText("Test Label 1")
    :setFontSize(16)

  local testLabel2 = Label:Create()
    :setText("Test Label 2")
    :setFontSize(16)

  local testButton = Button:Create()
    :setText("Test Button")
    :setSize(100, 30)

  testStack:addChild(testLabel1)
  testStack:addChild(testLabel2)
  testStack:addChild(testButton)

  mainPanel:addChild(testStack)

  return mainPanel
end

function lovr.load()
  local mainPanel = createDemoUI()
  UI.setRoot(mainPanel)
  
  print("Debug Demo loaded. Press 'D' to toggle debug mode.")
  print("Debug commands:")
  print("  D - Toggle debug mode")
  print("  B - Toggle bounds display")
  print("  L - Toggle layout rects")
  print("  C - Toggle content rects")
  print("  H - Toggle hierarchy display")
  print("  A - Show all debug info")
  print("  N - Hide all debug info")
end

function lovr.update(dt)
  UI.update(dt)
end

function lovr.draw(pass)
  local w, h = lovr.system.getWindowDimensions()
  UI.draw(pass, w, h)
end

function lovr.keypressed(key)
  if key == 'd' or key == 'D' then
    demoState.debugEnabled = not demoState.debugEnabled
    if demoState.debugEnabled then
      UI.Debug.enable()
      print("Debug mode ENABLED")
    else
      UI.Debug.disable()
      print("Debug mode DISABLED")
    end
  elseif key == 'b' or key == 'B' then
    UI.Debug.toggleBounds()
  elseif key == 'l' or key == 'L' then
    UI.Debug.toggleLayoutRects()
  elseif key == 'c' or key == 'C' then
    UI.Debug.toggleContentRects()
  elseif key == 'h' or key == 'H' then
    UI.Debug.toggleHierarchy()
  elseif key == 'a' or key == 'A' then
    UI.Debug.showAll()
  elseif key == 'n' or key == 'N' then
    UI.Debug.hideAll()
  end
end
