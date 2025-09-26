local Theme = require('lumi.core.theme')

local Text = {}
local font = lovr.graphics.newFont(Theme.typography.fontSize)

function Text.estimateWidth(text)
  return font:getWidth(text) * Theme.typography.fontSize
end

function Text.wrap(text, maxWidth, mode)
  mode = mode or 'word'
  
  if mode == 'none' then
    return {text}
  end
  
  local lines = {}
  local currentLine = ""
  local words = {}
  
  if mode == 'word' then
    words = {}
    for word in text:gmatch("%S+") do
      table.insert(words, word)
    end
  elseif mode == 'char' then
    words = {}
    for i = 1, #text do
      table.insert(words, text:sub(i, i))
    end
  end
  
  for i, word in ipairs(words) do
    local testLine = currentLine
    if currentLine ~= "" then
      testLine = testLine .. (mode == 'word' and " " or "") .. word
    else
      testLine = word
    end
    
    if Text.estimateWidth(testLine) <= maxWidth then
      currentLine = testLine
    else
      if currentLine ~= "" then
        table.insert(lines, currentLine)
        currentLine = word
      else
        
        table.insert(lines, word)
        currentLine = ""
      end
    end
  end
  
  if currentLine ~= "" then
    table.insert(lines, currentLine)
  end
  
  return lines
end

function Text.truncate(text, maxWidth)
  local ellipsis = "..."
  local ellipsisWidth = Text.estimateWidth(ellipsis)
  
  if Text.estimateWidth(text) <= maxWidth then
    return text
  end
  
  local truncated = text
  while Text.estimateWidth(truncated .. ellipsis) > maxWidth and #truncated > 0 do
    truncated = truncated:sub(1, -2)
  end
  
  return truncated .. ellipsis
end

function Text.getAlignOffset(text, maxWidth, align)
  align = align or 'left'
  local textWidth = Text.estimateWidth(text)
  
  if align == 'left' then
    return 0
  elseif align == 'center' then
    return (maxWidth - textWidth) / 2
  elseif align == 'right' then
    return maxWidth - textWidth
  end
  
  return 0
end

return Text
