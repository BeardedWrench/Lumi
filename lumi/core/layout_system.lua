-- Rock-Solid Layout System for Lumi UI
-- Based on established UI layout principles from CSS, Qt, and other systems

local LayoutSystem = {}

-- Layout System Principles:
-- 1. Root elements: Positioned absolutely on screen
-- 2. Child elements: Positioned relative to parent's content area
-- 3. Content area: Parent's bounds minus padding
-- 4. No double-positioning: Each element positioned exactly once
-- 5. Layout containers: Handle their own children's positioning

-- Layout a single element
function LayoutSystem.layoutElement(element, parentRect, screenRect)
  if not element or not element.visible then
    return nil
  end
  
  
  -- Calculate element size
  local elementWidth = element.w or 0
  local elementHeight = element.h or 0
  
  -- Apply full width/height constraints
  if element.fullWidth and parentRect then
    elementWidth = parentRect.w
  end
  if element.fullHeight and parentRect then
    elementHeight = parentRect.h
  end
  
  -- Apply size constraints
  elementWidth = math.max(elementWidth, element.minWidth or 0)
  elementHeight = math.max(elementHeight, element.minHeight or 0)
  elementWidth = math.min(elementWidth, element.maxWidth or math.huge)
  elementHeight = math.min(elementHeight, element.maxHeight or math.huge)
  
  -- Calculate position based on anchor
  local x, y = element.x or 0, element.y or 0
  
  if parentRect then
    -- Check if this is the root element (parentRect is screenRect)
    if parentRect == screenRect then
      -- Root element: apply anchor relative to screen
      x, y = LayoutSystem.applyAnchor(x, y, elementWidth, elementHeight, parentRect, element)
    else
      -- Child element: position relative to parent's content area
      x, y = LayoutSystem.applyAnchor(x, y, elementWidth, elementHeight, parentRect, element)
    end
  else
    -- No parent: use absolute coordinates
  end
  
  
  -- Create layout rectangle
  local layoutRect = {
    x = x,
    y = y,
    w = elementWidth,
    h = elementHeight
  }
  
  
  -- Store layout rect on element
  element._layoutRect = layoutRect
  
  return layoutRect
end

-- Apply anchor positioning using dual anchor system
function LayoutSystem.applyAnchor(x, y, elementWidth, elementHeight, parentRect, element)
  local parentX, parentY = parentRect.x, parentRect.y
  local parentWidth, parentHeight = parentRect.w, parentRect.h
  
  -- Use dual anchor system - anchorX and anchorY are independent
  local anchorX = element.anchorX or 'left'
  local anchorY = element.anchorY or 'top'
  
  
  -- Calculate X position
  local finalX
  if anchorX == 'left' then
    finalX = parentX + x
  elseif anchorX == 'center' then
    finalX = parentX + (parentWidth - elementWidth) / 2 + x
  elseif anchorX == 'right' then
    finalX = parentX + parentWidth - elementWidth - x
  end
  
  
  -- Calculate Y position
  local finalY
  if anchorY == 'top' then
    finalY = parentY + y
  elseif anchorY == 'center' then
    finalY = parentY + (parentHeight - elementHeight) / 2 + y
  elseif anchorY == 'bottom' then
    finalY = parentY + parentHeight - elementHeight - y
  end
  
  
  return finalX, finalY
end

-- Get content area of an element (bounds minus padding)
function LayoutSystem.getContentArea(element)
  local layoutRect = element._layoutRect
  if not layoutRect then
    return nil
  end
  
  local padding = element.padding or {0, 0, 0, 0} -- top, right, bottom, left
  local top, right, bottom, left = padding[1], padding[2], padding[3], padding[4]
  
  return {
    x = layoutRect.x + left,
    y = layoutRect.y + top,
    w = layoutRect.w - left - right,
    h = layoutRect.h - top - bottom
  }
end

