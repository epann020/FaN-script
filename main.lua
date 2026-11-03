local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character, humanoid, rootPart

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end
updateCharacter()
player.CharacterAdded:Connect(updateCharacter)

local Settings = {
    Player = false,
    Key = true,
    Code = true,
    Opah = false,
    Padlok = true
}

local activeESP = {}

local NAMA_KEY = {"Key"}
local NAMA_PADLOK = {"PADLOK", "Padlock", "Lock"}
-- ✅ Banyak variasi nama Code biar pasti ketemu
local NAMA_CODE = {"Code", "Passcode", "PasscodeNote", "Passcode_Note", "Note", "CodeNote", "Password"}
local NAMA_OPAH = {"Opah"}

local gui = Instance.new("ScreenGui")
gui.Name = "ESPMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(380, 320)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
frame.ClipsDescendants = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
title.Text = "MALAM BERSAMA OPAH"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local menuDragging = false
local menuStartPos, menuInputStartPos

title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = true
        menuStartPos = frame.Position
        menuInputStartPos = input.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if menuDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - menuInputStartPos
            frame.Position = UDim2.new(
                menuStartPos.X.Scale,
                menuStartPos.X.Offset + delta.X,
                menuStartPos.Y.Scale,
                menuStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = false
    end
end)

local logo = Instance.new("TextButton")
logo.Size = UDim2.fromOffset(60, 60)
logo.Position = UDim2.new(0, 15, 0.5, 0)
logo.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
logo.Text = "⚡\nFaN"
logo.TextColor3 = Color3.new(1, 1, 1)
logo.TextSize = 17
logo.Font = Enum.Font.GothamBold
logo.Parent = gui
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)
logo.ZIndex = 10

local menuOpen = true
logo.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    frame.Visible = menuOpen
end)

local logoDragging = false
local logoStartPos, logoInputStartPos

logo.Active = true
logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        logoDragging = true
        logoStartPos = logo.Position
        logoInputStartPos = input.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if logoDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - logoInputStartPos
            logo.Position = UDim2.new(
                logoStartPos.X.Scale,
                logoStartPos.X.Offset + delta.X,
                logoStartPos.Y.Scale,
                logoStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        logoDragging = false
    end
end)

local function removeESP(target)
    local data = activeESP[target]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        activeESP[target] = nil
    end
end

local function clearAllESP()
    for t in pairs(activeESP) do removeESP(t) end
end

