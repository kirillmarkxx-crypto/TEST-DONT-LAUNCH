-- ============================================
-- FRACTURE UI v1.0 - БИБЛИОТЕКА ДЛЯ LOADSTRING
-- ТОЛЬКО GUI, БЕЗ ЛОГИКИ
-- Использование: local UI = loadstring(game:HttpGet("ссылка"))()
-- ============================================

local FractureUI = {}
FractureUI.__index = FractureUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
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
    BgDeep      = Color3.fromRGB(5, 6, 10),
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
    Info        = Color3.fromRGB(100, 170, 255),
    Telegram    = Color3.fromRGB(42, 171, 238),
    Discord     = Color3.fromRGB(88, 101, 242),
    Accent      = Color3.fromRGB(124, 109, 242),
    AccentHover = Color3.fromRGB(140, 125, 255),
    AccentSoft  = Color3.fromRGB(70, 60, 160),
    Logo        = Color3.fromRGB(140, 120, 255),
}

local Themes = {
    Purple = { Accent = Color3.fromRGB(124, 109, 242), AccentHover = Color3.fromRGB(140, 125, 255), AccentSoft = Color3.fromRGB(70, 60, 160), Logo = Color3.fromRGB(140, 120, 255) },
    Blue   = { Accent = Color3.fromRGB(80, 140, 255), AccentHover = Color3.fromRGB(100, 160, 255), AccentSoft = Color3.fromRGB(50, 90, 180), Logo = Color3.fromRGB(110, 165, 255) },
    Red    = { Accent = Color3.fromRGB(235, 80, 90), AccentHover = Color3.fromRGB(250, 100, 110), AccentSoft = Color3.fromRGB(170, 50, 60), Logo = Color3.fromRGB(245, 100, 110) },
    Green  = { Accent = Color3.fromRGB(80, 200, 130), AccentHover = Color3.fromRGB(100, 220, 150), AccentSoft = Color3.fromRGB(50, 140, 90), Logo = Color3.fromRGB(110, 220, 150) },
}

local function setTheme(name)
    local t = Themes[name] or Themes.Purple
    C.Accent = t.Accent
    C.AccentHover = t.AccentHover
    C.AccentSoft = t.AccentSoft
    C.Logo = t.Logo
end

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================
local function new(class, props)
    local o = Instance.new(class)
    if props then for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
        if props.Parent then o.Parent = props.Parent end end
    return o
end

