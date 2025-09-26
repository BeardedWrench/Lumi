local Debug = {}
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')

local debugState = {
  enabled = false,
  showBounds = false,
  showLayoutRects = false,
  showContentRects = false,
  showHierarchy = false,
  logLevel = 'info' 
}

local debugColors = {
  bounds = {1, 0, 0, 0.8},      
  layoutRect = {0, 1, 0, 0.8},  
  contentRect = {0, 0, 1, 0.8}, 
  hierarchy = {1, 1, 0, 0.8},   
  text = {1, 1, 1, 1}           
}

function Debug.log(level, message, ...)
  if not debugState.enabled then return end
  
  local levels = {debug = 1, info = 2, warn = 3, error = 4}
  local currentLevel = levels[debugState.logLevel] or 2
  local messageLevel = levels[level] or 2
  
  if messageLevel >= currentLevel then
    local prefix = string.upper(level) .. " [UI-DEBUG]"
    print(prefix .. ": " .. string.format(message, ...))
  end
end

function Debug.debug(message, ...)
  Debug.log('debug', message, ...)
end

function Debug.info(message, ...)
  Debug.log('info', message, ...)
end

function Debug.warn(message, ...)
  Debug.log('warn', message, ...)
end

function Debug.error(message, ...)
  Debug.log('error', message, ...)
end

function Debug.drawElementBounds(pass, element, color)
  if not debugState.showBounds then return end
  
  local rect = element:getLayoutRect()
  if not rect then return end
  
  color = color or debugColors.bounds
  Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 2, color[1], color[2], color[3], color[4])
  
  local info = string.format("%s\n%.0f,%.0f %.0fx%.0f", 
    element.className or "Unknown", 
    rect.x, rect.y, rect.w, rect.h)
  Draw.text(pass, info, rect.x, rect.y - 20, 12, color[1], color[2], color[3], color[4])
end

function Debug.drawLayoutRect(pass, element, color)
  if not debugState.showLayoutRects then return end
  
  local rect = element:getLayoutRect()
  if not rect then return end
  
  color = color or debugColors.layoutRect
  Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 1, color[1], color[2], color[3], color[4])
end

function Debug.drawContentRect(pass, element, color)
  if not debugState.showContentRects then return end
  
  local rect = element:getContentRect()
  if not rect then return end
  
  color = color or debugColors.contentRect
  Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 1, color[1], color[2], color[3], color[4])
  
  
  local info = string.format("Content: %.0f,%.0f %.0fx%.0f", rect.x, rect.y, rect.w, rect.h)
  Draw.text(pass, info, rect.x, rect.y - 15, 10, color[1], color[2], color[3], color[4])
end

function Debug.drawHierarchy(pass, element, depth)
  if not debugState.showHierarchy then return end
  
  depth = depth or 0
  local rect = element:getLayoutRect()
  if not rect then return end
  
  if element.parent then
    local parentRect = element.parent:getLayoutRect()
    if parentRect then
      local color = debugColors.hierarchy
      Draw.line(pass, 
        parentRect.x + parentRect.w/2, parentRect.y + parentRect.h/2,
        rect.x + rect.w/2, rect.y + rect.h/2,
        color[1], color[2], color[3], color[4])
    end
  end
  
  local depthText = string.rep("  ", depth) .. (element.className or "Unknown")
  Draw.text(pass, depthText, rect.x, rect.y - 5, 8, debugColors.text[1], debugColors.text[2], debugColors.text[3], debugColors.text[4])
end

function Debug.debugElement(pass, element, depth)
  if not element or not element.visible then return end
  
  depth = depth or 0
  
  local rect = element:getLayoutRect()
  local contentRect = element:getContentRect()
  
  Debug.debug("Element: %s (depth: %d)", element.className or "Unknown", depth)
  if rect then
    Debug.debug("  Layout: %.0f,%.0f %.0fx%.0f", rect.x, rect.y, rect.w, rect.h)
  end
  if contentRect then
    Debug.debug("  Content: %.0f,%.0f %.0fx%.0f", contentRect.x, contentRect.y, contentRect.w, contentRect.h)
  end
  Debug.debug("  Position: %.0f,%.0f Size: %.0fx%.0f", element.x, element.y, element.w, element.h)
  Debug.debug("  Parent: %s", element.parent and (element.parent.className or "Unknown") or "None")
  
  Debug.drawElementBounds(pass, element)
  Debug.drawLayoutRect(pass, element)
  Debug.drawContentRect(pass, element)
  Debug.drawHierarchy(pass, element, depth)
  
  if element.children then
    for _, child in ipairs(element.children) do
      Debug.debugElement(pass, child, depth + 1)
    end
  end
end

function Debug.debugUI(pass, rootElement)
  if not debugState.enabled then return end
  
  Debug.info("=== UI DEBUG SESSION ===")
  Debug.debugElement(pass, rootElement)
  Debug.info("=== END DEBUG SESSION ===")
end

function Debug.enable()
  debugState.enabled = true
  Debug.info("UI Debug enabled")
end

function Debug.disable()
  debugState.enabled = false
  Debug.info("UI Debug disabled")
end

function Debug.toggle()
  debugState.enabled = not debugState.enabled
  Debug.info("UI Debug %s", debugState.enabled and "enabled" or "disabled")
end

function Debug.setLogLevel(level)
  debugState.logLevel = level
  Debug.info("Debug log level set to: %s", level)
end

function Debug.toggleBounds()
  debugState.showBounds = not debugState.showBounds
  Debug.info("Bounds display %s", debugState.showBounds and "enabled" or "disabled")
end

function Debug.toggleLayoutRects()
  debugState.showLayoutRects = not debugState.showLayoutRects
  Debug.info("Layout rects display %s", debugState.showLayoutRects and "enabled" or "disabled")
end

function Debug.toggleContentRects()
  debugState.showContentRects = not debugState.showContentRects
  Debug.info("Content rects display %s", debugState.showContentRects and "enabled" or "disabled")
end

function Debug.toggleHierarchy()
  debugState.showHierarchy = not debugState.showHierarchy
  Debug.info("Hierarchy display %s", debugState.showHierarchy and "enabled" or "disabled")
end

function Debug.showAll()
  debugState.showBounds = true
  debugState.showLayoutRects = true
  debugState.showContentRects = true
  debugState.showHierarchy = true
  Debug.info("All debug displays enabled")
end

function Debug.hideAll()
  debugState.showBounds = false
  debugState.showLayoutRects = false
  debugState.showContentRects = false
  debugState.showHierarchy = false
  Debug.info("All debug displays disabled")
end

function Debug.getState()
  return debugState
end

Debug.Debug = Debug
Debug.Create = function() return Debug end

return Debug
