-- ============ VARIABLES FIRST ============
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local ESP_Enabled = true
local Box_Enabled = true
local Name_Enabled = true
local Health_Enabled = true
local Distance_Enabled = true
local Tracer_Enabled = true
local Head_Dot_Enabled = true
local Dead_Check_Enabled = true
local Box_Color = Color3.fromRGB(255, 255, 255)
local Name_Color = Color3.fromRGB(255, 255, 255)
local Tracer_Color = Color3.fromRGB(255, 255, 255)
local Head_Dot_Color = Color3.fromRGB(255, 0, 0)
local Tracer_Origin = "Bottom"
local Aim_Enabled = true
local Aim_FOV = 150
local Aim_Smoothness = 0
local Aim_Part = "Head"
local Aim_Key_Name = "MB2"
local Aim_Key = Enum.UserInputType.MouseButton2
local Aim_Visible_Check = true
local Team_Check = false
local FOV_Circle_Enabled = true
local FOV_Circle_Color = Color3.fromRGB(255, 255, 255)
local Aim_Always_On = false
local Max_Distance_Enabled = false
local Max_Distance = 500
local Player_Dead = {}
local ESP_Pool = {}
local MainFrame = nil
local ToggleMenu = function() end

local function Set_Aim_Key(value)
    Aim_Key_Name = value
    if value == "MB1" then Aim_Key = Enum.UserInputType.MouseButton1 else Aim_Key = Enum.UserInputType.MouseButton2 end
end

local function ClearTable(t)
    for k in next, t do t[k] = nil end
end

-- ============ BUILT-IN UI (NO EXTERNAL LIBRARIES) ============
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GlonksEnhancements"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local uiSizeX = isMobile and 220 or 350
local uiSizeY = isMobile and 350 or 480
local fontSize = isMobile and 13 or 13
local rowHeight = isMobile and 30 or 28
local btnSizeX = isMobile and 45 or 42
local btnSizeY = isMobile and 22 and 20
local titleHeight = isMobile and 30 or 38
local tabHeight = isMobile and 28 and 32

MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, uiSizeX, 0, uiSizeY)
MainFrame.Position = UDim2.new(0.5, -uiSizeX/2, 0.5, -uiSizeY/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Add corner rounding effect
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then 
            MainFrame.Visible = not MainFrame.Visible 
        end
    end)
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, titleHeight)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(100, 180, 255)
Title.Text = "Glonk's Enhancements"
Title.Font = Enum.Font.GothamBold
Title.TextSize = isMobile and 13 or 15
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, tabHeight)
TabFrame.Position = UDim2.new(0, 0, 0, titleHeight)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -6, 1, -titleHeight - tabHeight - 8)
ScrollFrame.Position = UDim2.new(0, 3, 0, titleHeight + tabHeight + 4)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
ContentFrame.Parent = ScrollFrame

