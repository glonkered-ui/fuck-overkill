-- ============ VARIABLES FIRST ============
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
local Player_Dead = {}
local ESP_Pool = {}

local function Set_Aim_Key(value)
    Aim_Key_Name = value
    if value == "MB1" then
        Aim_Key = Enum.UserInputType.MouseButton1
    else
        Aim_Key = Enum.UserInputType.MouseButton2
    end
end

local function ClearTable(t)
    for k in next, t do t[k] = nil end
end

-- ============ UI SETUP ============
local UI_Success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

local UI_Worked = false

if UI_Success and OrionLib then
    local success, err = pcall(function()
        local Window = OrionLib:MakeWindow({
            Name = "Glonk's Enhancements",
            HidePremium = false,
            IntroText = "Loading...",
            SaveConfig = true,
            ConfigFolder = "GlonksEnhancementsConfig"
        })

        local AimTab = Window:MakeTab({ Name = "Aim", Icon = "rbxassetid://4483345998", PremiumOnly = false })
        AimTab:AddToggle({ Name = "Enabled", Default = true, Callback = function(v) Aim_Enabled = v end })
        AimTab:AddDropdown({ Name = "Aim Key", Default = "MB2", Options = {"MB1", "MB2"}, Callback = function(v) Set_Aim_Key(v) end })
        AimTab:AddSlider({ Name = "FOV", Min = 20, Max = 500, Default = 150, Increment = 1, Callback = function(v) Aim_FOV = v end })
        AimTab:AddSlider({ Name = "Smoothness", Min = 0, Max = 99, Default = 0, Increment = 1, Callback = function(v) Aim_Smoothness = v end })
        AimTab:AddDropdown({ Name = "Aim Part", Default = "Head", Options = {"Head", "HumanoidRootPart", "Torso", "Random"}, Callback = function(v) Aim_Part = v end })
        AimTab:AddToggle({ Name = "Visible Check", Default = true, Callback = function(v) Aim_Visible_Check = v end })
        AimTab:AddToggle({ Name = "Team Check", Default = false, Callback = function(v) Team_Check = v end })
        AimTab:AddToggle({ Name = "Draw FOV", Default = true, Callback = function(v) FOV_Circle_Enabled = v end })
        AimTab:AddColorpicker({ Name = "FOV Color", Default = FOV_Circle_Color, Callback = function(v) FOV_Circle_Color = v end })

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
    if success then UI_Worked = true end
end

-- ============ ULTRA-COMPATIBLE FALLBACK UI ============
if not UI_Worked then
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GlonksEnhancements"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- RIGHT SHIFT TOGGLE
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.RightShift then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    end)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Glonk's Enhancements (RightShift)"
    Title.Font = Enum.Font.SourceSans
    Title.TextSize = 14
    Title.BorderSizePixel = 0
    Title.Parent = MainFrame

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 0, 25)
    TabFrame.Position = UDim2.new(0, 0, 0, 30)
    TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -10, 1, -65)
    ContentFrame.Position = UDim2.new(0, 5, 0, 60)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = false
    ContentFrame.Parent = MainFrame

    local Tab1 = Instance.new("TextButton")
    Tab1.Size = UDim2.new(1/3, 0, 1, 0)
    Tab1.Position = UDim2.new(0, 0, 0, 0)
    Tab1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab1.Text = "Aim"
    Tab1.Font = Enum.Font.SourceSans
    Tab1.TextSize = 12
    Tab1.BorderSizePixel = 0
    Tab1.Parent = TabFrame

    local Tab2 = Instance.new("TextButton")
    Tab2.Size = UDim2.new(1/3, 0, 1, 0)
    Tab2.Position = UDim2.new(1/3, 0, 0, 0)
    Tab2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2.Text = "ESP"
    Tab2.Font = Enum.Font.SourceSans
    Tab2.TextSize = 12
    Tab2.BorderSizePixel = 0
    Tab2.Parent = TabFrame

    local Tab3 = Instance.new("TextButton")
    Tab3.Size = UDim2.new(1/3, 0, 1, 0)
    Tab3.Position = UDim2.new(2/3, 0, 0, 0)
    Tab3.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab3.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab3.Text = "Settings"
    Tab3.Font = Enum.Font.SourceSans
    Tab3.TextSize = 12
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

    local function SwitchTab(tab, p1, p2, p3)
        Tab1.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Tab2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Tab3.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        tab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        p1.Visible = true
        p2.Visible = false
        p3.Visible = false
    end

    Tab1.MouseButton1Click:Connect(function() SwitchTab(Tab1, Page1, Page2, Page3) end)
    Tab2.MouseButton1Click:Connect(function() SwitchTab(Tab2, Page2, Page1, Page3) end)
    Tab3.MouseButton1Click:Connect(function() SwitchTab(Tab3, Page3, Page1, Page2) end)

    local function MakeToggle(parent, y, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 25)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -45, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Text = text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 12
        lbl.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 35, 0, 18)
        btn.Position = UDim2.new(1, -40, 0.5, -9)
        if default then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            btn.Text = "OFF"
        end
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            default = not default
            if default then
                btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                btn.Text = "ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                btn.Text = "OFF"
            end
            callback(default)
        end)
        return y + 28
    end

    local function MakeDropdown(parent, y, text, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 25)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        frame.BorderSizePixel = 0
        frame.ZIndex = 5
        frame.Parent = parent
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 1, 0)
        btn.Position = UDim2.new(0, 5, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text .. ": " .. default
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.ZIndex = 6
        btn.Parent = frame
        
        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, -10, 0, #options * 22)
        -- CHANGED: Position above the button instead of below
        listFrame.Position = UDim2.new(0, 5, 0, -#options * 22 - 2)
        listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        listFrame.BorderSizePixel = 0
        listFrame.Visible = false
        listFrame.ZIndex = 10
        listFrame.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            listFrame.Visible = not listFrame.Visible
        end)
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 22)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1)*22)
            optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            optBtn.TextColor3 = Color3.new(1, 1, 1)
            optBtn.Text = opt
            optBtn.Font = Enum.Font.SourceSans
            optBtn.TextSize = 11
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 11
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                btn.Text = text .. ": " .. opt
                listFrame.Visible = false
                callback(opt)
            end)
        end
        return y + 28
    end

    -- Build Aim Tab
    local y = 0
    y = MakeToggle(Page1, y, "Enabled", Aim_Enabled, function(v) Aim_Enabled = v end)
    y = MakeDropdown(Page1, y, "Aim Key", {"MB1", "MB2"}, Aim_Key_Name, function(v) Set_Aim_Key(v) end)
    y = MakeDropdown(Page1, y, "FOV", {"50", "100", "150", "200", "300", "500"}, "150", function(v) Aim_FOV = tonumber(v) end)
    y = MakeDropdown(Page1, y, "Smoothness", {"0", "25", "50", "75", "99"}, "0", function(v) Aim_Smoothness = tonumber(v) end)
    y = MakeDropdown(Page1, y, "Aim Part", {"Head", "HumanoidRootPart", "Torso", "Random"}, "Head", function(v) Aim_Part = v end)
    y = MakeToggle(Page1, y, "Visible Check", Aim_Visible_Check, function(v) Aim_Visible_Check = v end)
    y = MakeToggle(Page1, y, "Team Check", Team_Check, function(v) Team_Check = v end)
    y = MakeToggle(Page1, y, "Draw FOV", FOV_Circle_Enabled, function(v) FOV_Circle_Enabled = v end)

    -- Build ESP Tab
    y = 0
    y = MakeToggle(Page2, y, "Enabled", ESP_Enabled, function(v) ESP_Enabled = v end)
    y = MakeToggle(Page2, y, "Dead Check", Dead_Check_Enabled, function(v) Dead_Check_Enabled = v; if not v then ClearTable(Player_Dead) end end)
    y = MakeToggle(Page2, y, "Box", Box_Enabled, function(v) Box_Enabled = v end)
    y = MakeToggle(Page2, y, "Name", Name_Enabled, function(v) Name_Enabled = v end)
    y = MakeToggle(Page2, y, "Health Bar", ZHealth_Enabled, function(v) Health_Enabled = v end)
    y = MakeToggle(Page2, y, "Distance", Distance_Enabled, function(v) Distance_Enabled = v end)
    y = MakeToggle(Page2, y, "Tracers", Tracer_Enabled, function(v) Tracer_Enabled = v end)
    y = MakeDropdown(Page2, y, "Tracer Origin", {"Bottom", "Middle", "Top"}, "Bottom", function(v) Tracer_Origin = v end)
    y = MakeToggle(Page2, y, "Head Dot", Head_Dot_Enabled, function(v) Head_Dot_Enabled = v end)

    -- Build Settings Tab
    y = 0
    y = MakeToggle(Page3, y, "Fallback Mode Active", true, function() end)
