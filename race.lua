-- =========================================================================
-- MODERN CDID SUMATERA BYPASS (STABLE UI V4.6.1 - PRO BUILD)
-- Logika Fisika: V4.2 | UI: Fluent | Auto Join Lobby (Fixed)
-- =========================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local RS = game:GetService("RunService")
local PL = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local RR = game:GetService("ReplicatedStorage"):WaitForChild("RaceRemotes")

-- [ VARIABEL GLOBAL ]
_G.MoveSpeed = 160
_G.HoverHeight = 45            -- <-- DIUBAH: 35 → 45
_G.IsTweening = false
_G.AutoClean = true
_G.AutoCarID = "2021Avanza15CVT"
_G.AutoCarName = "2021 Tokoma Avanza 1.5 CVT"

-- ==========================================
-- LOGIKA FISIKA (ASLI V4.2 - NO SKIP)
-- ==========================================
local function getCar()
    return workspace.Vehicles:FindFirstChild(PL.Name .. "sCar")
end

local function applyForceMovement(car, targetPos, cpNumber)
    local part = car:FindFirstChild("DriveSeat") or car.PrimaryPart
    if not part then return end

    part.AssemblyLinearVelocity = Vector3.zero
    part.AssemblyAngularVelocity = Vector3.zero
    
    local currentPos = car:GetPivot().Position
    car:PivotTo(CFrame.new(currentPos.X, currentPos.Y + _G.HoverHeight, currentPos.Z) * CFrame.Angles(0, math.rad(part.Orientation.Y), 0))
    task.wait(0.1)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.P = 5000 
    bv.Velocity = (targetPos - car:GetPivot().Position).Unit * _G.MoveSpeed
    bv.Parent = part

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 3000; bg.D = 500
    bg.CFrame = car:GetPivot(); bg.Parent = part

    local hbConn
    hbConn = RS.Heartbeat:Connect(function()
        if not _G.IsTweening or not bv.Parent then hbConn:Disconnect() return end
        local goalWithHover = targetPos + Vector3.new(0, _G.HoverHeight, 0)
        bv.Velocity = (goalWithHover - car:GetPivot().Position).Unit * _G.MoveSpeed
        bg.CFrame = CFrame.lookAt(car:GetPivot().Position, goalWithHover)
        part.AssemblyAngularVelocity = Vector3.zero
    end)

    repeat task.wait() until (Vector2.new(car:GetPivot().Position.X, car:GetPivot().Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude < 12 or not _G.IsTweening

    if hbConn then hbConn:Disconnect() end
    if bv then bv:Destroy() end 
    if bg then bg:Destroy() end 
    
    part.AssemblyLinearVelocity = Vector3.zero 
    task.wait(0.05) 
    
    if _G.IsTweening then
        part.AssemblyLinearVelocity = Vector3.new(0, -250, 0) 
        local groundFound = false
        local t = tick()
        repeat 
            task.wait()
            if math.abs(part.AssemblyLinearVelocity.Y) < 1 then groundFound = true end
        until groundFound or (tick() - t > 1.2)
        task.wait(0.3)   -- <-- DIUBAH: jeda setelah landing menjadi 0.3 detik
        part.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ==========================================
-- FUNGSI TELEPORT KARAKTER (DENGAN TWEEN)
-- ==========================================
local function playerTeleport(targetVector)
    local char = PL.Character
    if not char then
        char = PL.CharacterAdded:Wait()
    end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        rootPart = char:WaitForChild("HumanoidRootPart", 5) -- timeout 5 detik
        if not rootPart then
            Fluent:Notify({Title = "Error", Content = "HumanoidRootPart not found", Duration = 3})
            return
        end
    end
    -- Tween langsung (gerakan halus)
    local targetPos = CFrame.new(targetVector + Vector3.new(0, 3, 0))
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TS:Create(rootPart, tweenInfo, {CFrame = targetPos})
    tween:Play()
    tween.Completed:Wait()
    task.wait(0.2) -- jeda singkat agar minimap stabil
    Fluent:Notify({Title = "Teleport Success", Content = "Karakter sampai!", Duration = 3})
end

-- ==========================================
-- FUNGSI PEMBERSIH JALUR (ditambah BillBoard Big & Meshes/mountain smooth)
-- ==========================================
local function cleanPathway()
    local targets = {
        workspace:FindFirstChild("NPCVehicle"),
        workspace:FindFirstChild("Tree"),
        workspace:FindFirstChild("Gajah"),
        workspace.Map:FindFirstChild("Roads & Infra") and workspace.Map["Roads & Infra"]:FindFirstChild("Tiang Listrik"),
        workspace.Map:FindFirstChild("map liintas sumatra") and workspace.Map["map liintas sumatra"]:FindFirstChild("Tiang Listrik"),
        workspace.Map:FindFirstChild("map liintas sumatra") and workspace.Map["map liintas sumatra"]:FindFirstChild("Model")
    }
    -- Tambahkan BillBoard Big
    local billboard = workspace.Map:FindFirstChild("Roads & Infra") and workspace.Map["Roads & Infra"]:FindFirstChild("BillBoard Big")
    if billboard then
        table.insert(targets, billboard)
    end
    -- Tambahkan Meshes/mountain smooth
    local mountainSmooth = workspace.Map:FindFirstChild("Roads & Infra") and workspace.Map["Roads & Infra"]:FindFirstChild("Meshes/mountain smooth")
    if mountainSmooth then
        table.insert(targets, mountainSmooth)
    end
    
    for _, folder in pairs(targets) do
        if folder then folder:Destroy() end
    end
end

-- ==========================================
-- UI SETUP
-- ==========================================
local Window = Fluent:CreateWindow({
    Title = "CDID BYPASS PRO V4.6.1",
    SubTitle = "Sumatera Dashboard",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Grinding", Icon = "car" }),
    AutoRace = Window:AddTab({ Title = "Auto Race", Icon = "flag" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [ TAB MAIN ]
Tabs.Main:AddSlider("MoveSpeed", {
    Title = "Speed Grinding",
    Default = 160, Min = 50, Max = 400, Rounding = 1,
    Callback = function(Value) _G.MoveSpeed = Value end
})

Tabs.Main:AddToggle("AutoClean", {
    Title = "Auto Delete Obstacles", 
    Default = true,
    Callback = function(Value) _G.AutoClean = Value end
})

Tabs.Main:AddButton({
    Title = "▶ START BYPASS",
    Callback = function()
        if _G.IsTweening then return end
        local car = getCar()
        if not car then 
            Fluent:Notify({Title = "Error", Content = "Mobil tidak ditemukan!", Duration = 3})
            return 
        end
        _G.IsTweening = true
        if _G.AutoClean then cleanPathway() end
        
        task.spawn(function()
            for i = 1, 38 do
                if not _G.IsTweening then break end
                local target = workspace.Etc.Race.Checkpoint:FindFirstChild(tostring(i))
                if target then applyForceMovement(car, target:GetPivot().Position, i) end
            end
            if _G.IsTweening then applyForceMovement(car, Vector3.new(-3129.03, -64.56, -27743.27), "FINISH") end
            _G.IsTweening = false
        end)
    end
})

Tabs.Main:AddButton({
    Title = "⏹ STOP BYPASS",
    Callback = function() _G.IsTweening = false end
})

-- [ TAB AUTO RACE ]
Tabs.AutoRace:AddInput("CarID", {
    Title = "Car ID (Avanza/GR86/dll)",
    Default = _G.AutoCarID,
    Callback = function(Value) _G.AutoCarID = Value end
})

Tabs.AutoRace:AddInput("CarName", {
    Title = "Car Full Name",
    Default = _G.AutoCarName,
    Callback = function(Value) _G.AutoCarName = Value end
})

Tabs.AutoRace:AddButton({
    Title = "HOST: Create and Ready",
    Callback = function()
        RR.CreateLobby:FireServer(PL.Name.."'s Lobby")
        task.wait(1.5) 
        RR.SelectCar:FireServer(_G.AutoCarID, _G.AutoCarName)
        task.wait(0.8)
        RR.ToggleReady:FireServer()
        Fluent:Notify({Title = "Auto Race", Content = "Lobby Created & Ready!", Duration = 3})
    end
})

Tabs.AutoRace:AddButton({
    Title = "HOST: Start Race",
    Callback = function() 
        RR.StartRace:FireServer() 
        Fluent:Notify({Title = "Auto Race", Content = "Race Started!", Duration = 2})
    end
})

-- ==========================================
-- [ AUTO JOIN LOBBY - FINAL FIX ]
-- ==========================================
local availableLobbies = {}  -- array of {displayName = string, id = number}
local selectedLobbyId = nil
local lobbyDropdown = nil

-- Fungsi untuk mengambil nama tampilan dari struktur lobby
local function getLobbyDisplayName(lobbyObj)
    if lobbyObj.name and type(lobbyObj.name) == "string" then
        return lobbyObj.name
    end
    if lobbyObj.Name and type(lobbyObj.Name) == "string" then
        return lobbyObj.Name
    end
    if lobbyObj.LobbyName and type(lobbyObj.LobbyName) == "string" then
        return lobbyObj.LobbyName
    end
    -- fallback: gunakan id jika tidak ada nama
    if lobbyObj.id then
        return "Lobby " .. tostring(lobbyObj.id)
    end
    return "Unknown Lobby"
end

-- Update dropdown dengan daftar lobby
local function updateLobbyDropdown()
    if not lobbyDropdown then return end
    local items = {}
    for _, lobby in ipairs(availableLobbies) do
        table.insert(items, lobby.displayName)
    end
    if #items == 0 then
        table.insert(items, "No lobbies found")
    end
    lobbyDropdown:SetValues(items)
    if #items > 0 and items[1] ~= "No lobbies found" then
        lobbyDropdown:SetValue(items[1])
        -- Set selectedLobbyId berdasarkan item pertama
        for _, lobby in ipairs(availableLobbies) do
            if lobby.displayName == items[1] then
                selectedLobbyId = lobby.id
                break
            end
        end
    end
end

-- Listener untuk update lobby dari server (jika ada event)
if RR.LobbyListUpdated then
    RR.LobbyListUpdated.OnClientEvent:Connect(function(lobbyList)
        availableLobbies = {}
        if lobbyList then
            for _, lobby in ipairs(lobbyList) do
                if lobby.id and lobby.name then
                    table.insert(availableLobbies, {
                        displayName = lobby.name,
                        id = lobby.id
                    })
                elseif lobby.id then
                    table.insert(availableLobbies, {
                        displayName = "Lobby " .. tostring(lobby.id),
                        id = lobby.id
                    })
                end
            end
        end
        updateLobbyDropdown()
    end)
end

-- Fungsi untuk meminta daftar lobby (menggunakan InvokeServer)
local function refreshLobbyList()
    local getLobbies = RR.GetLobbies
    if getLobbies.ClassName == "RemoteFunction" then
        local success, result = pcall(function()
            return getLobbies:InvokeServer()
        end)
        if success and result then
            availableLobbies = {}
            if type(result) == "table" then
                -- iterasi sebagai array
                for _, v in ipairs(result) do
                    if v.id and v.name then
                        table.insert(availableLobbies, {
                            displayName = v.name,
                            id = v.id
                        })
                    elseif v.id then
                        table.insert(availableLobbies, {
                            displayName = "Lobby " .. tostring(v.id),
                            id = v.id
                        })
                    end
                end
                -- jika tidak ada ipairs, mungkin result adalah dictionary
                if #availableLobbies == 0 then
                    for _, v in pairs(result) do
                        if v.id and v.name then
                            table.insert(availableLobbies, {
                                displayName = v.name,
                                id = v.id
                            })
                        elseif v.id then
                            table.insert(availableLobbies, {
                                displayName = "Lobby " .. tostring(v.id),
                                id = v.id
                            })
                        end
                    end
                end
            end
            updateLobbyDropdown()
            Fluent:Notify({Title = "Lobby List", Content = "Updated: " .. #availableLobbies .. " lobbies", Duration = 2})
        else
            Fluent:Notify({Title = "Error", Content = "Gagal mengambil lobby list", Duration = 3})
        end
    elseif getLobbies.ClassName == "RemoteEvent" then
        getLobbies:FireServer()
        Fluent:Notify({Title = "Lobby List", Content = "Request sent...", Duration = 2})
    else
        Fluent:Notify({Title = "Error", Content = "Unknown remote type: " .. getLobbies.ClassName, Duration = 3})
    end
end

-- Dropdown untuk memilih lobby
lobbyDropdown = Tabs.AutoRace:AddDropdown("LobbySelector", {
    Title = "Available Lobbies",
    Values = {"Loading..."},
    Default = "Loading...",
    Callback = function(value)
        -- cari id berdasarkan displayName yang dipilih
        for _, lobby in ipairs(availableLobbies) do
            if lobby.displayName == value then
                selectedLobbyId = lobby.id
                break
            end
        end
    end
})

-- Tombol refresh lobby
Tabs.AutoRace:AddButton({
    Title = "Refresh Lobby List",
    Callback = refreshLobbyList
})

-- Tombol join lobby yang dipilih
Tabs.AutoRace:AddButton({
    Title = "Join Selected Lobby & Ready",
    Callback = function()
        if not selectedLobbyId then
            Fluent:Notify({Title = "Error", Content = "Pilih lobby terlebih dahulu!", Duration = 3})
            return
        end
        -- Kirim ID lobby (number) ke server
        RR.JoinLobby:FireServer(selectedLobbyId)
        task.wait(1.5)
        RR.SelectCar:FireServer(_G.AutoCarID, _G.AutoCarName)
        task.wait(0.8)
        RR.ToggleReady:FireServer()
        Fluent:Notify({Title = "Auto Race", Content = "Joined lobby (ID: " .. selectedLobbyId .. ")", Duration = 3})
    end
})

-- Tombol auto join lobby pertama yang tersedia
Tabs.AutoRace:AddButton({
    Title = "Auto Join First Lobby & Ready",
    Callback = function()
        refreshLobbyList()
        task.wait(2)
        if #availableLobbies > 0 then
            local firstLobby = availableLobbies[1]
            RR.JoinLobby:FireServer(firstLobby.id)
            task.wait(1.5)
            RR.SelectCar:FireServer(_G.AutoCarID, _G.AutoCarName)
            task.wait(0.8)
            RR.ToggleReady:FireServer()
            Fluent:Notify({Title = "Auto Race", Content = "Auto joined: " .. firstLobby.displayName, Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Tidak ada lobby yang tersedia.", Duration = 3})
        end
    end
})

-- Panggil refresh pertama kali
task.spawn(refreshLobbyList)
-- ==========================================

-- [ TAB TELEPORT ]
Tabs.Teleport:AddButton({
    Title = "Character to DA0ZA",
    Callback = function() playerTeleport(Vector3.new(-7.83422661, 3.01886272, 441.855499)) end
})

Tabs.Teleport:AddButton({
    Title = "Character to SHAD",
    Callback = function() playerTeleport(Vector3.new(12.8298206, 3.23346472, 305.551514)) end
})

-- [ TAB SETTINGS ]
Tabs.Settings:AddSlider("HoverHeight", {
    Title = "Hover Height",
    Default = 45, Min = 20, Max = 100, Rounding = 1,  -- <-- DIUBAH: 35 → 45
    Callback = function(Value) _G.HoverHeight = Value end
})

Tabs.Settings:AddButton({
    Title = "Manual Clean Pathway",
    Callback = function() cleanPathway() end
})

Window:SelectTab(1)
Fluent:Notify({Title = "V4.6.1 Loaded", Content = "Auto Join Lobby Fixed, Teleport dengan Tween", Duration = 5})
