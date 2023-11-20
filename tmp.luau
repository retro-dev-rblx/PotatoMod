local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio

local Black = Color3.fromRGB(0,0,0)
local Blue = Color3.fromRGB(0,0,255)
local LightBlue = Color3.fromRGB(0,155,255)
local DarkBack = Color3.fromRGB(40,40,40)
local LightBack = Color3.fromRGB(80,80,80)
local LightBack2 = Color3.fromRGB(120,120,120)
local WhiteText = Color3.fromRGB(240,240,240)
local Outline = Color3.fromRGB(100,100,100)
local SourceSans = Enum.Font.SourceSans

local palletes = {
    dark = {
        bg = Color3.new(0,0,0)
    }
}

palletes["current"] = palletes.dark

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
        if debug then
            guiLayoutUnknown = true
            return nil
        end
    end
    children = splitString(children,".")
    for k, v in pairs(children) do
        if not obj[v] or not obj:IsA("Instance") then
            if debug then
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
local function registerStatic(instance,child, debug)
    debug = debug or false
    if instance and instance[child] then 
        local new = {instance[child],{}}
        staticGuiList[#staticGuiList] = new
        return new
    else
        if debug then
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function registerDynamic(instance, debug)
    debug = debug or false
    if instance then 
        local new = {instance,{}}
        dynamicGuiList[#dynamicGuiList] = new
        return new
    else
        if debug then
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function registerProperty(instance, property, value)
    debug = debug or false
    if instance and instance[1][property] then
        instance[2][property] = {instance[1][property],value}
    else
        if debug then
            guiLayoutUnknown = true
            return nil
        end
    end
end

-- Output
-- Static

local Output = registerStatic(StudioGui,"Output")
if Output then
    registerProperty(Output,"BackGroundColor3",palletes.current.bg)
end


if guiLayoutUnknown == true then
    warn("PotatoMod: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local function renderStatic(state)
    for k,v in pairs(staticGuiList) do
        for property,value in pairs(v[2]) do
            v[1][property] = value
        end
    end
end

renderStatic(RENDER_STATE_POTATO)

print("PotatoInjector has injected PotatoMod!!! wow!!!")