local function CreateTab(name, xPos)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1/4, 0, 1, 0)
    tab.Position = UDim2.new(xPos, 0, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tab.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab.Text = name
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = isMobile and 11 or 12
    tab.BorderSizePixel = 0
    tab.Parent = TabFrame
    return tab
end

local Tab1 = CreateTab("Aim", 0)
local Tab2 = CreateTab("Rage", 0.25)
local Tab3 = CreateTab("ESP", 0.5)
local Tab4 = CreateTab("Settings", 0.75)

local Pages = {}
for i = 1, 4 do
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Visible = (i == 1)
    page.Parent = ContentFrame
    table.insert(Pages, page)
end

local Tabs = {Tab1, Tab2, Tab3, Tab4}
local ActiveTabColor = Color3.fromRGB(60, 60, 90)
local InactiveTabColor = Color3.fromRGB(35, 35, 35)
local ActiveTextColor = Color3.fromRGB(255, 255, 255)
local InactiveTextColor = Color3.fromRGB(150, 150, 150)

local function SwitchTab(tabNum)
    for i, t in ipairs(Tabs) do
        if i == tabNum then
            t.BackgroundColor3 = ActiveTabColor
            t.TextColor3 = ActiveTextColor
            Pages[i].Visible = true
        else
            t.BackgroundColor3 = InactiveTabColor
            t.TextColor3 = InactiveTextColor
            Pages[i].Visible = false
        end
    end
    ScrollFrame.CanvasPosition = Vector2.new(0, 0)
end

Tab1.MouseButton1Click:Connect(function() SwitchTab(1) end)
Tab2.MouseButton1Click:Connect(function() SwitchTab(2) end)
Tab3.MouseButton1Click:Connect(function() SwitchTab(3) end)
Tab4.MouseButton1Click:Connect(function() SwitchTab(4) end)

local Themes = {
    ["Default Blue"] = { Main = Color3.fromRGB(30, 30, 30), Title = Color3.fromRGB(20, 20, 20), ActiveTab = Color3.fromRGB(60, 60, 90), InactiveTab = Color3.fromRGB(35, 35, 35), Row = Color3.fromRGB(45, 45, 65), Button = Color3.fromRGB(60, 60, 85), Accent = Color3.fromRGB(100, 180, 255) },
    ["Red"] = { Main = Color3.fromRGB(35, 20, 20), Title = Color3.fromRGB(25, 15, 15), ActiveTab = Color3.fromRGB(100, 30, 30), InactiveTab = Color3.fromRGB(45, 25, 25), Row = Color3.fromRGB(60, 30, 30), Button = Color3.fromRGB(80, 35, 35), Accent = Color3.fromRGB(255, 100, 100) },
    ["Green"] = { Main = Color3.fromRGB(20, 35, 20), Title = Color3.fromRGB(15, 25, 15), ActiveTab = Color3.fromRGB(30, 90, 30), InactiveTab = Color3.fromRGB(25, 45, 25), Row = Color3.fromRGB(30, 55, 30), Button = Color3.fromRGB(35, 75, 35), Accent = Color3.fromRGB(100, 255, 100) },
    ["Purple"] = { Main = Color3.fromRGB(30, 20, 35), Title = Color3.fromRGB(20, 15, 25), ActiveTab = Color3.fromRGB(70, 30, 90), InactiveTab = Color3.fromRGB(40, 25, 50), Row = Color3.fromRGB(50, 35, 60), Button = Color3.fromRGB(65, 45, 80), Accent = Color3.fromRGB(180, 100, 255) },
    ["Pure Black"] = { Main = Color3.fromRGB(15, 15, 15), Title = Color3.fromRGB(10, 10, 10), ActiveTab = Color3.fromRGB(40, 40, 40), InactiveTab = Color3.fromRGB(25, 25, 25), Row = Color3.fromRGB(35, 35, 35), Button = Color3.fromRGB(45, 45, 45), Accent = Color3.fromRGB(200, 200, 200) },
    ["Pink"] = { Main = Color3.fromRGB(35, 20, 30), Title = Color3.fromRGB(25, 15, 22), ActiveTab = Color3.fromRGB(100, 30, 70), InactiveTab = Color3.fromRGB(45, 25, 40), Row = Color3.fromRGB(60, 30, 50), Button = Color3.fromRGB(80, 35, 65), Accent = Color3.fromRGB(255, 100, 180) }
}

local currentTheme = Themes["Default Blue"]

local function ApplyTheme(theme)
    currentTheme = theme
    ActiveTabColor = theme.ActiveTab
    InactiveTabColor = theme.InactiveTab
    MainFrame.BackgroundColor3 = theme.Main
    Title.BackgroundColor3 = theme.Title
    Title.TextColor3 = theme.Accent
    TabFrame.BackgroundColor3 = theme.Title
    for _, page in ipairs(Pages) do
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") and child.Name == "RowFrame" then
                child.BackgroundColor3 = theme.Row
            end
            if child:IsA("TextButton") and child.Name == "DropdownBtn" then
                child.BackgroundColor3 = theme.Button
            end
        end
    end
    SwitchTab(1)
end

local function MakeToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = "RowFrame"
    frame.Size = UDim2.new(1, -8, 0, rowHeight)
    frame.BackgroundColor3 = currentTheme.Row
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.Parent = frame
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -btnSizeX - 12, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = fontSize
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, btnSizeX, 0, btnSizeY)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -4, 0.5, 0)
    local isOn = default
    local function UpdateBtn()
        if isOn then 
            btn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
            btn.Text = "ON"
        else 
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.Text = "OFF"
        end
    end
    UpdateBtn()
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        UpdateBtn()
        callback(isOn)
    end)
    
    return frame
end

