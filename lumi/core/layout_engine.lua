local LayoutEngine = {}

function LayoutEngine.layoutElement(element, parentRect, screenRect)
  if not element or not element.visible then
    return nil
  end

  local elementWidth = element.w or 0
  local elementHeight = element.h or 0
  
  if element.fullWidth and parentRect then
    elementWidth = parentRect.w
  end
  if element.fullHeight and parentRect then
    elementHeight = parentRect.h
  end
  
  elementWidth = math.max(elementWidth, element.minWidth or 0)
  elementHeight = math.max(elementHeight, element.minHeight or 0)
  elementWidth = math.min(elementWidth, element.maxWidth or math.huge)
  elementHeight = math.min(elementHeight, element.maxHeight or math.huge)
  
  local x, y = element.x or 0, element.y or 0
  if parentRect then
    x, y = LayoutEngine.applyAnchor(x, y, elementWidth, elementHeight, parentRect, element)
  end
  
  local layoutRect = {
    x = x,
    y = y,
    w = elementWidth,
    h = elementHeight
  }
  
  -- Update the element's actual position and size
  element.x = x
  element.y = y
  element.w = elementWidth
  element.h = elementHeight
  
  element._layoutRect = layoutRect
  return layoutRect
end

function LayoutEngine.applyAnchor(x, y, elementWidth, elementHeight, parentRect, element)
  local parentX, parentY = parentRect.x, parentRect.y
  local parentWidth, parentHeight = parentRect.w, parentRect.h
  local anchorX = element.anchorX or 'left'
  local anchorY = element.anchorY or 'top'
  local finalX
  if anchorX == 'left' then
    finalX = parentX + x
  elseif anchorX == 'center' then
    finalX = parentX + (parentWidth - elementWidth) / 2 + x
  elseif anchorX == 'right' then
    finalX = parentX + parentWidth - elementWidth - x
  end
  
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

function LayoutEngine.getContentArea(element)
  local layoutRect = element._layoutRect
  if not layoutRect then
    return nil
  end
  
  local padding = element.padding or {0, 0, 0, 0} 
  local top, right, bottom, left = padding[1], padding[2], padding[3], padding[4]
  
  return {
    x = layoutRect.x + left,
    y = layoutRect.y + top,
    w = layoutRect.w - left - right,
    h = layoutRect.h - top - bottom
  }
end

function LayoutEngine.layoutChildren(element, screenRect)
  if not element.children or #element.children == 0 then
    return
  end
  
  local contentArea = LayoutEngine.getContentArea(element)
  if not contentArea then
    return
  end
  
  if element.className == "StackElement" then
    if element.layout then
      element:layout(contentArea)
    end
    LayoutEngine.layoutStack(element, contentArea)
    -- Don't process Stack children with regular layout engine - Stack handles its own children
    return
  else
    for _, child in ipairs(element.children) do
      if child.className == "StackElement" then
        -- Handle Stack elements specially regardless of parent
        if child.layout then
          child:layout(contentArea)
        end
        LayoutEngine.layoutStack(child, contentArea)
        -- Don't call layoutChildren for Stacks - they handle their own children
      else
        -- Skip children that are already laid out by their parent (e.g., Stack children)
        if not child._stackLaidOut then
          print("DEBUG layoutChildren: Processing child", child.className, "not laid out (_stackLaidOut =", child._stackLaidOut, ")")
          LayoutEngine.layoutElement(child, contentArea, screenRect)
          LayoutEngine.layoutChildren(child, screenRect) 
        else
          print("DEBUG layoutChildren: Skipping child", child.className, "already laid out (_stackLaidOut =", child._stackLaidOut, ")")
        end
      end
    end
  end
end

function LayoutEngine.layoutTree(rootElement, screenRect)
  if not rootElement then
    return
  end
  LayoutEngine.layoutElement(rootElement, screenRect, screenRect)
  LayoutEngine.layoutChildren(rootElement, screenRect)
end

function LayoutEngine.layoutStack(stackElement, contentArea)
  if not stackElement.children or #stackElement.children == 0 then
    return
  end
  
  local direction = stackElement.direction or 'column'
  local gap = stackElement.gap or 0
  local justify = stackElement.justify or 'start'
  local align = stackElement.align or 'start'
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
  
  if #stackElement.children > 1 then
    totalSize = totalSize + gap * (#stackElement.children - 1)
  end
  
  local availableMain = direction == 'column' and contentArea.h or contentArea.w
  local availableCross = direction == 'column' and contentArea.w or contentArea.h
  
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
  
  local currentPos = startPos
  for i, child in ipairs(stackElement.children) do
    local childSize = childSizes[i]
    local childX, childY, childW, childH
    
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
    
    child.x = childX - contentArea.x
    child.y = childY - contentArea.y
    child.w = childW
    child.h = childH
    
    -- Don't call layoutElement or layoutChildren here - Stack handles its own children
    -- LayoutEngine.layoutElement(child, contentArea)
    -- LayoutEngine.layoutChildren(child)
    
    currentPos = currentPos + childSize.main + gap
  end
end

LayoutEngine.Create = function() return LayoutEngine end

return LayoutEngine
