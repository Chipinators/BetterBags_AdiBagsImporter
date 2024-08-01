---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

if L then
    -- General Strings
    local generalStrings = {
        ["Warning!"] = "Warning!",
        ["AdiBags Importer"] = "AdiBags Importer",
        ["Enable AdiBags"] = "Enable AdiBags",
        ["Import"] = "Import",
        ["Undo"] = "Undo",
    }

    -- Descriptions
    local descriptions = {
        ["AdiBags is installed but disabled. Please enable it and reload the UI."] = "AdiBags is installed but disabled. Please enable it and reload the UI.",
        ["AdiBags not detected! The functionality of this module will be disabled."] = "AdiBags not detected! The functionality of this module will be disabled.",
        ["Import your AdiBags custom filters into BetterBags"] = "Import your AdiBags custom filters into BetterBags",
        ["Enter the separator to use between Category and Sub-Category"] = "Enter the separator to use between Category and Sub-Category",
        ["If enabled, only the Sub-Category will be used for the category name"] = "If enabled, only the Sub-Category will be used for the category name",
        ["AdiBags configuration not found!"] = "AdiBags configuration not found!",
        ["Successfully imported %d AdiBags categories into BetterBags."] = "Successfully imported %d AdiBags categories into BetterBags.",
        ["No import to undo."] = "No import to undo.",
        ["Undo successful. Reverted imported items and categories."] = "Undo successful. Reverted imported items and categories.",
    }

    -- Errors
    local errors = {
        ["AdiBags Importer Warning: Attempted to import item '%d' but the item does not exist. Item import was skipped."] = "AdiBags Importer Warning: Attempted to import item '%d' but the item does not exist. Item import was skipped.",
    }

    -- Register Strings
    for key, value in pairs(generalStrings) do
        L:S(key, value)
    end

    for key, value in pairs(descriptions) do
        L:S(key, value)
    end

    for key, value in pairs(errors) do
        L:S(key, value)
    end
end