local function MakeDropdown(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = "RowFrame"
    frame.Size = UDim2.new(1, -8, 0, rowHeight)
    frame.BackgroundColor3 = currentTheme.Row
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.ZIndex = 5
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Name = "DropdownBtn"
    btn.Size = UDim2.new(1, -8, 1, -6)
    btn.Position = UDim2.new(0, 4, 0, 3)
    btn.BackgroundColor3 = currentTheme.Button
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text .. ": " .. default
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = fontSize
    btn.BorderSizePixel = 0
    btn.ZIndex = 6
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -8, 0, #options * 24)
    listFrame.Position = UDim2.new(0, 4, 0, -#options * 24 - 2)
    listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 10
    listFrame.ClipsDescendants = false
    listFrame.Parent = frame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = listFrame
    
    btn.MouseButton1Click:Connect(function() 
        listFrame.Visible = not listFrame.Visible 
    end)
    
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 24)
        optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        optBtn.TextColor3 = Color3.new(1, 1, 1)
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = fontSize
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 11
        optBtn.Parent = listFrame
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 3)
        optCorner.Parent = optBtn
        
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = text .. ": " .. opt
            listFrame.Visible = false
            callback(opt)
        end)
    end
    
    return frame
end

local function MakeLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = currentTheme.Accent
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Page 1: Aim
MakeToggle(Pages[1], "Enabled", Aim_Enabled, function(v) Aim_Enabled = v end)
MakeDropdown(Pages[1], "Aim Key", {"MB1", "MB2"}, Aim_Key_Name, function(v) Set_Aim_Key(v) end)
MakeToggle(Pages[1], "Always On (Mobile)", false, function(v) Aim_Always_On = v end)
MakeDropdown(Pages[1], "FOV", {"50", "100", "150", "200", "300", "500"}, "150", function(v) Aim_FOV = tonumber(v) end)
MakeDropdown(Pages[1], "Smoothness", {"0", "25", "50", "75", "99"}, "0", function(v) Aim_Smoothness = tonumber(v) end)
MakeDropdown(Pages[1], "Aim Part", {"Head", "RootPart", "Torso", "Random"}, "Head", function(v) Aim_Part = v end)
MakeToggle(Pages[1], "Wall Check", Aim_Visible_Check, function(v) Aim_Visible_Check = v end)
MakeToggle(Pages[1], "Team Check", Team_Check, function(v) Team_Check = v end)
MakeToggle(Pages[1], "Draw FOV", FOV_Circle_Enabled, function(v) FOV_Circle_Enabled = v end)
MakeToggle(Pages[1], "Max Distance", false, function(v) Max_Distance_Enabled = v end)
MakeDropdown(Pages[1], "Max Studs", {"100", "200", "300", "500", "750", "1000"}, "500", function(v) Max_Distance = tonumber(v) end)

-- Page 2: Rage (Empty for now)
MakeLabel(Pages[2], "Rage features coming soon...")

-- Page 3: ESP
MakeToggle(Pages[3], "Enabled", ESP_Enabled, function(v) ESP_Enabled = v end)
MakeToggle(Pages[3], "Dead Check", Dead_Check_Enabled, function(v) Dead_Check_Enabled = v; if not v then ClearTable(Player_Dead) end end)
MakeToggle(Pages[3], "Box", Box_Enabled, function(v) Box_Enabled = v end)
MakeToggle(Pages[3], "Name", Name_Enabled, function(v) Name_Enabled = v end)
MakeToggle(Pages[3], "Health Bar", Health_Enabled, function(v) Health_Enabled = v end)
MakeToggle(Pages[3], "Distance", Distance_Enabled, function(v) Distance_Enabled = v end)
MakeToggle(Pages[3], "Tracers", Tracer_Enabled, function(v) Tracer_Enabled = v end)
MakeDropdown(Pages[3], "Tracer Origin", {"Bottom", "Middle", "Top"}, "Bottom", function(v) Tracer_Origin = v end)
MakeToggle(Pages[3], "Head Dot", Head_Dot_Enabled, function(v) Head_Dot_Enabled = v end)

-- Page 4: Settings
MakeLabel(Pages[4], "Built-in UI (No External Libs)")
MakeDropdown(Pages[4], "UI Theme", {"Default Blue", "Red", "Green", "Purple", "Pure Black", "Pink"}, "Default Blue", function(v)
    if Themes[v] then ApplyTheme(Themes[v]) end
end)
MakeLabel(Pages[4], "Toggle Key: Right Shift")

