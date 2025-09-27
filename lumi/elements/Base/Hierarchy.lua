local BaseHierarchy = {}

function BaseHierarchy:addChild(child)
  if child then
    child.parent = self
    table.insert(self.children, child)
  end
  return self
end

function BaseHierarchy:removeChild(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil
      break
    end
  end
  return self
end

function BaseHierarchy:getChildren()
  return self.children
end

function BaseHierarchy:getParent()
  return self.parent
end

function BaseHierarchy:getRoot()
  local current = self
  while current.parent do
    current = current.parent
  end
  return current
end

function BaseHierarchy:getAbsolutePos()
  local x, y = self.x, self.y
  local parent = self.parent
  
  while parent do
    local parentRect = parent:getLayoutRect()
    if parentRect then
      x = x + parentRect.x
      y = y + parentRect.y
    end
    parent = parent.parent
  end
  
  return x, y
end

function BaseHierarchy:findChild(predicate)
  for _, child in ipairs(self.children) do
    if predicate(child) then
      return child
    end
    local found = child:findChild(predicate)
    if found then
      return found
    end
  end
  return nil
end

function BaseHierarchy:findChildren(predicate)
  local results = {}
  for _, child in ipairs(self.children) do
    if predicate(child) then
      table.insert(results, child)
    end
    local childResults = child:findChildren(predicate)
    for _, result in ipairs(childResults) do
      table.insert(results, result)
    end
  end
  return results
end

return BaseHierarchy
