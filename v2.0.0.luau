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
        header = Color3.fromRGB(80,80,80),
        bgl_2 = Color3.fromRGB(120,120,120),
        bg = Color3.fromRGB(40,40,40),
        ol = Color3.fromRGB(100,100,100),
        font = Enum.Font.SourceSans,
        text = Color3.fromRGB(240,240,240),
        text_print = Color3.fromRGB(240,240,240),
        text_info = Color3.fromRGB(0,155,255),
        text_error = Color3.fromRGB(255,0,0),
        text_warn = Color3.fromRGB(255, 128, 0)
    }
}

themes["current"] = themes.dark

local theme = {
    header = "header",
    bgl_2 = "bgl_2",
    bg = "bg",
    ol = "ol",
    font = "font",
    text = "text",
    text_print = "text_print",
    text_info = "text_info",
    text_error = "text_error",
    text_warn = "text_warn"
}



-- PotatoInjector has no script property
local debug = false
if not script then debug = true end

local instanceList = {}

local guiLayoutUnknown = false -- Has the gui been changed/updated?

local function handleError(errorString)
    error("\nPotatoMod2 has died (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
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
            [property]
                {initial, replace}
    3 - dynamic
        [entry]
            1 - connect function
            2 - disconnect function
            3 - arg table
            4 - connections
    Register new object
]]

local currentInst -- Instance to apply property to

-- I made these lowercase to type them easier
local function regnew(instance, child, debug) -- Register a new instance to be modified
    debug = debug or false
    if type(instance) == "table" then instance = instance[1] end
    if instance and getNested(instance,child) then 
        local new = {getNested(instance,child),{},{}} -- {instance, properties, dynamics}
        instanceList[#instanceList+1] = new
        currentInst = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.."."..child.. " is missing!")
            guiLayoutUnknown = true
            currentInst = nil
            return nil
        end
    end
end

