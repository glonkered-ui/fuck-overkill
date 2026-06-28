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
local UI_Worked = false
local ToggleMenu = function() end

local function Set_Aim_Key(value)
    Aim_Key_Name = value
    if value == "MB1" then Aim_Key = Enum.UserInputType.MouseButton1 else Aim_Key = Enum.UserInputType.MouseButton2 end
end

local function ClearTable(t)
    for k in next, t do t[k] = nil end
end

-- ============ UI SETUP (SAFE) ============
local UI_Success, OrionLib = false, nil
if not isMobile then
    UI_Success, OrionLib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
end

if UI_Success and OrionLib then
    local success = pcall(function()
        local Window = OrionLib:MakeWindow({ Name = "Glonk's Enhancements", HidePremium = false, IntroText = "Loading...", SaveConfig = true, ConfigFolder = "GlonksEnhancementsConfig" })
        local AimTab = Window:MakeTab({ Name = "Aim", Icon = "rbxassetid://4483345998", PremiumOnly = false })
        AimTab:AddToggle({ Name = "Enabled", Default = true, Callback = function(v) Aim_Enabled = v end })
        AimTab:AddDropdown({ Name = "Aim Key", Default = "MB2", Options = {"MB1", "MB2"}, Callback = function(v) Set_Aim_Key(v) end })
        AimTab:AddToggle({ Name = "Always On (Mobile)", Default = false, Callback = function(v) Aim_Always_On = v end })
        AimTab:AddSlider({ Name = "FOV", Min = 20, Max = 500, Default = 150, Increment = 1, Callback = function(v) Aim_FOV = v end })
        AimTab:AddSlider({ Name = "Smoothness", Min = 0, Max = 99, Default = 0, Increment = 1, Callback = function(v) Aim_Smoothness = v end })
        AimTab:AddDropdown({ Name = "Aim Part", Default = "Head", Options = {"Head", "HumanoidRootPart", "Torso", "Random"}, Callback = function(v) Aim_Part = v end })
        AimTab:AddToggle({ Name = "Visible Check", Default = true, Callback = function(v) Aim_Visible_Check = v end })
        AimTab:AddToggle({ Name = "Team Check", Default = false, Callback = function(v) Team_Check = v end })
        AimTab:AddToggle({ Name = "Draw FOV", Default = true, Callback = function(v) FOV_Circle_Enabled = v end })
        AimTab:AddColorpicker({ Name = "FOV Color", Default = FOV_Circle_Color, Callback = function(v) FOV_Circle_Color = v end })
        AimTab:AddToggle({ Name = "Max Distance", Default = false, Callback = function(v) Max_Distance_Enabled = v end })
        AimTab:AddSlider({ Name = "Max Studs", Min = 100, Max = 1000, Default = 500, Increment = 50, Callback = function(v) Max_Distance = v end })
        local ESPTab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false })
        ESPTab:AddToggle({ Name = "Enabled", Default = true, Callback = function(v) ESP_Enabled = v end })
        ESPTab:AddToggle({ Name = "Dead Check", Default = true, Callback = function(v) Dead_Check_Enabled = v; if not v then ClearTable(Player_Dead) end end })
        ESPTab:AddToggle({ Name = "Box", Default = true, Callback = function(v) Box_Enabled = v end })
        ESPTab:AddColorpicker({ Name = "Box Color", Default = Box_Color, Callback = function(v) Box_Color = v end })
        ESPTab:AddToggle({ Name = "Name", Default = true, Callback = function(v) Name_Enabled = v end })
        ESPTab:AddColorpicker({ Name = "Name Color", Default = Name_Color, Callback = function(v) Name_Color = v end })
        ESPTab:AddToggle({ Name = "Health Bar", Default = true, Callback = function(v) Health_Enabled = v end })
        ESPTab:AddToggle({ Name = "Distance", Default = true, Callback = function(v) Distance_Enabled = v end })
        ESPTab:AddToggle({ Name = "Tracers", Default = true, Callback = function(v) Tracer_Enabled = v end })
        ESPTab:AddColorpicker({ Name = "Tracer Color", Default = Tracer_Color, Callback = function(v) Tracer_Color = v end })
        ESPTab:AddDropdown({ Name = "Tracer Origin", Default = "Bottom", Options = {"Bottom", "Middle", "Top"}, Callback = function(v) Tracer_Origin = v end })
        ESPTab:AddToggle({ Name = "Head Dot", Default = true, Callback = function(v) Head_Dot_Enabled = v end })
        ESPTab:AddColorpicker({ Name = "Dot Color", Default = Head_Dot_Color, Callback = function(v) Head_Dot_Color = v end })
        local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false })
        SettingsTab:AddLabel("UI: Orion Library Loaded")
        OrionLib:Init()
    end)
    if success then
        UI_Worked = true
        ToggleMenu = function() pcall(function() OrionLib:ToggleUI() end) end
    end
