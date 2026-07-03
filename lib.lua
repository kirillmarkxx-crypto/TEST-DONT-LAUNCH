-- ============================================
-- AREA 51 SCRIPT v3.5 - ПОЛНАЯ ВЕРСИЯ
-- С КРАСИВОЙ БИБЛИОТЕКОЙ И ВСЕМИ ФУНКЦИЯМИ
-- ============================================

-- ============================================
-- БИБЛИОТЕКА FRACTURE UI v5.0 (ВСТРОЕННАЯ)
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
    return game:GetService("CoreGui") or PlayerGui
end
local UI_PARENT = getGuiParent()

-- ВСЕ ИКОНКИ
local ICONS = {
    home = "rbxassetid://7743872758",
    settings = "rbxassetid://7734053495",
    info = "rbxassetid://7733964719",
    search = "rbxassetid://7734052925",
    folder = "rbxassetid://7733799185",
    save = "rbxassetid://7734052335",
    trash = "rbxassetid://7743873772",
    refresh = "rbxassetid://7734051052",
    player = "rbxassetid://7743872758",
    health = "rbxassetid://7733965118",
    speed = "rbxassetid://7733771628",
    jump = "rbxassetid://7733798747",
    armor = "rbxassetid://7734056608",
    sword = "rbxassetid://7743875962",
    shield = "rbxassetid://7734056608",
    eye = "rbxassetid://7733774602",
    esp = "rbxassetid://7733774602",
    glow = "rbxassetid://7734056608",
    color = "rbxassetid://7733965118",
    brightness = "rbxassetid://7734053495",
    fog = "rbxassetid://7734052925",
    target = "rbxassetid://7743872758",
    aim = "rbxassetid://7743872758",
    crosshair = "rbxassetid://7743872758",
    bullet = "rbxassetid://7743875962",
    fire = "rbxassetid://7733798747",
    explosion = "rbxassetid://7733798747",
    knife = "rbxassetid://7743875962",
    gun = "rbxassetid://7743875962",
    telegram = "rbxassetid://7733964719",
    discord = "rbxassetid://7733964719",
    youtube = "rbxassetid://7733964719",
    github = "rbxassetid://7733964719",
    link = "rbxassetid://7743866903",
    minimize = "rbxassetid://7733997870",
    close = "rbxassetid://7743878857",
    lock = "rbxassetid://7733965118",
    unlock = "rbxassetid://7733965118",
    check = "rbxassetid://7733715400",
    alert = "rbxassetid://7733658504",
    star = "rbxassetid://7733715400",
    heart = "rbxassetid://7733965118",
    trophy = "rbxassetid://7733965118",
    clock = "rbxassetid://7734053495",
    map = "rbxassetid://7734052925",
    wifi = "rbxassetid://7733965118",
    battery = "rbxassetid://7734053495",
    cpu = "rbxassetid://7733765045",
    chevron = "rbxassetid://7733717447",
}

