--[[
    PotatoMod3 - a client mod for Retrostudio
    Created by NicePotato

    Credits
    Ayray
    Cristiano
]]--

--- Generic theme attribute with no associated color
---@class theme_attribute
---@field protected is_theme boolean
---@field attribute string Attribute name

---@class static_group

--- Instance Hook
---@class hook : pm_meta_funcs
---@field instance Instance The Instance influenced by the hook
---@field children hook[] Child Hooks
---@field parent hook | nil Parent Hook
---@field orig_properties table<string, any> Original properties of hooked instance
---@field static_properties table<string, any> Static property overrides for hooked instance
---@field static_theme table<string, theme_attribute> Static theme overrides for hooked instance

---@class pm_meta_funcs
local PM_mf = {}

local PM = {
    label = "PotatoMod3",
    hooks = {},
    meta = {
        meta_funcs = PM_mf
    },
    layout_unknown = false
}

PM.themes = {
    dark = {
        header = Color3.fromRGB(64,64,64),
        bg = Color3.fromRGB(46,46,46),
        ol = Color3.fromRGB(60,60,60),
        font = Enum.Font.SourceSans,
        font_bold = Enum.Font.SourceSansBold,
        text = Color3.fromRGB(240,240,240),
        text_print = Color3.fromRGB(240,240,240),
        text_info = Color3.fromRGB(0,155,255),
        text_error = Color3.fromRGB(255,0,0),
        text_warn = Color3.fromRGB(255, 128, 0),
        zebra_1 = Color3.fromRGB(46,46,46),
        zebra_2 = Color3.fromRGB(50, 50, 50),
        scrollback = Color3.fromRGB(40,40,40),
        scrollbar = Color3.fromRGB(64,64,64)
    },
    classic = {
        header = Color3.fromRGB(80,80,80),
        bg = Color3.fromRGB(40,40,40),
        ol = Color3.fromRGB(100,100,100),
        font = Enum.Font.SourceSans,
        font_bold = Enum.Font.SourceSansBold,
        text = Color3.fromRGB(240,240,240),
        text_print = Color3.fromRGB(240,240,240),
        text_info = Color3.fromRGB(0,155,255),
        text_error = Color3.fromRGB(255,0,0),
        text_warn = Color3.fromRGB(255, 128, 0),
        zebra_1 = Color3.fromRGB(40,40,40),
        zebra_2 = Color3.fromRGB(44,44,44),
        scrollback = Color3.fromRGB(40,40,40),
        scrollbar = Color3.fromRGB(80,80,80)
    }
}

local theme = {}

for attribute in pairs(PM.themes.dark) do
    theme[attribute] = {
        is_theme = true,
        attribute = attribute
    }
end

local static_groups

PM.static_groups = static_groups

static_groups.Frame = {
    ["BackgroundColor3"] = theme.bg,
    ["BorderColor3"] = theme.ol
}
static_groups.Text = {
    ["TextColor3"] = theme.text,
    ["Font"] = theme.font
}

static_groups.TextLabel = {
    static_groups.Frame,
    static_groups.Text
}
static_groups.TextBox = static_groups.TextLabel
static_groups.TextButton = static_groups.TextLabel

function PM.warn(...)
    local out = PM.label
    for _,message in ipairs({...}) do
        if message then
            out = out.." "..tostring(message)
        else
            out = out.." nil"
        end
    end
    warn(out)
end

--- Add an instance to constant hooks
---@param instance Instance
---@param ignore_missing boolean
---@return hook hook
---@return boolean success
function PM.HookInstance(instance, ignore_missing)
    ignore_missing = ignore_missing or false
    
    local hook = {
        instance = instance,
        children = {},
        orig_properties = {},
        static_properties = {},
        static_theme = {}
    }
    hook:setmetatable(PM.meta)

    if instance then
        PM.hooks[instance] = hook
        return hook, true
    elseif not ignore_missing then
        PM.warn("Attempt to hook nil instance")
        PM.layout_unknown = true
    end
    return hook, false
end

--- Hook another hooks child
---@param self hook
---@param child_name string
---@param ignore_missing boolean
---@return hook hook
function PM_mf:HookChild(child_name, ignore_missing)
    local child
    if self.instance then
        child = self.instance:FindFirstChild(child_name)
    end

    local hook, hooked = PM.HookInstance(child, true)

    if self.instance then
        self.children[child_name] = hook
        hook.parent = self
        if not ignore_missing and not hooked then
            PM.warn(self.instance:GetFullName()..' has no child "'..child_name..'"')
            PM.layout_unknown = true
        end
    end

    return hook
end

--- Save original property from a hooked instance
---@param self hook
---@param property string
---@return boolean success
function PM_mf:SaveProperty(property)
    if not pcall(function() self.orig_properties[property] = self.instance[property] end) then
        PM.warn(self.instance:GetFullName()..' has no property "'..property..'"')
        return false
    end
    return true
end

--- Apply a static property override to a hooked instance
---@param self hook
---@param property string
---@param value any
function PM_mf:StaticProperty(property, value)
    if self.instance then
        if PM_mf:SaveProperty(property) then
            self.static_properties[property] = value
        end
    end
end

--- Apply a static theme override to a hooked instance
---@param self hook
---@param property string
---@param attribute theme_attribute
function PM_mf:StaticTheme(property, attribute)
    if self.instance then
        if PM_mf:SaveProperty(property) then
            self.static_theme[property] = attribute
        end
    end
end

--- Apply many static overrides to a hooked instance and/or its descendants
---@param self hook
---@param static_group static_group
function PM_mf:StaticGroup(static_group)
    local function apply(static_group)
        for property, value in pairs(static_group) do
            if type(value) == "table" then
                if value.is_theme then
                    self:StaticTheme(property, value)
                else
                    if type(property) == "string" then
                        self[property]:StaticGroup(value)
                    else
                        apply(value)
                    end        
                end
            else
                self:StaticProperty(property, value)
            end
        end
    end

    if self.instance then
        if type(static_group) == "table" then
            apply(static_group)
        else
            PM.warn("Attempt to apply a non-table static group to "..self.instance:GetFullName())
        end
    end
end

---@param self hook
---@return hook
function PM.meta.__index(self, key)
    if PM_mf[key] then return PM_mf[key] end
    if self.instance then
        if key == "Parent" then
            return self.parent
        else
            return self.children[key] or self:HookChild(key)
        end
    else
        return self -- this hook is a dummy, so just pass itself
    end
end

---@param self hook
function PM.meta.__newindex(self, key, value)
    if type(value) == "table" then
        if value.is_theme then
            self:StaticTheme(key, value)
        else
            PM.warn("Attempt to assign "..self.instance:GetFullName().."."..tostring(key).." to a table")
        end
    else
        self:StaticProperty(key, value)
    end
end

-----------------------------
-- End of PotatoMod module --
-----------------------------

local function registerStudio()
    PM.HookInstance()
end

registerStudio()