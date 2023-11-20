local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio
local Windows = StudioGui.Windows -- The main windows of the studio

local Blue = Color3.fromRGB(0,0,255)
local LightBlue = Color3.fromRGB(0,155,255)

local themes = {
    dark = {
        bg = Color3.new(0,0,0),
        bgl_1 = Color3.new(80,80,80),
        bgl_2 = Color3.new(120,120,120),
        bgd = Color3.new(40,40,40),
        outline = Color3.new(100,100,100),
        font = Enum.Font.SourceSans,
        text = Color3.new(240,240,240),
        text_error = Color3.new(255,0,0),
        text_warn = Color3.new(255, 128, 0)
    }
}

themes["current"] = themes.dark
local curTheme = themes.current

function splitString(inputString, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    inputString:gsub(pattern, function(substring)
        table.insert(result, substring)
    end)
    
    return result
end

-- PotatoInjector has no script property
local debug = false
if not script then debug = true end

local staticGuiList = {}
local dynamicGuiList = {}

local guiLayoutUnknown = false -- Has the gui been changed/updated?

local function handleError(errorString)
    error("\nPotatoMod has died (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
    print("Challenge Complete: How did we get here?") -- this should not run
end

local function getNested(obj, children, debug)
    debug = debug or false
    if not obj then
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end 
    children = splitString(children,".")
    for k, v in pairs(children) do
        if not obj:FindFirstChild(v) or not obj:IsA("Instance") then
            if not debug then
                guiLayoutUnknown = true
                return nil
            end
        end
        obj = obj[v]
    end
    return obj
end

--[[
    1 - instance
    2 - property
        1 - default
        2 - potato
    Register new object
]]
local function registerStatic(instance, child, debug)
    debug = debug or false
    if type(instance) == "table" then instance = instance[1] end
    if instance and instance:FindFirstChild(child) then 
        local new = {instance[child],{}}
        staticGuiList[#staticGuiList] = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.."."..child.. " is missing!")
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function registerDynamic(instance, child, debug)
    debug = debug or false
    if type(instance) == "table" then instance = instance[1] end
    if instance and instance:FindFirstChild(child) then 
        local new = {instance,{}}
        dynamicGuiList[#dynamicGuiList] = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.."."..child.. " is missing!")
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function registerProperty(instance, property, value, debug)
    debug = debug or false
    if instance then
        instance[2][property] = {instance[1][property],value}
    else
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end
end



-- Toolbar
-- Static
local Toolbar = registerStatic(Windows,"Toolbar")
if Toolbar then
    
end

-- TabBar
-- Static
local TabBar = registerStatic(Windows,"TabBar")
if TabBar then
    registerProperty(TabBar,"BackgroundColor3",curTheme.bg)
    local BottomLine = registerStatic(TabBar,"BottomLine")
    if BottomLine then
        registerProperty(BottomLine,"BackgroundColor3",curTheme.outline)
        registerProperty(BottomLine,"BorderColor3",curTheme.outline)
    end
end

-- Output
-- Static
local Output = registerStatic(Windows,"Output")
if Output then
    registerProperty(Output,"BackgroundColor3",curTheme.bg)
    registerProperty(Output,"BorderColor3",curTheme.outline)
    local ListOutline = registerStatic(Output,"ListOutline")
    if ListOutline then
        registerProperty(ListOutline,"BackgroundColor3",curTheme.bg)
        registerProperty(ListOutline,"BorderColor3",curTheme.outline)
    end
    local WindowHeader = registerStatic(Output,"WindowHeader")
    if WindowHeader then
        registerStatic(WindowHeader,"BackgroundColor3",curTheme.bgl_1)
        registerStatic(WindowHeader,"BorderColor3",curTheme.outline)
        registerStatic(WindowHeader,"TextColor3",curTheme.text)
        registerStatic(WindowHeader,"Font",curTheme.font)
    end
end

-- BottomBar
-- Static
local BottomBar = registerStatic(Windows,"BottomBar")
if BottomBar then
    
end


if guiLayoutUnknown == true then
    warn("PotatoMod2: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local function renderStatic(state)
    for k,v in pairs(staticGuiList) do
        for property,value in pairs(v[2]) do
            v[1][property] = value[state]
        end
    end
end

renderStatic(RENDER_STATE_POTATO)

warn("PotatoInjector has injected PotatoMod2!!! wow!!!")