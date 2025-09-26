-- LÜMI Elements Module
-- Centralized imports for all UI elements

local Elements = {}

-- Foundation elements
Elements.Box = require('lumi.elements.foundation.Box')
Elements.Text = require('lumi.elements.foundation.Text')
Elements.RoundedRect = require('lumi.elements.foundation.RoundedRect')

-- UI elements
Elements.Base = require('lumi.elements.Base.Base')
Elements.Panel = require('lumi.elements.Panel.Panel')
Elements.Label = require('lumi.elements.Label.Label')
Elements.Button = require('lumi.elements.Button.Button')
Elements.Input = require('lumi.elements.Input.Input')
Elements.Slot = require('lumi.elements.Slot.Slot')
Elements.Tooltip = require('lumi.elements.Tooltip.Tooltip')

-- Layout elements
Elements.Stack = require('lumi.layout.Stack.Stack')
Elements.Grid = require('lumi.layout.Grid.Grid')

return Elements
