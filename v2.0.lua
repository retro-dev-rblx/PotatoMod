-- PotatoMod v2.1 created by NicePotato (.nicepotato)
-- Credits to Cristiano and Ayray for letting this project exist
-- Credits to ayray for helping during development

-- Mind my spaghetti (much less than v1 though lol)

-- TODO remake dropdown arrow for theme (toolbox)
-- TODO hook tabs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GetSettings = ReplicatedStorage.RemoteFunctions.GetPotatoModSettings
local SetSettings = ReplicatedStorage.RemoteEvents.SetPotatoModSettings

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui:WaitForChild("StudioGui",5) -- The GUI of the studio
local Windows = StudioGui:WaitForChild("Windows",5) -- The main windows of the studio
local Topbar = StudioGui:WaitForChild("Topbar",5)
local MenusBar = Topbar:WaitForChild("MenusBar",5)

local themes = {
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

local theme = {
    header = "header",
    bg = "bg",
    ol = "ol",
    font = "font",
    font_bold = "font_bold",
    text = "text",
    text_print = "text_print",
    text_info = "text_info",
    text_error = "text_error",
    text_warn = "text_warn",
    zebra_1 = "zebra_1",
    zebra_2 = "zebra_2",
    scrollback = "scrollback",
    scrollbar = "scrollbar"
}

-- PotatoInjector has no script property
local maindebug = false
if not script then
    warn("PotatoInjector has injected PotatoMod2!!! wow!!!")
    maindebug = true
end

local instanceList = {}

local guiLayoutUnknown = false -- Has the gui been changed/updated?

local function handleError(errorString)
    error("\nPotatoMod2 has crashed (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
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
            end
            return nil
        end
        obj = obj[v]
    end
    return obj
end

-- Handle Settings

local function serialize(data)
    if typeof(data) == "Color3" then
        return {
            SerializedType = "Color3",
            r = data.r,
            g = data.g,
            b = data.b
        }
    end
    if typeof(data) == "EnumItem" then
        return data.Value
    end
    return data -- Data does not need to be serialized
end

local function deserialize(data)
    if type(data) == "table" then
        local dataType = data["SerializedType"]
        if dataType then -- Is this data serialized?
            if dataType == "Color3" then
                return Color3.new(data.r,data.g,data.b)
            end
        else
            return data -- Table is not serialized data
        end
    else
        return data -- Data is not serialized data
    end
end

local function serializeTable(inTable,recurse)
    recurse = recurse or 0
    if recurse >= 1000 then
        warn("Warning: Table serializer overflow! Data may be corrupted.")
        return
    end
    local outTable = {}
    for k,v in pairs(inTable) do
        k = serialize(k)
        v = serialize(v)
        if type(k) == "table" then
            k = serializeTable(k,recurse+1)
        end
        if type(v) == "table" then
            v = serializeTable(v,recurse+1)
        end
        outTable[k] = v
    end
    return outTable
end

local function deserializeTable(inTable,recurse)
    recurse = recurse or 0
    if recurse >= 1000 then
        warn("Warning: Table deserializer overflow! Data may be corrupted.")
        return
    end
    local outTable = {}
    for k,v in pairs(inTable) do
        k = deserialize(k) -- Key may be serialized data
        v = deserialize(v) -- Value may be serialized data
        if type(k) == "table" then
            k = deserializeTable(k,recurse+1)
        end
        if type(v) == "table" then
            v = deserializeTable(v,recurse+1)
        end
        outTable[k] = v
    end
    return outTable
end

local Settings = deserializeTable(GetSettings:InvokeServer())

local function printTable(table,depth, key)
    depth = depth or 1

    local function textBrackets()
        if typeof(table) == "Instance" then
            if #table:GetChildren() == 0 then
                return "{}"
            else
                return "{"
            end
        else
            if #table == 0 then
                return "{}"
            else
                return "{"
            end
        end
    end
    if typeof(table) == "Instance" then
        if key then
            print(string.rep("  ",depth-1).."["..tostring(key).."] = <["..table.ClassName..":"..table.Name.."]> = "..textBrackets())
        else
            print(string.rep("  ",depth-1).."<["..table.ClassName..":"..table.Name.."]> = "..textBrackets())
        end
        table = table:GetChildren()
    else
        if key then
            print(string.rep("  ",depth-1).."["..tostring(key).."] = "..textBrackets())
        else
            print(string.rep("  ",depth-1)..textBrackets())
        end
    end
    for k,v in pairs(table) do
        if type(v) == "table" or typeof(v) == "Instance" then
            printTable(v,depth+1,k)
        else
            print(string.rep("  ",depth).."["..tostring(k).."] = "..tostring(v))
        end
    end
    if #table > 0 then
        print(string.rep("  ",depth-1).."}")
    end
end

local settingsVersion = 4

local defaultSettings = {
    version = settingsVersion,
    toggles = {
        autoLaunch = false,
        enableTheme = true
    },
    themedata = {
        current = "dark",
        customTheme = {}
    },
    used_before = false
}

for k,v in pairs(themes.dark) do
    defaultSettings.themedata.customTheme[k] = v
end


if not Settings["version"] or Settings["version"] < settingsVersion then
    Settings = defaultSettings
end

themes["current"] = themes[Settings.themedata.current]

local last_save = 0
local function SaveSettings(force)
    force = force or false

    if os.clock() - last_save >= 1 or force then
        last_save = os.clock()
        SetSettings:FireServer(serializeTable(Settings))
    end
end

--[[ docs probably outdated lol
    1 - instance
    2 - theme
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
    4 - property
        1 - default
        2 - potato
            [property]
                {initial, replace}
    5 - delete?
    Register new object
]]

local currentInst -- Instance to apply property to

local PotatoTab

local function registerStudio()

-- I made these lowercase to type them easier

local function newreg(instance, child, debug) -- Register a new instance to be modified
    if type(instance) == "table" then instance = instance[1] end
    if instance and getNested(instance,child,debug) then 
        local new = {getNested(instance,child,debug),{},{},{}} -- {instance, themeProperties, dynamics, properties}
        instanceList[#instanceList+1] = new
        currentInst = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance:GetFullName().."."..child.. " is missing!")
            guiLayoutUnknown = true
            currentInst = nil
            return nil
        end
    end
end

local function newself(instance,debug)
    debug = debug or false
    if instance then 
        local new = {instance,{},{},{}} -- {instance, themeProperties, dynamics, properties}
        instanceList[#instanceList+1] = new
        currentInst = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance:GetFullName().. " is missing!")
            guiLayoutUnknown = true
            currentInst = nil
            return nil
        end
    end
end

local function regtheme(property, value, instance, debug) -- Register a static property theme change
    -- This takes keys for the theme table
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

local function regprop(property, value, instance, debug) -- Register a static property change
    -- This is the exact same as theme change, but it gets rendered in another step
    -- This takes any arbitrary value
    instance = instance or currentInst
    debug = debug or false
    local set, message = pcall(function()
        if instance then
            instance[4][property] = {instance[1][property],value} -- {initial,replace}
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
        instance[3][#instance[3]+1] = {connectFunc,disconnectFunc,argtable} -- {connectFunc,disconnectFunc,args}
    else
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function marktemp(instance, debug) -- Mark to be deleted
    instance = instance or currentInst
    debug = debug or false
    instance[5] = true
end

local function dynamicReplaceThemeConnect(instance,entry) -- replace all theme property [keys] with [value]
    -- argtable
        -- [property]
            -- [original]
                -- = replace
    
    entry[4] = {} -- Connections

    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == init then
                instance[property] = themes.current[replace]
            end
            local connection = instance:GetPropertyChangedSignal(property):Connect(function()
                -- Really hope they don't start fighting over each other for their wanted value! (please don't)
                if instance[property] == init then
                    instance[property] = themes.current[replace]
                end
            end)
            entry[4][#entry[4]+1] = connection
        end
    end
end

local function dynamicReplaceThemeDisconnect(instance,entry) -- kill active replaces and reset to inital value
    if not entry[4] then return end -- If not connected, can't disconnect
    for _,connection in pairs(entry[4]) do -- for all connections
        connection:Disconnect()
    end
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == themes.current[replace] then -- if value has been replaced, restore it
                instance[property] = init
            end
        end
    end
end

local function dynamicReplacePropertyConnect(instance,entry) -- replace all property [keys] with [value]
    -- argtable
        -- [property]
            -- [original]
                -- = replace

    entry[4] = {} -- Connections

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
    if not entry[4] then return end -- If not connected, can't disconnect
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
    regtheme("TextColor3",theme.text)
    regtheme("Font",theme.font)
end

local function regdefault(...) -- Register a default instance property change
    regtheme("BackgroundColor3",theme.bg)
    regtheme("BorderColor3",theme.ol)
    if currentInst[1]:IsA("TextLabel") or currentInst[1]:IsA("TextBox") or currentInst[1]:IsA("TextButton") then
        regfont()
    end
end

local function newdefaultself(instance, debug)
    local newStatic = newself(instance, debug)
    if newStatic then
        regdefault()
    end
    return newStatic
end

local function newdefault(instance, child, debug) -- Register a new instance with default properties
    local newStatic = newreg(instance, child, debug)
    if newStatic then
        regdefault() -- Register default theme properties
    end
    return newStatic
end

local function regheader(...)
    -- default x unhovered rbxassetid://13622951236
    -- default x hovered rbxassetid://13622964770
    -- mod x unhovered rbxassetid://16336560641
    -- mod x hovered rbxassetid://16336555516
    regtheme("BackgroundColor3",theme.header)
    regtheme("BorderColor3",theme.ol)
    regfont()
    local CloseButton = newreg(currentInst,"CloseButton")
    if CloseButton then
        regtheme("ImageColor3",theme.text)
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

local function newheader(instance, child, debug) -- Register a new header
    local newHeader = newself(instance[1]:WaitForChild(child, 5))
    if newHeader then
        regheader()
    else
        warn("PotatoMod2: Headers are misplaced, buggy behaviour will ensue")
    end
    return newHeader
end

local function regscrollbar(...)
    -- mod scroll arrow - rbxassetid://16434877920
    local function hideSomeStuff(Bar)
        local SemiHover = newreg(Bar,"SemiHover")
        if SemiHover then
            regprop("Image","")
            regprop("BackgroundTransparency",1)
        end
        local Hover = newreg(Bar,"Hover")
        if Hover then
            regprop("Image","")
            regprop("BackgroundTransparency",1)
        end
        local Down = newreg(Bar,"Down")
        if Down then
            regprop("Image","")
            regprop("BackgroundTransparency",1)
        end
    end
    local Scrollbar = currentInst
    regtheme("BackgroundColor3",theme.scrollback)
    regtheme("BorderColor3",theme.ol)
    local Vertical = newreg(Scrollbar,"Vertical")
    if Vertical then
        local DownButton = newreg(Vertical,"DownButton")
        if DownButton then
            hideSomeStuff(DownButton)
            local NewArrow = newself(Instance.new("ImageLabel"))
            if NewArrow then
                marktemp()
                regtheme("BackgroundColor3",theme.scrollbar)
                regtheme("BorderColor3",theme.scrollbar)
                NewArrow[1].Parent = DownButton[1]
                NewArrow[1].ZIndex = 5
                NewArrow[1].Size = DownButton[1].Size
                NewArrow[1].Active = false
                NewArrow[1].Rotation = 0
                NewArrow[1].Image = "rbxassetid://16434877920"
                NewArrow[1].Visible = false
            end
        end
        local UpButton = newreg(Vertical,"UpButton")
        if UpButton then
            hideSomeStuff(UpButton)
            local NewArrow = newself(Instance.new("ImageLabel"))
            if NewArrow then
                marktemp()
                regtheme("BackgroundColor3",theme.scrollbar)
                regtheme("BorderColor3",theme.scrollbar)
                NewArrow[1].Parent = UpButton[1]
                NewArrow[1].ZIndex = 5
                NewArrow[1].Size = UpButton[1].Size
                NewArrow[1].Active = false
                NewArrow[1].Rotation = 180
                NewArrow[1].Image = "rbxassetid://16434877920"
                NewArrow[1].Visible = false
            end
        end
        local BarExtents = newreg(Vertical,"BarExtents")
        if BarExtents then
            regprop("ImageTransparency",1)
            local Bar = newreg(BarExtents,"Bar")
            if Bar then -- I'd prefer not to replace the image, however it's most efficient here
                regprop("Image","")
                regprop("BackgroundTransparency",0)
                regprop("AutoButtonColor",true)
                regtheme("BackgroundColor3",theme.scrollbar)
                regtheme("BorderColor3",theme.ol)
                hideSomeStuff(Bar)
                local Thing = newreg(Bar,"Thing")
                if Thing then
                    regprop("Image","")
                    regprop("BackgroundTransparency",1)
                    hideSomeStuff(Thing)
                end
            end
        end
        local LeftBorder = newreg(Vertical,"LeftBorder")
        if LeftBorder then
            regtheme("BackgroundColor3",theme.ol)
        end
        local RightBorder = newreg(Vertical,"RightBorder")
        if RightBorder then
            regtheme("BackgroundColor3",theme.ol)
        end
    end
    local Horizontal = newreg(Scrollbar,"Horizontal")
    if Horizontal then
        local LeftButton = newreg(Horizontal,"LeftButton")
        if LeftButton then
            hideSomeStuff(LeftButton)
            local NewArrow = newself(Instance.new("ImageLabel"))
            if NewArrow then
                marktemp()
                regtheme("BackgroundColor3",theme.scrollbar)
                regtheme("BorderColor3",theme.scrollbar)
                NewArrow[1].Parent = LeftButton[1]
                NewArrow[1].ZIndex = 5
                NewArrow[1].Size = LeftButton[1].Size
                NewArrow[1].Active = false
                NewArrow[1].Rotation = 90
                NewArrow[1].Image = "rbxassetid://16434877920"
                NewArrow[1].Visible = false
            end
        end
        local RightButton = newreg(Horizontal,"RightButton")
        if RightButton then
            hideSomeStuff(RightButton)
            local NewArrow = newself(Instance.new("ImageLabel"))
            if NewArrow then
                marktemp()
                regtheme("BackgroundColor3",theme.scrollbar)
                regtheme("BorderColor3",theme.scrollbar)
                NewArrow[1].Parent = RightButton[1]
                NewArrow[1].ZIndex = 5
                NewArrow[1].Size = RightButton[1].Size
                NewArrow[1].Active = false
                NewArrow[1].Rotation = -90
                NewArrow[1].Image = "rbxassetid://16434877920"
                NewArrow[1].Visible = false
            end
        end
        local BarExtents = newreg(Horizontal,"BarExtents")
        if BarExtents then
            regprop("ImageTransparency",1)
            local Bar = newreg(BarExtents,"Bar")
            if Bar then -- I'd prefer not to replace the image, however it's most efficient here
                regprop("Image","")
                regprop("BackgroundTransparency",0)
                regprop("AutoButtonColor",true)
                regtheme("BackgroundColor3",theme.scrollbar)
                regtheme("BorderColor3",theme.ol)
                hideSomeStuff(Bar)
                local Thing = newreg(Bar,"Thing")
                if Thing then
                    regprop("Image","")
                    regprop("BackgroundTransparency",1)
                    hideSomeStuff(Thing)
                end
            end
        end
        local LowerBorder = newreg(Horizontal,"LowerBorder")
        if LowerBorder then
            regtheme("BackgroundColor3",theme.ol)
        end
        local UpperBorder = newreg(Horizontal,"UpperBorder")
        if UpperBorder then
            regtheme("BackgroundColor3",theme.ol)
        end
    end
end

local function newscrollbar(instance, child, debug) -- Register a new scrolbar
    local newScrollbar = newreg(instance, child, debug)
    if newScrollbar then
        regscrollbar()
    end
    return newScrollbar
end

-- PotatoMod Gui
PotatoTab = MenusBar:FindFirstChild("WindowButton")
if PotatoTab then
    PotatoTab.Size = UDim2.new(0,69,1,0)
    local TextLabel = PotatoTab.TextLabel
    TextLabel.Text = "PotatoMod"
    PotatoTab.MenuFrame.Visible = false
    PotatoTab.MenuFrame.Background.Visible = true

    local PotatoFrame = Instance.new("Frame")
    PotatoFrame.Size = UDim2.new(1,0,1,0)
    PotatoFrame.BackgroundColor3 = themes.dark.bg
    PotatoFrame.BorderColor3 = themes.dark.ol
    PotatoFrame.Name = "PotatoFrame"
    PotatoFrame.Parent = PotatoTab.MenuFrame.Background

    local LazyTipLol = Instance.new("TextLabel")
    LazyTipLol.Text = [[proper gui coming soon to a PotatoMod2 near you
(I am too lazy rn sorry, be happy with a new version)
credits to NicePotato (me), Ayray, and Cristiano]]
    LazyTipLol.Parent = PotatoFrame
    LazyTipLol.TextColor3 = themes.dark.text
    LazyTipLol.TextSize = 16
    LazyTipLol.Font = themes.dark.font
    LazyTipLol.BackgroundTransparency = 1
    LazyTipLol.Size = UDim2.new(0,300,0,50)
    LazyTipLol.Position = UDim2.new(0,5,0,0)
    LazyTipLol.TextXAlignment = "Left"

    local AutoInjectText = Instance.new("TextLabel")
    AutoInjectText.Text = "Auto Launch"
    AutoInjectText.Parent = PotatoFrame
    AutoInjectText.TextColor3 = themes.dark.text
    AutoInjectText.TextSize = 16
    AutoInjectText.Font = themes.dark.font
    AutoInjectText.BackgroundTransparency = 1
    AutoInjectText.Size = UDim2.new(0,80,0,20)
    AutoInjectText.Position = UDim2.new(0,5,0,55)
    AutoInjectText.TextXAlignment = "Left"

    local function renderButtonState(button, state)
        if state then
            button.Position = UDim2.new(0,22,0,2)
            button.BackgroundColor3 = Color3.fromRGB(25,235,25)
            button.BorderColor3 = Color3.fromRGB(25,235,25)
        else
            button.Position = UDim2.new(0,2,0,2)
            button.BackgroundColor3 = Color3.fromRGB(255,25,25)
            button.BorderColor3 = Color3.fromRGB(235,25,25)
        end
    end

    local AutoInjectButton = Instance.new("TextButton")
    AutoInjectButton.Text = ""
    AutoInjectButton.BackgroundColor3 = themes.dark.bg
    AutoInjectButton.BorderColor3 = themes.dark.ol
    AutoInjectButton.Size = UDim2.new(0,40,0,20)
    AutoInjectButton.Position = UDim2.new(0,85,0,0)
    AutoInjectButton.Parent = AutoInjectText

    local AutoInjectSwitch = Instance.new("Frame")
    
    AutoInjectSwitch.Size = UDim2.new(0,16,0,16)
    AutoInjectSwitch.BorderMode = Enum.BorderMode.Inset
    AutoInjectSwitch.BorderSizePixel = 2
    AutoInjectSwitch.Active = false
    AutoInjectSwitch.Parent = AutoInjectButton

    renderButtonState(AutoInjectSwitch, Settings.toggles["autoLaunch"])


    AutoInjectButton.MouseButton1Click:Connect(function()
        Settings.toggles["autoLaunch"] = not Settings.toggles["autoLaunch"]
        renderButtonState(AutoInjectSwitch, Settings.toggles["autoLaunch"])
        SaveSettings()
    end)

else
    handleError("Funny thing, the tab that PotatoMod embeds itself into has been removed by the devs! (this is not good)")
end

-- CodeEditorLocal

-- TitleBar


-- Toolbox
local Toolbox = newdefault(Windows,"Toolbox")
if Toolbox then
    newheader(Toolbox,"WindowHeader")
    
    local EmbedOutline = newdefault(Toolbox,"EmbedOutline")
    if EmbedOutline then
        local ListFrame = newreg(EmbedOutline,"ListFrame")
        if ListFrame then
            local List = newdefault(ListFrame,"List")
            if List then
                regprop("BackgroundTransparency",0)
                for _,child in pairs(List[1]:GetChildren()) do
                    if child:isA("Frame") then
                        local Model = newdefaultself(child)
                        if Model then
                            newdefault(Model,"TextLabel")
                            newdefault(Model,"ImageLabel")
                        end
                    end
                end
            end
            newscrollbar(ListFrame,"ScrollbarBackground")
        end
        local Controls = newdefault(EmbedOutline,"Controls")
        if Controls then
            local InventoryControls = newdefault(Controls,"InventoryControls")
            if InventoryControls then
                local Border = newreg(InventoryControls,"Border")
                if Border then
                    regtheme("BackgroundColor3",theme.ol)
                    regtheme("BorderColor3",theme.ol)
                end
                local SortLabel = newdefault(InventoryControls,"SortLabel")
                if SortLabel then
                    local DropdownButton = newdefault(SortLabel,"DropdownButton")
                    if DropdownButton then
                        -- TODO remake dropdown arrow for theme
                    end
                    local DropdownList = newdefault(SortLabel,"DropdownList")
                    if DropdownList then
                        for _,child in pairs(DropdownList[1]:GetChildren()) do
                            if child:isA("TextButton") then
                                newdefaultself(child)
                            end
                        end
                    end
                end
            end
            local SearchControls = newreg(Controls,"SearchControls")
            if SearchControls then
                local SearchBackground = newreg(SearchControls,"SearchBackground")
                if SearchBackground then
                    regprop("BackgroundTransparency",1)
                end
                newdefault(SearchControls,"SearchBar")
                local Border = newreg(InventoryControls,"Border")
                if Border then
                    regtheme("BackgroundColor3",theme.ol)
                    regtheme("BorderColor3",theme.ol)
                end
                local DisplayLabel = newreg(SearchControls,"DisplayLabel")
                if DisplayLabel then
                    local DropdownButton = newdefault(DisplayLabel,"DropdownButton")
                    if DropdownButton then
                        -- TODO remake dropdown arrow for theme
                    end
                    local DropdownList = newdefault(DisplayLabel,"DropdownList")
                    if DropdownList then
                        for _,child in pairs(DropdownList[1]:GetChildren()) do
                            if child:isA("TextButton") then
                                newdefaultself(child)
                            end
                        end
                    end
                end
            end
            
            local Tabs = newreg(Controls,"Tabs")
            if Tabs then
                regtheme("BackgroundColor3",theme.header)
                regtheme("BorderColor3",theme.ol)
                local replaceColors = {
                    ["BackgroundColor3"] = {
                        [Color3.fromRGB(240,240,240)] = theme.bg,
                        [Color3.fromRGB(201,201,201)] = theme.header
                    }
                }
                local Inventory = newreg(Tabs,"Inventory")
                if Inventory then
                    regtheme("BorderColor3",theme.ol)
                    regfont()
                    regdynamic(dynamicReplaceThemeConnect,
                        dynamicReplaceThemeDisconnect,
                        replaceColors)
                end
                local Search = newreg(Tabs,"Search")
                if Search then
                    regtheme("BorderColor3",theme.ol)
                    regfont()
                    regdynamic(dynamicReplaceThemeConnect,
                        dynamicReplaceThemeDisconnect,
                        replaceColors)
                end
            end
        end
    end
end 

-- BasicObjects
local function dynamicBasicObjectsHandlerConnect(instance, entry)
    entry[5] = {} -- ObjectName
    entry[6] = {} -- Instance Entries

    local function recolorTextLabel(TextLabel)
        if TextLabel.Parent.MouseOverHighlight.Visible then -- Hovered
            TextLabel.TextColor3 = Color3.new(0,0,0)
        elseif TextLabel.Parent.SelectionHighlight.Visible then -- Selected
            TextLabel.TextColor3 = Color3.new(1,1,1)
        else
            TextLabel.TextColor3 = themes.current["text"]
        end
    end

    local function hookTextLabel(TextLabel)
        if TextLabel:IsA("TextLabel") then
            TextLabel.Font = themes.current["font"]
            TextLabel.Parent.NoteLabel.Font = themes.current["font"]
            TextLabel.Parent.NoteLabel.TextColor3 = themes.current["text"]
            recolorTextLabel(TextLabel)
            local textConnection = TextLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local selectConnection = TextLabel.Parent.SelectionHighlight:GetPropertyChangedSignal("Visible"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local hoverConnection = TextLabel.Parent.MouseOverHighlight:GetPropertyChangedSignal("Visible"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            entry[5][#entry[5]+1] = {TextLabel,textConnection,selectConnection,hoverConnection}
        end
    end

    local function recolorInstance(instance)
        if instance.BackgroundColor3 == Color3.new(1,1,1) then
            instance.BackgroundColor3 = themes.current["zebra_1"]
        elseif instance.BackgroundColor3 == Color3.fromRGB(246,246,246) then
            instance.BackgroundColor3 = themes.current["zebra_2"]
        end
    end

    local function hookInstance(instance)
        recolorInstance(instance)
        local textConnection = instance:GetPropertyChangedSignal("TextColor3"):Connect(function()
            recolorTextLabel(instance)
        end)
        local bgConnection = instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            recolorInstance(instance)
        end)
        entry[6][#entry[6]+1] = {instance,textConnection,bgConnection}
    end

    for _,child in pairs(instance:GetChildren()) do
        if child:IsA("TextButton") then
            hookInstance(child)
            if child:FindFirstChild("ObjectName") then
                hookTextLabel(child.ObjectName)
            end
        end
    end
    local connection = instance.ChildAdded:Connect(function(child)
        if child:IsA("TextButton") then
            hookInstance(child)
            if child:FindFirstChild("ObjectName") then
                hookTextLabel(child.ObjectName)
            end
        end
    end)
    entry[4] = connection
end

local function dynamicBasicObjectsHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect()
    for _,TextLabel in pairs(entry[5]) do 
        TextLabel[2]:Disconnect() -- TextColor listener
        TextLabel[3]:Disconnect() -- Selection listener
        TextLabel[4]:Disconnect() -- MouseOver listener
        if TextLabel[1] then
            TextLabel[1].Font = Enum.Font.SourceSans
            TextLabel[1].Parent.NoteLabel.Font = Enum.Font.SourceSans
            TextLabel[1].Parent.NoteLabel.TextColor3 = Color3.new(0.5,0.5,0.5)
            if TextLabel[1].Parent.MouseOverHighlight.Visible then -- Hovered
                TextLabel[1].TextColor3 = Color3.new(0,0,0)
            elseif TextLabel[1].Parent.SelectionHighlight.Visible then -- Selected
                TextLabel[1].TextColor3 = Color3.new(1,1,1)
            else
                TextLabel[1].TextColor3 = Color3.new(0,0,0)
            end
        end
    end
    for _,InstanceEntry in pairs(entry[6]) do
        InstanceEntry[2]:Disconnect() -- Text listener
        InstanceEntry[3]:Disconnect() -- BG listener
        if InstanceEntry[1] then
            if InstanceEntry[1].BackgroundColor3 == themes.current["zebra_1"] then
                InstanceEntry[1].BackgroundColor3 = Color3.new(1,1,1)
            elseif InstanceEntry[1].BackgroundColor3 == themes.current["zebra_2"] then
                InstanceEntry[1].BackgroundColor3 = Color3.fromRGB(246,246,246)
            end
        end
    end
end

local BasicObjects = newdefault(Windows,"Basic Objects")
if BasicObjects then

    newheader(BasicObjects,"WindowHeader")
    local ListOutline = newdefault(BasicObjects,"ListOutline")
    if ListOutline then
        local List = newdefault(ListOutline,"List")
        if List then
            regprop("BackgroundTransparency",0)
            regdynamic(dynamicBasicObjectsHandlerConnect,
                dynamicBasicObjectsHandlerDisconnect)
        end
        newscrollbar(ListOutline,"ScrollbarBackground")
    end
    local SearchBar = newreg(BasicObjects,"SearchBar")
    if SearchBar then
        regprop("ImageTransparency",1)
        regtheme("BackgroundColor3",theme.bg)
        regtheme("BorderColor3",theme.ol)
    end
    regdefault(BasicObjects,"BasicObjectsScript.ItemTemplate")
    newdefault(BasicObjects,"SelectText")
end

-- Explorer
local function dynamicExplorerHandlerConnect(instance, entry)
    entry[5] = {} -- ObjectName

    local function recolorTextLabel(TextLabel)
        if TextLabel.Parent.ImageTransparency == 1 then -- Unhovered
            TextLabel.TextColor3 = themes.current["text"]
        elseif TextLabel.Parent.Image == "rbxassetid://6381376761" then -- Hovered
            TextLabel.TextColor3 = Color3.new(0,0,0)
        elseif TextLabel.Parent.Image == "rbxassetid://6381375977" then -- Selected
            TextLabel.TextColor3 = Color3.new(1,1,1)
        end
    end

    local function hookTextLabel(TextLabel)
        if TextLabel:IsA("TextLabel") then
            local self_entry = #entry[5]+1
            TextLabel.Font = themes.current["font"]
            recolorTextLabel(TextLabel)
            local textConnection = TextLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local imageConnection = TextLabel.Parent:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            TextLabel.Destroying:Connect(function()
                entry[5][self_entry] = nil
            end)
            entry[5][self_entry] = {TextLabel,textConnection,imageConnection}
        end
    end

    for _,child in pairs(instance:GetChildren()) do
        if child:IsA("ImageLabel") then
            if child:FindFirstChild("ObjectName") then
                hookTextLabel(child.ObjectName)
            end
        end
    end
    local connection = instance.ChildAdded:Connect(function(child)
        if child:FindFirstChild("ObjectName") then
            hookTextLabel(child.ObjectName)
        end
    end)
    entry[4] = connection
end

local function dynamicExplorerHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect()
    for _,TextLabel in pairs(entry[5]) do 
        TextLabel[2]:Disconnect() -- TextColor listener
        TextLabel[3]:Disconnect() -- Selection listener
        if TextLabel[1] then
            TextLabel[1].Font = Enum.Font.SourceSans
            if TextLabel[1].Parent.ImageTransparency == 1 then -- Unhovered
                TextLabel[1].TextColor3 = Color3.new(0,0,0)
            elseif TextLabel[1].Parent.Image == "rbxassetid://6381376761" then -- Hovered
                TextLabel[1].TextColor3 = Color3.new(0,0,0)
            elseif TextLabel[1].Parent.Image == "rbxassetid://6381375977" then -- Selected
                TextLabel[1].TextColor3 = Color3.new(1,1,1)
            end
        end
    end
end

local Explorer = newdefault(Windows,"Explorer")
if Explorer then
    newheader(Explorer,"WindowHeader")
    local ListOutline = newdefault(Explorer,"ListOutline")
    if ListOutline then
        local Explorer = newreg(ListOutline,"Explorer")
        if Explorer then
            regdynamic(dynamicExplorerHandlerConnect,
                dynamicExplorerHandlerDisconnect)
        end
        newscrollbar(ListOutline,"ScrollbarBackground")
    end
end


--Properties
local function dynamicPropertiesHandlerConnect(instance, entry)
    entry[5] = {} -- Property Names
    entry[6] = {} -- Property Entries
    entry[7] = {} -- Category Headers

    local function recolorTextLabel(TextLabel)
        local function recolorValueHalf(color)
            local ValueHalf = TextLabel.Parent.Parent.ValueHalf
            for _,child in pairs(ValueHalf:GetChildren()) do
                if child:IsA("TextBox") or child.Name == "EnumText" or child.name == "BrickColorText" then
                    child.TextColor3 = color
                end
            end
        end

        if TextLabel.Parent.Parent.SelectionHighlight.Visible then -- Selected
            TextLabel.TextColor3 = Color3.new(1,1,1)
            recolorValueHalf(Color3.new(0,0,0))
        elseif TextLabel.Parent.Parent.MouseOverHighlight.Visible then -- Hovered
            TextLabel.TextColor3 = Color3.new(0,0,0)
            recolorValueHalf(Color3.new(0,0,0))
        else
            TextLabel.TextColor3 = themes.current["text"]
            recolorValueHalf(themes.current["text"])
        end
    end

    local function hookPropertyName(TextLabel)
        local self_entry = #entry[5]+1
        if TextLabel:IsA("TextLabel") then
            TextLabel.Font = themes.current["font"]
            recolorTextLabel(TextLabel)
            local textConnection = TextLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local selectConnection = TextLabel.Parent.Parent.SelectionHighlight:GetPropertyChangedSignal("Visible"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local hoverConnection = TextLabel.Parent.Parent.MouseOverHighlight:GetPropertyChangedSignal("Visible"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local EnumText = TextLabel.Parent.Parent.ValueHalf:FindFirstChild("EnumText") or TextLabel.Parent.Parent.ValueHalf:FindFirstChildOfClass("TextBox")
            local enumConnection
            if EnumText then
                enumConnection = EnumText:GetPropertyChangedSignal("TextColor3"):Connect(function()
                    recolorTextLabel(TextLabel)
                end)
            end
            entry[5][self_entry] = {TextLabel,textConnection,selectConnection,hoverConnection,enumConnection}

            return self_entry
        end
    end

    local function recolorPropertyBG(instance)
        if instance.BackgroundColor3 == Color3.new(1,1,1) then
            instance.BackgroundColor3 = themes.current["zebra_1"]
        elseif instance.BackgroundColor3 == Color3.fromRGB(246,246,246) then
            instance.BackgroundColor3 = themes.current["zebra_2"]
        end
    end

    local function hookProperty(instance)
        local self_entry = #entry[6]+1

        for _,child in pairs(instance:GetChildren()) do
            if child.Name == "Outline" then
                child.BackgroundColor3 = themes.current.ol
            end
        end

        recolorPropertyBG(instance)

        instance.BorderColor3 = themes.current.ol
        instance.PropertyHalf.Outline.BackgroundColor3 = themes.current.ol
        local name_entry = hookPropertyName(instance.PropertyHalf.TextLabel)
        local bgConnection = instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            recolorPropertyBG(instance)
        end)
        instance.Destroying:Connect(function()
            entry[5][name_entry] = nil
            entry[6][self_entry] = nil
        end)
        entry[6][self_entry] = {instance,bgConnection}
    end

    local function recolor1Topbar(Topbar)
        Topbar.BackgroundColor3 = themes.current.header
        if Topbar.HoverGlow.Visible then
            Topbar.CategoryName.TextColor3 = Color3.new(0,0,0)
        else
            Topbar.CategoryName.TextColor3 = themes.current.text
        end
    end

    local function hookCategoryHeader(instance)
        local self_entry = #entry[7]+1

        recolor1Topbar(instance)
        local topbar_connection = instance.HoverGlow:GetPropertyChangedSignal("Visible"):Connect(function()
            recolor1Topbar(instance)
        end)

        instance.Destroying:Connect(function()
            entry[7][self_entry] = nil
        end)

        entry[7][self_entry] = {instance, topbar_connection}
    end

    local function hookCategoryTemplate(child)
        if child.Name == "CategoryTemplate" then
            for _,child in pairs(child:GetChildren()) do
                if child:IsA("Frame") then
                    if child:FindFirstChild("CategoryName") then
                        hookCategoryHeader(child)
                    else
                        hookProperty(child)
                    end
                end
            end
        end
    end

    for _,child in pairs(instance:GetChildren()) do
        hookCategoryTemplate(child)
    end
    local connection = instance.ChildAdded:Connect(function(child)
        hookCategoryTemplate(child)
    end)
    entry[4] = connection
end

local function dynamicPropertiesHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect()

    for _,TextLabel in pairs(entry[5]) do 
        TextLabel[2]:Disconnect() -- TextColor listener
        TextLabel[3]:Disconnect() -- Selection listener
        TextLabel[4]:Disconnect() -- MouseOver listener
        if TextLabel[5] then TextLabel[5]:Disconnect() end -- EnumText listener
        if TextLabel[1] then
            local function recolorValueHalf(color)
                local ValueHalf = TextLabel[1].Parent.Parent.ValueHalf
                for _,child in pairs(ValueHalf:GetChildren()) do
                    if child:IsA("TextBox") or child.Name == "EnumText" or child.name == "BrickColorText" then
                        child.TextColor3 = color
                    end
                end
            end

            TextLabel[1].Font = Enum.Font.SourceSans
            if TextLabel[1].Parent.Parent.MouseOverHighlight.Visible then -- Hovered
                TextLabel[1].TextColor3 = Color3.new(0,0,0)
                recolorValueHalf(Color3.new(0,0,0))
            elseif TextLabel[1].Parent.Parent.SelectionHighlight.Visible then -- Selected
                TextLabel[1].TextColor3 = Color3.new(1,1,1)
                recolorValueHalf(Color3.new(1,1,1))
            else
                TextLabel[1].TextColor3 = Color3.new(0,0,0)
                recolorValueHalf(Color3.new(0,0,0))
            end
        end
    end
    for _,InstanceEntry in pairs(entry[6]) do
        InstanceEntry[2]:Disconnect() -- BG listener
        if InstanceEntry[1] then
            for _,child in pairs(InstanceEntry[1]:GetChildren()) do
                if child.Name == "Outline" then
                    child.BackgroundColor3 = Color3.fromRGB(216,216,216)
                end
            end

            InstanceEntry[1].PropertyHalf.Outline.BackgroundColor3 = Color3.fromRGB(216,216,216)
            if InstanceEntry[1].BackgroundColor3 == themes.current["zebra_1"] then
                InstanceEntry[1].BackgroundColor3 = Color3.new(1,1,1)
            elseif InstanceEntry[1].BackgroundColor3 == themes.current["zebra_2"] then
                InstanceEntry[1].BackgroundColor3 = Color3.fromRGB(246,246,246)
            end
        end
    end

    for _,CategoryHeader in pairs(entry[7]) do
        CategoryHeader[2]:Disconnect()
        CategoryHeader[1].BackgroundColor3 = Color3.fromRGB(160,160,160)
        CategoryHeader[1].CategoryName.TextColor3 = Color3.new(0,0,0) 
    end
end

local Properties = newdefault(Windows,"Properties")
if Properties then
    newheader(Properties,"WindowHeader")
    local ListOutline = newdefault(Properties,"ListOutline")
    if ListOutline then
        local Header = newdefault(ListOutline,"Header")
        if Header then
            local Frame = newreg(Header,"Frame")
            if Frame then
                regtheme("BackgroundColor3",theme.ol)
            end
            local Background = newreg(Header,"Background")
            if Background then
                regprop("ImageTransparency",1)
                regprop("BackgroundTransparency",0)
                regtheme("BackgroundColor3",theme.header)
                regprop("BorderSizePixel",1)
                regtheme("BorderColor3",theme.bg)
            end
            local BackgroundB = newreg(Header,"BackgroundB")
            if BackgroundB then
                regprop("ImageTransparency",1)
                regprop("BackgroundTransparency",0)
                regtheme("BackgroundColor3",theme.header)
                regprop("BorderSizePixel",1)
                regtheme("BorderColor3",theme.bg)
            end
            for _,child in pairs(Header[1]:GetChildren()) do
                if child:IsA("TextLabel") then
                    newdefaultself(child)
                end
            end
        end
        local PropertyList = newdefault(ListOutline,"PropertyList")
        if PropertyList then
            regdynamic(dynamicPropertiesHandlerConnect,
                dynamicPropertiesHandlerDisconnect)
            newdefault(PropertyList,"BumpForHeader")
        end
        local LeftOutlineOverHeader = newreg(ListOutline,"LeftOutlineOverHeader")
        if LeftOutlineOverHeader then
            regtheme("BackgroundColor3",theme.ol)
        end
        -- ListOutline[1]:WaitForChild("ScrollbarBackground",5)
        -- newscrollbar(ListOutline,"ScrollbarBackground")
    end
    local IdentityBackground = newreg(Properties,"IdentityBackground")
    if IdentityBackground then
        regtheme("ImageColor3",theme.header)
        local IdentityLabel = newreg(IdentityBackground,"IdentityLabel")
        if IdentityLabel then
            regfont()
        end
    end
    local PropertiesScript = newreg(Properties,"PropertiesScript")
    if PropertiesScript then
        local EnumList = newreg(PropertiesScript,"EnumList")
        if EnumList then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regtheme("BackgroundColor3",theme.ol)
            local ScrollingFrame = newreg(EnumList,"Frame.ScrollingFrame")
            if ScrollingFrame then
                regtheme("BackgroundColor3",theme.bg)
                local ListItem = newreg(ScrollingFrame,"ListItem")
                if ListItem then
                    regtheme("BackgroundColor3",theme.bg)
                    regfont()
                    local TextLabel = newreg(ListItem,"TextLabel")
                    if TextLabel then
                        regfont()
                    end
                end
            end
        end
        local PropertyBrickColorPalette = newreg(PropertiesScript,"PropertyBrickColorPalette")
        if PropertyBrickColorPalette then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regtheme("BorderColor3",theme.ol)
            regtheme("BackgroundColor3",theme.bg)
            regprop("BorderSizePixel",1)
        end
    end
end



-- TabBar
-- I really can't be bothered right now...
-- local function dynamicTabBarHandlerConnect(instance, entry)
--     entry[6] = {}

--     local function recolorTextLabel(TextLabel)
--         print(TextLabel.Parent, TextLabel.Parent.Image)
--         if TextLabel.Parent.Image == "8678265568" or TextLabel.Parent.Image == "rbxassetid://8678262348" then -- Selected
--             TextLabel.TextColor3 = themes.current["text"]
--             TextLabel.Parent.BackgroundColor3 = themes.current.header
--         elseif TextLabel.Parent.Image == "rbxassetid://8678262348" then -- Hovered
--             TextLabel.TextColor3 = Color3.new(0,0,0)
--         elseif TextLabel.Parent.Image == "rbxassetid://8678267866" then -- Unselected
--             TextLabel.TextColor3 = themes.current["text"]
--             TextLabel.Parent.ImageTransparency = 1
--             TextLabel.Parent.BackgroundColor3 = themes.current.bg
--         end
--     end

--     local function hookTextLabel(TextLabel)
--         if TextLabel:IsA("TextLabel") then
--             local self_entry = #entry[6]+1
--             TextLabel.Font = themes.current["font"]
--             recolorTextLabel(TextLabel)
--             local textConnection = TextLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
--                 recolorTextLabel(TextLabel)
--             end)
--             local imageConnection = TextLabel.Parent:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
--                 recolorTextLabel(TextLabel)
--             end)
--             TextLabel.Destroying:Connect(function()
--                 entry[6][self_entry] = nil
--             end)
--             entry[6][self_entry] = {TextLabel,textConnection,imageConnection}
--         end
--     end

--     local function hookTab(Tab)
--         if Tab:IsA("ImageButton") then
--             Tab.BottomLine.BackgroundColor3 = themes.current.ol
--             hookTextLabel(Tab.TextLabel)
--         end
--         -- instance.Destroying:Connect(function()
--         --     entry[2][self_entry] = nil
--         -- end)

--         -- entry[2][#entry[2]+1] = connection
--     end

--     for _,child in pairs(instance:GetChildren()) do
--         hookTab(child)
--     end
--     local connection = instance.ChildAdded:Connect(function(child)
--         hookTab(child)
--     end)

--     entry[5] = connection
-- end

-- local function dynamicTabBarHandlerDisconnect(instance, entry)
--     if not entry[5] then return end -- If not connected, can't disconnect
--     entry[5]:Disconnect()
--     for _,child in pairs(instance:GetChildren()) do
--         if child:IsA("ImageButton") then
--             child.BottomLine.BackgroundColor3 = Color3.fromRGB(216,216,216)
--         end
--     end
--     for _,TextLabel in pairs(entry[6]) do 
--         TextLabel[2]:Disconnect() -- TextColor listener
--         TextLabel[3]:Disconnect() -- Selection listener
--         if TextLabel[1] then
--             TextLabel[1].Font = Enum.Font.SourceSans
--             if TextLabel[1].Parent.ImageTransparency == 1 then -- Unhovered
--                 TextLabel[1].TextColor3 = Color3.new(0,0,0)
--             elseif TextLabel[1].Parent.Image == "rbxassetid://8678262348" then -- Hovered
--                 TextLabel[1].TextColor3 = Color3.new(0,0,0)
--             elseif TextLabel[1].Parent.Image == "rbxassetid://8678267866" then -- Selected
--                 TextLabel[1].TextColor3 = Color3.new(1,1,1)
--             end
--         end
--     end
-- end

local TabBar = newdefault(StudioGui,"TabBar")
if TabBar then
    local BottomLine = newreg(TabBar,"BottomLine")
    if BottomLine then
        regtheme("BackgroundColor3",theme.ol)
        regtheme("BorderColor3",theme.ol)
    end

    local List = newreg(TabBar,"List")
    if List then
        -- printTable(List[1])
        -- regdynamic(dynamicTabBarHandlerConnect, -- TODO
        --     dynamicTabBarHandlerDisconnect)
    end
end

-- Topbar
local Topbar = newreg(StudioGui,"Topbar")
if Topbar then
    -- TitleBar
    local TitleBar = newreg(Topbar,"TitleBar")
    if TitleBar then
        regtheme("BackgroundColor3",theme.bg)
        local UIGradient = newreg(TitleBar,"UIGradient")
        if UIGradient then
            regprop("Enabled", false)
        end
        local TextLabel = newreg(TitleBar,"TextLabel")
        if TextLabel then
            regfont()
        end
    end

    -- Toolbar
    local Toolbar = newdefault(Topbar,"ToolBar")
    if Toolbar then
        regprop("ImageTransparency",1)
        local PropertyBrickColorPalette = newreg(Toolbar,"Tools.Color.ColorPaletteTemplate")
        if PropertyBrickColorPalette then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regtheme("BorderColor3",theme.ol)
            regtheme("BackgroundColor3",theme.bg)
            regprop("BorderSizePixel",1)
        end
        for _,child in pairs(Toolbar[1]:GetChildren()) do
            if child:IsA("ImageLabel") then
                local ImageLabel = newdefaultself(child)
                if ImageLabel then
                    regprop("ImageTransparency",1)
                    for _,child in pairs(child:GetChildren()) do
                        if child:IsA("Frame") then
                            newself(child)
                            regtheme("BackgroundColor3",theme.ol)
                            regtheme("BorderColor3", theme.header)
                        end
                    end
                end
            end
        end
    end

    local MenusBar = newreg(Topbar,"MenusBar")
    if MenusBar then
        regtheme("BackgroundColor3",theme.header)
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        for _,child in pairs(MenusBar[1]:GetChildren()) do
            if child:IsA("TextButton") then
                local TextButton = newself(child)
                if TextButton then
                    regprop("BackgroundTransparency",0)
                    regtheme("BackgroundColor3",theme.header)
                    local TextLabel = newreg(TextButton,"TextLabel")
                    if TextLabel then
                        regfont()
                        regtheme("BackgroundColor3",theme.header)
                        regtheme("BorderColor3",theme.ol)
                    end
                    local Background = newdefault(TextButton,"Background")
                    if Background then
                        regprop("BackgroundTransparency",0)
                        regprop("ImageTransparency",1)
                    end
                    if TextButton[1]:FindFirstChild("MenuFrame") then
                        local Background = newdefault(TextButton,"MenuFrame.Background")
                        if Background then
                            regprop("BackgroundTransparency",0)
                            regprop("BorderSizePixel",1)
                            if Background[1]:IsA("ImageLabel") then
                                regprop("ImageTransparency",1)
                            end
                            if child.Name ~= "WindowButton" then
                                for _,desc in pairs(Background[1]:GetDescendants()) do
                                    if desc:IsA("TextButton") or desc:IsA("TextLabel") or desc:IsA("Frame") then
                                        newdefaultself(desc)
                                    end                               
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local PluginBar = newdefault(Topbar,"PluginBar")
    if PluginBar then
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        for _,child in pairs(PluginBar[1]:GetChildren()) do
            if child:IsA("ImageLabel") then
                local PluginGroup = newdefaultself(child)
                if PluginGroup then
                    regprop("ImageTransparency",1)
                    regprop("BackgroundTransparency",0)
                end
            end
        end
    end
end

-- BottomBar
local BottomBar = newdefault(StudioGui,"BottomBar")
if BottomBar then
    newdefault(BottomBar,"Diagnostics")
    local TextLabel = newdefault(BottomBar,"TextLabel")
    if TextLabel then
        regprop("BackgroundTransparency",0)
    end
end

-- Output
local outputColorReplace = {
    [Color3.fromRGB(0,0,0)] = theme.text_print,
    [Color3.fromRGB(0,0,255)] = theme.text_info,
    [Color3.fromRGB(255,128,0)] = theme.text_warn,
    [Color3.fromRGB(255,0,0)] = theme.text_error
}

local function dynamicOutputHandlerConnect(instance, entry)
    entry[5] = {} -- TextBox entries
    entry[6] = {} -- Table list entries

    local function outputReplaceColors(textgui)
        for init,replace in pairs(outputColorReplace) do
            if textgui.TextColor3 == init then
                if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                    -- We can set this as bold font
                    textgui.Font = themes.current["font_bold"]
                else
                    -- We can set this as normal font
                    textgui.Font = themes.current["font"]
                end
                textgui.TextColor3 = themes.current[replace]
            end
        end
    end

    local function hookTextGui(textgui)
        local self_entry = #entry[5]+1
        outputReplaceColors(textgui)
        entry[5][self_entry] = {textgui}
    end

    local function hookOutput(Element)
        if Element:IsA("TextBox") then
            hookTextGui(Element)
        elseif Element:IsA("TextLabel") then -- Table Output
            -- retro tableClosed Image (6x6) - rbxassetid://8949637080
            -- retro tableOpened Image (6x6) - rbxassetid://8949639420
            -- mod tableClosed Image (7x7) - rbxassetid://16405593659
            -- mod tableOpened Image (7x7) - rbxassetid://16421483906

            local self_entry = #entry[6]+1
            local text_entry = hookTextGui(Element)
            
            for _,child in pairs(Element.List:GetChildren()) do
                hookOutput(child)
            end
            local listConnection = Element.List.ChildAdded:Connect(function(child)
                hookOutput(child)
            end)
            
            Element.ExpandButton.ImageLabel.ImageColor3 = themes.current["text"]
            Element.ExpandButton.Frame.BackgroundColor3 = themes.current["text"]

            local ImageLabel = Element.ExpandButton.ImageLabel
            if ImageLabel.Image == "rbxassetid://8949637080" then -- tableClosed
                    ImageLabel.Image = "rbxassetid://16405593659"
                elseif ImageLabel.Image == "rbxassetid://8949639420" then --tableOpened
                    ImageLabel.Image = "rbxassetid://16421483906"
                end
            local imageConnection = Element.ExpandButton.ImageLabel:GetPropertyChangedSignal("Image"):Connect(function()
                if ImageLabel.Image == "rbxassetid://8949637080" then -- tableClosed
                    ImageLabel.Image = "rbxassetid://16405593659"
                elseif ImageLabel.Image == "rbxassetid://8949639420" then --tableOpened
                    ImageLabel.Image = "rbxassetid://16421483906"
                end
            end)

            instance.Destroying:Connect(function()
                entry[5][text_entry] = nil
                entry[6][self_entry] = nil
            end)

            local newEntry = {Element,listConnection,imageConnection}
            entry[6][self_entry] = newEntry
        end
    end

    for _,TextBox in pairs(instance:GetChildren()) do
        hookOutput(TextBox)
    end

    local connection = instance.ChildAdded:Connect(function(child)
        hookOutput(child)
    end)
    entry[4] = connection
end

local function dynamicOutputHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect() -- Disconnect if connected

    local function outputReplaceColors(textgui)
        for init,replace in pairs(outputColorReplace) do
            if textgui[1].TextColor3 == themes.current[replace] then
                if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                    -- We can set this as bold font
                    textgui[1].Font = Enum.Font.SourceSansBold
                else
                    -- We can set this as normal font
                    textgui[1].Font = Enum.Font.SourceSans
                end
                textgui[1].TextColor3 = init
            end
        end
    end

    for _,textEntry in pairs(entry[5]) do -- Disconnect and reset all TextBoxes
        if textEntry[1] then
            outputReplaceColors(textEntry)
        end
    end

    for _,tableOutput in pairs(entry[6]) do -- Disconnect and reset all TableOutputs
        -- retro tableClosed Image (6x6) - rbxassetid://8949637080
        -- retro tableOpened Image (6x6) - rbxassetid://8949639420
        -- mod tableClosed Image (7x7) - rbxassetid://16405593659
        -- mod tableOpened Image (7x7) - rbxassetid://16421483906

        if tableOutput[1] then
            tableOutput[2]:Disconnect()
            tableOutput[3]:Disconnect()
            tableOutput[1].ExpandButton.ImageLabel.ImageColor3 = Color3.new(0,0,0)
            tableOutput[1].ExpandButton.Frame.BackgroundColor3 = Color3.new(0,0,0)
            local ImageLabel = tableOutput[1].ExpandButton.ImageLabel
            if ImageLabel.Image == "rbxassetid://16405593659" then -- tableClosed
                ImageLabel.Image = "rbxassetid://8949637080"
            elseif ImageLabel.Image == "rbxassetid://16421483906" then --tableOpened
                ImageLabel.Image = "rbxassetid://8949639420"
            end
        end
    end
end

local Output = newdefault(Windows,"Output")
local RightClickPopup = newdefault(StudioGui,"RightClickPopup", true)

if Output then
    newheader(Output,"WindowHeader")
    local ListOutline = newdefault(Output,"ListOutline")
    if ListOutline then
        local List = newreg(ListOutline,"List")
        if List then
            regdynamic(dynamicOutputHandlerConnect,
                dynamicOutputHandlerDisconnect)
        end
        newscrollbar(ListOutline,"ScrollbarBackground")
    end
    RightClickPopup = RightClickPopup or newdefault(Output,"OutputScript.RightClickPopup", true)
    if RightClickPopup then
        local Background = newdefault(RightClickPopup,"Background")
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        if Background then
            local ClearOutput = newdefault(Background,"ClearOutput")
            if ClearOutput then
                newdefault(ClearOutput,"NameLabel")
                newdefault(ClearOutput,"ShortcutLabel")
                local ImageLabel = newreg(ClearOutput,"ImageLabel")
                if ImageLabel then
                    regprop("ImageTransparency",1)
                end
                local Highlight = newreg(ClearOutput,"Highlight")
                if Highlight then
                    regtheme("BackgroundColor3",theme.ol)
                    regprop("BorderSizePixel",0)
                    regprop("BackgroundTransparency",0)
                    regprop("ImageTransparency",1)
                end
            end
        end
    end
end


if guiLayoutUnknown == true then
    warn("PotatoMod2: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

end -- registerStudio

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local divider = "-------------------------------------"

local exceptionKeys = {}

local function render(state,previousException) 
    -- breakKey is used to not render things that caused an error
    for k,v in pairs(instanceList) do
        local set, message    
        if not exceptionKeys[k] then -- If this key didn't fire an error
            -- Step 1 (theme render)
            set, message = pcall(function() -- pcall as to not stop after error if can't set property
                for property,value in pairs(v[2]) do -- Static theme changes
                    if state == RENDER_STATE_DEFAULT then
                        v[1][property] = value[state]
                    else
                        if themes.current[value[state]] == nil then warn("PM2 ThemeError: "..v[1]:GetFullName().."."..property.." = theme<"..value[state]..">") end
                        v[1][property] = themes.current[value[state]]
                    end
                end
            end)
            if not set then
                exceptionKeys[k] = true
                local err = "Error during theme render stage.\nRender state: "..tostring(state).."\nKey: "..tostring(k).."\n".."Instance: "..v[1]:GetFullName().."\n"..message
                if previousException then
                    err = "During the handling of the exception\n"..divider.."\n"..previousException.."\n"..divider.."\nAnother exception occured\n\n"..err
                end
                render(RENDER_STATE_DEFAULT,err)
                handleError(err)
            end
            -- Step 2 (property override)
            set, message = pcall(function() -- pcall as to not stop after error if can't set property
                for property,value in pairs(v[4]) do -- Static property changes
                    v[1][property] = value[state]
                end
            end)
            if not set then
                exceptionKeys[k] = true
                local err = "Error during property override stage.\nRender state: "..tostring(state).."\nKey: "..tostring(k).."\n".."Instance: "..v[1]:GetFullName().."\n"..message
                if previousException then
                    err = "During the handling of the exception\n"..divider.."\n"..previousException.."\n"..divider.."\nAnother exception occured\n\n"..err
                end
                render(RENDER_STATE_DEFAULT,err)
                handleError(err)
            end
            -- Step 3 (hook/dynamic stage)
            set, message = pcall(function() -- pcall as to not stop after error
                for _,entry in pairs(v[3]) do -- Dynamic properties
                    if state == RENDER_STATE_DEFAULT then
                        entry[2](v[1],entry) -- Disconnect
                    else
                        entry[2](v[1],entry) -- Disconnect
                        entry[1](v[1],entry) -- Connect
                    end
                end
            end)
            if not set then
                exceptionKeys[k] = true
                local err = "Error during hook stage.\nRender state: "..tostring(state).."\nKey: "..tostring(k).."\n".."Instance: "..v[1]:GetFullName().."\n"..message
                if previousException then
                    err = "During the handling of the exception\n"..divider.."\n"..previousException.."\n"..divider.."\nAnother exception occured\n\n"..err
                end
                render(RENDER_STATE_DEFAULT,err)
                handleError(err)
            end 
            -- Step 4
            if v[5] then
                if state == RENDER_STATE_DEFAULT then
                    if v[1] then
                        v[1]:Destroy()
                        instanceList[k] = nil
                    end
                elseif state == RENDER_STATE_POTATO then
                    if v[1] then
                        if v[1]:IsA("GuiObject") then
                            v[1].Visible = true
                        end
                    end
                end
            end
        end
    end
end

local enabled = false

local function disablePotatoMod()
    PotatoTab.Visible = false
    if PotatoTab.MenuFrame.Background:FindFirstChild("PotatoFrame") then
        PotatoTab.MenuFrame.Background.PotatoFrame:Destroy()
    end
    SaveSettings(true)
    render(RENDER_STATE_DEFAULT)
    enabled = false
    warn("PotatoMod2 disabled.")
end

local function enablePotatoMod()
    enabled = true
    game.Players.PlayerRemoving:Connect(function() SaveSettings(true) end)
    if Settings.toggles.enableTheme then
        render(RENDER_STATE_POTATO)
    end
    PotatoTab.Visible = true
    warn("PotatoMod2 loaded.")
    if not Settings["used_before"] then
        Settings["used_before"] = true
        warn("This appears to be your first time using PotatoMod2")
        warn("You can enable auto-launch in the PotatoMod tab")
        warn("Tip: You can clear output by right-clicking it and pressing Clear Output")
    end
end

local registered = false

local function registerStudioProtected()
    if not registered then
        registered = true
        local set, message = pcall(function()
            registerStudio()
        end)
        if not set then
            local err = "Error during register stage.\n".."\n"..message
            handleError(err)
        end 
    end
end

if script then -- Real PotatoMod, do startup stuffs
    local EnableBind = script.Enable
    EnableBind.Event:Connect(function()
        if enabled then
            warn("PotatoMod2 is already loaded.")
        else
            registerStudioProtected()
            enablePotatoMod()
        end
    end)
end

if Settings.toggles.autoLaunch or maindebug then
    if enabled then
        warn("PotatoMod2 is already loaded.")
    else
        registerStudioProtected()
        enablePotatoMod()
    end

    if maindebug then
        task.wait(5)
        disablePotatoMod()
    end
end