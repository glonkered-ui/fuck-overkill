local replicated_first = game:GetService("ReplicatedFirst")
local players = game:GetService("Players")
local packets = require(replicated_first:WaitForChild("neuron")).net.packets
local peuron = require(replicated_first.neuron)
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIVisible = true
local Menu_Background_Color = Color3.fromRGB(20, 20, 20)
local Menu_Text_Color = Color3.fromRGB(255, 255, 255)
local Menu_Outline_Color = Color3.fromRGB(60, 60, 60)

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
    while true do
        wait()
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
local Dead_Check_Enabled = true

local Box_Color = Color3.fromRGB(255, 255, 255)
local Name_Color = Color3.fromRGB(255, 255, 255)
local Tracer_Color = Color3.fromRGB(255, 255, 255)
local Head_Dot_Color = Color3.fromRGB(255, 0, 0)
local Tracer_Origin = "Bottom"

local Aim_Enabled = true
local Aim_FOV = 150
local Aim_Smoothness = 0 -- 0 is instant, 99 is very smooth
local Aim_Part = "Head"
local Aim_Key_Name = "MB2"
local Aim_Key = Enum.UserInputType.MouseButton2
local Aim_Visible_Check = true
local Team_Check = false

local FOV_Circle_Enabled = true
local FOV_Circle_Color = Color3.fromRGB(255, 255, 255)
local FOV_Circle_Transparency = 0.7

local Window
local Connections = {}

local function AddConnection(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        table.insert(Connections, conn)
    end
    return conn
end

local function RemoveAllDrawings()
    if FOV_Drawing then
        pcall(function() FOV_Drawing.Visible = false end)
        pcall(function() FOV_Drawing:Remove() end)
        FOV_Drawing = nil
    end

    for player, drawings in pairs(ESP_Pool) do
        for _, d in pairs(drawings) do
            pcall(function() d:Remove() end)
        end
        ESP_Pool[player] = nil
    end
end

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
    local direction = (part.Position - origin)
    local ray = Ray.new(origin, direction)
    
    local ignore_list = {}
    if Local_Player.Character then
        table_insert(ignore_list, Local_Player.Character)
    end
    if part and part.Parent then
        table_insert(ignore_list, part.Parent)
    end
    
    local hit = Services.Workspace:FindPartOnRayWithIgnoreList(ray, ignore_list, false, true)
    return hit ~= nil
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

local function Find_Custom_Health_Values(player)
    local roots = {}
    if player then
        table_insert(roots, player)
    end
    if player.Character then
        table_insert(roots, player.Character)
    end

    local health_value
    local max_health_value

    local function check_instance(inst)
        local name = inst.Name:lower()
        local value

        if inst:IsA("NumberValue") or inst:IsA("IntValue") or inst:IsA("DoubleConstrainedValue") then
            value = inst.Value
        elseif inst:IsA("StringValue") then
            value = tonumber(inst.Value)
        else
            return
        end

        if value == nil then
            return
        end

        if name == "health" or name == "hp" or name == "currenthealth" or name == "healthamount" or name == "healthvalue" or name == "hpvalue" then
            health_value = health_value or value
        elseif name == "maxhealth" or name == "maxhp" or name == "healthmax" or name == "maxhealthvalue" or name == "maxhpvalue" then
            max_health_value = max_health_value or value
        end
    end

    for _, root in ipairs(roots) do
        if root then
            for _, inst in ipairs(root:GetDescendants()) do
                check_instance(inst)
            end

            if health_value == nil then
                local attr_health = root:GetAttribute("Health") or root:GetAttribute("HP")
                health_value = tonumber(attr_health) or attr_health
            end
            if max_health_value == nil then
                local attr_max = root:GetAttribute("MaxHealth") or root:GetAttribute("MaxHP")
                max_health_value = tonumber(attr_max) or attr_max
            end
        end
    end

    return health_value, max_health_value
end

local function Find_Custom_Dead_State(player)
    local roots = {}
    if player then
        table_insert(roots, player)
    end
    if player.Character then
        table_insert(roots, player.Character)
    end

    for _, root in ipairs(roots) do
        if root then
            for _, inst in ipairs(root:GetDescendants()) do
                local name = inst.Name:lower()
                if name == "dead" or name == "isdead" or name == "died" or name == "is_dead" then
                    if inst:IsA("BoolValue") then
                        return inst.Value
                    elseif inst:IsA("IntValue") or inst:IsA("NumberValue") or inst:IsA("DoubleConstrainedValue") then
                        return inst.Value ~= 0
                    elseif inst.GetAttribute then
                        local attr = inst:GetAttribute("Value")
                        if attr ~= nil then
                            return attr ~= 0 and attr ~= false
                        end
                    end
                end
            end

            local attr_dead = root:GetAttribute("Dead")
            if attr_dead ~= nil then
                return attr_dead == true or attr_dead ~= 0
            end
        end
    end

    return false
end

local function Get_Health(player)
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
                return humanoid.Health / humanoid.MaxHealth
            end
            return humanoid.Health > 0 and 1 or 0
        end
    end

    local health, max_health = Find_Custom_Health_Values(player)
    if health == nil then
        return 0
    end

    if max_health and max_health > 0 then
        return math.clamp(health / max_health, 0, 1)
    end

    return health > 0 and 1 or 0
end

local function Is_Player_Dead(player)
    local char = player.Character
    if not char then return true end -- No character means dead/respawning
    
    -- Check custom dead state first
    if Find_Custom_Dead_State(player) then
        return true
    end
    
    local health, max_health = Find_Custom_Health_Values(player)
    if health ~= nil then
        -- If custom health exists, use it to determine death
        return health <= 0
    end
    
    -- Fallback to humanoid if no custom health
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid:GetState() == Enum.HumanoidStateType.Dead then return true end
        if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
            return humanoid.Health <= 0
        end
    end
    
    return false
end

local function Is_Same_Team(player)
    if not Team_Check then return false end
    return Local_Player.Team ~= nil and player.Team == Local_Player.Team
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
local Player_Dead = {}
local Player_Death_Connections = {}

local function Set_Player_ESP_Visibility(player, visible)
    local drawings = ESP_Pool[player]
    if not drawings then return end
    for _, d in pairs(drawings) do
        d.Visible = visible
    end
end

local function Clear_Player_Death_Connections(player)
    if not Player_Death_Connections[player] then return end
    for _, conn in pairs(Player_Death_Connections[player]) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    Player_Death_Connections[player] = nil
end

local function Handle_Humanoid_Death(player, humanoid)
    if not humanoid then return end

    local function update_state()
        if not Dead_Check_Enabled then
            Player_Dead[player] = nil
            return
        end
        Player_Dead[player] = Is_Player_Dead(player)
    end

    update_state()

    local health_conn = AddConnection(humanoid.HealthChanged:Connect(function()
        update_state()
    end))

    local died_conn = AddConnection(humanoid.Died:Connect(function()
        update_state()
    end))

    Player_Death_Connections[player] = Player_Death_Connections[player] or {}
    table.insert(Player_Death_Connections[player], health_conn)
    table.insert(Player_Death_Connections[player], died_conn)
end

local function Bind_Player_Death(player)
    Clear_Player_Death_Connections(player)

    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Handle_Humanoid_Death(player, humanoid)
        end

        AddConnection(player.Character.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                Handle_Humanoid_Death(player, child)
            end
        end))
    end

    AddConnection(player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            Handle_Humanoid_Death(player, humanoid)
        end
    end))
