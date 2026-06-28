local replicated_first = game:GetService("ReplicatedFirst")
local players = game:GetService("Players")
local packets = require(replicated_first:WaitForChild("neuron")).net.packets
local peuron = require(replicated_first.neuron)

function resolve_player(player)
    if not player or player.Character then
        return
    end

    local neuron_character = peuron:get_character(player)
    player.Character = neuron_character

    if player.Character ~= neuron_character then
        return error("Failed to set", player.Name)
    end

    return neuron_character, player
end

task.spawn(function()
    while wait() do
        for _, v in game.Players:GetPlayers() do
            resolve_player(v)
        end
    end
end)

local Services = {
    Players = game:GetService("Players"),
    Run_Service = game:GetService("RunService"),
    User_Input = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
}

local Local_Player = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

local v2_new = Vector2.new
local v3_new = Vector3.new
local cframe_new = CFrame.new
local cframe_angles = CFrame.Angles
local math_atan2 = math.atan2
local math_rad = math.rad
local math_sqrt = math.sqrt
local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local math_pi = math.pi
local math_floor = math.floor
local table_insert = table.insert
local table_clear = table.clear or function(t) for k in next, t do t[k] = nil end end

local ESP_Enabled = true
local Box_Enabled = true
local Name_Enabled = true
local Health_Enabled = true
local Distance_Enabled = true
local Tracer_Enabled = true
local Head_Dot_Enabled = true

local Box_Color = Color3.fromRGB(255, 255, 255)
local Name_Color = Color3.fromRGB(255, 255, 255)
local Tracer_Color = Color3.fromRGB(255, 255, 255)
local Head_Dot_Color = Color3.fromRGB(255, 0, 0)
local Tracer_Origin = "Bottom"

local Aim_Enabled = true
local Aim_FOV = 150
local Aim_Smoothness = 3
local Aim_Part = "Head"
local Aim_Key_Name = "MB2"
local Aim_Key = Enum.UserInputType.MouseButton2
local Aim_Visible_Check = true
local Team_Check = false

local FOV_Circle_Enabled = true
local FOV_Circle_Color = Color3.fromRGB(255, 255, 255)
local FOV_Circle_Transparency = 0.7

local function Set_Aim_Key(value)
    Aim_Key_Name = value
    if value == "MB1" then
        Aim_Key = Enum.UserInputType.MouseButton1
    else
        Aim_Key = Enum.UserInputType.MouseButton2
    end
end

local function Is_Behind_Wall(part)
    if not Aim_Visible_Check then return false end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit = Services.Workspace:FindPartOnRayWithIgnoreList(ray, { Local_Player.Character }, false, true)
    return hit and hit:IsDescendantOf(part.Parent) == false
end

local function World_To_Screen(position)
    local point, on_screen = Camera:WorldToViewportPoint(position)
    return v2_new(point.X, point.Y), on_screen, point.Z
end

