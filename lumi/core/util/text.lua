-- Text utility functions for Lumi UI

local Text = {}

-- Simple character width estimation (approximate)
-- This is a fallback when font metrics aren't available
local CHAR_WIDTHS = {
  ['i'] = 0.3, ['l'] = 0.3, ['t'] = 0.4, ['f'] = 0.4, ['j'] = 0.3,
  ['r'] = 0.5, ['s'] = 0.5, ['c'] = 0.5, ['a'] = 0.5, ['e'] = 0.5,
  ['o'] = 0.6, ['n'] = 0.6, ['u'] = 0.6, ['h'] = 0.6, ['b'] = 0.6,
  ['d'] = 0.6, ['p'] = 0.6, ['q'] = 0.6, ['g'] = 0.6, ['y'] = 0.6,
  ['k'] = 0.6, ['v'] = 0.6, ['x'] = 0.6, ['z'] = 0.5, ['w'] = 0.8,
  ['m'] = 0.8, ['A'] = 0.7, ['B'] = 0.7, ['C'] = 0.7, ['D'] = 0.7,
  ['E'] = 0.6, ['F'] = 0.6, ['G'] = 0.7, ['H'] = 0.7, ['I'] = 0.3,
  ['J'] = 0.5, ['K'] = 0.7, ['L'] = 0.6, ['M'] = 0.8, ['N'] = 0.7,
  ['O'] = 0.7, ['P'] = 0.6, ['Q'] = 0.7, ['R'] = 0.7, ['S'] = 0.6,
  ['T'] = 0.6, ['U'] = 0.7, ['V'] = 0.7, ['W'] = 0.9, ['X'] = 0.7,
  ['Y'] = 0.7, ['Z'] = 0.6, [' '] = 0.3, ['.'] = 0.2, [','] = 0.2,
  ['!'] = 0.2, ['?'] = 0.5, [':'] = 0.2, [';'] = 0.2, ['-'] = 0.4,
  ['_'] = 0.5, ['('] = 0.3, [')'] = 0.3, ['['] = 0.3, [']'] = 0.3,
  ['{'] = 0.3, ['}'] = 0.3, ['"'] = 0.3, ["'"] = 0.2, ['`'] = 0.2,
  ['~'] = 0.6, ['@'] = 0.8, ['#'] = 0.6, ['$'] = 0.6, ['%'] = 0.8,
  ['^'] = 0.5, ['&'] = 0.7, ['*'] = 0.4, ['+'] = 0.5, ['='] = 0.5,
  ['|'] = 0.2, ['\\'] = 0.4, ['/'] = 0.4, ['<'] = 0.5, ['>'] = 0.5
}

-- Estimate text width in pixels
function Text.estimateWidth(text, fontSize)
  fontSize = fontSize or 16
  local width = 0
  
  for i = 1, #text do
    local char = text:sub(i, i)
    local charWidth = CHAR_WIDTHS[char] or 0.6 -- default width
    width = width + charWidth * fontSize
  end
  
  return width
end

-- Wrap text to fit within given width
function Text.wrap(text, maxWidth, fontSize, mode)
  mode = mode or 'word'
  fontSize = fontSize or 16
  
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
    
    if Text.estimateWidth(testLine, fontSize) <= maxWidth then
      currentLine = testLine
    else
      if currentLine ~= "" then
        table.insert(lines, currentLine)
        currentLine = word
      else
        -- Single word/char is too long, force it
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

-- Truncate text with ellipsis
function Text.truncate(text, maxWidth, fontSize)
  fontSize = fontSize or 16
  local ellipsis = "..."
  local ellipsisWidth = Text.estimateWidth(ellipsis, fontSize)
  
  if Text.estimateWidth(text, fontSize) <= maxWidth then
    return text
  end
  
  local truncated = text
  while Text.estimateWidth(truncated .. ellipsis, fontSize) > maxWidth and #truncated > 0 do
    truncated = truncated:sub(1, -2)
  end
  
  return truncated .. ellipsis
end

-- Get text alignment offset
function Text.getAlignOffset(text, maxWidth, fontSize, align)
  align = align or 'left'
  local textWidth = Text.estimateWidth(text, fontSize)
  
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
