-- ============================================
-- FRACTURE UI v3.0 - РАБОЧАЯ ВЕРСИЯ
-- ============================================

local FractureUI = {}
FractureUI.__index = FractureUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok = pcall(function() return game:GetService("CoreGui"):GetChildren() end)
    if ok then return game:GetService("CoreGui") end
    return PlayerGui
end
local UI_PARENT = getGuiParent()

-- ============================================
-- ЦВЕТА
-- ============================================
local C = {
    Bg          = Color3.fromRGB(10, 11, 16),
    Sidebar     = Color3.fromRGB(7, 8, 13),
    Panel       = Color3.fromRGB(12, 14, 20),
    PanelInner  = Color3.fromRGB(20, 22, 32),
    PanelHover  = Color3.fromRGB(30, 32, 46),
    Text        = Color3.fromRGB(232, 232, 240),
    TextDim     = Color3.fromRGB(150, 152, 168),
    TextMuted   = Color3.fromRGB(95, 98, 115),
    Border      = Color3.fromRGB(28, 30, 44),
    BorderBrt   = Color3.fromRGB(45, 47, 65),
    Success     = Color3.fromRGB(95, 220, 130),
    Warning     = Color3.fromRGB(255, 200, 100),
    Danger      = Color3.fromRGB(235, 90, 100),
    Accent      = Color3.fromRGB(124, 109, 242),
    AccentHover = Color3.fromRGB(140, 125, 255),
    Logo        = Color3.fromRGB(140, 120, 255),
}

local Icons = {
    home     = "rbxassetid://7743872758",
    sliders  = "rbxassetid://7743875962",
    eye      = "rbxassetid://7733774602",
    flame    = "rbxassetid://7733798747",
    settings = "rbxassetid://7734053495",
    minimize = "rbxassetid://7733997870",
    close    = "rbxassetid://7743878857",
    lock     = "rbxassetid://7733965118",
    check    = "rbxassetid://7733715400",
    alert    = "rbxassetid://7733658504",
    info     = "rbxassetid://7733964719",
    folder   = "rbxassetid://7733799185",
    save     = "rbxassetid://7734052335",
    trash    = "rbxassetid://7743873772",
    chevDown = "rbxassetid://7733717447",
    externalLink = "rbxassetid://7743866903",
    refreshCw = "rbxassetid://7734051052",
}

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================
local function new(class, props)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then o[k] = v end
        end
        if props.Parent then o.Parent = props.Parent end
    end
    return o
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function ustroke(p, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Border
    s.Thickness = t or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

-- ============================================
-- КЛЮЧ-СИСТЕМА
-- ============================================
local hasFS = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local FOLDER = "fracture"
if hasFS and not isfolder(FOLDER) then pcall(makefolder, FOLDER) end

local KEY_FILE = FOLDER .. "/key.dat"
local HWID_FILE = FOLDER .. "/hwid.dat"

local function saveKey(k) pcall(function() if hasFS then writefile(KEY_FILE, k) end end) end
local function loadKey() if hasFS and isfile(KEY_FILE) then local ok,c=pcall(readfile,KEY_FILE); return ok and c or nil end end
local function saveHWID(h) pcall(function() if hasFS then writefile(HWID_FILE, h) end end) end
local function loadHWID() if hasFS and isfile(HWID_FILE) then local ok,c=pcall(readfile,HWID_FILE); return ok and c or nil end end
local function getRealHWID()
    local h
    pcall(function() h = game:GetService("RbxAnalyticsService"):GetClientId() end)
    if not h or h == "" then pcall(function() h = game:GetService("RunService"):GetMachineId() end) end
    return h or tostring(Player.UserId)
end
local function checkHWID(key)
    local cur = getRealHWID()
    local saved = loadHWID()
    local sk = loadKey()
    if not saved or not sk or sk ~= key or saved ~= cur then return false end
    return true
end
local function setHWID(key) saveHWID(getRealHWID()); saveKey(key) end

local Junkie
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
    end)
    if ok and lib and type(lib) == "table" and lib.check_key then
        Junkie = lib
        Junkie.service = "linkvertise"
        Junkie.identifier = "1036846"
        Junkie.provider = "linkvertise"
    else
        Junkie = {
            check_key = function(k) if k and #k > 0 then return {valid = true} end; return {valid = false} end,
            get_key_link = function() return nil end,
            __fallback = true,
        }
    end