local function Get_Nearest_Part(player, part_name)
    local char = player.Character
    if not char then return nil end
    if part_name == "Head" then
        return char:FindFirstChild("Head")
    elseif part_name == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    elseif part_name == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    elseif part_name == "Random" then
        local parts = {}
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then table_insert(parts, v) end
        end
        if #parts == 0 then return char:FindFirstChild("HumanoidRootPart") end
        return parts[math.random(1, #parts)]
    end
    return char:FindFirstChild(part_name)
end

local function Get_Distance_From_Local(player)
    local char = player.Character
    local local_char = Local_Player.Character
    if not char or not local_char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    local local_root = local_char:FindFirstChild("HumanoidRootPart")
    if not root or not local_root then return 0 end
    return (root.Position - local_root.Position).Magnitude
end

local function Get_Health(player)
    local char = player.Character
    if not char then return 0 end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 0 end
    return humanoid.Health / humanoid.MaxHealth
end

local FOV_Drawing = Drawing.new("Circle")
FOV_Drawing.Visible = false
FOV_Drawing.Filled = false
FOV_Drawing.Color = FOV_Circle_Color
FOV_Drawing.Thickness = 1.5
FOV_Drawing.NumSides = 100
FOV_Drawing.Transparency = FOV_Circle_Transparency
FOV_Drawing.ZIndex = 2

local ESP_Pool = {}

local function Create_ESP_Drawings(player)
    local drawings = {}
    drawings.Box_Outline = Drawing.new("Square")
    drawings.Box_Outline.Visible = false
    drawings.Box_Outline.Filled = false
    drawings.Box_Outline.Color = Box_Color
    drawings.Box_Outline.Thickness = 1.5
    drawings.Box_Outline.ZIndex = 3

    drawings.Box_Fill = Drawing.new("Square")
    drawings.Box_Fill.Visible = false
    drawings.Box_Fill.Filled = true
    drawings.Box_Fill.Color = Color3.fromRGB(0, 0, 0)
    drawings.Box_Fill.Transparency = 0.7
    drawings.Box_Fill.ZIndex = 2

    drawings.Health_Bar_BG = Drawing.new("Line")
    drawings.Health_Bar_BG.Visible = false
    drawings.Health_Bar_BG.Color = Color3.fromRGB(40, 40, 40)
    drawings.Health_Bar_BG.Thickness = 2
    drawings.Health_Bar_BG.ZIndex = 3

    drawings.Health_Bar = Drawing.new("Line")
    drawings.Health_Bar.Visible = false
    drawings.Health_Bar.Color = Color3.fromRGB(0, 255, 0)
    drawings.Health_Bar.Thickness = 2
    drawings.Health_Bar.ZIndex = 4

    drawings.Name_Text = Drawing.new("Text")
    drawings.Name_Text.Visible = false
    drawings.Name_Text.Color = Name_Color
    drawings.Name_Text.Size = 13
    drawings.Name_Text.Center = true
    drawings.Name_Text.Outline = true
    drawings.Name_Text.Font = Drawing.Fonts.Plex
    drawings.Name_Text.ZIndex = 3

    drawings.Distance_Text = Drawing.new("Text")
    drawings.Distance_Text.Visible = false
    drawings.Distance_Text.Color = Color3.fromRGB(200, 200, 200)
    drawings.Distance_Text.Size = 12
    drawings.Distance_Text.Center = true
    drawings.Distance_Text.Outline = true
    drawings.Distance_Text.Font = Drawing.Fonts.Plex
    drawings.Distance_Text.ZIndex = 3

    drawings.Tracer_Line = Drawing.new("Line")
    drawings.Tracer_Line.Visible = false
    drawings.Tracer_Line.Color = Tracer_Color
    drawings.Tracer_Line.Thickness = 1
    drawings.Tracer_Line.Transparency = 0.5
    drawings.Tracer_Line.ZIndex = 1

    drawings.Head_Dot = Drawing.new("Circle")
    drawings.Head_Dot.Visible = false
    drawings.Head_Dot.Filled = true
    drawings.Head_Dot.Color = Head_Dot_Color
    drawings.Head_Dot.Radius = 4
    drawings.Head_Dot.NumSides = 20
    drawings.Head_Dot.ZIndex = 4

    ESP_Pool[player] = drawings
    return drawings
end

local function Remove_ESP_Drawings(player)
    local drawings = ESP_Pool[player]
    if not drawings then return end
    for _, d in pairs(drawings) do
        pcall(function() d:Remove() end)
    end
    ESP_Pool[player] = nil
end

local function Cleanup_ESP_Drawings()
    for player, drawings in pairs(ESP_Pool) do
        if not player.Parent then
            for _, d in pairs(drawings) do
                pcall(function() d:Remove() end)
            end
            ESP_Pool[player] = nil
        end
    end
end

local function Get_Corner_Points(pos, size)
    local x, y = pos.X, pos.Y
    local w, h = size.X, size.Y
    return {
        TopLeft = v2_new(x, y),
        TopRight = v2_new(x + w, y),
        BottomLeft = v2_new(x, y + h),
        BottomRight = v2_new(x + w, y + h),
    }
end

local function Get_Closest_Target()
    local closest_player = nil
    local closest_distance = Aim_FOV
    local mouse_pos = Services.User_Input:GetMouseLocation()
    local screen_center = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == Local_Player then continue end
        if Team_Check and player.Team == Local_Player.Team then continue end
        local char = player.Character
        if not char then continue end
        local target_part = Get_Nearest_Part(player, Aim_Part)
        if not target_part then continue end
        if Aim_Visible_Check and Is_Behind_Wall(target_part) then continue end
        local screen_pos, on_screen = World_To_Screen(target_part.Position)
        if not on_screen then continue end
        local dist = (screen_pos - screen_center).Magnitude
        if dist < closest_distance then
            closest_distance = dist
            closest_player = player
        end
    end
    return closest_player
end

local function Aim_At_Target(player)
    if not player then return end
    local char = player.Character
    if not char then return end
    local target_part = Get_Nearest_Part(player, Aim_Part)
    if not target_part then return end
    local screen_pos, on_screen = World_To_Screen(target_part.Position)
    if not on_screen then return end
    local screen_center = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local delta = (screen_pos - screen_center) / Aim_Smoothness
    mousemoverel(delta.X, delta.Y)
end

local function Update_ESP()
    Cleanup_ESP_Drawings()
    local screen_size = Camera.ViewportSize

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == Local_Player then continue end
        if Team_Check and player.Team == Local_Player.Team then continue end
        local char = player.Character
        if not char then
            local drawings = ESP_Pool[player]
            if drawings then
                for _, d in pairs(drawings) do d.Visible = false end
            end
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then
            local drawings = ESP_Pool[player]
            if drawings then
                for _, d in pairs(drawings) do d.Visible = false end
            end
            continue
        end

        local root_pos, root_visible, root_depth = World_To_Screen(hrp.Position)
        local head_pos, head_visible, head_depth = World_To_Screen(head.Position + v3_new(0, 0.3, 0))

        local drawings = ESP_Pool[player]
        if not drawings then
            drawings = Create_ESP_Drawings(player)
        end

        if not root_visible and not head_visible then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local health = Get_Health(player)
        local distance = Get_Distance_From_Local(player)
        local dist_str = tostring(math_floor(distance)) .. "m"

        local head_size = 2
        local head_y = head_pos.Y - head_size
        local root_size = 2
        local root_y = root_pos.Y + root_size
        local height = math_abs(root_y - head_y)
        local width = height * 0.55
        local box_x = root_pos.X - width / 2
        local box_y = head_pos.Y - head_size

        if Box_Enabled and ESP_Enabled then
            drawings.Box_Outline.Position = v2_new(box_x, box_y)
            drawings.Box_Outline.Size = v2_new(width, height)
            drawings.Box_Outline.Visible = true
            drawings.Box_Outline.Color = Box_Color

            drawings.Box_Fill.Position = v2_new(box_x, box_y)
            drawings.Box_Fill.Size = v2_new(width, height)
            drawings.Box_Fill.Visible = true
        else
            drawings.Box_Outline.Visible = false
            drawings.Box_Fill.Visible = false
        end

        if Health_Enabled and ESP_Enabled then
            local bar_x = box_x - 6
            local bar_height = height
            drawings.Health_Bar_BG.From = v2_new(bar_x, box_y)
            drawings.Health_Bar_BG.To = v2_new(bar_x, box_y + bar_height)
            drawings.Health_Bar_BG.Visible = true

            local filled_height = bar_height * health
            local start_y = box_y + bar_height - filled_height
            drawings.Health_Bar.From = v2_new(bar_x, start_y)
            drawings.Health_Bar.To = v2_new(bar_x, box_y + bar_height)
            drawings.Health_Bar.Visible = true

            local r = (1 - health) * 255
            local g = health * 255
            drawings.Health_Bar.Color = Color3.fromRGB(r, g, 40)
        else
            drawings.Health_Bar_BG.Visible = false
            drawings.Health_Bar.Visible = false
        end

        if Name_Enabled and ESP_Enabled then
            drawings.Name_Text.Text = player.Name
            drawings.Name_Text.Position = v2_new(root_pos.X, box_y - 14)
            drawings.Name_Text.Visible = true
            drawings.Name_Text.Color = Name_Color
        else
            drawings.Name_Text.Visible = false
        end

        if Distance_Enabled and ESP_Enabled then
            drawings.Distance_Text.Text = dist_str
            drawings.Distance_Text.Position = v2_new(root_pos.X, box_y + height + 4)
            drawings.Distance_Text.Visible = true
        else
            drawings.Distance_Text.Visible = false
        end

        if Tracer_Enabled and ESP_Enabled then
            local origin_x = Tracer_Origin == "Bottom"
                and screen_size.X / 2
                or Tracer_Origin == "Top"
                    and screen_size.X / 2
                    or Tracer_Origin == "Middle"
                        and screen_size.X / 2
                        or screen_size.X / 2
            local origin_y = Tracer_Origin == "Bottom"
                and screen_size.Y
                or Tracer_Origin == "Top"
                    and 0
                    or screen_size.Y / 2

            drawings.Tracer_Line.From = v2_new(origin_x, origin_y)
            drawings.Tracer_Line.To = v2_new(root_pos.X, root_pos.Y)
            drawings.Tracer_Line.Visible = true
        else
            drawings.Tracer_Line.Visible = false
        end

        if Head_Dot_Enabled and ESP_Enabled then
            drawings.Head_Dot.Position = head_pos
            drawings.Head_Dot.Visible = true
        else
            drawings.Head_Dot.Visible = false
        end
    end
end

local function Update_Aim()
    if not Aim_Enabled then return end
    local is_key_down = Services.User_Input:IsMouseButtonPressed(Aim_Key)
    if not is_key_down then return end
    local target = Get_Closest_Target()
    if target then
        Aim_At_Target(target)
    end
end

local function Update_FOV_Circle()
    if not FOV_Circle_Enabled then
        FOV_Drawing.Visible = false
        return
    end
    local center = v2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Drawing.Position = center
    FOV_Drawing.Radius = Aim_FOV
    FOV_Drawing.Visible = true
    FOV_Drawing.Color = FOV_Circle_Color
end

Services.Run_Service.RenderStepped:Connect(function()
    Update_ESP()
    Update_Aim()
    Update_FOV_Circle()
end)

Services.Players.PlayerRemoving:Connect(function(player)
    Remove_ESP_Drawings(player)
end)

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local UI_Loaded, UI_Library = pcall(function()
    return loadstring(game:HttpGet(repo .. "Library.lua"))()
end)

if UI_Loaded and UI_Library then
    local Window = UI_Library:CreateWindow({
        Title = "fucking overkill",
        Center = true,
        AutoShow = true,
    })

    local Tabs = {
        Aim = Window:AddTab("Aim"),
        ESP = Window:AddTab("ESP"),
    }

    local Aim_Group = Tabs.Aim:AddLeftGroupbox("Aim")
    Aim_Group:AddToggle("Aim_Enabled", { Text = "Enabled", Default = true, Tooltip = "Toggle Aim" })
    Aim_Group:AddDropdown("Aim_Key_Select", { Text = "Aim Key", Default = "MB2", Values = { "MB1", "MB2" }, Multi = false })
    Aim_Group:AddSlider("Aim_FOV", { Text = "FOV", Default = 150, Min = 20, Max = 500, Rounding = 0, Suffix = "px" })
    Aim_Group:AddSlider("Aim_Smoothness", { Text = "Smoothness", Default = 3, Min = 1, Max = 20, Rounding = 1 })
    Aim_Group:AddDropdown("Aim_Part", { Text = "Aim Part", Default = "Head", Values = { "Head", "HumanoidRootPart", "Torso", "Random" }, Multi = false })
    Aim_Group:AddToggle("Visible_Check", { Text = "Visible Check", Default = true })
    Aim_Group:AddToggle("Team_Check", { Text = "Team Check", Default = false })
    Aim_Group:AddToggle("FOV_Circle", { Text = "Draw FOV", Default = true })
    Aim_Group:AddLabel("FOV Color"):AddColorPicker("FOV_Color", { Default = Color3.fromRGB(255, 255, 255), Title = "FOV Circle Color" })

    local ESP_Group = Tabs.ESP:AddLeftGroupbox("ESP")
    ESP_Group:AddToggle("ESP_Enabled", { Text = "Enabled", Default = true })
    ESP_Group:AddToggle("Box", { Text = "Box", Default = true })
    ESP_Group:AddLabel("Box Color"):AddColorPicker("Box_Color", { Default = Color3.fromRGB(255, 255, 255), Title = "Box Color" })
    ESP_Group:AddToggle("Name", { Text = "Name", Default = true })
    ESP_Group:AddLabel("Name Color"):AddColorPicker("Name_Color", { Default = Color3.fromRGB(255, 255, 255), Title = "Name Color" })
    ESP_Group:AddToggle("Health", { Text = "Health Bar", Default = true })
    ESP_Group:AddToggle("Distance", { Text = "Distance", Default = true })
    ESP_Group:AddToggle("Tracer", { Text = "Tracers", Default = true })
    ESP_Group:AddLabel("Tracer Color"):AddColorPicker("Tracer_Color", { Default = Color3.fromRGB(255, 255, 255), Title = "Tracer Color" })
    ESP_Group:AddDropdown("Tracer_Origin", { Text = "Tracer Origin", Default = "Bottom", Values = { "Bottom", "Middle", "Top" }, Multi = false })
    ESP_Group:AddToggle("Head_Dot", { Text = "Head Dot", Default = true })
    ESP_Group:AddLabel("Dot Color"):AddColorPicker("Head_Dot_Color", { Default = Color3.fromRGB(255, 0, 0), Title = "Head Dot Color" })

    Toggles.Aim_Enabled:OnChanged(function() Aim_Enabled = Toggles.Aim_Enabled.Value end)
    Toggles.Visible_Check:OnChanged(function() Aim_Visible_Check = Toggles.Visible_Check.Value end)
    Toggles.Team_Check:OnChanged(function() Team_Check = Toggles.Team_Check.Value end)
    Toggles.FOV_Circle:OnChanged(function() FOV_Circle_Enabled = Toggles.FOV_Circle.Value end)
    Toggles.ESP_Enabled:OnChanged(function() ESP_Enabled = Toggles.ESP_Enabled.Value end)
    Toggles.Box:OnChanged(function() Box_Enabled = Toggles.Box.Value end)
    Toggles.Name:OnChanged(function() Name_Enabled = Toggles.Name.Value end)
    Toggles.Health:OnChanged(function() Health_Enabled = Toggles.Health.Value end)
    Toggles.Distance:OnChanged(function() Distance_Enabled = Toggles.Distance.Value end)
    Toggles.Tracer:OnChanged(function() Tracer_Enabled = Toggles.Tracer.Value end)
    Toggles.Head_Dot:OnChanged(function() Head_Dot_Enabled = Toggles.Head_Dot.Value end)

    Options.Aim_FOV:OnChanged(function() Aim_FOV = Options.Aim_FOV.Value end)
    Options.Aim_Smoothness:OnChanged(function() Aim_Smoothness = Options.Aim_Smoothness.Value end)
    Options.Aim_Part:OnChanged(function() Aim_Part = Options.Aim_Part.Value end)
    Options.Aim_Key_Select:OnChanged(function()
        Set_Aim_Key(Options.Aim_Key_Select.Value)
    end)
    Options.Tracer_Origin:OnChanged(function() Tracer_Origin = Options.Tracer_Origin.Value end)
    Options.Box_Color:OnChanged(function() Box_Color = Options.Box_Color.Value end)
    Options.Name_Color:OnChanged(function() Name_Color = Options.Name_Color.Value end)
    Options.Tracer_Color:OnChanged(function() Tracer_Color = Options.Tracer_Color.Value end)
    Options.Head_Dot_Color:OnChanged(function() Head_Dot_Color = Options.Head_Dot_Color.Value end)
    Options.FOV_Color:OnChanged(function() FOV_Circle_Color = Options.FOV_Color.Value end)
end