end

local function Update_Player_Death_Status(player)
    if not Dead_Check_Enabled then
        Player_Dead[player] = nil
        return
    end
    Player_Dead[player] = Is_Player_Dead(player)
end

task.spawn(function()
    while true do
        task.wait(3)
        if Dead_Check_Enabled then
            for _, player in ipairs(Services.Players:GetPlayers()) do
                if player ~= Local_Player then
                    Update_Player_Death_Status(player)
                end
            end
        else
            table_clear(Player_Dead)
        end
    end
end)

AddConnection(Services.Players.PlayerAdded:Connect(function(player)
    if player ~= Local_Player then
        Bind_Player_Death(player)
    end
end))

for _, player in ipairs(Services.Players:GetPlayers()) do
    if player ~= Local_Player then
        Bind_Player_Death(player)
    end
end

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
        if player ~= Local_Player and not Is_Same_Team(player) then
            if Dead_Check_Enabled and Is_Player_Dead(player) then
                continue
            end
            
            local char = player.Character
            if char then
                local target_part = Get_Nearest_Part(player, Aim_Part)
                if target_part and (not Aim_Visible_Check or not Is_Behind_Wall(target_part)) then
                    local screen_pos, on_screen = World_To_Screen(target_part.Position)
                    if on_screen then
                        local dist = (screen_pos - screen_center).Magnitude
                        if dist < closest_distance then
                            closest_distance = dist
                            closest_player = player
                        end
                    end
                end
            end
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
    local delta = (screen_pos - screen_center)
    
    -- 0 is instant, 99 is very slow. 
    local smooth_val = math.clamp(Aim_Smoothness, 0, 99) / 100
    local smoothness = 1 - smooth_val
    if smoothness <= 0 then smoothness = 0.01 end -- Prevent freezing at 0
    
    mousemoverel(delta.X * smoothness, delta.Y * smoothness)
