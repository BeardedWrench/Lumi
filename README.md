# LÜMI UI Library for LÖVR

A modular, screen-space UI library for LÖVR with a clean, builder-pattern API inspired by DERMA (Garry's Mod) and HTML/CSS flexbox semantics. Built with atomic design principles and optimized for modern LÖVR builds.

## Features

- **Screen-space rendering** with orthographic projection
- **Pixel-perfect UI** that maintains exact sizes across all window dimensions
- **Builder pattern** with chainable setters for clean, readable code
- **Flexbox-like layout** with Stack component for automatic child arrangement
- **Dual anchor system** for precise positioning with independent X/Y anchoring
- **Comprehensive element library**: Panel, Label, Button, Input, Slot, Tooltip
- **Event handling**: mouse, keyboard, focus, hover states
- **Theming system** with customizable colors, spacing, and typography
- **Tooltip support** with smart positioning and auto-hide
- **Draggable panels** with optional titlebars and close buttons
- **Atomic design pattern** with foundation elements (Box, Text, RoundedRect)
- **No external dependencies** - pure Lua implementation

## Quick Start

```lua
local UI = require('lumi')
local Panel = UI.Panel
local Stack = UI.Stack
local Label = UI.Label
local Button = UI.Button

function lovr.load()
  -- Create a panel with titlebar
  local panel = Panel:Create()
    :setTitle("My Application")
    :setSize(400, 300)
    :setAnchors('center', 'center')
    :setClosable(true)
    :setDraggable(true)

  -- Create a vertical stack for content
  local stack = Stack:Create()
    :setDirection('column')
    :setGap(10)
    :setFullWidth(true)
    :setFullHeight(true)
    :setPadding(15, 15, 15, 15)

  -- Add content to the stack
  stack:addChild(Label:Create():setText("Welcome to LÜMI UI!"))
  stack:addChild(Button:Create():setText("Click Me!"))

  -- Add stack to panel and set as root
  panel:addChild(stack)
  UI.setRoot(panel)
end

function lovr.update(dt)
  UI.update(dt)
end

function lovr.draw(pass)
  local w, h = lovr.system.getWindowDimensions()
  UI.draw(pass, w, h)
end
```

## UI Scaling and Window Resizing

LÜMI UI maintains exact pixel sizes by default, ensuring consistent appearance across all window sizes and aspect ratios. Optional manual scaling is available when needed.

```lua
-- Default: No scaling (exact pixel sizes)
-- UI.setEnableScaling(false)  -- This is the default

-- Manual scaling for high-DPI displays
UI.setEnableScaling(true)
UI.setUIScale(1.5)  -- Make UI 1.5x larger

-- Smaller UI for cramped windows
UI.setEnableScaling(true)
UI.setUIScale(0.8)  -- Make UI 0.8x smaller
```

## Core API

### Initialization
- `UI.init()` - Initialize UI system (optional)
- `UI.setRoot(root)` - Set the root UI element
- `UI.update(dt)` - Update UI (call from lovr.update)
- `UI.draw(pass, width, height)` - Draw UI (call from lovr.draw)

### Scaling and Configuration
- `UI.setUIScale(scale)` - Set manual UI scale factor
- `UI.setEnableScaling(enable)` - Enable/disable scaling
- `UI.getScale()` - Get current UI scale
- `UI.theme` - Access theme configuration

## Elements

### Panel
Container element with optional titlebar, close button, and drag functionality.

```lua
local panel = Panel:Create()
  :setTitle("Settings Panel")
  :setSize(350, 250)
  :setAnchors('center', 'center')
  :setClosable(true)
  :setDraggable(true)
  :onClose(function() print("Panel closed!") end)
```

### Label
Text display element with wrapping, alignment, and color options.

```lua
local label = Label:Create()
  :setText("Hello World!")
  :setFontSize(18)
  :setTextColor(1, 1, 1, 1)
  :setTextAlign('center')
  :setWrapMode('word')
  :setMaxWidth(200)
```

### Button
Interactive button with hover, press, and disabled states.

```lua
local button = Button:Create()
  :setText("Submit")
  :setSize(120, 35)
  :onClick(function() print("Button clicked!") end)
  :onHover(function() print("Button hovered!") end)
```

### Input
Single-line text input with cursor, selection, and validation.

```lua
local input = Input:Create()
  :setPlaceholder("Enter your name...")
  :setMaxLength(50)
  :onChange(function(text) print("Text changed: " .. text) end)
  :onSubmit(function(text) print("Submitted: " .. text) end)
```

### Slot
Icon container with hover tooltip support.

```lua
local slot = Slot:Create()
  :setSize(64, 64)
  :setIcon("path/to/icon.png")
  :setTooltip("This is an inventory slot")
```

### Tooltip
Anchored popup with smart positioning and auto-hide.

```lua
local tooltip = Tooltip:Create()
  :setText("Helpful information")
  :setMaxWidth(200)
```

## Layout System

### Stack
Flexbox-like layout engine for automatic child arrangement.

```lua
local stack = Stack:Create()
  :setDirection('column')        -- 'row' or 'column'
  :setJustify('space-between')   -- 'start', 'center', 'end', 'space-between', 'space-around'
  :setAlign('stretch')          -- 'start', 'center', 'end', 'stretch'
  :setGap(10)                   -- Space between children
  :setWrap(true)                -- Allow wrapping
  :setFullWidth(true)           -- Fill parent width
  :setFullHeight(true)          -- Fill parent height
```

### Anchoring System
Dual anchor system for precise positioning with independent X and Y anchoring.

```lua
-- Set independent X and Y anchors
element:setAnchors('left', 'center')    -- Left edge, vertically centered
element:setAnchors('right', 'top')      -- Right edge, top aligned
element:setAnchors('center', 'bottom')  -- Horizontally centered, bottom aligned

-- Position relative to anchor point
element:setPos(10, 5)  -- 10px from left edge, 5px from center
```

## Common Properties

All elements support these properties:

### Position & Size
- `:setPos(x, y)` - Set position relative to anchor
- `:setSize(w, h)` - Set element size
- `:setAnchors(anchorX, anchorY)` - Set dual anchors
- `:setMinSize(w, h)` - Set minimum size constraints
- `:setMaxSize(w, h)` - Set maximum size constraints

### Layout
- `:setMargin(top, right, bottom, left)` - Set outer spacing
- `:setPadding(top, right, bottom, left)` - Set inner spacing
- `:setFullWidth(bool)` - Fill parent width
- `:setFullHeight(bool)` - Fill parent height

### Visual
- `:setVisible(bool)` - Show/hide element
- `:setAlpha(alpha)` - Set opacity (0-1)
- `:setEnabled(bool)` - Enable/disable interaction
- `:setBackgroundColor(r, g, b, a)` - Set background color
- `:setBorderColor(r, g, b, a)` - Set border color
- `:setBorderWidth(width)` - Set border thickness
- `:setBorderRadius(radius)` - Set corner rounding

### Events
- `:onClick(callback)` - Mouse click handler
- `:onHover(callback)` - Mouse hover handler
- `:onMouseEnter(callback)` - Mouse enter handler
- `:onMouseLeave(callback)` - Mouse leave handler
- `:onFocus(callback)` - Element focused handler
- `:onBlur(callback)` - Element blurred handler
- `:onKeyPress(callback)` - Key press handler
- `:onTextInput(callback)` - Text input handler

## Theming

Customize the appearance by modifying the theme configuration:

```lua
UI.theme:set({
  colors = {
    background = {0.1, 0.1, 0.1, 0.9},
    panel = {0.15, 0.15, 0.15, 0.95},
    text = {0.9, 0.9, 0.9, 1.0},
    primary = {0.2, 0.6, 1.0, 1.0},
    border = {0.3, 0.3, 0.3, 1.0}
  },
  spacing = {
    padding = 8,
    margin = 4,
    gap = 8,
    borderRadius = 4,
    titlebarHeight = 24
  },
  typography = {
    fontSize = 16,
    fontSizeSmall = 12,
    fontSizeLarge = 18,
    lineHeight = 1.2
  }
})
```

## LÖVR Compatibility

LÜMI UI is designed for modern LÖVR builds and uses current APIs:

- `pass:setProjection()` and `pass:setViewPose()` for orthographic rendering
- `pass:setFont()` and `pass:text()` for text rendering with proper alignment
- `pass:plane()` for filled rectangles and backgrounds
- `pass:line()` for borders and strokes
- `lovr.system.getWindowDimensions()` for window size detection

## Project Structure

```
lumi/
├── init.lua                 # Public API entry point
├── core/                    # Core systems
│   ├── context.lua         # UI context and lifecycle
│   ├── layout_system.lua   # Layout and positioning
│   ├── draw.lua            # Low-level drawing utilities
│   ├── input.lua           # Input handling and routing
│   ├── theme.lua           # Theme configuration
│   ├── debug.lua           # Debug visualization tools
│   └── util/               # Utility modules
│       ├── class.lua       # Class system
│       ├── color.lua       # Color utilities
│       ├── geom.lua        # Geometry utilities
│       └── text.lua        # Text measurement utilities
├── elements/               # UI elements
│   ├── Base.lua           # Base element class
│   ├── Panel.lua          # Panel container
│   ├── Label.lua          # Text display
│   ├── Button.lua         # Interactive button
│   ├── Input.lua          # Text input
│   ├── Slot.lua           # Icon container
│   ├── Tooltip.lua        # Tooltip popup
│   └── foundation/        # Foundation elements
│       ├── Box.lua        # Basic container
│       ├── Text.lua       # Text rendering
│       └── RoundedRect.lua # Rounded rectangle
└── layout/                # Layout components
    └── Stack.lua          # Flexbox layout
```

## Examples

The `examples/` directory contains several demonstration files:

- `minimal_panel.lua` - Basic panel with titlebar and content
- `demo.lua` - Comprehensive showcase of all UI elements
- `debug_demo.lua` - Debug visualization tools demonstration

## Development

LÜMI UI follows atomic design principles where complex elements are composed of simpler foundation elements. All elements extend the Base class and support the full lifecycle of creation, layout, update, and rendering.

The library is designed to be:
- **Modular**: Each element is self-contained and reusable
- **Extensible**: Easy to add new elements or modify existing ones
- **Performant**: Efficient rendering and layout calculations
- **Maintainable**: Clean, readable code with minimal dependencies

## License

MIT License - see LICENSE file for details.
