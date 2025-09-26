local Layout = {}
local Geom = require('lumi.core.util.geom')
local Measure = require('lumi.core.measure')


Layout.DIRECTION = {
  ROW = 'row',
  COLUMN = 'column'
}


Layout.JUSTIFY = {
  START = 'start',
  END = 'end',
  CENTER = 'center',
  SPACE_BETWEEN = 'space-between',
  SPACE_AROUND = 'space-around',
  SPACE_EVENLY = 'space-evenly'
}


Layout.ALIGN = {
  START = 'start',
  END = 'end',
  CENTER = 'center',
  STRETCH = 'stretch'
}


function Layout.calculateFlexSizes(items, availableSize, direction, gap)
  gap = gap or 0
  local totalGap = gap * math.max(0, #items - 1)
  local availableForItems = availableSize - totalGap
  
  local totalFlexGrow = 0
  local totalFlexShrink = 0
  local totalFixedSize = 0
  
  
  for _, item in ipairs(items) do
    local flexGrow = item.flexGrow or 0
    local flexShrink = item.flexShrink or 1
    local flexBasis = item.flexBasis or 'auto'
    
    totalFlexGrow = totalFlexGrow + flexGrow
    totalFlexShrink = totalFlexShrink + flexShrink
    
    if flexBasis == 'auto' then
      local preferredWidth, preferredHeight = Measure.elementPreferredSize(item)
      local size = direction == Layout.DIRECTION.ROW and preferredWidth or preferredHeight
      totalFixedSize = totalFixedSize + size
    else
      totalFixedSize = totalFixedSize + flexBasis
    end
  end
  
  
  local remainingSpace = availableForItems - totalFixedSize
  local sizes = {}
  
  for i, item in ipairs(items) do
    local flexGrow = item.flexGrow or 0
    local flexShrink = item.flexShrink or 1
    local flexBasis = item.flexBasis or 'auto'
    
    local baseSize
    if flexBasis == 'auto' then
      local preferredWidth, preferredHeight = Measure.elementPreferredSize(item)
      baseSize = direction == Layout.DIRECTION.ROW and preferredWidth or preferredHeight
    else
      baseSize = flexBasis
    end
    
    local finalSize = baseSize
    
    if remainingSpace > 0 and totalFlexGrow > 0 then
      
      local extraSpace = remainingSpace * (flexGrow / totalFlexGrow)
      finalSize = baseSize + extraSpace
    elseif remainingSpace < 0 and totalFlexShrink > 0 then
      
      local shrinkSpace = math.abs(remainingSpace) * (flexShrink / totalFlexShrink)
      finalSize = math.max(0, baseSize - shrinkSpace)
    end
    
    sizes[i] = finalSize
  end
  
  return sizes
end


function Layout.distributeItems(items, sizes, availableSize, direction, justify, gap)
  gap = gap or 0
  local totalItemSize = 0
  for _, size in ipairs(sizes) do
    totalItemSize = totalItemSize + size
  end
  
  local totalGap = gap * math.max(0, #items - 1)
  local totalSize = totalItemSize + totalGap
  local remainingSpace = availableSize - totalSize
  
  local positions = {}
  local startPos = 0
  
  if justify == Layout.JUSTIFY.START then
    startPos = 0
  elseif justify == Layout.JUSTIFY.END then
    startPos = remainingSpace
  elseif justify == Layout.JUSTIFY.CENTER then
    startPos = remainingSpace / 2
  elseif justify == Layout.JUSTIFY.SPACE_BETWEEN then
    if #items > 1 then
      gap = gap + remainingSpace / (#items - 1)
    end
  elseif justify == Layout.JUSTIFY.SPACE_AROUND then
    local spacePerItem = remainingSpace / #items
    startPos = spacePerItem / 2
    gap = gap + spacePerItem
  elseif justify == Layout.JUSTIFY.SPACE_EVENLY then
    local spacePerItem = remainingSpace / (#items + 1)
    startPos = spacePerItem
    gap = gap + spacePerItem
  end
  
  local currentPos = startPos
  for i, size in ipairs(sizes) do
    positions[i] = currentPos
    currentPos = currentPos + size + gap
  end
  
  return positions
end


function Layout.alignItems(items, sizes, availableSize, direction, align)
  local alignments = {}
  
  for i, item in ipairs(items) do
    local itemSize = sizes[i]
    local alignment = 0
    
    if align == Layout.ALIGN.START then
      alignment = 0
    elseif align == Layout.ALIGN.END then
      alignment = availableSize - itemSize
    elseif align == Layout.ALIGN.CENTER then
      alignment = (availableSize - itemSize) / 2
    elseif align == Layout.ALIGN.STRETCH then
      
      alignment = 0
    end
    
    alignments[i] = alignment
  end
  
  return alignments
end

return Layout
