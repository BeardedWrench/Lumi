local Stack = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Layout = require('lumi.core.layout')
local Measure = require('lumi.core.measure')
local Theme = require('lumi.core.theme')
local LayoutSystem = require('lumi.core.layout_system')
local Draw = require('lumi.core.draw')

local StackElement = Base.BaseElement:extend()

function StackElement:init()
  StackElement.__super.init(self)
  
  self.className = "StackElement"
  self.direction = Layout.DIRECTION.ROW 
  self.justify = Layout.JUSTIFY.START 
  self.align = Layout.ALIGN.START 
  self.gap = Theme.spacing.gap
  self.wrap = false
  self._layoutLines = {}
end

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

function StackElement:preferredSize()
  if #self.children == 0 then
    return StackElement.__super.preferredSize(self)
  end
  
  local w, h = 0, 0
  if self.direction == Layout.DIRECTION.ROW then
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

function StackElement:_layoutSingleLine(contentRect)
  local items = {}
  local availableSize
  if self.direction == Layout.DIRECTION.ROW then
    availableSize = contentRect.w
  else
    availableSize = contentRect.h
  end
  local sizes = Layout.calculateFlexSizes(self.children, availableSize, self.direction, self.gap)
  local positions = Layout.distributeItems(self.children, sizes, availableSize, self.direction, self.justify, self.gap)
  local alignments = Layout.alignItems(self.children, sizes, 
    self.direction == Layout.DIRECTION.ROW and contentRect.h or contentRect.w, 
    self.direction, self.align)
    for i, child in ipairs(self.children) do
      local size = sizes[i]
      local position = positions[i]
      local alignment = alignments[i]
      if self.direction == Layout.DIRECTION.ROW then
        child:setPos(position, alignment)
      else
        child:setPos(alignment, position)
      end
    end
end

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
  
  for _, child in ipairs(self.children) do
    local childW, childH = Measure.elementPreferredSize(child)
    local childSize = self.direction == Layout.DIRECTION.ROW and childW or childH
    if #currentLine > 0 then
      childSize = childSize + self.gap
    end
    if currentLineSize + childSize > availableSize and #currentLine > 0 then
      table.insert(lines, currentLine)
      currentLine = {child}
      currentLineSize = self.direction == Layout.DIRECTION.ROW and childW or childH
    else
      table.insert(currentLine, child)
      currentLineSize = currentLineSize + childSize
    end
  end
  if #currentLine > 0 then
    table.insert(lines, currentLine)
  end
  
  local currentY = contentRect.y
  for lineIndex, line in ipairs(lines) do
    local lineHeight = 0
    
    for _, child in ipairs(line) do
      local childW, childH = Measure.elementPreferredSize(child)
      local childSize = self.direction == Layout.DIRECTION.ROW and childH or childW
      lineHeight = math.max(lineHeight, childSize)
    end
    local lineSizes = Layout.calculateFlexSizes(line, availableSize, self.direction, self.gap)
    local linePositions = Layout.distributeItems(line, lineSizes, availableSize, self.direction, self.justify, self.gap)
    local lineAlignments = Layout.alignItems(line, lineSizes, lineHeight, self.direction, self.align)
    
    for i, child in ipairs(line) do
      local size = lineSizes[i]
      local position = linePositions[i]
      local alignment = lineAlignments[i]
      if self.direction == Layout.DIRECTION.ROW then
        child:setPos(position, currentY - contentRect.y + alignment)
      else
        child:setPos(alignment, currentY - contentRect.y + position)
      end
    end
    
    currentY = currentY + lineHeight
    if lineIndex < #lines then
      currentY = currentY + self.gap
    end
  end
end

function StackElement:layout(rect)
  self._layoutRect = rect
  if self.fullWidth then
    self.w = rect.w
  end
  if self.fullHeight then
    self.h = rect.h
  end
  local contentRect = LayoutSystem.getContentArea(self, rect)
  if self.wrap then
    self:_layoutWrapped(contentRect)
  else
    self:_layoutSingleLine(contentRect)
  end
end

function StackElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.rect(pass, rect.x, rect.y, rect.w, rect.h, bg[1], bg[2], bg[3], alpha)
  end
  
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local alpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], alpha)
  end
  
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

Stack.StackElement = StackElement
Stack.Create = function() return StackElement:Create() end

return Stack
