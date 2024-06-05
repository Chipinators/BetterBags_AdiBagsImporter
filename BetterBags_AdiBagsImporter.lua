---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, "BetterBags_AdiBagsImporter requires BetterBags")

local addonName, root = ...
---@class BetterBags_AdiBagsImporter: AceModule
local addon = LibStub("AceAddon-3.0"):NewAddon(root, addonName, 'AceHook-3.0')

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')

---@class Config: AceModule
local config = BetterBags:GetModule('Config')

---@class Events: AceModule
local events = BetterBags:GetModule('Events')

---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

-- Variables
local importRun = false
local importedItems = {}
local createdCategories = {}
local categorySeparator = " - "
local useSubcategoryOnly = false

-- Check if AdiBags is installed and loaded
local adiBagsInstalled = false
local adiBagsEnabled = false
for i = 1, GetNumAddOns() do
    local name, _, _, enabled = GetAddOnInfo(i)
    if name == "AdiBags" then
        adiBagsInstalled = true
        adiBagsEnabled = enabled
        break
    end
end
local adiBagsDetected = adiBagsInstalled and IsAddOnLoaded("AdiBags") and AdiBagsDB and AdiBagsDB.namespaces and AdiBagsDB.namespaces.FilterOverride

-- Function to format category name
local function formatCategoryName(category)
    if useSubcategoryOnly then
        local _, subCategory = strsplit("#", category)
        return subCategory
    end
    return gsub(category, "#", categorySeparator)
end

-- Function to import AdiBags filters
function addon:ImportAdiBagsFilters()
    -- Check if AdiBags configuration exists
    if not adiBagsDetected then
        print(L:G("AdiBags configuration not found!"))
        return
    end

    -- Read AdiBags filters
    local adiBagsFilters = AdiBagsDB.namespaces.FilterOverride.profiles.Default.overrides

    -- Create a set to store unique "Category#Sub-Category" strings
    local uniqueCategories = {}

    for _, category in pairs(adiBagsFilters) do
        local formattedCategory = formatCategoryName(category)
        uniqueCategories[formattedCategory] = true
    end

    -- Count the number of unique categories
    local uniqueCategoryCount = 0
    for _ in pairs(uniqueCategories) do
        uniqueCategoryCount = uniqueCategoryCount + 1
    end

    -- Migrate categories and items to BetterBags
    for itemId, category in pairs(adiBagsFilters) do
        local formattedCategory = formatCategoryName(category)
        -- Check if the category already exists in BetterBags
        if not categories:DoesCategoryExist(formattedCategory) then
            categories:CreatePersistentCategory(formattedCategory)
            createdCategories[formattedCategory] = true
        end
        -- Add item to the category
        categories:AddItemToPersistentCategory(itemId, formattedCategory)
        -- Track imported items
        importedItems[itemId] = formattedCategory
    end

    importRun = true
    print(format(L:G("Successfully imported %d AdiBags categories into BetterBags."), uniqueCategoryCount))
    events:SendMessage('bags/FullRefreshAll')
end

-- Function to undo the import
function addon:UndoImport()
    if not importRun then
        print(L:G("No import to undo."))
        return
    end

    -- Remove imported items from categories
    for itemId, category in pairs(importedItems) do
        categories:RemoveItemFromCategory(itemId)
    end

    -- Remove created categories
    for category, _ in pairs(createdCategories) do
        categories:DeleteCategory(category)
    end

    importedItems = {}
    createdCategories = {}
    importRun = false
    print(L:G("Undo successful. Reverted imported items and categories."))
    events:SendMessage('bags/FullRefreshAll')
end

-- Function to Enable Adi Bags and Reload UI
function addon:EnableAdiBags()
    EnableAddOn("AdiBags")
    ReloadUI()
end

---@type AceConfig.OptionsTable
local adiBagsImporterConfigOptions = {
    warning = {
        type = "group",
        name = L:G("Warning!"),
        order = 0,
        inline = true,
        hidden = function() return adiBagsDetected end,
        args = {
            description = {
                type = "description",
                name = adiBagsInstalled and L:G("AdiBags is installed but disabled. Please enable it and reload the UI.") or L:G("AdiBags not detected! The functionality of this module will be disabled."),
                order = 1,
            },
            enableAdiBags = {
                type = "execute",
                name = L:G("Enable AdiBags"),
                order = 2,
                hidden = function() return not adiBagsInstalled or adiBagsEnabled end,
                func = function() addon:EnableAdiBags() end,
            },
        }
    },
    adiBagsImporter = {
        name = L:G("AdiBags Importer"),
        type = "group",
        order = 1,
        inline = true,
        args = {
            description = {
                type = "description",
                name = L:G("Import your AdiBags custom filters into BetterBags"),
                order = 1,
                hidden = function() return not adiBagsDetected end,
            },
            separator = {
                type = "input",
                name = L:G("Category Separator"),
                desc = L:G("Enter the separator to use between Category and Sub-Category"),
                order = 2,
                get = function() return categorySeparator end,
                set = function(_, value) categorySeparator = value end,
                disabled = function() return useSubcategoryOnly or not adiBagsDetected end,
                hidden = function() return not adiBagsDetected end,
            },
            useSubcategoryOnly = {
                type = "toggle",
                name = L:G("Use Sub-Category Only"),
                desc = L:G("If enabled, only the Sub-Category will be used for the category name"),
                order = 3,
                get = function() return useSubcategoryOnly end,
                set = function(_, value) useSubcategoryOnly = value end,
                disabled = function() return not adiBagsDetected end,
                hidden = function() return not adiBagsDetected end,
            },
            buttons = {
                name = "",
                type = "group",
                inline = true,
                order = 4,
                hidden = function() return not adiBagsDetected end,
                args = {
                    import = {
                        type = "execute",
                        name = L:G("Import"),
                        order = 1,
                        disabled = function() return not adiBagsDetected end,
                        func = function() addon:ImportAdiBagsFilters() end,
                    },
                    undo = {
                        type = "execute",
                        name = L:G("Undo"),
                        order = 2,
                        disabled = function() return not importRun or not adiBagsDetected end,
                        func = function() addon:UndoImport() end,
                    },
                },
            },
        },
    },
}

config:AddPluginConfig("AdiBags Importer", adiBagsImporterConfigOptions)