ToggleMenu = function()
    if MainFrame then MainFrame.Visible = not MainFrame.Visible end
end

-- ============ MOBILE BUTTON ============
if isMobile then
    local MobileGui = Instance.new("ScreenGui")
    MobileGui.Name = "GlonksMobileBtn"
    MobileGui.ResetOnSpawn = false
    MobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MobileGui.Parent = playerGui

    local mobileBtn = Instance.new("TextButton")
    mobileBtn.Size = UDim2.new(0, 55, 0, 55)
    mobileBtn.Position = UDim2.new(0, 10, 0.5, -27)
    mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    mobileBtn.TextColor3 = Color3.new(1, 1, 1)
    mobileBtn.Text = "GE"
    mobileBtn.Font = Enum.Font.GothamBold
    mobileBtn.TextSize = 20
    mobileBtn.BorderSizePixel = 0
    mobileBtn.Parent = MobileGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = mobileBtn

    local dragging, dragStart, startPos = false, nil, nil
    mobileBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mobileBtn.Position
        end
    end)
    mobileBtn.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mobileBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    mobileBtn.InputEnded:Connect(function(input)
        if dragging and input.UserInputState == Enum.UserInputState.End then
            dragging = false
            if (input.Position - dragStart).Magnitude < 10 then ToggleMenu() end
        end
    end)
end

-- ============ GAME LOGIC ============
pcall(function()
    local replicated_first = game:GetService("ReplicatedFirst")
    local peuron = require(replicated_first:WaitForChild("neuron"))
    task.spawn(function()
        while task.wait() do
            pcall(function()
                for _, v in game.Players:GetPlayers() do
                    if not v.Character then v.Character = peuron:get_character(v) end
                end
            end)
        end
    end)
end)

local Services = { Players = game:GetService("Players"), Run_Service = game:GetService("RunService"), User_Input = game:GetService("UserInputService"), Workspace = game:GetService("Workspace") }
local Local_Player = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local v2_new, v3_new = Vector2.new, Vector3.new
local math_abs, math_floor, math_clamp = math.abs, math.floor, math.clamp
local table_insert = table.insert

local function World_To_Screen(pos)
    local p, o = Camera:WorldToViewportPoint(pos)
    return v2_new(p.X, p.Y), o, p.Z
end

local function Get_Nearest_Part(player, part_name)
    local char = player.Character
    if not char then return nil end
    if part_name == "Random" then
        local parts = {}
        for _, v in ipairs(char:GetChildren()) do if v:IsA("BasePart") then table_insert(parts, v) end end
        if #parts > 0 then return parts[math.random(1, #parts)] else return char:FindFirstChild("HumanoidRootPart") end
    end
    if part_name == "Torso" then return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end
    if part_name == "RootPart" then return char:FindFirstChild("HumanoidRootPart") end
    return char:FindFirstChild(part_name)
end

local function Get_Distance_From_Local(player)
    local c, lc = player.Character, Local_Player.Character
    if not c or not lc then return 0 end
    local r, lr = c:FindFirstChild("HumanoidRootPart"), lc:FindFirstChild("HumanoidRootPart")
    if r and lr then return (r.Position - lr.Position).Magnitude end
    return 0
end

local function Find_Custom_Health(player)
    local h, mh = nil, nil
    for _, root in ipairs({player, player.Character}) do
        if root then
            for _, inst in ipairs(root:GetDescendants()) do
                local n = inst.Name:lower()
                local v = (inst:IsA("NumberValue") or inst:IsA("IntValue")) and inst.Value or (inst:IsA("StringValue") and tonumber(inst.Value))
                if v then
                    if n:match("health") or n == "hp" then h = h or v
                    elseif n:match("max") and (n:match("health") or n:match("hp")) then mh = mh or v end
                end
            end
            h = h or tonumber(root:GetAttribute("Health") or root:GetAttribute("HP"))
            mh = mh or tonumber(root:GetAttribute("MaxHealth") or root:GetAttribute("MaxHP"))
        end
    end
    return h, mh
end

local function Get_Health(player)
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MaxHealth and hum.MaxHealth > 0 then return hum.Health / hum.MaxHealth end
    end
    local h, mh = Find_Custom_Health(player)
    if h == nil then return 0 end
    if mh and mh > 0 then return math_clamp(h / mh, 0, 1) end
    return h > 0 and 1 or 0