end

-- ============ FALLBACK UI ============
if not UI_Worked then
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GlonksEnhancements"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local uiSizeX = isMobile and 200 or 350
    local uiSizeY = isMobile and 320 or 450
    local fontSize = isMobile and 22 or 13
    local rowHeight = isMobile and 28 or 28
    local btnSizeX = isMobile and 42 or 40
    local btnSizeY = isMobile and 22 or 20
    local titleHeight = isMobile and 28 or 40
    local tabHeight = isMobile and 24 or 35

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, uiSizeX, 0, uiSizeY)
    MainFrame.Position = UDim2.new(0.5, -uiSizeX/2, 0.5, -uiSizeY/2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    if not isMobile then
        UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
        end)
    end

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, titleHeight)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Glonk's Enhancements"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = isMobile and 14 or 16
    Title.BorderSizePixel = 0
    Title.Parent = MainFrame

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 0, tabHeight)
    TabFrame.Position = UDim2.new(0, 0, 0, titleHeight)
    TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -6, 1, -titleHeight - tabHeight - 8)
    ContentFrame.Position = UDim2.new(0, 3, 0, titleHeight + tabHeight + 4)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = false
    ContentFrame.Parent = MainFrame

    local Tab1 = Instance.new("TextButton")
    Tab1.Size = UDim2.new(1/3, 0, 1, 0)
    Tab1.Position = UDim2.new(0, 0, 0, 0)
    Tab1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab1.Text = "Aim"
    Tab1.Font = Enum.Font.SourceSansBold
    Tab1.TextSize = isMobile and 14 or 14
    Tab1.BorderSizePixel = 0
    Tab1.Parent = TabFrame

    local Tab2 = Instance.new("TextButton")
    Tab2.Size = UDim2.new(1/3, 0, 1, 0)
    Tab2.Position = UDim2.new(1/3, 0, 0, 0)
    Tab2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2.Text = "ESP"
    Tab2.Font = Enum.Font.SourceSansBold
    Tab2.TextSize = isMobile and 14 or 14
    Tab2.BorderSizePixel = 0
    Tab2.Parent = TabFrame

    local Tab3 = Instance.new("TextButton")
    Tab3.Size = UDim2.new(1/3, 0, 1, 0)
    Tab3.Position = UDim2.new(2/3, 0, 0, 0)
    Tab3.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab3.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab3.Text = "Settings"
    Tab3.Font = Enum.Font.SourceSansBold
    Tab3.TextSize = isMobile and 14 or 14
    Tab3.BorderSizePixel = 0
    Tab3.Parent = TabFrame

    local Page1 = Instance.new("Frame")
    Page1.Size = UDim2.new(1, 0, 1, 0)
    Page1.BackgroundTransparency = 1
    Page1.Parent = ContentFrame
    local Page2 = Instance.new("Frame")
    Page2.Size = UDim2.new(1, 0, 1, 0)
    Page2.BackgroundTransparency = 1
    Page2.Visible = false
    Page2.Parent = ContentFrame
    local Page3 = Instance.new("Frame")
    Page3.Size = UDim2.new(1, 0, 1, 0)
    Page3.BackgroundTransparency = 1
    Page3.Visible = false
    Page3.Parent = ContentFrame

    local ActiveTabColor = Color3.fromRGB(60, 60, 60)
    local InactiveTabColor = Color3.fromRGB(35, 35, 35)

    local function SwitchTab(tab, p1, p2, p3)
        Tab1.BackgroundColor3 = InactiveTabColor
        Tab2.BackgroundColor3 = InactiveTabColor
        Tab3.BackgroundColor3 = InactiveTabColor
        tab.BackgroundColor3 = ActiveTabColor
        p1.Visible = true; p2.Visible = false; p3.Visible = false
    end

    Tab1.MouseButton1Click:Connect(function() SwitchTab(Tab1, Page1, Page2, Page3) end)
    Tab2.MouseButton1Click:Connect(function() SwitchTab(Tab2, Page2, Page1, Page3) end)
    Tab3.MouseButton1Click:Connect(function() SwitchTab(Tab3, Page3, Page1, Page2) end)

    local Themes = {
        ["Default Blue"] = { Main = Color3.fromRGB(30, 30, 30), Primary = Color3.fromRGB(50, 50, 80), Secondary = Color3.fromRGB(70, 70, 100), ActiveTab = Color3.fromRGB(60, 60, 60), InactiveTab = Color3.fromRGB(35, 35, 35) },
        ["Red"] = { Main = Color3.fromRGB(40, 20, 20), Primary = Color3.fromRGB(80, 30, 30), Secondary = Color3.fromRGB(120, 40, 40), ActiveTab = Color3.fromRGB(120, 40, 40), InactiveTab = Color3.fromRGB(50, 25, 25) },
        ["Green"] = { Main = Color3.fromRGB(20, 40, 20), Primary = Color3.fromRGB(30, 80, 30), Secondary = Color3.fromRGB(40, 120, 40), ActiveTab = Color3.fromRGB(40, 120, 40), InactiveTab = Color3.fromRGB(25, 50, 25) },
        ["Purple"] = { Main = Color3.fromRGB(35, 20, 40), Primary = Color3.fromRGB(70, 30, 80), Secondary = Color3.fromRGB(100, 40, 120), ActiveTab = Color3.fromRGB(100, 40, 120), InactiveTab = Color3.fromRGB(50, 25, 60) },
        ["Pure Black"] = { Main = Color3.fromRGB(15, 15, 15), Primary = Color3.fromRGB(30, 30, 30), Secondary = Color3.fromRGB(50, 50, 50), ActiveTab = Color3.fromRGB(40, 40, 40), InactiveTab = Color3.fromRGB(20, 20, 20) },
        ["Pink"] = { Main = Color3.fromRGB(40, 20, 35), Primary = Color3.fromRGB(80, 30, 70), Secondary = Color3.fromRGB(120, 40, 100), ActiveTab = Color3.fromRGB(120, 40, 100), InactiveTab = Color3.fromRGB(50, 25, 45) }
    }

    local function ApplyTheme(theme)
        ActiveTabColor = theme.ActiveTab
        InactiveTabColor = theme.InactiveTab
        MainFrame.BackgroundColor3 = theme.Main
        Title.BackgroundColor3 = theme.InactiveTab
        TabFrame.BackgroundColor3 = theme.InactiveTab
        for _, child in ipairs(MainFrame:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                if child.BackgroundColor3 == Color3.fromRGB(30, 30, 30) then child.BackgroundColor3 = theme.Main
                elseif child.BackgroundColor3 == Color3.fromRGB(50, 50, 80) then child.BackgroundColor3 = theme.Primary
                elseif child.BackgroundColor3 == Color3.fromRGB(70, 70, 100) then child.BackgroundColor3 = theme.Secondary end
            end
        end
        if Page1.Visible then SwitchTab(Tab1, Page1, Page2, Page3)
        elseif Page2.Visible then SwitchTab(Tab2, Page2, Page1, Page3)
        else SwitchTab(Tab3, Page3, Page1, Page2) end
    end

    local function MakeToggle(parent, y, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, rowHeight)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -btnSizeX - 8, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Text = text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = fontSize
        lbl.Parent = frame
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnSizeX, 0, btnSizeY)
        btn.Position = UDim2.new(1, -btnSizeX - 3, 0.5, -btnSizeY/2)
        if default then btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0); btn.Text = "ON" else btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btn.Text = "OFF" end
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = isMobile and 15 or 10
        btn.BorderSizePixel = 0
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            default = not default
            if default then btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0); btn.Text = "ON" else btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btn.Text = "OFF" end
            callback(default)
        end)
        return y + rowHeight + 1
    end

    local function MakeDropdown(parent, y, text, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, rowHeight)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        frame.BorderSizePixel = 0
        frame.ZIndex = 5
        frame.Parent = parent
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 1, 0)
        btn.Position = UDim2.new(0, 2, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text .. ": " .. default
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = fontSize
        btn.BorderSizePixel = 0
        btn.ZIndex = 6
        btn.Parent = frame
        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, -4, 0, #options * (rowHeight - 4))
        listFrame.Position = UDim2.new(0, 2, 0, -#options * (rowHeight - 4) - 2)
        listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        listFrame.BorderSizePixel = 0
        listFrame.Visible = false
        listFrame.ZIndex = 10
        listFrame.Parent = frame
        btn.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible end)
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, rowHeight - 4)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1)*(rowHeight - 4))
            optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            optBtn.TextColor3 = Color3.new(1, 1, 1)
            optBtn.Text = opt
            optBtn.Font = Enum.Font.SourceSansBold
            optBtn.TextSize = fontSize
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 11
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                btn.Text = text .. ": " .. opt
                listFrame.Visible = false
                callback(opt)
            end)
        end
        return y + rowHeight + 1
    end

    local y = 0
    y = MakeToggle(Page1, y, "Enabled", Aim_Enabled, function(v) Aim_Enabled = v end)
    y = MakeDropdown(Page1, y, "Aim Key", {"MB1", "MB2"}, Aim_Key_Name, function(v) Set_Aim_Key(v) end)
    y = MakeToggle(Page1, y, "Always On", false, function(v) Aim_Always_On = v end)
    y = MakeDropdown(Page1, y, "FOV", {"50", "100", "150", "200", "300", "500"}, "150", function(v) Aim_FOV = tonumber(v) end)
    y = MakeDropdown(Page1, y, "Smoothness", {"0", "25", "50", "75", "99"}, "0", function(v) Aim_Smoothness = tonumber(v) end)
    y = MakeDropdown(Page1, y, "Aim Part", {"Head", "RootPart", "Torso", "Random"}, "Head", function(v) Aim_Part = v end)
    y = MakeToggle(Page1, y, "Wall Check", Aim_Visible_Check, function(v) Aim_Visible_Check = v end)
    y = MakeToggle(Page1, y, "Team Check", Team_Check, function(v) Team_Check = v end)
    y = MakeToggle(Page1, y, "Draw FOV", FOV_Circle_Enabled, function(v) FOV_Circle_Enabled = v end)
    y = MakeToggle(Page1, y, "Max Dist", false, function(v) Max_Distance_Enabled = v end)
    y = MakeDropdown(Page1, y, "Max Studs", {"100", "200", "300", "500", "750", "1000"}, "500", function(v) Max_Distance = tonumber(v) end)

    y = 0
    y = MakeToggle(Page2, y, "Enabled", ESP_Enabled, function(v) ESP_Enabled = v end)
    y = MakeToggle(Page2, y, "Dead Check", Dead_Check_Enabled, function(v) Dead_Check_Enabled = v; if not v then ClearTable(Player_Dead) end end)
    y = MakeToggle(Page2, y, "Box", Box_Enabled, function(v) Box_Enabled = v end)
    y = MakeToggle(Page2, y, "Name", Name_Enabled, function(v) Name_Enabled = v end)
    y = MakeToggle(Page2, y, "Health Bar", Health_Enabled, function(v) Health_Enabled = v end)
    y = MakeToggle(Page2, y, "Distance", Distance_Enabled, function(v) Distance_Enabled = v end)
    y = MakeToggle(Page2, y, "Tracers", Tracer_Enabled, function(v) Tracer_Enabled = v end)
    y = MakeDropdown(Page2, y, "Tracer Origin", {"Bottom", "Middle", "Top"}, "Bottom", function(v) Tracer_Origin = v end)
    y = MakeToggle(Page2, y, "Head Dot", Head_Dot_Enabled, function(v) Head_Dot_Enabled = v end)

    y = 0
    y = MakeToggle(Page3, y, "Fallback UI", true, function() end)
    y = MakeDropdown(Page3, y, "UI Theme", {"Default Blue", "Red", "Green", "Purple", "Pure Black", "Pink"}, "Default Blue", function(v)
        if Themes[v] then ApplyTheme(Themes[v]) end
    end)

    ToggleMenu = function()
        if MainFrame then MainFrame.Visible = not MainFrame.Visible end
    end
