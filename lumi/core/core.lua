-- LÜMI Core Module
-- Centralized imports for all core functionality

local Core = {}

-- Core modules
Core.Context = require('lumi.core.context')
Core.Input = require('lumi.core.input')
Core.Draw = require('lumi.core.draw')
Core.LayoutEngine = require('lumi.core.layout_engine')
Core.LayoutConstants = require('lumi.core.layout_constants')
Core.Measure = require('lumi.core.measure')
Core.Theme = require('lumi.core.theme')
Core.Drag = require('lumi.core.drag')
Core.Debug = require('lumi.core.debug')

-- Utility modules
Core.Class = require('lumi.core.util.class')
Core.Color = require('lumi.core.util.color')
Core.Geom = require('lumi.core.util.geom')
Core.Text = require('lumi.core.util.text')

return Core