end

local function Is_Player_Dead(player)
    local char = player.Character
    if not char then return true end
    local h, _ = Find_Custom_Health(player)
    if h ~= nil then return h <= 0 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum:GetState() == Enum.HumanoidStateType.Dead then return true end
        if hum.MaxHealth and hum.MaxHealth > 0 then return hum.Health <= 0 end
    end
    return false
end

local function Is_Same_Team(player)
    if not Team_Check then return false end
    if Local_Player.Team == nil then return false end
    return player.Team == Local_Player.Team
end

local FOV_Drawing = Drawing.new("Circle")
FOV_Drawing.Filled = false
FOV_Drawing.Thickness = 1.5
FOV_Drawing.NumSides = 100
FOV_Drawing.Transparency = 0.7
FOV_Drawing.ZIndex = 2

local function Create_ESP_Drawings(player)
    local d = {}
    d.Box_Outline = Drawing.new("Square"); d.Box_Outline.Thickness = 1.5; d.Box_Outline.ZIndex = 3
    d.Box_Fill = Drawing.new("Square"); d.Box_Fill.Filled = true; d.Box_Fill.Color = Color3.new(0,0,0); d.Box_Fill.Transparency = 0.7; d.Box_Fill.ZIndex = 2
    d.Health_Bar_BG = Drawing.new("Line"); d.Health_Bar_BG.Color = Color3.fromRGB(40,40,40); d.Health_Bar_BG.Thickness = 2; d.Health_Bar_BG.ZIndex = 3
    d.Health_Bar = Drawing.new("Line"); d.Health_Bar.Thickness = 2; d.Health_Bar.ZIndex = 4
    d.Name_Text = Drawing.new("Text"); d.Name_Text.Size = 13; d.Name_Text.Center = true; d.Name_Text.Outline = true; d.Name_Text.Font = Drawing.Fonts.Plex; d.Name_Text.ZIndex = 3
    d.Distance_Text = Drawing.new("Text"); d.Distance_Text.Color = Color3.fromRGB(200,200,200); d.Distance_Text.Size = 12; d.Distance_Text.Center = true; d.Distance_Text.Outline = true; d.Distance_Text.Font = Drawing.Fonts.Plex; d.Distance_Text.ZIndex = 3
    d.Tracer_Line = Drawing.new("Line"); d.Tracer_Line.Thickness = 1; d.Tracer_Line.Transparency = 0.5; d.Tracer_Line.ZIndex = 1
    d.Head_Dot = Drawing.new("Circle"); d.Head_Dot.Filled = true; d.Head_Dot.Radius = 4; d.Head_Dot.NumSides = 20; d.Head_Dot.ZIndex = 4
    ESP_Pool[player] = d
    return d
end

local function Get_Closest_Target()
    local closest, dist = nil, Aim_FOV
    local center = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local_Player and not Is_Same_Team(p) and not (Dead_Check_Enabled and Is_Player_Dead(p)) then
            local part = Get_Nearest_Part(p, Aim_Part)
            if part then
                local skip_target = false
                if Max_Distance_Enabled then
                    if Get_Distance_From_Local(p) > Max_Distance then skip_target = true end
                end
                if not skip_target then
                    local sp, vis = World_To_Screen(part.Position)
                    if vis then
                        local d = (sp - center).Magnitude
                        if d < dist then dist, closest = d, p end
                    end
                end
            end
        end
    end
    return closest
end

local function Aim_At_Target(player)
    local part = Get_Nearest_Part(player, Aim_Part)
    if not part then return end
    
    if isMobile then
        local target_pos = part.Position
        local cam_pos = Camera.CFrame.Position
        local look_vec = (target_pos - cam_pos)
        if look_vec:Dot(Camera.CFrame.LookVector) > 0.1 then
            local target_cframe = CFrame.lookAt(cam_pos, target_pos, Camera.CFrame.UpVector)
            local s = math_clamp(0.8 - (Aim_Smoothness * 0.0075), 0.05, 0.8)
            Camera.CFrame = Camera.CFrame:Lerp(target_cframe, s)
        end
    else
        local sp, vis = World_To_Screen(part.Position)
        if not vis then return end
        local center = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local delta = sp - center
        local s = math_clamp(1 - (math_clamp(Aim_Smoothness, 0, 99) / 100), 0.01, 1)
        mousemoverel(delta.X * s, delta.Y * s)
    end