end

local function Update_ESP()
    Cleanup_ESP_Drawings()
    local screen_size = Camera.ViewportSize

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Local_Player then
            local drawings = ESP_Pool[player]
            local skip_player = false

            if Dead_Check_Enabled then
                Update_Player_Death_Status(player)
                if Player_Dead[player] then
                    skip_player = true
                end
            end

            if Is_Same_Team(player) then
                skip_player = true
            end

            local char = player.Character
            if not char then
                skip_player = true
            end

            local hrp, head
            if not skip_player then
                hrp = char:FindFirstChild("HumanoidRootPart")
                head = char:FindFirstChild("Head")
                if not hrp or not head then
                    skip_player = true
                end
            end

            if not skip_player then
                local root_pos, root_visible, root_depth = World_To_Screen(hrp.Position)
                local head_pos, head_visible, head_depth = World_To_Screen(head.Position + v3_new(0, 0.3, 0))

                if not root_visible and not head_visible then
                    skip_player = true
                else
                    if not drawings then
                        drawings = Create_ESP_Drawings(player)
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

            if skip_player and drawings then
                for _, d in pairs(drawings) do
                    d.Visible = false
                end
            end
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

AddConnection(Services.Run_Service.RenderStepped:Connect(function()
    Update_ESP()
    Update_Aim()
    Update_FOV_Circle()
end))

AddConnection(Services.Players.PlayerRemoving:Connect(function(player)
    Remove_ESP_Drawings(player)
    Clear_Player_Death_Connections(player)
    Player_Dead[player] = nil
end))

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local UI_Loaded, UI_Library = pcall(function()
    return loadstring(game:HttpGet(repo .. "Library.lua"))()
end)