end

local function showKeySystem(callback)
    local saved = loadKey()
    if saved and saved ~= "" then
        if checkHWID(saved) then
            local ok, res = pcall(Junkie.check_key, saved)
            if ok and res and res.valid then
                if callback then callback() end
                return
            end
        end
    end

    local gui = new("ScreenGui", {
        Name = "FractureKeySystem",
        Parent = UI_PARENT,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 99999,
        IgnoreGuiInset = true,
    })

    local overlay = new("Frame", {
        Parent = gui,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 1,
    })
    TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 0.6}):Play()

    local Main = new("Frame", {
        Parent = overlay,
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = C.Bg,
        BorderSizePixel = 0,
        ZIndex = 2,
        ClipsDescendants = true,
    })
    corner(Main, 16)
    ustroke(Main, C.BorderBrt, 1, 0.4)

    -- Заголовок
    local TB = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    corner(TB, 16)
    new("TextLabel", {
        Parent = TB,
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.fromOffset(15, 5),
        BackgroundTransparency = 1,
        Text = "FR",
        TextColor3 = C.Logo,
        TextSize = 22,
        Font = Enum.Font.GothamBlack,
        ZIndex = 4,
    })
    new("TextLabel", {
        Parent = TB,
        Size = UDim2.new(1, -130, 0, 40),
        Position = UDim2.fromOffset(60, 5),
        BackgroundTransparency = 1,
        Text = "KEY SYSTEM",
        TextColor3 = C.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4,
    })

    -- Lock
    local lockBox = new("Frame", {
        Parent = Main,
        Size = UDim2.fromOffset(78, 78),
        Position = UDim2.new(0.5, -39, 0, 70),
        BackgroundColor3 = C.PanelInner,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    corner(lockBox, 18)
    ustroke(lockBox, C.Accent, 1, 0.4)
    new("ImageLabel", {
        Parent = lockBox,
        Size = UDim2.fromOffset(44, 44),
        Position = UDim2.fromOffset(17, 17),
        BackgroundTransparency = 1,
        Image = Icons.lock,
        ImageColor3 = C.Logo,
        ZIndex = 4,
    })

    new("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1, -40, 0, 18),
        Position = UDim2.fromOffset(20, 160),
        BackgroundTransparency = 1,
        Text = "Enter your key to continue",
        TextColor3 = C.TextDim,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ZIndex = 3,
    })

    local KeyBoxFrame = new("Frame", {
        Parent = Main,
        Size = UDim2.fromOffset(360, 42),
        Position = UDim2.new(0.5, -180, 0, 190),
        BackgroundColor3 = C.PanelInner,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    corner(KeyBoxFrame, 10)
    ustroke(KeyBoxFrame, C.Border, 1, 0.5)
    local KeyBox = new("TextBox", {
        Parent = KeyBoxFrame,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Paste your key here...",
        PlaceholderColor3 = C.TextMuted,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Text = "",
        ZIndex = 4,
    })

    local VerifyBtn = new("TextButton", {
        Parent = Main,
        Size = UDim2.fromOffset(360, 42),
        Position = UDim2.new(0.5, -180, 0, 246),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        Text = "VERIFY",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 3,
    })
    corner(VerifyBtn, 10)
    VerifyBtn.MouseEnter:Connect(function()
        TweenService:Create(VerifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.AccentHover}):Play()
    end)
    VerifyBtn.MouseLeave:Connect(function()
        TweenService:Create(VerifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Accent}):Play()
    end)

    local GetKeyBtn = new("TextButton", {
        Parent = Main,
        Size = UDim2.fromOffset(360, 36),
        Position = UDim2.new(0.5, -180, 0, 298),
        BackgroundColor3 = C.PanelInner,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
    })
    corner(GetKeyBtn, 10)
    ustroke(GetKeyBtn, C.BorderBrt, 1, 0.4)
    new("UIListLayout", {
        Parent = GetKeyBtn,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
    })
    new("ImageLabel", {
        Parent = GetKeyBtn,
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Image = Icons.externalLink,
        ImageColor3 = C.Text,
        ZIndex = 4,
        LayoutOrder = 1,
    })
    new("TextLabel", {
        Parent = GetKeyBtn,
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "GET KEY",
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
        LayoutOrder = 2,
    })

    local StatusLabel = new("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.fromOffset(20, 344),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.TextDim,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    })

    new("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1, -40, 0, 14),
        Position = UDim2.fromOffset(20, 372),
        BackgroundTransparency = 1,
        Text = "OUR SOCIALS",
        TextColor3 = C.TextMuted,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    })

    local socialsRow = new("Frame", {
        Parent = Main,
        Size = UDim2.fromOffset(360, 32),
        Position = UDim2.new(0.5, -180, 0, 410),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })
    new("UIListLayout", {
        Parent = socialsRow,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
    })

    local function makeSocial(label, color, link)
        local b = new("TextButton", {
            Parent = socialsRow,
            Size = UDim2.fromOffset(170, 32),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 3,
        })
        corner(b, 8)
        ustroke(b, color, 1, 0.5)
        new("TextLabel", {
            Parent = b,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = color,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = 4,
        })
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.7}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
        end)
        b.MouseButton1Click:Connect(function()
            pcall(function()
                if setclipboard then setclipboard(link) end
            end)
        end)
        return b
    end
    makeSocial("Telegram", C.Telegram or Color3.fromRGB(42, 171, 238), "https://t.me/erafox")
    makeSocial("Discord", C.Discord or Color3.fromRGB(88, 101, 242), "https://discord.gg/fracture")

    local verifying = false
    local function doVerify()
        if verifying then return end
        local k = KeyBox.Text:gsub("%s+", "")
        if k == "" then
            StatusLabel.Text = "Please enter a key"
            StatusLabel.TextColor3 = C.Warning
            return
        end
        verifying = true
        StatusLabel.Text = "Verifying..."
        StatusLabel.TextColor3 = C.Warning
        task.spawn(function()
            local ok, res = pcall(Junkie.check_key, k)
            if ok and res and res.valid then
                setHWID(k)
                StatusLabel.Text = "KEY VALID"
                StatusLabel.TextColor3 = C.Success
                TweenService:Create(VerifyBtn, TweenInfo.new(0.3), {BackgroundColor3 = C.Success}):Play()
                task.wait(0.8)
                TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(Main, TweenInfo.new(0.3), {
                    Size = UDim2.fromOffset(0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                }):Play()
                task.wait(0.3)
                gui:Destroy()
                if callback then callback() end
            else
                StatusLabel.Text = "INVALID KEY"
                StatusLabel.TextColor3 = C.Danger
                TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Danger}):Play()
                task.wait(0.4)
                TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent}):Play()
                verifying = false
            end
        end)
    end

    VerifyBtn.MouseButton1Click:Connect(doVerify)
    KeyBox.FocusLost:Connect(function(enter)
        if enter then doVerify() end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if Junkie.__fallback then
            StatusLabel.Text = "Junkie SDK unavailable"
            StatusLabel.TextColor3 = C.Warning
            return
        end
        local link
        local ok = pcall(function()
            link = Junkie.get_key_link()
        end)
        if ok and link then
            pcall(function()
                if setclipboard then setclipboard(link) end
            end)
            StatusLabel.Text = "Link copied!"
            StatusLabel.TextColor3 = C.Success
        else
            StatusLabel.Text = "Failed to get link"
            StatusLabel.TextColor3 = C.Danger
        end
    end)

    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(440, 490),
        Position = UDim2.new(0.5, -220, 0.5, -245),
    }):Play()