end

local function Update_ESP()
    local ss = Camera.ViewportSize
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Local_Player then
            local drawings = ESP_Pool[player]
            local skip = Is_Same_Team(player) or (Dead_Check_Enabled and Is_Player_Dead(player))
            local char, hrp, head = nil, nil, nil
            if not skip then
                char = player.Character
                if char then hrp = char:FindFirstChild("HumanoidRootPart"); head = char:FindFirstChild("Head") end
                if not hrp or not head then skip = true end
            end
            
            if not skip then
                if not drawings then drawings = Create_ESP_Drawings(player) end
                
                local rp, _, _ = World_To_Screen(hrp.Position)
                local hp, _, _ = World_To_Screen(head.Position + v3_new(0, 0.3, 0))
                local distance = Get_Distance_From_Local(player)
                
                local height = (1000 / math.clamp(distance, 1, 1000)) * 4
                local width = height * 0.55
                
                local cx = (rp.X + hp.X) / 2
                local cy = (rp.Y + hp.Y) / 2
                local bx, by = cx - width / 2, cy - height / 2

                drawings.Box_Outline.Position = v2_new(bx, by); drawings.Box_Outline.Size = v2_new(width, height)
                drawings.Box_Outline.Color = Box_Color; drawings.Box_Outline.Visible = Box_Enabled and ESP_Enabled
                drawings.Box_Fill.Position = v2_new(bx, by); drawings.Box_Fill.Size = v2_new(width, height)
                drawings.Box_Fill.Visible = Box_Enabled and ESP_Enabled
                local barx = bx - 6
                local health = Get_Health(player)
                drawings.Health_Bar_BG.From = v2_new(barx, by); drawings.Health_Bar_BG.To = v2_new(barx, by + height)
                drawings.Health_Bar_BG.Visible = Health_Enabled and ESP_Enabled
                drawings.Health_Bar.From = v2_new(barx, by + height - (height * health)); drawings.Health_Bar.To = v2_new(barx, by + height)
                drawings.Health_Bar.Color = Color3.fromRGB((1 - health) * 255, health * 255, 40)
                drawings.Health_Bar.Visible = Health_Enabled and ESP_Enabled
                drawings.Name_Text.Text = player.Name; drawings.Name_Text.Position = v2_new(cx, by - 14)
                drawings.Name_Text.Color = Name_Color; drawings.Name_Text.Visible = Name_Enabled and ESP_Enabled
                drawings.Distance_Text.Text = math_floor(distance) .. "m"; drawings.Distance_Text.Position = v2_new(cx, by + height + 4)
                drawings.Distance_Text.Visible = Distance_Enabled and ESP_Enabled
                local oy = ss.Y
                if Tracer_Origin == "Top" then oy = 0 elseif Tracer_Origin == "Middle" then oy = ss.Y / 2 end
                drawings.Tracer_Line.From = v2_new(ss.X / 2, oy); drawings.Tracer_Line.To = v2_new(cx, (rp.Y + height/2))
                drawings.Tracer_Line.Color = Tracer_Color; drawings.Tracer_Line.Visible = Tracer_Enabled and ESP_Enabled
                drawings.Head_Dot.Position = hp; drawings.Head_Dot.Color = Head_Dot_Color
                drawings.Head_Dot.Visible = Head_Dot_Enabled and ESP_Enabled
            end
            if skip and drawings then
                for _, d in pairs(drawings) do d.Visible = false end
            end
        end
    end
end

Services.Run_Service.RenderStepped:Connect(function()
    pcall(function()
        Update_ESP()
        if Aim_Enabled then
            local is_holding_key = Services.User_Input:IsMouseButtonPressed(Aim_Key)
            if Aim_Always_On or is_holding_key then
                local t = Get_Closest_Target()
                if t then Aim_At_Target(t) end
            end
        end
        FOV_Drawing.Position = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOV_Drawing.Radius = Aim_FOV; FOV_Drawing.Color = FOV_Circle_Color
        FOV_Drawing.Visible = FOV_Circle_Enabled
    end)
end)

Services.Players.PlayerRemoving:Connect(function(player)
    if ESP_Pool[player] then
        for _, d in pairs(ESP_Pool[player]) do pcall(d.Remove, d) end
        ESP_Pool[player] = nil
    end
    Player_Dead[player] = nil
end)