local function addESP(target, label, color)
    if not target or activeESP[target] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "LocalESP"
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.4
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gui

    local rootPartObj
    if target:IsA("Model") then
        rootPartObj = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    else
        rootPartObj = target
    end

    local billboard
    if rootPartObj then
        billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.fromOffset(160, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = rootPartObj

        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = color
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.new(0,0,0)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 16
        text.Parent = billboard
        billboard.Parent = gui
    end

    activeESP[target] = {Highlight = highlight, Billboard = billboard}
end

-- ✅ Cek PERSIS untuk Key & Padlok → AMAN, gak nyangkut ke pohon
local function cariPasti(namaList)
    local hasil = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not obj:IsDescendantOf(character) then
            for _, kw in ipairs(namaList) do
                if obj.Name == kw then
                    table.insert(hasil, obj)
                    break
                end
            end
        end
    end
    return hasil
end

-- ✅ Khusus Code: cari yang mengandung kata kunci (lebih fleksibel)
local function cariCode(namaList)
    local hasil = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not obj:IsDescendantOf(character) then
            local n = obj.Name:lower()
            for _, kw in ipairs(namaList) do
                local k = kw:lower()
                if n == k or string.find(n, k, 1, true) then
                    table.insert(hasil, obj)
                    print("[FOUND CODE]:", obj.Name) -- Debug: tampilkan nama yang ketemu
                    break
                end
            end
        end
    end
    return hasil
end

local function getBasePart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function dapatPosisiObjek(obj)
    local part = getBasePart(obj)
    return part and part.Position or nil
end

local function teleportKeSamping(obj, jarakAtas)
    local pos = dapatPosisiObjek(obj)
    if not pos or not rootPart then return end
    local posTujuan = pos + Vector3.new(0, jarakAtas, 0)
    rootPart.Anchored = true
    rootPart.CFrame = CFrame.new(posTujuan)
    task.wait(0.05)
    rootPart.Anchored = false
end

local function cariObjekTerdekat(objekList)
    local terdekat, jarakMin = nil, math.huge
    if not rootPart then return nil end
    for _, obj in ipairs(objekList) do
        local pos = dapatPosisiObjek(obj)
        if pos then
            local jarak = (rootPart.Position - pos).Magnitude
            if jarak < jarakMin then
                terdekat = obj
                jarakMin = jarak
            end
        end
    end
    return terdekat
end

local function scanObjects()
    clearAllESP()
    local daftarKey = cariPasti(NAMA_KEY)
    local daftarPadlok = cariPasti(NAMA_PADLOK)
    local daftarCode = cariCode(NAMA_CODE)
    local daftarOpah = cariPasti(NAMA_OPAH)

    print("[SCAN] Key:", #daftarKey, "| Padlok:", #daftarPadlok, "| Code:", #daftarCode)

    if Settings.Key then
        for i = 1, math.min(#daftarKey, 5) do
            addESP(daftarKey[i], "🔑 KEY", Color3.fromRGB(255, 220, 0))
        end
    end
    if Settings.Padlok then
        for i = 1, math.min(#daftarPadlok, 5) do
            addESP(daftarPadlok[i], "🔒 PADLOK", Color3.fromRGB(255, 80, 80))
        end
    end
    if Settings.Code and #daftarCode > 0 then
        local codeObj = cariObjekTerdekat(daftarCode) or daftarCode[1]
        addESP(codeObj, "📝 CODE", Color3.fromRGB(80, 200, 255))
    end
    if Settings.Opah and #daftarOpah > 0 then
        addESP(daftarOpah[1], "👹 OPAH", Color3.fromRGB(180, 60, 220))
    end
end

local function scanPlayers()
    if not Settings.Player then return end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            addESP(other.Character, "👤 "..other.Name, Color3.fromRGB(0, 255, 100))
        end
    end
end

local yToggle = 55
local function buatToggle(nama, y, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 175, 0, 40)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local function update()
        btn.Text = nama.." : "..(Settings[nama] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[nama] and Color3.fromRGB(20,145,75) or Color3.fromRGB(65,65,75)
    end

    btn.MouseButton1Click:Connect(function()
        Settings[nama] = not Settings[nama]
        clearAllESP()
        update()
        scanObjects()
        scanPlayers()
    end)
    update()
end

buatToggle("Player", yToggle, 10)
buatToggle("Key", yToggle, 195); yToggle += 45
buatToggle("Padlok", yToggle, 10)
buatToggle("Code", yToggle, 195); yToggle += 45
buatToggle("Opah", yToggle, 10)

local yBtn = 240
local function buatTombolTeleport(nama, y, cariFunc, jarakAtas)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 42)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(200, 110, 20)
    btn.Text = "🚀 "..nama
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        local daftar = cariFunc()
        print("[TELEPORT] "..nama.." ditemukan: "..#daftar.." objek")
        if #daftar == 0 then
            btn.Text = "❌ Tidak ketemu!"
            task.wait(1.5)
            btn.Text = "🚀 "..nama
            return
        end
        local tujuan = cariObjekTerdekat(daftar) or daftar[1]
        teleportKeSamping(tujuan, jarakAtas)
        btn.Text = "✅ SAMPAI!"
        task.wait(1.2)
        btn.Text = "🚀 "..nama
    end)
end

buatTombolTeleport("TELEPORT KEY", yBtn, function() return cariPasti(NAMA_KEY) end, 3)
yBtn += 47
buatTombolTeleport("TELEPORT PADLOK", yBtn, function() return cariPasti(NAMA_PADLOK) end, 2.5)
yBtn += 47
buatTombolTeleport("TELEPORT CODE", yBtn, function() return cariCode(NAMA_CODE) end, 2)

scanObjects()
task.spawn(function()
    while gui and gui.Parent do
        clearAllESP()
        scanObjects()
        scanPlayers()
        task.wait(1)
    end
end)
