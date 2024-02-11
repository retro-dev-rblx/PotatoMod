local function printChildrenWithIndentation(object, indent, gui)
    -- Set default indentation level if not provided
    indent = indent or 0
    
    -- Print object type with current indentation
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Text = object.ClassName .. " - " .. object.Name
    typeLabel.Parent = gui
    typeLabel.Position = UDim2.new(0, indent*20, 0, #gui:GetChildren() * 17)
    typeLabel.Size = UDim2.new(0.95, -1*indent*20, 0, 16)
    typeLabel.TextSize = 14
    typeLabel.TextColor3 = Color3.new(1, 1, 1)
    typeLabel.BackgroundColor3 = Color3.new(0,0,0)
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.Font = "Code"
    typeLabel.BorderSizePixel = 1
    typeLabel.BorderColor3 = Color3.new(16,16,16)
    
    -- Recursively print children with increased indentation
    for _, child in ipairs(object:GetChildren()) do
        printChildrenWithIndentation(child, indent + 1, gui)
    end
end

-- Create GUI and parent it to PlayerGui
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.DisplayOrder = 10^9 -- Set DisplayOrder to a large value to ensure it's at the very front

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = screenGui
scrollFrame.Size = UDim2.new(0.8, 0, 0.96, 0)
scrollFrame.Position = UDim2.new(0,0,0.04,0)
scrollFrame.CanvasSize = UDim2.new(1,0,500,0)
scrollFrame.BackgroundTransparency = 0.5
scrollFrame.BackgroundColor3 = Color3.new(0, 0, 0)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 16

-- Create close button
local closeButton = Instance.new("TextButton")
closeButton.Parent = screenGui
closeButton.Text = "X"
closeButton.Position = UDim2.new(0.8, 0, 0, 10)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.TextSize = 20
closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)

-- Add functionality to close button
closeButton.MouseButton1Click:Connect(function()
    if screenGui then
        screenGui:Destroy()
    end
end)

-- Call the function to populate the GUI with children of Workspace
printChildrenWithIndentation(game.Players.LocalPlayer.PlayerGui,0, scrollFrame)