local function regprop(property, value, instance, debug) -- Register a static property change
    instance = instance or currentInst
    debug = debug or false
    local set, message = pcall(function()
        if instance then
            instance[2][property] = {instance[1][property],value} -- {initial,replace}
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

local function regdynamic(connectFunc, disconnectFunc, argtable, instance, debug) -- Register a dynamic change
    instance = instance or currentInst
    debug = debug or false
    argtable = argtable or {}

    if instance then
        instance[3][#instance[3]+1] = {connectFunc,disconnectFunc,argtable,{}} -- {connectFunc,disconnectFunc,args,connections}
    else
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end

end


local function dynamicReplacePropertyConnect(instance,entry) -- replace all property [keys] with [value]
    -- argtable
        -- [property]
            -- [original]
                -- = replace
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == init then
                instance[property] = replace
            end
            local connection = instance:GetPropertyChangedSignal(property):Connect(function()
                -- Really hope they don't start fighting over each other for their wanted value! (please don't)
                if instance[property] == init then
                    instance[property] = replace
                end
            end)
            entry[4][#entry[4]+1] = connection
        end
    end
end

local function dynamicReplacePropertyDisconnect(instance,entry) -- kill active replaces and reset to inital value
    for _,connection in pairs(entry[4]) do -- for all connections
        connection:Disconnect()
    end
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == replace then -- if value has been replaced, restore it
                instance[property] = init
            end
        end
    end
end

-- ... used to allow setting static inside of function
local function regfont(...) -- Register a default text change
    regprop("TextColor3",theme.text)
    regprop("Font",theme.font)
end

local function regdefault(...) -- Register a default instance property change
    regprop("BackgroundColor3",theme.bg)
    regprop("BorderColor3",theme.ol)
    if currentInst[1]:IsA("TextLabel") or currentInst[1]:IsA("TextBox") or currentInst[1]:IsA("TextButton") then
        regfont()
    end
end

local function newdefault(instance, child, debug) -- Register a new instance with default properties
    local newStatic = regnew(instance, child, debug)
    if newStatic then
        regdefault()
    end
    return newStatic
end

local function regheader(...)
    -- default x unhovered rbxassetid://13622951236
    -- default x hovered rbxassetid://13622964770
    -- mod x unhovered rbxassetid://16336560641
    -- mod x hovered rbxassetid://16336555516
    regprop("BackgroundColor3",theme.header)
    regprop("BorderColor3",theme.ol)
    regfont()
    local CloseButton = regnew(currentInst,"CloseButton")
    if CloseButton then
        regdynamic(dynamicReplacePropertyConnect,
            dynamicReplacePropertyDisconnect,
            {
                ["Image"] = {
                                ["rbxassetid://13622951236"] = "rbxassetid://16336560641", -- x unhovered
                                ["rbxassetid://13622964770"] = "rbxassetid://16336555516" -- x hovered
                            }
            })
    end
end

-- Custom GUI
if not MenusBar:FindFirstChild("WindowButton") then handleError("Funny thing, the tab that PotatoMod embeds itself into has been removed by the devs!") end
local PotatoModGui = Instance.new("Frame")
PotatoModGui.Name = "PotatoMod"


--Properties
local Properties = newdefault(Windows,"Properties")
if Properties then
    regheader(regnew(Properties,"WindowHeader"))
    local ListOutline = newdefault(Properties,"ListOutline")
    if ListOutline then
        local Header = newdefault(ListOutline,"Header")
        if Header then
            local Frame = regnew(Header,"Frame")
            if Frame then
                regprop("BackgroundColor3",theme.ol)
            end
        end
    end
    local IdentityBackground = regnew(Properties,"IdentityBackground")
    if IdentityBackground then
        regprop("ImageColor3",theme.header)
        local IdentityLabel = regnew(IdentityBackground,"IdentityLabel")
        if IdentityLabel then
            regfont()
        end
    end
    local PropertiesScript = regnew(Properties,"PropertiesScript")
    if PropertiesScript then
        local EnumList = regnew(PropertiesScript,"EnumList")
        if EnumList then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regprop("BackgroundColor3",theme.ol)
            local ScrollingFrame = regnew(EnumList,"Frame.ScrollingFrame")
            if ScrollingFrame then
                regprop("BackgroundColor3",theme.bg)
                local ListItem = regnew(ScrollingFrame,"ListItem")
                if ListItem then
                    regprop("BackgroundColor3",theme.bg)
                    regfont()
                    local TextLabel = regnew(ListItem,"TextLabel")
                    if TextLabel then
                        regfont()
                    end
                end
            end
        end
        local PropertyBrickColorPalette = regnew(PropertiesScript,"PropertyBrickColorPalette")
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
local Toolbar = regnew(Topbar,"ToolBar")
if Toolbar then
    
end

-- TabBar
local TabBar = newdefault(StudioGui,"TabBar")
if TabBar then
    local BottomLine = regnew(TabBar,"BottomLine")
    if BottomLine then
        regprop("BackgroundColor3",theme.ol)
        regprop("BorderColor3",theme.ol)
    end
end

-- Output
local outputColorReplace = {
    [Color3.fromRGB(0,0,0)] = theme.text_print,
    [Color3.fromRGB(0,0,255)] = theme.text_info,
    [Color3.fromRGB(255,128,0)] = theme.text_warn,
    [Color3.fromRGB(255,0,0)] = theme.text_error
}

local function dynamicOutputHandlerConnect(instance,entry)
    -- entry
        -- 4 - list connection (not table)
        -- 5 - TextBox entry table
            -- instance
            -- connection

    entry[5] = {} -- TextBox entries

    local function hookTextBox(TextBox)
        if TextBox:IsA("TextBox") then
            for init,replace in pairs(outputColorReplace) do
                if TextBox.TextColor3 == init then
                    TextBox.TextColor3 = themes.current[replace]
                end
            end
            local connection = TextBox:GetPropertyChangedSignal("TextColor3"):Connect(function()
                for init,replace in pairs(outputColorReplace) do
                    if TextBox.TextColor3 == init then
                        TextBox.TextColor3 = themes.current[replace]
                    end
                end
            end)
            entry[5][#entry[5]+1] = {TextBox,connection}
        end
    end

    for _,TextBox in pairs(instance:GetChildren()) do
        hookTextBox(TextBox)
    end

    local connection = instance.ChildAdded:Connect(function(child)
        hookTextBox(child)
    end)
    entry[4] = connection
end

local function dynamicOutputHandlerDisconnect(instance,entry)
    if not entry[5] then return end -- If we have never connected, no need to disconnect
                                    -- entry 5 is the TextBox entry table
    entry[4]:Disconnect() -- Disconnect if connected
    for _,textEntry in pairs(entry[5]) do -- Disconnect and reset all TextBoxes
        textEntry[2]:Disconnect()
        for init,replace in pairs(outputColorReplace) do
            if textEntry[1].TextColor3 == themes.current[replace] then
                textEntry[1].TextColor3 = init
            end
        end
    end
end

local Output = newdefault(Windows,"Output")
if Output then
    local ListOutline = newdefault(Output,"ListOutline")
    if ListOutline then
        local List = regnew(ListOutline,"List")
        if List then
            regdynamic(dynamicOutputHandlerConnect,
                dynamicOutputHandlerDisconnect)
        end
    end
    regheader(regnew(Output,"WindowHeader"))
end

-- BottomBar
local BottomBar = regnew(StudioGui,"BottomBar")
if BottomBar then
    --print(BottomBar[1].ClassName)
end


if guiLayoutUnknown == true then
    warn("PotatoMod2: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local function renderRegnew(state)
    for k,v in pairs(instanceList) do
        for property,value in pairs(v[2]) do -- Static properties
            local set, message = pcall(function() -- pcall as to not stop after error if can't set property
                if state == RENDER_STATE_DEFAULT then
                    v[1][property] = value[state]
                else
                    v[1][property] = themes.current[value[state]]
                end
            end)
            if not set then
                if state ~= RENDER_STATE_DEFAULT then
                    renderRegnew(RENDER_STATE_DEFAULT)
                    handleError("Error during render stage.\n"..message)
                end
            end
        end
        for _,entry in pairs(v[3]) do -- Dynamic properties
            local set, message = pcall(function() -- pcall as to not stop after error
                if state == RENDER_STATE_DEFAULT then
                    entry[2](v[1],entry) -- Disconnect
                else
                    entry[2](v[1],entry) -- Disconnect
                    entry[1](v[1],entry) -- Connect
                end
            end)
            if not set then
                if state ~= RENDER_STATE_DEFAULT then
                    renderRegnew(RENDER_STATE_DEFAULT)
                    handleError("Error during hook stage.\n"..message)
                end
            end
        end
    end
end

theme.bg = Color3.fromRGB(255,128,128)

renderRegnew(RENDER_STATE_POTATO)


warn("PotatoInjector has injected PotatoMod2!!! wow!!!")

task.wait(2)

renderRegnew(RENDER_STATE_DEFAULT)