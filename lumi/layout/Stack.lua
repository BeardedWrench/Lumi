-- Stack layout engine for Lumi UI
-- Provides flexbox-like layout behavior

local Stack = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Layout = require('lumi.core.layout')
local Measure = require('lumi.core.measure')
local Theme = require('lumi.core.theme')
local LayoutSystem = require('lumi.core.layout_system')

-- Stack class
local StackElement = Base.BaseElement:extend()

function StackElement:init()
  StackElement.__super.init(self)
  
  -- Stack-specific properties
  self.direction = Layout.DIRECTION.ROW -- row or column
  self.justify = Layout.JUSTIFY.START -- start, end, center, space-between, space-around, space-evenly
  self.align = Layout.ALIGN.START -- start, end, center, stretch
  self.gap = Theme.spacing.gap
  self.wrap = false
  
  -- Internal state
  self._layoutLines = {}
end

-- Stack setters
function StackElement:setDirection(direction)
  self.direction = direction or Layout.DIRECTION.ROW
  return self
end

function StackElement:setJustify(justify)
  self.justify = justify or Layout.JUSTIFY.START
  return self
end

function StackElement:setAlign(align)
  self.align = align or Layout.ALIGN.START
  return self
end

function StackElement:setGap(gap)
  self.gap = gap or Theme.spacing.gap
  return self
end

function StackElement:setWrap(wrap)
  self.wrap = wrap or false
  return self
end

-- Override preferred size to account for children
function StackElement:preferredSize()
  if #self.children == 0 then
    return StackElement.__super.preferredSize(self)
  end
  
  local w, h = 0, 0
  
  if self.direction == Layout.DIRECTION.ROW then
    -- Calculate width and height for row direction
    local totalWidth = 0
    local maxHeight = 0
    
    for i, child in ipairs(self.children) do
      local childW, childH = Measure.elementPreferredSize(child)
      totalWidth = totalWidth + childW
      maxHeight = math.max(maxHeight, childH)
      
      if i > 1 then
        totalWidth = totalWidth + self.gap
      end
    end
    
    w = totalWidth
    h = maxHeight
  else
    -- Calculate width and height for column direction
    local maxWidth = 0
    local totalHeight = 0
    
    for i, child in ipairs(self.children) do
      local childW, childH = Measure.elementPreferredSize(child)
      maxWidth = math.max(maxWidth, childW)
      totalHeight = totalHeight + childH
      
      if i > 1 then
        totalHeight = totalHeight + self.gap
      end
    end
    
    w = maxWidth
    h = totalHeight
  end
  
  return w, h
end

-- Stack layout is handled by the main layout system
-- No need to override layout method

-- Layout children in a single line
function StackElement:_layoutSingleLine(contentRect)
  local items = {}
  local availableSize
  
  if self.direction == Layout.DIRECTION.ROW then
    availableSize = contentRect.w
  else
    availableSize = contentRect.h
  end
  
  -- Calculate flex sizes
  local sizes = Layout.calculateFlexSizes(self.children, availableSize, self.direction, self.gap)
  
  -- Distribute items according to justify content
  local positions = Layout.distributeItems(self.children, sizes, availableSize, self.direction, self.justify, self.gap)
  
  -- Align items on cross axis
  local alignments = Layout.alignItems(self.children, sizes, 
    self.direction == Layout.DIRECTION.ROW and contentRect.h or contentRect.w, 
    self.direction, self.align)
  
    -- Position children
    for i, child in ipairs(self.children) do
      local size = sizes[i]
      local position = positions[i]
      local alignment = alignments[i]
      
      -- Set child position relative to content area (not absolute)
      if self.direction == Layout.DIRECTION.ROW then
        child:setPos(position, alignment)
        child:setSize(size, sizes[i])
      else
        child:setPos(alignment, position)
        child:setSize(sizes[i], size)
      end
      
      -- Apply full width/height constraints
      if child.fullWidth then
        child:setSize(contentRect.w, child.h)
      end
      if child.fullHeight then
        child:setSize(child.w, contentRect.h)
      end
    end
end

-- Layout children with wrapping
function StackElement:_layoutWrapped(contentRect)
  local lines = {}
  local currentLine = {}
  local currentLineSize = 0
  local availableSize
  
  if self.direction == Layout.DIRECTION.ROW then
    availableSize = contentRect.w
  else
    availableSize = contentRect.h
  end
  
  -- Group children into lines
  for _, child in ipairs(self.children) do
    local childW, childH = Measure.elementPreferredSize(child)
    local childSize = self.direction == Layout.DIRECTION.ROW and childW or childH
    
    if #currentLine > 0 then
      childSize = childSize + self.gap
    end
    
    if currentLineSize + childSize > availableSize and #currentLine > 0 then
      -- Start new line
      table.insert(lines, currentLine)
      currentLine = {child}
      currentLineSize = self.direction == Layout.DIRECTION.ROW and childW or childH
    else
      -- Add to current line
      table.insert(currentLine, child)
      currentLineSize = currentLineSize + childSize
    end
  end
  
  if #currentLine > 0 then
    table.insert(lines, currentLine)
  end
  
  -- Layout each line
  local currentY = contentRect.y
  for lineIndex, line in ipairs(lines) do
    local lineHeight = 0
    
    -- Calculate line height
    for _, child in ipairs(line) do
      local childW, childH = Measure.elementPreferredSize(child)
      local childSize = self.direction == Layout.DIRECTION.ROW and childH or childW
      lineHeight = math.max(lineHeight, childSize)
    end
    
    -- Calculate flex sizes for this line
    local lineSizes = Layout.calculateFlexSizes(line, availableSize, self.direction, self.gap)
    
    -- Distribute items in this line
    local linePositions = Layout.distributeItems(line, lineSizes, availableSize, self.direction, self.justify, self.gap)
    
    -- Align items in this line
    local lineAlignments = Layout.alignItems(line, lineSizes, lineHeight, self.direction, self.align)
    
    -- Position children in this line
    for i, child in ipairs(line) do
      local size = lineSizes[i]
      local position = linePositions[i]
      local alignment = lineAlignments[i]
      
      -- Set child position relative to content area (not absolute)
      if self.direction == Layout.DIRECTION.ROW then
        child:setPos(position, currentY - contentRect.y + alignment)
        child:setSize(size, lineSizes[i])
      else
        child:setPos(alignment, currentY - contentRect.y + position)
        child:setSize(lineSizes[i], size)
      end
      
      -- Apply full width/height constraints
      if child.fullWidth then
        child:setSize(contentRect.w, child.h)
      end
      if child.fullHeight then
        child:setSize(child.w, contentRect.h)
      end
    end
    
    currentY = currentY + lineHeight
    if lineIndex < #lines then
      currentY = currentY + self.gap
    end
  end
end

-- Override draw to render stack
function StackElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Draw stack background
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderRadius, bg[1], bg[2], bg[3], alpha)
  end
  
  -- Draw stack border
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local alpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], alpha)
  end
  
  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Export the class
Stack.StackElement = StackElement
Stack.Create = function() return StackElement:Create() end

return Stack