local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function ustroke(p, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Border; s.Thickness = t or 1; s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local Icons = {
    search       = "rbxassetid://7734052925",
    folder       = "rbxassetid://7733799185",
    chevDown     = "rbxassetid://7733717447",
    target       = "rbxassetid://7743872758",
    eye          = "rbxassetid://7733774602",
    globe        = "rbxassetid://7733954760",
    zap          = "rbxassetid://7733771628",
    settings     = "rbxassetid://7734053495",
    minimize     = "rbxassetid://7733997870",
    close        = "rbxassetid://7743878857",
    lock         = "rbxassetid://7733965118",
    alert        = "rbxassetid://7733658504",
    check        = "rbxassetid://7733715400",
    info         = "rbxassetid://7733964719",
    cpu          = "rbxassetid://7733765045",
    shield       = "rbxassetid://7734056608",
    externalLink = "rbxassetid://7743866903",
    flame        = "rbxassetid://7733798747",
    home         = "rbxassetid://7743872758",
    save         = "rbxassetid://7734052335",
    trash        = "rbxassetid://7743873772",
    refreshCw    = "rbxassetid://7734051052",
    copy         = "rbxassetid://7733764083",
    sliders      = "rbxassetid://7743875962",
}

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
    local icon  = (kind == "success" and Icons.check) or (kind == "error" and Icons.close)
                or (kind == "warning" and Icons.alert) or Icons.info

    local idx = #activeNotifs
    local notifH = 56
    local notifW = 290
    local gap = 10
    local YPos = 80 + idx * (notifH + gap)

    local notif = new("Frame", {
        Parent = NotificationsGui,
        BackgroundColor3 = C.Panel, BorderSizePixel = 0,
        Size = UDim2.fromOffset(notifW, notifH),
        Position = UDim2.new(1, notifW + 30, 0, YPos),
        ZIndex = 1000, ClipsDescendants = false,
        BackgroundTransparency = 0.05,
    })
    corner(notif, 10)
    ustroke(notif, C.BorderBrt, 1, 0.5)
    table.insert(activeNotifs, notif)

    local iconBox = new("Frame", {
        Parent = notif, Size = UDim2.fromOffset(36, 36),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = color, BackgroundTransparency = 0.82,
        BorderSizePixel = 0, ZIndex = 1001,
    })
    corner(iconBox, 8)
    ustroke(iconBox, color, 1, 0.55)
    new("ImageLabel", {
        Parent = iconBox, Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromOffset(9, 9),
        BackgroundTransparency = 1, Image = icon, ImageColor3 = color, ZIndex = 1002,
    })
    local txt = new("TextLabel", {
        Parent = notif, Size = UDim2.new(1, -60, 1, -10),
        Position = UDim2.fromOffset(54, 5), BackgroundTransparency = 1,
        Text = text, TextColor3 = C.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = true,
        ZIndex = 1001,
    })
    local pbarBg = new("Frame", {
        Parent = notif, Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 1, -6),
        BackgroundColor3 = C.PanelInner, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ZIndex = 1001,
    })
    corner(pbarBg, 999)
    local pbar = new("Frame", {
        Parent = pbarBg, Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 1002,
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
-- ГЛАВНАЯ ФУНКЦИЯ СОЗДАНИЯ GUI
-- ============================================
function FractureUI:CreateWindow(config)
    config = config or {}
    local title = config.title or "Fracture"
    local version = config.version or "v1.0"
    local bindKey = config.bindKey or Enum.KeyCode.RightShift
    local theme = config.theme or "Purple"
    
    setTheme(theme)
    ensureNotifGui()

    -- Очищаем старые GUI
    for _, n in ipairs({"FractureUI", "FractureOverlay"}) do
        pcall(function()
            local g = UI_PARENT:FindFirstChild(n)
            if g then g:Destroy() end
        end)
    end

    local ScreenGui = new("ScreenGui", {
        Name = "FractureUI", Parent = UI_PARENT,
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 99000,
    })

    local OverlayGui = new("ScreenGui", {
        Name = "FractureOverlay", Parent = UI_PARENT,
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 99100,
    })

    -- Основное окно
    local Main = new("Frame", {
        Parent = ScreenGui, Name = "Main",
        Size = UDim2.fromOffset(890, 555),
        Position = UDim2.new(0.5, -445, 0.5, -277),
        BackgroundColor3 = C.Bg, BorderSizePixel = 0,
    })
    corner(Main, 14); ustroke(Main, C.Border, 1, 0.4)

    -- Sidebar
    local Sidebar = new("Frame", {
        Parent = Main, Name = "Sidebar",
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundColor3 = C.Sidebar, BorderSizePixel = 0,
    })
    corner(Sidebar, 14)
    new("Frame", {
        Parent = Sidebar, Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        BackgroundColor3 = C.Sidebar, BorderSizePixel = 0,
    })

    -- Logo
    new("TextLabel", {
        Parent = Sidebar, Size = UDim2.fromOffset(40, 40),
        Position = UDim2.fromOffset(10, 14), BackgroundTransparency = 1,
        Text = "FR", TextColor3 = C.Logo,
        TextSize = 22, Font = Enum.Font.GothamBlack,
    })

    -- Top Bar
    local TopBar = new("Frame", {
        Parent = Main, Size = UDim2.new(1, -80, 0, 50),
        Position = UDim2.fromOffset(70, 12), BackgroundTransparency = 1,
    })

    local CloseBtn = new("TextButton", {
        Parent = TopBar, Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -36, 0, 4),
        BackgroundColor3 = C.Panel, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })
    corner(CloseBtn, 8)
    new("ImageLabel", {Parent = CloseBtn, Size = UDim2.fromOffset(16,16),
        Position = UDim2.fromOffset(8,8), BackgroundTransparency = 1,
        Image = Icons.close, ImageColor3 = C.TextDim})

    local MinBtn = new("TextButton", {
        Parent = TopBar, Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -72, 0, 4),
        BackgroundColor3 = C.Panel, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "",
    })
    corner(MinBtn, 8)
    new("ImageLabel", {Parent = MinBtn, Size = UDim2.fromOffset(16,16),
        Position = UDim2.fromOffset(8,8), BackgroundTransparency = 1,
        Image = Icons.minimize, ImageColor3 = C.TextDim})

    -- Avatar
    local AvatarBox = new("Frame", {
        Parent = Sidebar, Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0, 10, 1, -55),
        BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
    })
    corner(AvatarBox, 999)
    ustroke(AvatarBox, C.Accent, 2, 0.3)
    local AvatarImg = new("ImageLabel", {
        Parent = AvatarBox, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, Image = "",
        ScaleType = Enum.ScaleType.Crop,
    })
    corner(AvatarImg, 999)
    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and content then AvatarImg.Image = content end
    end)

    -- Content
    local Content = new("Frame", {
        Parent = Main, Size = UDim2.new(1, -80, 1, -80),
        Position = UDim2.fromOffset(70, 70), BackgroundTransparency = 1,
    })

    -- ============================================
    -- ВКЛАДКИ
    -- ============================================
    local Tabs = {}
    local CurrentTab = nil

    local tabDefs = {
        {name = "1", icon = Icons.home, key = "tab1"},
        {name = "2", icon = Icons.sliders, key = "tab2"},
        {name = "3", icon = Icons.eye, key = "tab3"},
        {name = "4", icon = Icons.flame, key = "tab4"},
        {name = "5", icon = Icons.settings, key = "tab5"},
    }

    local function createSidebarBtn(idx, def)
        local btn = new("TextButton", {
            Parent = Sidebar, Name = "Tab_" .. def.key,
            Size = UDim2.fromOffset(40, 40),
            Position = UDim2.fromOffset(10, 80 + (idx-1)*48),
            BackgroundColor3 = C.PanelInner, BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false,
        })
        corner(btn, 8)
        local img = new("ImageLabel", {
            Parent = btn, Size = UDim2.fromOffset(20, 20),
            Position = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1, Image = def.icon, ImageColor3 = C.TextDim,
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
        local tab = new("Frame", {Parent = Content, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Visible = false})
        return tab
    end

    for i, def in ipairs(tabDefs) do
        local btn, img = createSidebarBtn(i, def)
        local content = createTabContent()
        Tabs[def.key] = {button = btn, image = img, content = content, key = def.key}
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
    -- ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ (ВОЗВРАЩАЕМ)
    -- ============================================
    local function makeRow(parent, yPos, labelText)
        local row = new("Frame", {
            Parent = parent, Size = UDim2.new(1, -32, 0, 36),
            Position = UDim2.fromOffset(16, yPos), BackgroundTransparency = 1,
        })
        new("TextLabel", {
            Parent = row, Size = UDim2.fromOffset(150, 36),
            BackgroundTransparency = 1, Text = labelText,
            TextColor3 = C.TextDim, TextSize = 13, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        return row
    end

    local function createToggle(parent, label, default, callback)
        local row = makeRow(parent, 0, label)
        local frame = new("Frame", {
            Parent = row, Size = UDim2.fromOffset(36, 20),
            Position = UDim2.new(1, -36, 0.5, -10),
            BackgroundColor3 = default and C.Accent or C.PanelInner,
            BorderSizePixel = 0,
        })
        corner(frame, 999)
        local knob = new("Frame", {
            Parent = frame, Size = UDim2.fromOffset(14, 14),
            Position = default and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
        })
        corner(knob, 999)
        local btn = new("TextButton", {Parent = frame, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = ""})
        local state = default or false
        local function setState(v)
            v = v and true or false
            state = v
            TweenService:Create(frame, TweenInfo.new(0.18), {BackgroundColor3 = state and C.Accent or C.PanelInner}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {Position = state and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3)}):Play()
            if callback then pcall(callback, state) end
        end
        btn.MouseButton1Click:Connect(function() setState(not state) end)
        return {setState = setState, getState = function() return state end, frame = row}
    end

    local function createSlider(parent, label, min, max, default, callback)
        local row = makeRow(parent, 0, label)
        local trackWidth = 170
        local function fmt(v) return tostring(math.floor(v + 0.5)) end
        local valBox = new("TextBox", {
            Parent = row, Size = UDim2.fromOffset(60, 18),
            Position = UDim2.new(1, -trackWidth - 70, 0.5, -9),
            BackgroundTransparency = 1, Text = fmt(default),
            TextColor3 = C.Text, TextSize = 12, Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = true,
        })
        local track = new("Frame", {
            Parent = row, Size = UDim2.fromOffset(trackWidth, 4),
            Position = UDim2.new(1, -trackWidth, 0.5, -2),
            BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
        })
        corner(track, 999)
        local fill = new("Frame", {Parent = track, BackgroundColor3 = C.Accent, BorderSizePixel = 0})
        corner(fill, 999)
        local knob = new("Frame", {
            Parent = track, Size = UDim2.fromOffset(14, 14),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 2,
        })
        corner(knob, 999)
        local value = default
        local function setVal(v, fire)
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
            Parent = track, Size = UDim2.new(1, 0, 1, 18),
            Position = UDim2.fromOffset(0, -7),
            BackgroundTransparency = 1, Text = "",
        })
        local dragging = false
        btn.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
            if n then setVal(n, true) else setVal(value, false) end
        end)
        return {setValue = function(v) setVal(v, true) end, getValue = function() return value end, frame = row}
    end

    local function createDropdown(parent, label, options, default, callback)
        local row = makeRow(parent, 0, label)
        local dd = new("TextButton", {
            Parent = row, Size = UDim2.fromOffset(150, 28),
            Position = UDim2.new(1, -150, 0.5, -14),
            BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
        })
        corner(dd, 6)
        local txtL = new("TextLabel", {
            Parent = dd, Size = UDim2.new(1, -28, 1, 0),
            Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
            Text = tostring(default), TextColor3 = C.Text, TextSize = 12,
            Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
        })
        local arrow = new("ImageLabel", {
            Parent = dd, Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(1, -22, 0.5, -7),
            BackgroundTransparency = 1, Image = Icons.chevDown, ImageColor3 = C.TextDim,
        })
        local current = default
        local function setValue(v)
            for _, opt in ipairs(options) do
                if tostring(opt) == tostring(v) then
                    current = opt
                    txtL.Text = tostring(opt)
                    if callback then pcall(callback, opt) end
                    return
                end
            end
        end
        dd.MouseButton1Click:Connect(function()
            local pop = new("Frame", {
                Parent = OverlayGui,
                Size = UDim2.fromOffset(150, 0),
                BackgroundColor3 = C.Panel, BorderSizePixel = 0,
                Visible = true, ClipsDescendants = true,
            })
            corner(pop, 10); ustroke(pop, C.BorderBrt, 1, 0.3)
            new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = pop})
            new("UIPadding", { Parent = pop, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
            local p = dd.AbsolutePosition; local s = dd.AbsoluteSize
            pop.Position = UDim2.fromOffset(p.X, p.Y + s.Y + 4)
            for i, opt in ipairs(options) do
                local item = new("TextButton", {
                    Parent = pop, Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = C.PanelHover, BackgroundTransparency = 1,
                    BorderSizePixel = 0, Text = "  " .. tostring(opt),
                    TextColor3 = (tostring(opt) == tostring(current)) and C.Accent or C.Text,
                    TextSize = 12, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false, LayoutOrder = i,
                })
                corner(item, 5)
                item.MouseEnter:Connect(function() item.BackgroundTransparency = 0 end)
                item.MouseLeave:Connect(function() item.BackgroundTransparency = 1 end)
                item.MouseButton1Click:Connect(function()
                    setValue(opt)
                    pop:Destroy()
                end)
            end
            pop.Size = UDim2.fromOffset(150, math.min(#options, 6) * 26 + 8)
        end)
        return {setValue = setValue, getValue = function() return current end, frame = row}
    end

    local function createKeybind(parent, label, default, callback)
        local row = makeRow(parent, 0, label)
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
            Parent = row, Size = UDim2.fromOffset(150, 28),
            Position = UDim2.new(1, -150, 0.5, -14),
            BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
            Text = keyName(default), TextColor3 = C.Text,
            TextSize = 12, Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
        })
        corner(btn, 6)
        local current = default
        local listening = false
        local listenerConn
        btn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true; btn.Text = "..."; btn.TextColor3 = C.Accent
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
                    btn.Text = keyName(k); btn.TextColor3 = C.Text
                    listening = false
                    if listenerConn then listenerConn:Disconnect(); listenerConn = nil end
                    if callback then pcall(callback, k) end
                end
            end)
        end)
        return {setKey = function(k) current = k; btn.Text = keyName(k) end, getKey = function() return current end, frame = row}
    end

    local function createButton(parent, label, color, onClick)
        local row = new("Frame", {
            Parent = parent, Size = UDim2.new(1, -32, 0, 36),
            Position = UDim2.fromOffset(16, 0),
            BackgroundTransparency = 1,
        })
        local btn = new("TextButton", {
            Parent = row, Size = UDim2.fromScale(1,1),
            BackgroundColor3 = color or C.PanelInner, BorderSizePixel = 0,
            Text = label, TextColor3 = C.Text,
            TextSize = 13, Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
        })
        corner(btn, 6)
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = (color or C.PanelInner):Lerp(Color3.new(1,1,1), 0.1)}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or C.PanelInner}):Play() end)
        btn.MouseButton1Click:Connect(function() if onClick then pcall(onClick) end end)
        return {frame = row}
    end

    local function createSection(parent, title, xScale, xOffset)
        new("TextLabel", {
            Parent = parent, Size = UDim2.new(xScale, -10, 0, 24),
            Position = UDim2.new(xOffset or 0, (xOffset or 0) > 0 and 10 or 0, 0, 0),
            BackgroundTransparency = 1, Text = title,
            TextColor3 = C.TextMuted, TextSize = 12,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
        })
        local panel = new("Frame", {
            Parent = parent, Size = UDim2.new(xScale, -10, 1, -32),
            Position = UDim2.new(xOffset or 0, (xOffset or 0) > 0 and 10 or 0, 0, 32),
            BackgroundColor3 = C.Panel, BorderSizePixel = 0,
        })
        corner(panel, 10)
        return panel
    end

    -- ============================================
    -- ПОСТРОЕНИЕ ВКЛАДОК
    -- ============================================
    -- Tab 1
    local tab1 = Tabs["tab1"].content
    local left1 = createSection(tab1, "GENERAL", 0.5, 0)
    local right1 = createSection(tab1, "ADVANCED", 0.5, 0.5)
    
    local y1 = {NextY = 14}
    local toggle1 = createToggle(left1, "Enable Module", false, function(s) end)
    y1.NextY = y1.NextY + 42
    local slider1 = createSlider(left1, "Intensity", 0, 100, 50, function(v) end)
    y1.NextY = y1.NextY + 42
    local dropdown1 = createDropdown(left1, "Mode", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(v) end)
    y1.NextY = y1.NextY + 42
    local keybind1 = createKeybind(left1, "Activation Key", Enum.KeyCode.E, function(k) end)

    local y1r = {NextY = 14}
    local slider2 = createSlider(right1, "Speed", 1, 20, 8, function(v) end)
    y1r.NextY = y1r.NextY + 42
    local toggle2 = createToggle(right1, "Smoothness", true, function(s) end)
    y1r.NextY = y1r.NextY + 42
    local toggle3 = createToggle(right1, "Show Indicator", false, function(s) end)

    -- Tab 2
    local tab2 = Tabs["tab2"].content
    local left2 = createSection(tab2, "GENERAL", 0.5, 0)
    local right2 = createSection(tab2, "ADVANCED", 0.5, 0.5)
    local y2 = {NextY = 14}
    local toggle4 = createToggle(left2, "Enable Module", false, function(s) end)
    y2.NextY = y2.NextY + 42
    local slider3 = createSlider(left2, "Intensity", 0.1, 5.0, 1.0, function(v) end)

    -- Tab 3
    local tab3 = Tabs["tab3"].content
    local left3 = createSection(tab3, "GENERAL", 0.5, 0)
    local right3 = createSection(tab3, "ADVANCED", 0.5, 0.5)
    local y3 = {NextY = 14}
    local toggle5 = createToggle(left3, "Enable Module", false, function(s) end)
    y3.NextY = y3.NextY + 42
    local toggle6 = createToggle(left3, "Team Filter", true, function(s) end)
    y3.NextY = y3.NextY + 42
    local slider4 = createSlider(left3, "Size", 8, 32, 14, function(v) end)

    -- Tab 4
    local tab4 = Tabs["tab4"].content
    local left4 = createSection(tab4, "GENERAL", 1, 0)
    local y4 = {NextY = 14}
    local toggle7 = createToggle(left4, "Enable Module", false, function(s) end)
    y4.NextY = y4.NextY + 42
    local toggle8 = createToggle(left4, "Enable Module 2", false, function(s) end)
    y4.NextY = y4.NextY + 42
    local toggle9 = createToggle(left4, "Enable Module 3", false, function(s) end)

    -- Tab 5 (Settings)
    local tab5 = Tabs["tab5"].content
    local left5 = createSection(tab5, "INTERFACE", 0.5, 0)
    local right5 = createSection(tab5, "CONFIG SYSTEM", 0.5, 0.5)
    local y5 = {NextY = 14}
    local bindUI = createKeybind(left5, "Toggle GUI Bind", Enum.KeyCode.RightShift, function(k) end)
    y5.NextY = y5.NextY + 42
    local dropdownTheme = createDropdown(left5, "Theme", {"Purple", "Blue", "Red", "Green"}, "Purple", function(v)
        setTheme(v)
    end)
    y5.NextY = y5.NextY + 42
    local toggleNotif = createToggle(left5, "Notifications", true, function(s) notificationEnabled = s end)

    -- Info row
    local infoRow = new("Frame", {
        Parent = left5, Size = UDim2.new(1, -32, 0, 60),
        Position = UDim2.fromOffset(16, y5.NextY),
        BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
    })
    corner(infoRow, 8)
    new("TextLabel", { Parent = infoRow, Size = UDim2.fromOffset(80, 16),
        Position = UDim2.fromOffset(12, 8), BackgroundTransparency = 1,
        Text = "Executor", TextColor3 = C.TextMuted, TextSize = 11,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left })
    new("TextLabel", { Parent = infoRow, Size = UDim2.new(1, -100, 0, 16),
        Position = UDim2.fromOffset(90, 8), BackgroundTransparency = 1,
        Text = "Unknown", TextColor3 = C.Text,
        TextSize = 12, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right })

    -- Config buttons (right5)
    local y5r = {NextY = 14}
    new("TextLabel", {
        Parent = right5, Size = UDim2.new(1, -32, 0, 16),
        Position = UDim2.fromOffset(16, y5r.NextY),
        BackgroundTransparency = 1, Text = "Config Name",
        TextColor3 = C.TextMuted, TextSize = 11, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    y5r.NextY = y5r.NextY + 22
    new("Frame", {
        Parent = right5, Size = UDim2.new(1, -32, 0, 36),
        Position = UDim2.fromOffset(16, y5r.NextY),
        BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
    })
    corner(right5:FindFirstChildOfClass("Frame") or right5, 8)
    y5r.NextY = y5r.NextY + 50

    local function btn(parent, label, color, icon, onClick, col, row)
        local b = new("TextButton", {
            Parent = parent,
            Size = UDim2.fromOffset(130, 34),
            Position = UDim2.fromOffset(col * (130 + 8), row * (34 + 8)),
            BackgroundColor3 = color, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
        })
        corner(b, 8)
        new("UIListLayout", {
            Parent = b, FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
        })
        new("ImageLabel", {Parent = b, Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1, Image = icon,
            ImageColor3 = Color3.new(1,1,1), LayoutOrder = 1})
        new("TextLabel", {Parent = b, Size = UDim2.fromOffset(0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1, Text = label,
            TextColor3 = Color3.new(1,1,1), TextSize = 12,
            Font = Enum.Font.GothamBold, LayoutOrder = 2})
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.12)}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
        end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    local cfgGrid = new("Frame", {
        Parent = right5, Size = UDim2.new(1, -32, 0, 76),
        Position = UDim2.fromOffset(16, y5r.NextY),
        BackgroundTransparency = 1,
    })
    btn(cfgGrid, "Save", C.Accent, Icons.save, function() end, 0, 0)
    btn(cfgGrid, "Load", C.PanelInner, Icons.folder, function() end, 1, 0)
    btn(cfgGrid, "Delete", C.Danger, Icons.trash, function() end, 0, 1)
    btn(cfgGrid, "Refresh", C.PanelInner, Icons.refreshCw, function() end, 1, 1)

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

    MinBtn.MouseButton1Click:Connect(function() setMinimized(not minimized) end)

    local function confirmDialog(text, onYes)
        local cgui = new("ScreenGui", {
            Name = "FractureConfirm", Parent = UI_PARENT,
            ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 99500, IgnoreGuiInset = true,
        })
        local dim = new("Frame", {
            Parent = cgui, Size = UDim2.fromScale(1,1),
            BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        TweenService:Create(dim, TweenInfo.new(0.2), {BackgroundTransparency = 0.55}):Play()

        local W, H = 400, 160
        local box = new("Frame", {
            Parent = dim, Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = C.Bg, BorderSizePixel = 0,
            ClipsDescendants = true,
        })
        corner(box, 12); ustroke(box, C.BorderBrt, 1, 0.3)
        new("TextLabel", { Parent = box,
            Size = UDim2.new(1, -32, 0, 80),
            Position = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Text = text, TextColor3 = C.Text, TextSize = 16,
            Font = Enum.Font.GothamMedium, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center })
        local btnW = (W - 16 * 2 - 8) / 2
        local yes = new("TextButton", { Parent = box, Size = UDim2.fromOffset(btnW, 34),
            Position = UDim2.fromOffset(16, H - 50),
            BackgroundColor3 = C.Danger, BorderSizePixel = 0,
            Text = "Yes", TextColor3 = Color3.new(1,1,1),
            TextSize = 13, Font = Enum.Font.GothamBold,
            AutoButtonColor = false })
        corner(yes, 8)
        local no = new("TextButton", { Parent = box, Size = UDim2.fromOffset(btnW, 34),
            Position = UDim2.fromOffset(16 + btnW + 8, H - 50),
            BackgroundColor3 = C.PanelInner, BorderSizePixel = 0,
            Text = "No", TextColor3 = C.Text,
            TextSize = 13, Font = Enum.Font.GothamBold,
            AutoButtonColor = false })
        corner(no, 8)
        yes.MouseEnter:Connect(function() TweenService:Create(yes, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(245, 110, 120)}):Play() end)
        yes.MouseLeave:Connect(function() TweenService:Create(yes, TweenInfo.new(0.15), {BackgroundColor3 = C.Danger}):Play() end)
        no.MouseEnter:Connect(function() TweenService:Create(no, TweenInfo.new(0.15), {BackgroundColor3 = C.PanelHover}):Play() end)
        no.MouseLeave:Connect(function() TweenService:Create(no, TweenInfo.new(0.15), {BackgroundColor3 = C.PanelInner}):Play() end)
        local function close() cgui:Destroy() end
        yes.MouseButton1Click:Connect(function() close(); if onYes then onYes() end end)
        no.MouseButton1Click:Connect(close)
        TweenService:Create(box, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(W, H),
            Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
        }):Play()
    end

    CloseBtn.MouseButton1Click:Connect(function()
        confirmDialog("Are you sure you want to close the script permanently?", function()
            ScreenGui:Destroy()
            OverlayGui:Destroy()
        end)
    end)

    -- Drag
    local dragging = false
    local dragStart, startPos
    local dragHandle = new("TextButton", {
        Parent = Main, Size = UDim2.new(1, -350, 0, 50),
        Position = UDim2.fromOffset(270, 0),
        BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, ZIndex = 0,
    })
    dragHandle.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Main.Position
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mp = UserInputService:GetMouseLocation()
            local d = mp - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- Bind
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
        setTheme = setTheme,
        setNotificationEnabled = function(state) notificationEnabled = state end,
        getUI = function() return ScreenGui end,
        getMain = function() return Main end,
        getTabs = function() return Tabs end,
        getCurrentTab = function() return CurrentTab end,
        close = function() ScreenGui:Destroy(); OverlayGui:Destroy() end,
        minimize = function() setMinimized(true) end,
        restore = function() setMinimized(false) end,
        colors = C,
        -- Элементы (для доступа из вне)
        elements = {
            toggle1 = toggle1,
            slider1 = slider1,
            dropdown1 = dropdown1,
            keybind1 = keybind1,
            slider2 = slider2,
            toggle2 = toggle2,
            toggle3 = toggle3,
            toggle4 = toggle4,
            slider3 = slider3,
            toggle5 = toggle5,
            toggle6 = toggle6,
            slider4 = slider4,
            toggle7 = toggle7,
            toggle8 = toggle8,
            toggle9 = toggle9,
            bindUI = bindUI,
            dropdownTheme = dropdownTheme,
            toggleNotif = toggleNotif,
        },
        -- Создание элементов на лету
        createToggle = function(parent, label, default, callback)
            return createToggle(parent, label, default, callback)
        end,
        createSlider = function(parent, label, min, max, default, callback)
            return createSlider(parent, label, min, max, default, callback)
        end,
        createDropdown = function(parent, label, options, default, callback)
            return createDropdown(parent, label, options, default, callback)
        end,
        createKeybind = function(parent, label, default, callback)
            return createKeybind(parent, label, default, callback)
        end,
        createButton = function(parent, label, color, onClick)
            return createButton(parent, label, color, onClick)
        end,
        createSection = createSection,
    }

    return api
end

return FractureUI
