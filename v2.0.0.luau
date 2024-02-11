local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio
local Windows = StudioGui.Windows -- The main windows of the studio
local Topbar = StudioGui.Topbar
local MenusBar = Topbar.MenusBar

local Blue = Color3.fromRGB(0,0,255)
local LightBlue = Color3.fromRGB(0,155,255)

local themes = {
    dark = {
        black = Color3.fromRGB(0,0,0),
        header = Color3.fromRGB(80,80,80),
        bgl_2 = Color3.fromRGB(120,120,120),
        bg = Color3.fromRGB(40,40,40),
        ol = Color3.fromRGB(100,100,100),
        font = Enum.Font.SourceSans,
        text = Color3.fromRGB(240,240,240),
        text_error = Color3.fromRGB(255,0,0),
        text_warn = Color3.fromRGB(255, 128, 0)
    }
}

themes["current"] = themes.dark

local theme = {
    black = "black",
    header = "header",
    bgl_2 = "bgl_2",
    bg = "bg",
    ol = "ol",
    font = "font",
    text = "text",
    text_error = "text_error",
    text_warn = "text_warn"
}



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

local function splitString(inputString, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    inputString:gsub(pattern, function(substring)
        table.insert(result, substring)
    end)
    
    return result
end

local function getNested(obj, children, debug)
    debug = debug or false
    children = splitString(children,".")
    for _, v in pairs(children) do
        if not obj:IsA("Instance") or not obj:FindFirstChild(v) then
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



local currentStatic -- Instance to apply property to

-- I made these lowercase to type them easier
local function static(instance, child, debug)
    debug = debug or false
    if type(instance) == "table" then instance = instance[1] end
    if instance and getNested(instance,child) then 
        local new = {getNested(instance,child),{}}
        staticGuiList[#staticGuiList+1] = new
        currentStatic = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.."."..child.. " is missing!")
            guiLayoutUnknown = true
            currentStatic = nil
            return nil
        end
    end
end

local function regprop(property, value, instance, debug)
    instance = instance or currentStatic
    debug = debug or false
    local set, message = pcall(function()
        if instance then
            instance[2][property] = {instance[1][property],value}
        else
            if not debug then
                guiLayoutUnknown = true
                return nil
            end
        end
    end)
    if not set then
        if not debug then
            warn("PotatoMod2: "..message)
            guiLayoutUnknown = true
            return nil
        end
    end
    
end

-- ... used to allow setting static inside of function
local function regfont()
    regprop("TextColor3",theme.text)
    regprop("Font",theme.font)
end

local function regdefault(...)
    regprop("BackgroundColor3",theme.bg)
    regprop("BorderColor3",theme.ol)
    if currentStatic[1]:IsA("TextLabel") or currentStatic[1]:IsA("TextBox") or currentStatic[1]:IsA("TextButton") then
        regfont()
    end
end

local function staticdefault(instance, child, debug) -- Create a static with default properties
    local newStatic = static(instance, child, debug)
    regdefault()
    return newStatic
end

local function regheader(...)
    regprop("BackgroundColor3",theme.header)
    regprop("BorderColor3",theme.ol)
    regfont()
end

-- Custom GUI
if not MenusBar:FindFirstChild("WindowButton") then handleError("Funny thing, the tab that PotatoMod embeds itself into has been removed by the devs!") end
local PotatoModGui = Instance.new("Frame")
PotatoModGui.Name = "PotatoMod"


--Properties
--Static
local Properties = staticdefault(Windows,"Properties")
if Properties then
    regheader(static(Properties,"WindowHeader"))
    local ListOutline = staticdefault(Properties,"ListOutline")
    if ListOutline then
        local Header = staticdefault(ListOutline,"Header")
        if Header then
            local Frame = static(Header,"Frame")
            if Frame then
                regprop("BackgroundColor3",theme.ol)
            end
        end
    end
    local IdentityBackground = static(Properties,"IdentityBackground")
    if IdentityBackground then
        regprop("ImageColor3",theme.header)
        local IdentityLabel = static(IdentityBackground,"IdentityLabel")
        if IdentityLabel then
            regfont()
        end
    end
    local PropertiesScript = static(Properties,"PropertiesScript")
    if PropertiesScript then
        local EnumList = static(PropertiesScript,"EnumList")
        if EnumList then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regprop("BackgroundColor3",theme.ol)
            local ScrollingFrame = static(EnumList,"Frame.ScrollingFrame")
            if ScrollingFrame then
                regprop("BackgroundColor3",theme.bg)
                local ListItem = static(ScrollingFrame,"ListItem")
                if ListItem then
                    regprop("BackgroundColor3",theme.bg)
                    regfont()
                    local TextLabel = static(ListItem,"TextLabel")
                    if TextLabel then
                        regfont()
                    end
                end
            end
        end
        local PropertyBrickColorPalette = static(PropertiesScript,"PropertyBrickColorPalette")
        if PropertyBrickColorPalette then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regprop("BorderColor3",theme.ol)
            regprop("BackgroundColor3",theme.bg)
            regprop("BorderSizePixel",1)
        end
    end
end

-- Toolbar
-- Static
local Toolbar = static(Topbar,"ToolBar")
if Toolbar then
    
end

-- TabBar
-- Static
local TabBar = staticdefault(StudioGui,"TabBar")
if TabBar then
    local BottomLine = static(TabBar,"BottomLine")
    if BottomLine then
        regprop("BackgroundColor3",theme.ol)
        regprop("BorderColor3",theme.ol)
    end
end

-- Output
-- Static
local Output = staticdefault(Windows,"Output")
if Output then
    local ListOutline = staticdefault(Output,"ListOutline")
    regheader(static(Output,"WindowHeader"))
end

-- BottomBar
-- Static
local BottomBar = static(StudioGui,"BottomBar")
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
            local set, message = pcall(function() -- pcall as to not error if can't set property
                if state == RENDER_STATE_DEFAULT then
                    v[1][property] = value[state]
                else
                    v[1][property] = themes.current[value[state]]
                end
            end)
            if not set then
                if state ~= RENDER_STATE_DEFAULT then
                    renderStatic(RENDER_STATE_DEFAULT)
                    handleError("Render fault.\n"..message)
                end
            end
        end
    end
end

theme.bg = Color3.fromRGB(255,128,128)

renderStatic(RENDER_STATE_POTATO)


warn("PotatoInjector has injected PotatoMod2!!! wow!!!")

wait(2)

renderStatic(RENDER_STATE_DEFAULT)