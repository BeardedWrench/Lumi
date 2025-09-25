# Lumi UI Library for LÖVR

A modular, screen-space UI library for LÖVR with a clean, builder-pattern API inspired by DERMA (Garry's Mod) and HTML/CSS flexbox semantics.

## Features

- **Screen-space rendering** with orthographic projection
- **Builder pattern** with chainable setters
- **Flexbox-like layout** with Stack component
- **Comprehensive elements**: Panel, Label, Button, Input, Slot, Tooltip
- **Event handling**: mouse, keyboard, focus, hover
- **Theming system** with customizable colors and spacing
- **Tooltip support** with smart positioning
- **No external dependencies** (pure Lua)

## Quick Start

```lua
local UI = require('lumi')
local Panel = UI.Panel
local Stack = UI.Stack
local Label = UI.Label
local Button = UI.Button

-- Create a panel
local panel = Panel:Create()
  :setTitle("My Panel")
  :setSize(300, 200)
  :setAnchor('top-left')
  :setPos(50, 50)
  :setClosable(true)
  :setDraggable(true)

-- Create a stack layout
local stack = Stack:Create()
  :setDirection('column')
  :setGap(10)
  :setFullWidth(true)
  :setPadding(10, 10, 10, 10)

-- Add elements
stack:addChild(Label:Create():setText("Hello World!"))
stack:addChild(Button:Create():setText("Click Me!"))

panel:addChild(stack)
UI.root():addChild(panel)

-- In your LÖVR callbacks
function lovr.update(dt)
  UI.update(dt)
end

function lovr.draw(pass)
  local w, h = lovr.system.getWindowDimensions()
  UI.draw(pass, w, h)
end
```

## API Reference

### Core API

- `UI.init()` - Initialize UI (optional)
- `UI.root()` - Get root element
- `UI.setRoot(root)` - Set root element
- `UI.update(dt)` - Update UI (call from lovr.update)
- `UI.draw(pass, width, height)` - Draw UI (call from lovr.draw)
- `UI.setFont(font)` - Set default font
- `UI.theme` - Access theme configuration

### Elements

#### Panel
Container with optional titlebar and close button.

```lua
local panel = Panel:Create()
  :setTitle("My Panel")
  :setSize(300, 200)
  :setClosable(true)
  :setDraggable(true)
  :onClose(function() print("Panel closed!") end)
```

#### Label
Text display with wrapping and alignment.

```lua
local label = Label:Create()
  :setText("Hello World!")
  :setFontSize(16)
  :setTextAlign('center')
  :setWrapMode('word')
  :setMaxWidth(200)
```

#### Button
Interactive button with states.

```lua
local button = Button:Create()
  :setText("Click Me!")
  :setSize(100, 30)
  :onClick(function() print("Clicked!") end)
```

#### Input
Single-line text input with cursor and selection.

```lua
local input = Input:Create()
  :setPlaceholder("Enter text...")
  :setMaxLength(100)
  :onChange(function(text) print("Changed: " .. text) end)
  :onSubmit(function(text) print("Submitted: " .. text) end)
```

#### Slot
Icon container with hover tooltip.

```lua
local slot = Slot:Create()
  :setSize(64, 64)
  :setIcon("path/to/icon.png")
  :setTooltip("This is a slot!")
```

#### Tooltip
Anchored popup with smart positioning.

```lua
local tooltip = Tooltip:Create()
  :setText("Tooltip text")
  :setMaxWidth(200)
```

### Layout

#### Stack
Flexbox-like layout engine.

```lua
local stack = Stack:Create()
  :setDirection('column') -- 'row' or 'column'
  :setJustify('space-between') -- 'start', 'end', 'center', 'space-between', 'space-around', 'space-evenly'
  :setAlign('stretch') -- 'start', 'end', 'center', 'stretch'
  :setGap(10)
  :setWrap(true)
```

### Common Properties

All elements support these properties:

#### Position & Size
- `:setPos(x, y)` - Set position
- `:setSize(w, h)` - Set size
- `:setMinSize(w, h)` - Set minimum size
- `:setMaxSize(w, h)` - Set maximum size
- `:setAnchor(anchor)` - Set anchor ('top-left', 'top', 'top-right', 'left', 'center', 'right', 'bottom-left', 'bottom', 'bottom-right')

#### Layout
- `:setMargin(top, right, bottom, left)` - Set margins
- `:setPadding(top, right, bottom, left)` - Set padding
- `:setFullWidth(bool)` - Fill parent width
- `:setFullHeight(bool)` - Fill parent height
- `:setFlexGrow(n)` - Flex grow factor
- `:setFlexShrink(n)` - Flex shrink factor
- `:setFlexBasis(px|'auto')` - Flex basis

#### Visual
- `:setVisible(bool)` - Show/hide element
- `:setAlpha(alpha)` - Set opacity (0-1)
- `:setEnabled(bool)` - Enable/disable element
- `:setZIndex(z)` - Set z-order
- `:setBackgroundColor(r, g, b, a)` - Set background color
- `:setBorderColor(r, g, b, a)` - Set border color
- `:setBorderWidth(width)` - Set border width
- `:setBorderRadius(radius)` - Set border radius

#### Events
- `:onClick(callback)` - Mouse click
- `:onHover(callback)` - Mouse hover
- `:onMouseEnter(callback)` - Mouse enter
- `:onMouseLeave(callback)` - Mouse leave
- `:onMouseMove(callback)` - Mouse move
- `:onMousePress(callback)` - Mouse press
- `:onMouseRelease(callback)` - Mouse release
- `:onFocus(callback)` - Element focused
- `:onBlur(callback)` - Element blurred
- `:onKeyPress(callback)` - Key pressed
- `:onKeyRelease(callback)` - Key released
- `:onTextInput(callback)` - Text input

## Theming

Customize the appearance by modifying the theme:

```lua
UI.theme:set({
  colors = {
    background = {0.1, 0.1, 0.1, 0.9},
    text = {0.9, 0.9, 0.9, 1.0},
    primary = {0.2, 0.6, 1.0, 1.0}
  },
  spacing = {
    padding = 8,
    gap = 10,
    borderRadius = 6
  }
})
```

## LÖVR Compatibility

Lumi UI is designed for modern LÖVR builds and uses:
- `pass:setProjection()` and `pass:setViewPose()` for orthographic rendering
- `pass:setFont()` and `pass:text()` for text rendering
- `pass:plane()` for filled rectangles
- `pass:line()` for borders and lines
- `pass:setMaterial()` for textures

## Examples

See `examples/demo.lua` for a complete demonstration of all UI elements and features.

## License

MIT License - see LICENSE file for details.