end

-- ============================================
-- УВЕДОМЛЕНИЯ
-- ============================================
local NotificationsGui = nil
local activeNotifs = {}
local notificationEnabled = true

local function ensureNotifGui()
    if NotificationsGui and NotificationsGui.Parent then return end
    NotificationsGui = new("ScreenGui", {
        Name = "FractureNotifications",
        Parent = UI_PARENT,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9998,
        IgnoreGuiInset = true,
    })
end

local function notify(text, kind, duration, force)
    if not notificationEnabled and not force then return end
    ensureNotifGui()
    duration = duration or 2.8
    local color = (kind == "success" and C.Success) or (kind == "error" and C.Danger)
                or (kind == "warning" and C.Warning) or C.Info
    local icon = (kind == "success" and Icons.check) or (kind == "error" and Icons.close)
                or (kind == "warning" and Icons.alert) or Icons.info

    local idx = #activeNotifs
    local notifH = 56
    local notifW = 290
    local gap = 10
    local YPos = 80 + idx * (notifH + gap)

    local notif = new("Frame", {
        Parent = NotificationsGui,
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(notifW, notifH),
        Position = UDim2.new(1, notifW + 30, 0, YPos),
        ZIndex = 1000,
        ClipsDescendants = false,
        BackgroundTransparency = 0.05,
    })
    corner(notif, 10)
    ustroke(notif, C.BorderBrt, 1, 0.5)
    table.insert(activeNotifs, notif)

    local iconBox = new("Frame", {
        Parent = notif,
        Size = UDim2.fromOffset(36, 36),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    corner(iconBox, 8)
    ustroke(iconBox, color, 1, 0.55)
    new("ImageLabel", {
        Parent = iconBox,
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromOffset(9, 9),
        BackgroundTransparency = 1,
        Image = icon,
        ImageColor3 = color,
        ZIndex = 1002,
    })
    local txt = new("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -60, 1, -10),
        Position = UDim2.fromOffset(54, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = true,
        ZIndex = 1001,
    })
    local pbarBg = new("Frame", {
        Parent = notif,
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 1, -6),
        BackgroundColor3 = C.PanelInner,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    corner(pbarBg, 999)
    local pbar = new("Frame", {
        Parent = pbarBg,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 1002,
    })
    corner(pbar, 999)

    notif.Position = UDim2.new(1, notifW + 30, 0, YPos)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -(notifW + 16), 0, YPos),
    }):Play()
    TweenService:Create(pbar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.fromScale(0, 1),
    }):Play()

    task.delay(duration, function()
        if not notif.Parent then return end
        local out = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(notif, out, {
            Position = UDim2.new(1, notifW + 30, 0, notif.Position.Y.Offset),
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(iconBox, out, {BackgroundTransparency = 1}):Play()
        TweenService:Create(txt, out, {TextTransparency = 1}):Play()
        task.wait(0.32)
        for i, n in ipairs(activeNotifs) do
            if n == notif then table.remove(activeNotifs, i); break end
        end
        notif:Destroy()
        for i, n in ipairs(activeNotifs) do
            TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Position = UDim2.new(1, -(notifW + 16), 0, 80 + (i-1) * (notifH + gap)),
            }):Play()
        end
    end)