end

-- ============ GAME LOGIC ============
pcall(function()
    local replicated_first = game:GetService("ReplicatedFirst")
    local peuron = require(replicated_first:WaitForChild("neuron"))
    task.spawn(function()
        while task.wait() do
            for _, v in game.Players:GetPlayers() do
                if not v.Character then v.Character = peuron:get_character(v) end
            end
        end
    end)
end)

local Services = {
    Players = game:GetService("Players"),
    Run_Service = game:GetService("RunService"),
    User_Input = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
}

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
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then table_insert(parts, v) end
        end
        if #parts > 0 then return parts[math.random(1, #parts)] else return char:FindFirstChild("HumanoidRootPart") end
    end
    if part_name == "Torso" then return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end
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
    d.Head_Dot = Drawing.new("Frame"); d.Head_Dot.Filled = true; d.Head_Dot.Radius = 4; d.Head_Dot.NumSides = 20; d.Head_Dot.ZIndex = 4
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
                local sp, vis = World_To_Screen(part.Position)
                if vis then
                    local d = (sp - center).Magnitude
                    if d < dist then dist, closest = d, p end
                end
            end
        end
    end
    return closest
end

local function Aim_At_Target(player)
    local part = Get_Nearest_Part(player, Aim_Part)
    if not part then return end
    local sp, vis = World_To_Screen(part.Position)
    if not vis then return end
    local center = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local delta = sp - center
    local s = math_clamp(1 - (math_clamp(Aim_Smoothness, 0, 99) / 100), 0.01, 1)
    mousemoverel(delta.X * s, delta.Y * s)
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
    if Aim_Enabled and Services.User_Input:IsMouseButtonPressed(Aim_Key) then
        local t = Get_Closest_Target()
        if t then Aim_At_Target(t) end
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