if UI_Loaded and UI_Library then
    Window = UI_Library:CreateWindow({
        Title = "Glonkie's Donkies - made with ♥ by Glonk (tf3m on discord)",
        Center = true,
        AutoShow = true,
    })

    -- Wait slightly for Linoria to initialize internally before creating tabs
    task.wait(0.1)

    local Tabs = {
        Aim = Window:AddTab("Aim"),
        ESP = Window:AddTab("ESP"),
        Settings = Window:AddTab("Settings"),
    }

    -- AIM TAB
    local Aim_Group = Tabs.Aim:AddLeftGroupbox("Aim")
    local Aim_Enabled_Toggle = Aim_Group:AddToggle("Aim_Enabled", { Text = "Enabled", Default = true, Tooltip = "Toggle Aim" })
    local Aim_Key_Select_Drop = Aim_Group:AddDropdown("Aim_Key_Select", { Text = "Aim Key", Default = "MB2", Values = { "MB1", "MB2" }, Multi = false })
    local Aim_FOV_Slider = Aim_Group:AddSlider("Aim_FOV", { Text = "FOV", Default = 150, Min = 20, Max = 500, Rounding = 0, Suffix = "px" })
    local Aim_Smoothness_Slider = Aim_Group:AddSlider("Aim_Smoothness", { Text = "Smoothness", Default = 0, Min = 0, Max = 99, Rounding = 0, Suffix = "%" })
    local Aim_Part_Drop = Aim_Group:AddDropdown("Aim_Part", { Text = "Aim Part", Default = "Head", Values = { "Head", "HumanoidRootPart", "Torso", "Random" }, Multi = false })
    local Visible_Check_Toggle = Aim_Group:AddToggle("Visible_Check", { Text = "Visible Check", Default = true })
    local Team_Check_Toggle = Aim_Group:AddToggle("Team_Check", { Text = "Team Check", Default = false })
    local FOV_Circle_Toggle = Aim_Group:AddToggle("FOV_Circle", { Text = "Draw FOV", Default = true })
    local FOV_Color_Picker = Aim_Group:AddLabel("FOV Color"):AddColorPicker("FOV_Color", { Default = FOV_Circle_Color })

    Aim_Enabled_Toggle:OnChanged(function(val) Aim_Enabled = val end)
    Visible_Check_Toggle:OnChanged(function(val) Aim_Visible_Check = val end)
    Team_Check_Toggle:OnChanged(function(val) Team_Check = val end)
    FOV_Circle_Toggle:OnChanged(function(val) FOV_Circle_Enabled = val end)
    Aim_FOV_Slider:OnChanged(function(val) Aim_FOV = val end)
    Aim_Smoothness_Slider:OnChanged(function(val) Aim_Smoothness = val end)
    Aim_Part_Drop:OnChanged(function(val) Aim_Part = val end)
    Aim_Key_Select_Drop:OnChanged(function(val) Set_Aim_Key(val) end)
    FOV_Color_Picker:OnChanged(function(val) FOV_Circle_Color = val end)

    -- ESP TAB
    local ESP_Group = Tabs.ESP:AddLeftGroupbox("ESP")
    local ESP_Enabled_Toggle = ESP_Group:AddToggle("ESP_Enabled", { Text = "Enabled", Default = true })
    local Dead_Check_Toggle = ESP_Group:AddToggle("Dead_Check", { Text = "Dead Check", Default = true })
    local Box_Toggle = ESP_Group:AddToggle("Box", { Text = "Box", Default = true })
    local Box_Color_Picker = ESP_Group:AddLabel("Box Color"):AddColorPicker("Box_Color", { Default = Box_Color })
    local Name_Toggle = ESP_Group:AddToggle("Name", { Text = "Name", Default = true })
    local Name_Color_Picker = ESP_Group:AddLabel("Name Color"):AddColorPicker("Name_Color", { Default = Name_Color })
    local Health_Toggle = ESP_Group:AddToggle("Health", { Text = "Health Bar", Default = true })
    local Distance_Toggle = ESP_Group:AddToggle("Distance", { Text = "Distance", Default = true })
    local Tracer_Toggle = ESP_Group:AddToggle("Tracer", { Text = "Tracers", Default = true })
    local Tracer_Color_Picker = ESP_Group:AddLabel("Tracer Color"):AddColorPicker("Tracer_Color", { Default = Tracer_Color })
    local Tracer_Origin_Drop = ESP_Group:AddDropdown("Tracer_Origin", { Text = "Tracer Origin", Default = "Bottom", Values = { "Bottom", "Middle", "Top" }, Multi = false })
    local Head_Dot_Toggle = ESP_Group:AddToggle("Head_Dot", { Text = "Head Dot", Default = true })
    local Head_Dot_Color_Picker = ESP_Group:AddLabel("Dot Color"):AddColorPicker("Head_Dot_Color", { Default = Head_Dot_Color })

    ESP_Enabled_Toggle:OnChanged(function(val) ESP_Enabled = val end)
    Dead_Check_Toggle:OnChanged(function(val)
        Dead_Check_Enabled = val
        if not Dead_Check_Enabled then
            table_clear(Player_Dead)
        end
    end)
    Box_Toggle:OnChanged(function(val) Box_Enabled = val end)
    Name_Toggle:OnChanged(function(val) Name_Enabled = val end)
    Health_Toggle:OnChanged(function(val) Health_Enabled = val end)
    Distance_Toggle:OnChanged(function(val) Distance_Enabled = val end)
    Tracer_Toggle:OnChanged(function(val) Tracer_Enabled = val end)
    Head_Dot_Toggle:OnChanged(function(val) Head_Dot_Enabled = val end)
    Tracer_Origin_Drop:OnChanged(function(val) Tracer_Origin = val end)
    Box_Color_Picker:OnChanged(function(val) Box_Color = val end)
    Name_Color_Picker:OnChanged(function(val) Name_Color = val end)
    Tracer_Color_Picker:OnChanged(function(val) Tracer_Color = val end)
    Head_Dot_Color_Picker:OnChanged(function(val) Head_Dot_Color = val end)

    -- SETTINGS TAB
    local Settings_Group = Tabs.Settings:AddLeftGroupbox("Settings")
    local Menu_Background_Picker = Settings_Group:AddLabel("Menu Background"):AddColorPicker("Menu_Background_Color", { Default = Menu_Background_Color })
    local Menu_Text_Picker = Settings_Group:AddLabel("Menu Text"):AddColorPicker("Menu_Text_Color", { Default = Menu_Text_Color })
    local Menu_Outline_Picker = Settings_Group:AddLabel("Menu Outline"):AddColorPicker("Menu_Outline_Color", { Default = Menu_Outline_Color })

    local function Update_Menu_Theme()
        if not UI_Library then return end
        if UI_Library.Theme then
            UI_Library.Theme.Background = Menu_Background_Color
            UI_Library.Theme.Text = Menu_Text_Color
            UI_Library.Theme.Outline = Menu_Outline_Color
        end
        if UI_Library.UpdateColorsUsingRegistry then
            UI_Library:UpdateColorsUsingRegistry()
        end
    end

    Menu_Background_Picker:OnChanged(function(val)
        Menu_Background_Color = val
        Update_Menu_Theme()
    end)
    Menu_Text_Picker:OnChanged(function(val)
        Menu_Text_Color = val
        Update_Menu_Theme()
    end)
    Menu_Outline_Picker:OnChanged(function(val)
        Menu_Outline_Color = val
        Update_Menu_Theme()
    end)

    -- Initialize Theme
    Update_Menu_Theme()
end