-- Layout all children of an element
function LayoutSystem.layoutChildren(element, screenRect)
  if not element.children or #element.children == 0 then
    return
  end
  
  local contentArea = LayoutSystem.getContentArea(element)
  if not contentArea then
    return
  end
  
  -- Check if this is a Stack element
  if element.className == "StackElement" then
    -- Call Stack's layout method with the content area (which has the correct height)
    if element.layout then
      element:layout(contentArea)
    end
    -- Use stack layout
    LayoutSystem.layoutStack(element, contentArea)
  else
    -- Layout each child normally
    for _, child in ipairs(element.children) do
      -- Skip titlebar if it's a Panel - it's laid out manually
      if element.className == "PanelElement" and child == element.titlebar then
        -- Titlebar is already laid out manually, just layout its children
        LayoutSystem.layoutChildren(child, screenRect)
      else
        LayoutSystem.layoutElement(child, contentArea, screenRect)
        LayoutSystem.layoutChildren(child, screenRect) -- Recursively layout grandchildren
      end
    end
  end
end

-- Layout an entire element tree
function LayoutSystem.layoutTree(rootElement, screenRect)
  if not rootElement then
    return
  end
  
  
  -- Layout root element with screen as parent for positioning
  LayoutSystem.layoutElement(rootElement, screenRect, screenRect)
  
  -- Layout all children recursively
  LayoutSystem.layoutChildren(rootElement, screenRect)
end

-- Stack layout: Arrange children in a column or row
function LayoutSystem.layoutStack(stackElement, contentArea)
  if not stackElement.children or #stackElement.children == 0 then
    return
  end
  
  local direction = stackElement.direction or 'column'
  local gap = stackElement.gap or 0
  local justify = stackElement.justify or 'start'
  local align = stackElement.align or 'start'
  
  -- Calculate total size needed
  local totalSize = 0
  local maxCrossSize = 0
  local childSizes = {}
  
  for _, child in ipairs(stackElement.children) do
    local childW, childH = child.w or 0, child.h or 0
    local mainSize, crossSize
    
    if direction == 'column' then
      mainSize = childH
      crossSize = childW
    else
      mainSize = childW
      crossSize = childH
    end
    
    totalSize = totalSize + mainSize
    maxCrossSize = math.max(maxCrossSize, crossSize)
    
    table.insert(childSizes, {main = mainSize, cross = crossSize})
  end
  
  -- Add gaps
  if #stackElement.children > 1 then
    totalSize = totalSize + gap * (#stackElement.children - 1)
  end
  
  -- Calculate available space
  local availableMain = direction == 'column' and contentArea.h or contentArea.w
  local availableCross = direction == 'column' and contentArea.w or contentArea.h
  
  -- Calculate start position based on justify
  local startPos = 0
  if justify == 'center' then
    startPos = (availableMain - totalSize) / 2
  elseif justify == 'end' then
    startPos = availableMain - totalSize
  elseif justify == 'space-between' and #stackElement.children > 1 then
    gap = (availableMain - totalSize + gap * (#stackElement.children - 1)) / (#stackElement.children - 1)
  elseif justify == 'space-around' then
    local space = (availableMain - totalSize) / #stackElement.children
    startPos = space / 2
    gap = gap + space
  elseif justify == 'space-evenly' then
    local space = (availableMain - totalSize) / (#stackElement.children + 1)
    startPos = space
    gap = gap + space
  end
  
  -- Position children
  local currentPos = startPos
  for i, child in ipairs(stackElement.children) do
    local childSize = childSizes[i]
    local childX, childY, childW, childH
    
    -- Calculate cross-axis alignment
    local crossOffset = 0
    if align == 'center' then
      crossOffset = (availableCross - childSize.cross) / 2
    elseif align == 'end' then
      crossOffset = availableCross - childSize.cross
    end
    
    if direction == 'column' then
      childX = contentArea.x + crossOffset
      childY = contentArea.y + currentPos
      childW = childSize.cross
      childH = childSize.main
    else
      childX = contentArea.x + currentPos
      childY = contentArea.y + crossOffset
      childW = childSize.main
      childH = childSize.cross
    end
    
    -- Set child position and size
    child.x = childX - contentArea.x
    child.y = childY - contentArea.y
    child.w = childW
    child.h = childH
    
    -- Layout child
    LayoutSystem.layoutElement(child, contentArea)
    LayoutSystem.layoutChildren(child)
    
    currentPos = currentPos + childSize.main + gap
  end
end

-- Export the layout system
LayoutSystem.LayoutSystem = LayoutSystem
LayoutSystem.Create = function() return LayoutSystem end

return LayoutSystem