-- КРАСИВЫЕ ЦВЕТА
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
        Image = ICONS.check,
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
-- ОСНОВНАЯ ФУНКЦИЯ СОЗДАНИЯ GUI
-- ============================================
function FractureUI:CreateWindow(config)
    config = config or {}
    local title = config.title or "Fracture"
    local version = config.version or "v1.0"
    local bindKey = config.bindKey or Enum.KeyCode.G

    ensureNotifGui()

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

    local Sidebar = new("Frame", {
        Parent = Main,
        Name = "Sidebar",
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundColor3 = C.Sidebar,
        BorderSizePixel = 0,
    })
    corner(Sidebar, 14)

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

    local TopBar = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -80, 0, 50),
        Position = UDim2.fromOffset(70, 12),
        BackgroundTransparency = 1,
    })

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
        Image = ICONS.close,
        ImageColor3 = C.TextDim,
    })

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
        Image = ICONS.minimize,
        ImageColor3 = C.TextDim,
    })

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

    local Content = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -80, 1, -80),
        Position = UDim2.fromOffset(70, 70),
        BackgroundTransparency = 1,
    })

    -- ============================================
    -- ДИНАМИЧЕСКИЕ ВКЛАДКИ
    -- ============================================
    local Tabs = {}
    local CurrentTab = nil
    local tabButtons = {}

    function FractureUI:CreateTab(name, iconKey)
        local icon = ICONS[iconKey] or ICONS.home
        
        local btn = new("TextButton", {
            Parent = Sidebar,
            Name = "Tab_" .. name:gsub("%s+", ""),
            Size = UDim2.fromOffset(40, 40),
            Position = UDim2.fromOffset(10, 80 + #tabButtons * 48),
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
            Image = icon,
            ImageColor3 = C.TextDim,
        })

        local content = new("Frame", {
            Parent = Content,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = #tabButtons == 0,
        })
        new("UIPadding", {
            Parent = content,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        })

        local tabData = {
            button = btn,
            image = img,
            content = content,
            key = name,
            name = name,
        }
        table.insert(tabButtons, tabData)
        Tabs[name] = tabData

        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabButtons) do
                t.content.Visible = (t == tabData)
                t.button.BackgroundTransparency = (t == tabData) and 0 or 1
                t.image.ImageColor3 = (t == tabData) and C.Logo or C.TextDim
            end
            CurrentTab = name
        end)

        btn.MouseEnter:Connect(function()
            if CurrentTab ~= name then
                TweenService:Create(img, TweenInfo.new(0.15), {ImageColor3 = C.Text}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= name then
                TweenService:Create(img, TweenInfo.new(0.15), {ImageColor3 = C.TextDim}):Play()
            end
        end)

        if #tabButtons == 1 then
            CurrentTab = name
            btn.BackgroundTransparency = 0
            img.ImageColor3 = C.Logo
        end

        -- ============================================
        -- ЭЛЕМЕНТЫ ВНУТРИ ВКЛАДКИ
        -- ============================================
        local tabApi = {
            content = content,
            
            CreateToggle = function(self, label, default, callback)
                local row = new("Frame", {
                    Parent = content,
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
                }
            end,

            CreateSlider = function(self, label, min, max, default, callback)
                local row = new("Frame", {
                    Parent = content,
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
                }
            end,

            CreateButton = function(self, label, color, onClick)
                local row = new("Frame", {
                    Parent = content,
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
            end,

            CreateKeybind = function(self, label, default, callback)
                local row = new("Frame", {
                    Parent = content,
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
                }
            end,

            CreateDropdown = function(self, label, options, default, callback)
                local row = new("Frame", {
                    Parent = content,
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
                local dd = new("TextButton", {
                    Parent = row,
                    Size = UDim2.fromOffset(150, 28),
                    Position = UDim2.new(1, -150, 0.5, -14),
                    BackgroundColor3 = C.PanelInner,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                })
                corner(dd, 6)
                local txtL = new("TextLabel", {
                    Parent = dd,
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = C.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local arrow = new("ImageLabel", {
                    Parent = dd,
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.new(1, -22, 0.5, -7),
                    BackgroundTransparency = 1,
                    Image = ICONS.chevron,
                    ImageColor3 = C.TextDim,
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
                        BackgroundColor3 = C.Panel,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                    })
                    corner(pop, 10)
                    ustroke(pop, C.BorderBrt, 1, 0.3)
                    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = pop})
                    new("UIPadding", { Parent = pop, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
                    local p = dd.AbsolutePosition
                    local s = dd.AbsoluteSize
                    pop.Position = UDim2.fromOffset(p.X, p.Y + s.Y + 4)
                    for i, opt in ipairs(options) do
                        local item = new("TextButton", {
                            Parent = pop,
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = C.PanelHover,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Text = "  " .. tostring(opt),
                            TextColor3 = (tostring(opt) == tostring(current)) and C.Accent or C.Text,
                            TextSize = 12,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            LayoutOrder = i,
                        })
                        corner(item, 5)
                        item.MouseEnter:Connect(function() item.BackgroundTransparency = 0 end)
                        item.MouseLeave:Connect(function() item.BackgroundTransparency = 1 end)
                        item.MouseButton1Click:Connect(function()
                            setValue(opt)
                            pop:Destroy()
                        end)
                    end                    pop.Size = UDim2.fromOffset(150, math.min(#options, 6) * 26 + 8)
                end)
                return {
                    setValue = setValue,
                    getValue = function() return current end,
                }
            end,
        }

        return tabApi
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

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == bindKey then
            Main.Visible = not Main.Visible
            OverlayGui.Enabled = Main.Visible
        end
    end)

    notify("UI Loaded", "success", 2, true)

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
        icons = ICONS,
        CreateTab = FractureUI.CreateTab,
    }

    return api
end

return FractureUI

-- ============================================
-- КОНЕЦ БИБЛИОТЕКИ
-- ============================================

-- ============================================
-- ВСЯ ЛОГИКА AREA 51 (ФУНКЦИИ)
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

_G.PremiumGUI = _G.PremiumGUI or {}
local g = _G.PremiumGUI

g.functionStates = {
    speedEnabled = false,
    walkSpeed = 2,
    monsterESP = false,
    mysteryBoxESP = false,
    playerESP = false,
    noProximityDelay = false,
    hitboxEnabled = false,
    noFogEnabled = false
}
g.monsterESPTable = {}
g.playerESPTable = {}
g.mysteryBoxESPTable = {}
g.hitboxSizes = {}
g.hitboxPendingMonsters = {}
g.hitboxConnections = {}
g.mysteryBoxESPConnections = {}
g.originalFog = nil
g.armorGiverOriginalCFrame = nil
g.speedConnection = nil
g.monsterESPConnection = nil
g.monsterChildAdded = nil
g.noProximityConnection = nil
g.playerESPConnection = nil

local functionStates = g.functionStates
local monsterESPTable = g.monsterESPTable
local playerESPTable = g.playerESPTable
local mysteryBoxESPTable = g.mysteryBoxESPTable

-- СПИСОК МОНСТРОВ
local MONSTER_NAMES = {
    "Aberration", "Alien", "Ao Oni", "Captain Zombie", "Chucky",
    "Eyeless Jack", "Fishface", "Freddy Krueger", "Fuwatti",
    "Ghostface", "Granny", "Jack Torrance", "Jason", "Jeff",
    "Kraken", "Leatherface", "Michael Myers", "Pennywise",
    "Pinhead", "Rake", "Robot", "Slenderman", "Smile Dog",
    "Sonic.exe", "Tails Doll", "Wendigo", "Yeti", "Zombie"
}

local function isMonster(name)
    for _, monsterName in ipairs(MONSTER_NAMES) do
        if name == monsterName then return true end
    end
    return false
end

-- === NO E DELAY ===
function toggleNoProximityDelay(state)
    functionStates.noProximityDelay = state
    if state then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
        if g.noProximityConnection then g.noProximityConnection:Disconnect() end
        g.noProximityConnection = Workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end)
        Window.notify("No E Delay включен", "success")
    else
        if g.noProximityConnection then
            g.noProximityConnection:Disconnect()
            g.noProximityConnection = nil
        end
        Window.notify("No E Delay выключен", "info")
    end
end

-- === SPEED CHANGER ===
function toggleSpeed(state)
    functionStates.speedEnabled = state
    if state then
        if g.speedConnection then g.speedConnection:Disconnect() end
        g.speedConnection = RunService.RenderStepped:Connect(function()
            local character = Player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if character and humanoid and hrp then
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + moveDir * math.max(functionStates.walkSpeed, 1) * 0.080
                end
            end
        end)
        Window.notify("Speed Changer включен", "success")
    else
        if g.speedConnection then
            g.speedConnection:Disconnect()
            g.speedConnection = nil
        end
        Window.notify("Speed Changer выключен", "info")
    end
end

-- === NO FOG ===
function toggleNoFog(state)
    functionStates.noFogEnabled = state
    if state then
        g.originalFog = {
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            FogColor = Lighting.FogColor
        }
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Window.notify("NoFog включен", "success")
    else
        if g.originalFog then
            Lighting.FogEnd = g.originalFog.FogEnd
            Lighting.FogStart = g.originalFog.FogStart
            Lighting.FogColor = g.originalFog.FogColor
        end
        Window.notify("NoFog выключен", "info")
    end
end

-- === GIVE ARMOR ===
function giveArmor()
    local area51 = Workspace:FindFirstChild("AREA51")
    if not area51 then Window.notify("Папка AREA51 не найдена", "error") return end
    local amory2Room = area51:FindFirstChild("Amory2Room")
    if not amory2Room then Window.notify("Amory2Room не найдена", "error") return end
    local armory = amory2Room:FindFirstChild("Armory")
    if not armory then Window.notify("Armory не найдена", "error") return end
    local giver = armory:FindFirstChild("Giver")
    if not giver then Window.notify("Объект Giver не найден", "error") return end
    local proximityPrompt = giver:FindFirstChildOfClass("ProximityPrompt")
    if not proximityPrompt then Window.notify("ProximityPrompt не найден", "error") return end
    
    g.armorGiverOriginalCFrame = giver:GetPivot()
    local character = Player.Character
    if not character then Window.notify("Персонаж не найден", "error") return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then Window.notify("HumanoidRootPart не найден", "error") return end
    
    local success = pcall(function()
        giver:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3))
        task.wait(0.2)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        task.wait(0.3)
        giver:PivotTo(g.armorGiverOriginalCFrame)
    end)
    
    if success then
        Window.notify("Броня получена", "success")
    else
        Window.notify("Ошибка при получении брони", "error")
        pcall(function() if g.armorGiverOriginalCFrame then giver:PivotTo(g.armorGiverOriginalCFrame) end end)
    end
end

-- === TP BACK GUI ===
local tpBackGui = nil
local savedPosition = nil

local function createTPBackGUI()
    if tpBackGui and tpBackGui.Parent then pcall(function() tpBackGui:Destroy() end) end
    local gui = Instance.new("ScreenGui")
    gui.Name = "TPBackGUI"
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 10000
    
    local frame = Instance.new("Frame")
    frame.Name = "TPBackFrame"
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    frame.BackgroundTransparency = 0.15
    frame.Size = UDim2.new(0, 150, 0, 50)
    frame.Position = UDim2.new(1, -170, 1, -70)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Parent = frame
    button.BackgroundTransparency = 1
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Text = "TP BACK"
    button.TextColor3 = Color3.fromRGB(245, 245, 245)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.AutoButtonColor = false
    
    button.MouseButton1Click:Connect(function()
        if savedPosition then
            local character = Player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(savedPosition)
                    gui:Destroy()
                    savedPosition = nil
                    Window.notify("Возвращение выполнено", "success")
                end
            end
        end
    end)
    
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragStart = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragStart and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    tpBackGui = gui
    return gui
end

-- === TELEPORT TO PACK-A-PUNCH ===
local packAPunchPos = Vector3.new(109, 335, 62)
function teleportToPackAPunch()
    local character = Player.Character
    if not character then Window.notify("Ошибка: нет персонажа", "error") return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then Window.notify("Ошибка: не найден HumanoidRootPart", "error") return end
    savedPosition = hrp.Position
    hrp.CFrame = CFrame.new(packAPunchPos)
    createTPBackGUI()
    Window.notify("Телепортация выполнена", "success")
end

-- === KILL MONSTERS ===
function killMonsters()
    local count = 0
    local killersFolder = Workspace:FindFirstChild("Killers")
    if not killersFolder then Window.notify("Папка Killers не найдена", "error") return end
    for _, obj in ipairs(killersFolder:GetChildren()) do
        if obj:IsA("Model") and isMonster(obj.Name) then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                count = count + 1
            end
        end
    end
    if count > 0 then
        Window.notify("Убито " .. count .. " монстров", "success")
    else
        Window.notify("Монстры не найдены", "info")
    end
end

-- === HITBOX ===
function increaseHitbox(monster)
    if not monster:IsA("Model") then return end
    local hrp = monster:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not g.hitboxSizes[monster] then
        g.hitboxSizes[monster] = {Size = hrp.Size, Transparency = hrp.Transparency, CanCollide = hrp.CanCollide}
    end
    hrp.Size = Vector3.new(8, 8, 8)
    hrp.Transparency = 0.7
    hrp.CanCollide = false
    hrp.BrickColor = BrickColor.new("Bright red")
    for _, part in ipairs(monster:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    local connection = monster.AncestryChanged:Connect(function()
        if not monster.Parent then
            if g.hitboxSizes[monster] then g.hitboxSizes[monster] = nil end
            if g.hitboxPendingMonsters[monster] then g.hitboxPendingMonsters[monster] = nil end
            connection:Disconnect()
        end
    end)
    table.insert(g.hitboxConnections, connection)
end

function scheduleHitboxIncrease(monster)
    if g.hitboxPendingMonsters[monster] then return end
    g.hitboxPendingMonsters[monster] = task.delay(4.2, function()
        if monster and monster.Parent and functionStates.hitboxEnabled then
            increaseHitbox(monster)
        end
        g.hitboxPendingMonsters[monster] = nil
    end)
end

function resetAllHitboxes()
    for monster, data in pairs(g.hitboxSizes) do
        if monster and monster.Parent then
            local hrp = monster:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = data.Size
                hrp.Transparency = data.Transparency
                hrp.CanCollide = data.CanCollide
                hrp.BrickColor = BrickColor.new("Medium stone grey")
            end
            for _, part in ipairs(monster:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
    g.hitboxSizes = {}
    for monster, timer in pairs(g.hitboxPendingMonsters) do pcall(function() task.cancel(timer) end); g.hitboxPendingMonsters[monster] = nil end
    for _, conn in ipairs(g.hitboxConnections) do pcall(function() conn:Disconnect() end) end
    g.hitboxConnections = {}
end

function toggleHitbox(state)
    functionStates.hitboxEnabled = state
    if state then
        resetAllHitboxes()
        local killersFolder = Workspace:FindFirstChild("Killers")
        if killersFolder then
            for _, monster in ipairs(killersFolder:GetChildren()) do
                if monster:IsA("Model") and isMonster(monster.Name) then
                    scheduleHitboxIncrease(monster)
                end
            end
            local childConn = killersFolder.ChildAdded:Connect(function(child)
                task.wait(0.1)
                if child:IsA("Model") and isMonster(child.Name) and functionStates.hitboxEnabled then
                    scheduleHitboxIncrease(child)
                end
            end)
            table.insert(g.hitboxConnections, childConn)
        end
        Window.notify("Hitbox включен", "success")
    else
        resetAllHitboxes()
        Window.notify("Hitbox выключен", "info")
    end
end

-- === PLAYER ESP ===
function createPlayerHighlight(player)
    if playerESPTable[player] or player == Player or not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.Parent = player.Character
    playerESPTable[player] = {Highlight = highlight, Player = player}
end

function scanPlayers()
    if not functionStates.playerESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and not playerESPTable[player] then
            createPlayerHighlight(player)
        end
    end
    for player, data in pairs(playerESPTable) do
        if not player.Parent or not player.Character then
            pcall(function() data.Highlight:Destroy() end)
            playerESPTable[player] = nil
        end
    end
end

function togglePlayerESP(state)
    functionStates.playerESP = state
    if state then
        for _, data in pairs(playerESPTable) do pcall(function() data.Highlight:Destroy() end) end
        playerESPTable = {}
        scanPlayers()
        if g.playerESPConnection then g.playerESPConnection:Disconnect() end
        g.playerESPConnection = RunService.Stepped:Connect(function()
            if tick() % 1 < 0.1 then scanPlayers() end
        end)
        Window.notify("Player ESP включен", "success")
    else
        if g.playerESPConnection then g.playerESPConnection:Disconnect(); g.playerESPConnection = nil end
        for _, data in pairs(playerESPTable) do pcall(function() data.Highlight:Destroy() end) end
        playerESPTable = {}
        Window.notify("Player ESP выключен", "info")
    end
end

-- === MONSTER ESP ===
function createMonsterHighlight(obj)
    if monsterESPTable[obj] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.Parent = obj
    monsterESPTable[obj] = {Highlight = highlight, Part = obj}
end

function scanMonstersOnce()
    if not functionStates or not functionStates.monsterESP then return end
    local monsters = {}
    local killersFolder = Workspace:FindFirstChild("Killers")
    if killersFolder then
        for _, v in ipairs(killersFolder:GetChildren()) do
            if v:IsA("Model") and isMonster(v.Name) then table.insert(monsters, v) end
        end
    end
    for obj, data in pairs(monsterESPTable) do
        if not obj or not obj.Parent then
            pcall(function() if data and data.Highlight then data.Highlight:Destroy() end end)
            monsterESPTable[obj] = nil
        else
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                pcall(function() if data and data.Highlight then data.Highlight:Destroy() end end)
                monsterESPTable[obj] = nil
            end
        end
    end
    for _, v in ipairs(monsters) do
        if not monsterESPTable[v] then
            local humanoid = v:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then createMonsterHighlight(v) end
        end
    end
end

function toggleMonsterESP(state)
    functionStates.monsterESP = state
    if state then
        for _, data in pairs(monsterESPTable) do pcall(function() data.Highlight:Destroy() end) end
        monsterESPTable = {}
        scanMonstersOnce()
        if g.monsterESPConnection then g.monsterESPConnection:Disconnect() end
        local lastScan = 0
        g.monsterESPConnection = RunService.Stepped:Connect(function()
            if tick() - lastScan > 1 then lastScan = tick(); scanMonstersOnce() end
        end)
        local killersFolder = Workspace:FindFirstChild("Killers")
        if killersFolder then
            g.monsterChildAdded = killersFolder.ChildAdded:Connect(function(child)
                task.wait(0.1)
                if child:IsA("Model") and isMonster(child.Name) then
                    local humanoid = child:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then createMonsterHighlight(child) end
                end
            end)
        end
        Window.notify("Monster ESP включен", "success")
    else
        if g.monsterESPConnection then g.monsterESPConnection:Disconnect(); g.monsterESPConnection = nil end
        if g.monsterChildAdded then g.monsterChildAdded:Disconnect(); g.monsterChildAdded = nil end
        for _, data in pairs(monsterESPTable) do pcall(function() data.Highlight:Destroy() end) end
        monsterESPTable = {}
        Window.notify("Monster ESP выключен", "info")
    end
end

-- === MYSTERY BOX ESP ===
function clearMysteryBoxESP()
    for obj, data in pairs(mysteryBoxESPTable) do
        if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
        mysteryBoxESPTable[obj] = nil
    end
end

function createMysteryBoxESP(obj)
    if not functionStates.mysteryBoxESP or mysteryBoxESPTable[obj] then return end
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.Parent = obj
    mysteryBoxESPTable[obj] = {Highlight = highlight, Part = obj}
    local connection = obj.AncestryChanged:Connect(function()
        if not obj.Parent then
            connection:Disconnect()
            if mysteryBoxESPTable[obj] then
                pcall(function() mysteryBoxESPTable[obj].Highlight:Destroy() end)
                mysteryBoxESPTable[obj] = nil
            end
        end
    end)
end

function scanForMysteryBoxes()
    if not functionStates.mysteryBoxESP then return end
    local mysteryFolder = Workspace:FindFirstChild("Mystery Box")
    if mysteryFolder then
        local box = mysteryFolder:FindFirstChild("Box")
        if box and not mysteryBoxESPTable[box] then createMysteryBoxESP(box) end
    end
end

function toggleMysteryBoxESP(state)
    functionStates.mysteryBoxESP = state
    if state then
        clearMysteryBoxESP()
        scanForMysteryBoxes()
        if g.mysteryBoxESPConnections.loop then g.mysteryBoxESPConnections.loop:Disconnect() end
        local lastScan = 0
        g.mysteryBoxESPConnections.loop = RunService.Stepped:Connect(function()
            if tick() - lastScan > 2 then lastScan = tick(); scanForMysteryBoxes() end
        end)
        if g.mysteryBoxESPConnections.descendantAdded then g.mysteryBoxESPConnections.descendantAdded:Disconnect() end
        g.mysteryBoxESPConnections.descendantAdded = Workspace.DescendantAdded:Connect(function(descendant)
            task.wait(0.1)
            if functionStates.mysteryBoxESP then
                if descendant.Name == "Box" and descendant.Parent and descendant.Parent.Name == "Mystery Box" then
                    createMysteryBoxESP(descendant)
                end
            end
        end)
        Window.notify("Mystery Box ESP включен", "success")
    else
        clearMysteryBoxESP()
        if g.mysteryBoxESPConnections.loop then g.mysteryBoxESPConnections.loop:Disconnect(); g.mysteryBoxESPConnections.loop = nil end
        if g.mysteryBoxESPConnections.descendantAdded then g.mysteryBoxESPConnections.descendantAdded:Disconnect(); g.mysteryBoxESPConnections.descendantAdded = nil end
        Window.notify("Mystery Box ESP выключен", "info")
    end
end

-- ============================================
-- СОЗДАЁМ GUI
-- ============================================
local Window = FractureUI:CreateWindow({
    title = "Area 51",
    version = "v3.5",
    bindKey = Enum.KeyCode.G
})

-- СОЗДАЁМ ВКЛАДКИ С ИКОНКАМИ
local mainTab = Window:CreateTab("ГЛАВНАЯ", "home")
local playerTab = Window:CreateTab("ИГРОК", "player")
local visualTab = Window:CreateTab("ВИЗУАЛ", "eye")
local utilsTab = Window:CreateTab("УТИЛИТЫ", "settings")
local socialTab = Window:CreateTab("СОЦСЕТИ", "telegram")

-- ============================================
-- НАПОЛНЯЕМ ВКЛАДКИ
-- ============================================

-- ГЛАВНАЯ
mainTab:CreateButton("Информация", Window.colors.Info, function()
    Window.notify("Area 51 v3.5 | PowerFracture", "info", 3, true)
end)

-- ИГРОК
playerTab:CreateToggle("Speed Changer", false, function(state)
    toggleSpeed(state)
end)

playerTab:CreateSlider("Скорость", 1, 10, 2, function(v)
    functionStates.walkSpeed = v
end)

playerTab:CreateToggle("No E Delay", false, function(state)
    toggleNoProximityDelay(state)
end)

playerTab:CreateButton("Give Armor", Window.colors.Success, function()
    giveArmor()
end)

-- ВИЗУАЛ
visualTab:CreateToggle("Player ESP", false, function(state)
    togglePlayerESP(state)
end)

visualTab:CreateToggle("Monster ESP", false, function(state)
    toggleMonsterESP(state)
end)

visualTab:CreateToggle("Mystery Box ESP", false, function(state)
    toggleMysteryBoxESP(state)
end)

visualTab:CreateToggle("NoFog", false, function(state)
    toggleNoFog(state)
end)

-- УТИЛИТЫ
utilsTab:CreateToggle("Hitbox", false, function(state)
    toggleHitbox(state)
end)

utilsTab:CreateButton("Kill Monsters", Window.colors.Danger, function()
    killMonsters()
end)

utilsTab:CreateButton("TP to Pack-a-Punch", Window.colors.Accent, function()
    teleportToPackAPunch()
end)

-- СОЦСЕТИ
socialTab:CreateButton("Telegram", Color3.fromRGB(42, 171, 238), function()
    setclipboard("https://t.me/erafox")
    Window.notify("Telegram ссылка скопирована!", "success")
end)

socialTab:CreateButton("Discord", Color3.fromRGB(88, 101, 242), function()
    setclipboard("https://discord.gg/fracture")
    Window.notify("Discord ссылка скопирована!", "success")
end)

socialTab:CreateButton("YouTube", Color3.fromRGB(255, 0, 0), function()
    setclipboard("https://youtube.com/@PowerFracture")
    Window.notify("YouTube ссылка скопирована!", "success")
end)

-- ============================================
-- ЗАВЕРШЕНИЕ
-- ============================================
Window.notify("Area 51 загружен! Нажми G", "success", 3, true)
print("[Area 51] v3.5 загружен. G - меню")