end

-- ============================================
=== ГЛАВНАЯ ФУНКЦИЯ СОЗДАНИЯ GUI
-- ============================================
function FractureUI:CreateWindow(config)
    config = config or {}
    local title = config.title or "Fracture"
    local version = config.version or "v1.0"
    local bindKey = config.bindKey or Enum.KeyCode.G
    local theme = config.theme or "Purple"

    ensureNotifGui()

    -- Очищаем старые GUI
    for _, n in ipairs({"FractureUI", "FractureOverlay"}) do
        pcall(function()
            local g = UI_PARENT:FindFirstChild(n)
            if g then g:Destroy() end
        end)
    end

    local ScreenGui = new("ScreenGui", {
        Name = "FractureUI",
        Parent = UI_PARENT,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 99000,
    })

    local OverlayGui = new("ScreenGui", {
        Name = "FractureOverlay",
        Parent = UI_PARENT,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 99100,
    })

    -- Основное окно
    local Main = new("Frame", {
        Parent = ScreenGui,
        Name = "Main",
        Size = UDim2.fromOffset(890, 555),
        Position = UDim2.new(0.5, -445, 0.5, -277),
        BackgroundColor3 = C.Bg,
        BorderSizePixel = 0,
    })
    corner(Main, 14)
    ustroke(Main, C.Border, 1, 0.4)

    -- Sidebar
    local Sidebar = new("Frame", {
        Parent = Main,
        Name = "Sidebar",
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundColor3 = C.Sidebar,
        BorderSizePixel = 0,
    })
    corner(Sidebar, 14)

    -- Logo
    new("TextLabel", {
        Parent = Sidebar,
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.fromOffset(10, 14),
        BackgroundTransparency = 1,
        Text = "FR",
        TextColor3 = C.Logo,
        TextSize = 22,
        Font = Enum.Font.GothamBlack,
    })

    -- Top Bar
    local TopBar = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -80, 0, 50),
        Position = UDim2.fromOffset(70, 12),
        BackgroundTransparency = 1,
    })

    -- Кнопка закрытия
    local CloseBtn = new("TextButton", {
        Parent = TopBar,
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -36, 0, 4),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    corner(CloseBtn, 8)
    new("ImageLabel", {
        Parent = CloseBtn,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        Image = Icons.close,
        ImageColor3 = C.TextDim,
    })

    -- Кнопка сворачивания
    local MinBtn = new("TextButton", {
        Parent = TopBar,
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -72, 0, 4),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    corner(MinBtn, 8)
    new("ImageLabel", {
        Parent = MinBtn,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        Image = Icons.minimize,
        ImageColor3 = C.TextDim,
    })

    -- Avatar (иконка внизу сайдбара)
    local AvatarBox = new("Frame", {
        Parent = Sidebar,
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0, 10, 1, -55),
        BackgroundColor3 = C.PanelInner,
        BorderSizePixel = 0,
    })
    corner(AvatarBox, 999)
    ustroke(AvatarBox, C.Accent, 2, 0.3)
    local AvatarImg = new("ImageLabel", {
        Parent = AvatarBox,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = "",
        ScaleType = Enum.ScaleType.Crop,
    })
    corner(AvatarImg, 999)
    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and content then AvatarImg.Image = content end
    end)

    -- Content area
    local Content = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -80, 1, -80),
        Position = UDim2.fromOffset(70, 70),
        BackgroundTransparency = 1,
    })

    -- ============================================
    -- ВКЛАДКИ
    -- ============================================
    local Tabs = {}
    local CurrentTab = nil

    local tabDefs = {
        {name = "MAIN", icon = Icons.home, key = "tab1"},
        {name = "PLAYER", icon = Icons.sliders, key = "tab2"},
        {name = "VISUALS", icon = Icons.eye, key = "tab3"},
        {name = "UTILS", icon = Icons.flame, key = "tab4"},
        {name = "SETTINGS", icon = Icons.settings, key = "tab5"},
    }

    local function createSidebarBtn(idx, def)
        local btn = new("TextButton", {
            Parent = Sidebar,
            Name = "Tab_" .. def.key,
            Size = UDim2.fromOffset(40, 40),
            Position = UDim2.fromOffset(10, 80 + (idx - 1) * 48),
            BackgroundColor3 = C.PanelInner,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
        })
        corner(btn, 8)
        local img = new("ImageLabel", {
            Parent = btn,
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            Image = def.icon,
            ImageColor3 = C.TextDim,
        })
        btn.MouseEnter:Connect(function()
            if CurrentTab ~= def.key then
                TweenService:Create(img, TweenInfo.new(0.15), {ImageColor3 = C.Text}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= def.key then
                TweenService:Create(img, TweenInfo.new(0.15), {ImageColor3 = C.TextDim}):Play()
            end
        end)
        return btn, img
    end

    local function createTabContent()
        local tab = new("Frame", {
            Parent = Content,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
        })
        new("UIPadding", {
            Parent = tab,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        })
        return tab
    end

    for i, def in ipairs(tabDefs) do
        local btn, img = createSidebarBtn(i, def)
        local content = createTabContent()
        Tabs[def.key] = {
            button = btn,
            image = img,
            content = content,
            key = def.key,
            name = def.name,
        }
        btn.MouseButton1Click:Connect(function()
            for k, t in pairs(Tabs) do
                t.content.Visible = (k == def.key)
                t.button.BackgroundTransparency = (k == def.key) and 0 or 1
                t.button.BackgroundColor3 = C.PanelInner
                t.image.ImageColor3 = (k == def.key) and C.Logo or C.TextDim
            end
            CurrentTab = def.key
        end)
    end

    -- Первая вкладка активна
    local firstKey = tabDefs[1].key
    Tabs[firstKey].content.Visible = true
    Tabs[firstKey].button.BackgroundTransparency = 0
    Tabs[firstKey].image.ImageColor3 = C.Logo
    CurrentTab = firstKey

    -- ============================================
    -- ЭЛЕМЕНТЫ GUI
    -- ============================================
    local function createToggle(parent, label, default, callback)
        local row = new("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
        })
        new("TextLabel", {
            Parent = row,
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = C.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local frame = new("Frame", {
            Parent = row,
            Size = UDim2.fromOffset(36, 20),
            Position = UDim2.new(1, -36, 0.5, -10),
            BackgroundColor3 = default and C.Accent or C.PanelInner,
            BorderSizePixel = 0,
        })
        corner(frame, 999)
        local knob = new("Frame", {
            Parent = frame,
            Size = UDim2.fromOffset(14, 14),
            Position = default and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
        })
        corner(knob, 999)
        local btn = new("TextButton", {
            Parent = frame,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
        })
        local state = default or false
        local function setState(v)
            v = v and true or false
            state = v
            TweenService:Create(frame, TweenInfo.new(0.18), {
                BackgroundColor3 = state and C.Accent or C.PanelInner,
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {
                Position = state and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
            }):Play()
            if callback then pcall(callback, state) end
        end
        btn.MouseButton1Click:Connect(function()
            setState(not state)
        end)
        return {
            setState = setState,
            getState = function() return state end,
            frame = row,
        }
    end

    local function createSlider(parent, label, min, max, default, callback)
        local row = new("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
        })
        new("TextLabel", {
            Parent = row,
            Size = UDim2.new(1, -180, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = C.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local trackWidth = 160
        local valBox = new("TextBox", {
            Parent = row,
            Size = UDim2.fromOffset(50, 18),
            Position = UDim2.new(1, -trackWidth - 60, 0.5, -9),
            BackgroundTransparency = 1,
            Text = tostring(math.floor(default + 0.5)),
            TextColor3 = C.Text,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Right,
            ClearTextOnFocus = true,
        })
        local track = new("Frame", {
            Parent = row,
            Size = UDim2.fromOffset(trackWidth, 4),
            Position = UDim2.new(1, -trackWidth, 0.5, -2),
            BackgroundColor3 = C.PanelInner,
            BorderSizePixel = 0,
        })
        corner(track, 999)
        local fill = new("Frame", {
            Parent = track,
            BackgroundColor3 = C.Accent,
            BorderSizePixel = 0,
        })
        corner(fill, 999)
        local knob = new("Frame", {
            Parent = track,
            Size = UDim2.fromOffset(14, 14),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 2,
        })
        corner(knob, 999)
        local value = default

        local function setVal(v, fire)
            v = tonumber(v) or default
            v = math.clamp(v, min, max)
            value = math.floor(v + 0.5)
            local p = (value - min) / (max - min)
            fill.Size = UDim2.fromScale(p, 1)
            knob.Position = UDim2.new(p, -7, 0.5, -7)
            valBox.Text = tostring(value)
            if fire and callback then pcall(callback, value) end
        end

        setVal(default, false)

        local btn = new("TextButton", {
            Parent = track,
            Size = UDim2.new(1, 0, 1, 18),
            Position = UDim2.fromOffset(0, -7),
            BackgroundTransparency = 1,
            Text = "",
        })

        local dragging = false
        btn.MouseButton1Down:Connect(function()
            dragging = true
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local mx = i.Position.X
                local tp = track.AbsolutePosition.X
                local ts = track.AbsoluteSize.X
                local p = math.clamp((mx - tp) / ts, 0, 1)
                setVal(min + (max - min) * p, true)
            end
        end)

        valBox.FocusLost:Connect(function()
            local n = tonumber((valBox.Text:gsub("[^%-%d%.]", "")))
            if n then
                setVal(n, true)
            else
                setVal(value, false)
            end
        end)

        return {
            setValue = function(v) setVal(v, true) end,
            getValue = function() return value end,
            frame = row,
        }
    end

    local function createButton(parent, label, color, onClick)
        local row = new("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
        })
        local btn = new("TextButton", {
            Parent = row,
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = color or C.Accent,
            BorderSizePixel = 0,
            Text = label,
            TextColor3 = C.Text,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
        })
        corner(btn, 6)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = (color or C.Accent):Lerp(Color3.new(1, 1, 1), 0.1),
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = color or C.Accent,
            }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            if onClick then pcall(onClick) end
        end)
        return {
            frame = row,
        }
    end

    local function createKeybind(parent, label, default, callback)
        local row = new("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
        })
        new("TextLabel", {
            Parent = row,
            Size = UDim2.new(1, -180, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = C.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local function keyName(k)
            if not k then return "None" end
            if typeof(k) == "EnumItem" then
                if k.EnumType == Enum.UserInputType then
                    if k == Enum.UserInputType.MouseButton1 then return "MB1"
                    elseif k == Enum.UserInputType.MouseButton2 then return "MB2"
                    elseif k == Enum.UserInputType.MouseButton3 then return "MB3" end
                    return tostring(k.Name)
                end
                return k.Name
            end
            return tostring(k)
        end

        local btn = new("TextButton", {
            Parent = row,
            Size = UDim2.fromOffset(150, 28),
            Position = UDim2.new(1, -150, 0.5, -14),
            BackgroundColor3 = C.PanelInner,
            BorderSizePixel = 0,
            Text = keyName(default),
            TextColor3 = C.Text,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
        })
        corner(btn, 6)

        local current = default
        local listening = false
        local listenerConn

        btn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            btn.Text = "..."
            btn.TextColor3 = C.Accent

            listenerConn = UserInputService.InputBegan:Connect(function(input, gp)
                if not listening then return end
                local k
                if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
                    k = input.KeyCode
                elseif input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.MouseButton2
                    or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    k = input.UserInputType
                end
                if k then
                    current = k
                    btn.Text = keyName(k)
                    btn.TextColor3 = C.Text
                    listening = false
                    if listenerConn then
                        listenerConn:Disconnect()
                        listenerConn = nil
                    end
                    if callback then pcall(callback, k) end
                end
            end)
        end)

        return {
            setKey = function(k)
                current = k
                btn.Text = keyName(k)
            end,
            getKey = function() return current end,
            frame = row,
        }
    end

    -- ============================================
    -- УПРАВЛЕНИЕ ОКНОМ
    -- ============================================
    local minimized = false
    local origSize = Main.Size

    local function setMinimized(state)
        minimized = state
        if minimized then
            Sidebar.Visible = false
            Content.Visible = false
            Main.Size = UDim2.fromOffset(origSize.X.Offset, 50)
        else
            Sidebar.Visible = true
            Content.Visible = true
            Main.Size = origSize
        end
    end

    MinBtn.MouseButton1Click:Connect(function()
        setMinimized(not minimized)
    end)

    local function confirmDialog(text, onYes)
        local cgui = new("ScreenGui", {
            Name = "FractureConfirm",
            Parent = UI_PARENT,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 99500,
            IgnoreGuiInset = true,
        })
        local dim = new("Frame", {
            Parent = cgui,
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        TweenService:Create(dim, TweenInfo.new(0.2), {BackgroundTransparency = 0.55}):Play()

        local W, H = 400, 160
        local box = new("Frame", {
            Parent = dim,
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = C.Bg,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        })
        corner(box, 12)
        ustroke(box, C.BorderBrt, 1, 0.3)
        new("TextLabel", {
            Parent = box,
            Size = UDim2.new(1, -32, 0, 80),
            Position = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = C.Text,
            TextSize = 16,
            Font = Enum.Font.GothamMedium,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        })

        local btnW = (W - 16 * 2 - 8) / 2
        local yes = new("TextButton", {
            Parent = box,
            Size = UDim2.fromOffset(btnW, 34),
            Position = UDim2.fromOffset(16, H - 50),
            BackgroundColor3 = C.Danger,
            BorderSizePixel = 0,
            Text = "Yes",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
        })
        corner(yes, 8)

        local no = new("TextButton", {
            Parent = box,
            Size = UDim2.fromOffset(btnW, 34),
            Position = UDim2.fromOffset(16 + btnW + 8, H - 50),
            BackgroundColor3 = C.PanelInner,
            BorderSizePixel = 0,
            Text = "No",
            TextColor3 = C.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
        })
        corner(no, 8)

        local function close()
            cgui:Destroy()
        end

        yes.MouseButton1Click:Connect(function()
            close()
            if onYes then onYes() end
        end)
        no.MouseButton1Click:Connect(close)

        TweenService:Create(box, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(W, H),
            Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
        }):Play()
    end

    CloseBtn.MouseButton1Click:Connect(function()
        confirmDialog("Are you sure you want to close the script permanently?", function()
            ScreenGui:Destroy()
            OverlayGui:Destroy()
        end)
    end)

    -- Перетаскивание
    local dragging = false
    local dragStart, startPos
    local dragHandle = new("TextButton", {
        Parent = Main,
        Size = UDim2.new(1, -350, 0, 50),
        Position = UDim2.fromOffset(270, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 0,
    })

    dragHandle.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Main.Position
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mp = UserInputService:GetMouseLocation()
            local d = mp - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + d.X,
                startPos.Y.Scale,
                startPos.Y.Offset + d.Y
            )
        end
    end)

    -- Бинд для открытия/закрытия
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == bindKey then
            Main.Visible = not Main.Visible
            OverlayGui.Enabled = Main.Visible
        end
    end)

    notify("UI Loaded", "success", 2, true)

    -- ============================================
    -- ВОЗВРАЩАЕМ API
    -- ============================================
    local api = {
        notify = notify,
        setNotificationEnabled = function(state)
            notificationEnabled = state
        end,
        getUI = function() return ScreenGui end,
        getMain = function() return Main end,
        getTabs = function() return Tabs end,
        getCurrentTab = function() return CurrentTab end,
        close = function()
            ScreenGui:Destroy()
            OverlayGui:Destroy()
        end,
        minimize = function()
            setMinimized(true)
        end,
        restore = function()
            setMinimized(false)
        end,
        colors = C,
        createToggle = createToggle,
        createSlider = createSlider,
        createButton = createButton,
        createKeybind = createKeybind,
        getTabContent = function(key)
            return Tabs[key] and Tabs[key].content
        end,
        getTabName = function(key)
            return Tabs[key] and Tabs[key].name
        end,
    }

    return api
end

-- ============================================
-- ЗАПУСК С КЛЮЧ-СИСТЕМОЙ
-- ============================================
function FractureUI:StartWithKey(callback)
    showKeySystem(function()
        if callback then callback() end
    end)
end

return FractureUI