end

-- ============ MOBILE BUTTON ============
if isMobile then
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
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

-- ============ GAME LOGIC (100% ISOLATED) ============
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
FOV_Drawing.Filled = false; FOV_Drawing.Thickness = 1.5; FOV_Drawing.NumSides = 100; FOV_Drawing.Transparency = 0.7; FOV_Drawing.ZIndex = 2

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
        -- FIXED OFFSET: Use CFrame.lookAt and keep the game's natural UpVector
        local target_pos = part.Position
        local cam_pos = Camera.CFrame.Position
        local look_vec = (target_pos - cam_pos)
        
        -- Ignore if they are directly behind us to prevent spazzing
        if look_vec:Dot(Camera.CFrame.LookVector) > 0.1 then
            -- Calculate perfect CFrame while keeping natural camera roll/zoom
            local target_cframe = CFrame.lookAt(cam_pos, target_pos, Camera.CFrame.UpVector)
            
            -- Smooth locking math
            local s = math_clamp(0.8 - (Aim_Smoothness * 0.0075), 0.05, 0.8)
            Camera.CFrame = Camera.CFrame:Lerp(target_cframe, s)
        end
    else
        -- PC SPECIFIC AIMING
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
                local rp, rv = World_To_Screen(hrp.Position)
                local hp, hv = World_To_Screen(head.Position + v3_new(0, 0.3, 0))
                if not rv and not hv then skip = true end
            end
            if not skip then
                if not drawings then drawings = Create_ESP_Drawings(player) end
                local rp, _, _ = World_To_Screen(hrp.Position)
                local hp, _, _ = World_To_Screen(head.Position + v3_new(0, 0.3, 0))
                local health, distance = Get_Health(player), Get_Distance_From_Local(player)
                local height = math_abs((rp.Y + 2) - (hp.Y - 2))
                local width = height * 0.55
                local bx, by = rp.X - width / 2, hp.Y - 2

                drawings.Box_Outline.Position = v2_new(bx, by); drawings.Box_Outline.Size = v2_new(width, height)
                drawings.Box_Outline.Color = Box_Color; drawings.Box_Outline.Visible = Box_Enabled and ESP_Enabled
                drawings.Box_Fill.Position = v2_new(bx, by); drawings.Box_Fill.Size = v2_new(width, height)
                drawings.Box_Fill.Visible = Box_Enabled and ESP_Enabled
                local barx = bx - 6
                drawings.Health_Bar_BG.From = v2_new(barx, by); drawings.Health_Bar_BG.To = v2_new(barx, by + height)
                drawings.Health_Bar_BG.Visible = Health_Enabled and ESP_Enabled
                drawings.Health_Bar.From = v2_new(barx, by + height - (height * health)); drawings.Health_Bar.To = v2_new(barx, by + height)
                drawings.Health_Bar.Color = Color3.fromRGB((1 - health) * 255, health * 255, 40)
                drawings.Health_Bar.Visible = Health_Enabled and ESP_Enabled
                drawings.Name_Text.Text = player.Name; drawings.Name_Text.Position = v2_new(rp.X, by - 14)
                drawings.Name_Text.Color = Name_Color; drawings.Name_Text.Visible = Name_Enabled and ESP_Enabled
                drawings.Distance_Text.Text = math_floor(distance) .. "m"; drawings.Distance_Text.Position = v2_new(rp.X, by + height + 4)
                drawings.Distance_Text.Visible = Distance_Enabled and ESP_Enabled
                local oy = ss.Y
                if Tracer_Origin == "Top" then oy = 0 elseif Tracer_Origin == "Middle" then oy = ss.Y / 2 end
                drawings.Tracer_Line.From = v2_new(ss.X / 2, oy); drawings.Tracer_Line.To = v2_new(rp.X, rp.Y)
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

Services.Players.PlayerRemoving:Connect(function(player)
    if ESP_Pool[player] then
        for _, d in pairs(ESP_Pool[player]) do pcall(d.Remove, d) end
        ESP_Pool[player] = nil
    end
    Player_Dead[player] = nil
end)
