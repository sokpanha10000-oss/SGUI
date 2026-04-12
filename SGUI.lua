local SGUI = {}
SGUI.__index = SGUI

-- ── Services ────────────────────────────────────────────────
local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ── Helpers ──────────────────────────────────────────────────
local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function NewInstance(class, parent, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    inst.Parent = parent
    return inst
end

-- ── Colours ───────────────────────────────────────────────────
local Theme = {
    Background    = Color3.fromRGB(18,  18,  24),
    TopBar        = Color3.fromRGB(28,  28,  38),
    Accent        = Color3.fromRGB(100, 80, 220),
    AccentHover   = Color3.fromRGB(120,100, 240),
    Tab           = Color3.fromRGB(24,  24,  34),
    TabActive     = Color3.fromRGB(38,  38,  55),
    Element       = Color3.fromRGB(30,  30,  42),
    ElementHover  = Color3.fromRGB(42,  42,  58),
    Text          = Color3.fromRGB(230, 230, 255),
    SubText       = Color3.fromRGB(140, 140, 170),
    Toggle_Off    = Color3.fromRGB(55,  55,  70),
    Toggle_On     = Color3.fromRGB(100, 80, 220),
    Slider_Track  = Color3.fromRGB(50,  50,  65),
    Slider_Fill   = Color3.fromRGB(100, 80, 220),
    Stroke        = Color3.fromRGB(55,  50,  80),
    Dropdown_BG   = Color3.fromRGB(22,  22,  32),
}

-- ╔══════════════════════════════════════════════════════════╗
--  SGUI:MakeWindow
-- ╚══════════════════════════════════════════════════════════╝
function SGUI:MakeWindow(cfg)
    cfg = cfg or {}
    local title       = cfg.Title        or "Script Hub"
    local subtitle    = cfg.SubTitle     or ""
    local folder      = cfg.ScriptFolder or "SGUI"

    -- pcall so it doesn't crash if folder already exists
    pcall(function()
        if not isfolder(folder) then makefolder(folder) end
    end)

    -- ── ScreenGui ──────────────────────────────────────────
    local screenGui = NewInstance("ScreenGui", LocalPlayer.PlayerGui, {
        Name            = folder .. "_ScreenGui",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
    })

    -- ── Main Frame ────────────────────────────────────────
    local main = NewInstance("Frame", screenGui, {
        Name            = "Main",
        Size            = UDim2.new(0, 560, 0, 350),
        Position        = UDim2.new(0.5, -280, 0.5, -195),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    NewInstance("UICorner",  main, { CornerRadius = UDim.new(0, 10) })
    NewInstance("UIStroke",  main, {
        Color     = Theme.Stroke,
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    -- Drop shadow
    local shadow = NewInstance("ImageLabel", main, {
        Name            = "Shadow",
        Size            = UDim2.new(1, 30, 1, 30),
        Position        = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image           = "rbxassetid://5554236805",
        ImageColor3     = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.55,
        ZIndex          = -1,
        ScaleType       = Enum.ScaleType.Slice,
        SliceCenter     = Rect.new(23,23,277,277),
    })

    -- ── Top Bar ────────────────────────────────────────────
    local topBar = NewInstance("Frame", main, {
        Name            = "TopBar",
        Size            = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
    })
    NewInstance("UICorner", topBar, { CornerRadius = UDim.new(0, 10) })
    -- Cover bottom corners of topBar
    NewInstance("Frame", topBar, {
        Size            = UDim2.new(1, 0, 0, 10),
        Position        = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
    })

    -- Accent line under topbar
    NewInstance("Frame", main, {
        Size            = UDim2.new(1, 0, 0, 2),
        Position        = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    })

    -- Title
    NewInstance("TextLabel", topBar, {
        Name            = "Title",
        Size            = UDim2.new(1, -120, 1, 0),
        Position        = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text            = title,
        Font            = Enum.Font.GothamBold,
        TextSize        = 15,
        TextColor3      = Theme.Text,
        TextXAlignment  = Enum.TextXAlignment.Left,
    })

    -- SubTitle
    NewInstance("TextLabel", topBar, {
        Name            = "SubTitle",
        Size            = UDim2.new(1, -120, 0, 14),
        Position        = UDim2.new(0, 14, 1, -17),
        BackgroundTransparency = 1,
        Text            = subtitle,
        Font            = Enum.Font.Gotham,
        TextSize        = 11,
        TextColor3      = Theme.SubText,
        TextXAlignment  = Enum.TextXAlignment.Left,
    })

    -- Minimizer button (built-in, always visible on the topbar)
    local minBtn = NewInstance("TextButton", topBar, {
        Name            = "MinBtn",
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Text            = "─",
        Font            = Enum.Font.GothamBold,
        TextSize        = 14,
        TextColor3      = Theme.SubText,
        AutoButtonColor = false,
    })
    NewInstance("UICorner", minBtn, { CornerRadius = UDim.new(0, 6) })

    -- ── Content Area ───────────────────────────────────────
    local content = NewInstance("Frame", main, {
        Name            = "Content",
        Size            = UDim2.new(1, 0, 1, -50),
        Position        = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    -- ── Tab Bar ────────────────────────────────────────────
    local tabBar = NewInstance("ScrollingFrame", content, {
        Name            = "TabBar",
        Size            = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = Theme.Tab,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
    })
    NewInstance("UIPadding", tabBar, {
        PaddingTop    = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
    })
    NewInstance("UIListLayout", tabBar, {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Padding         = UDim.new(0, 5),
    })

    -- ── Element Area ───────────────────────────────────────
    local elementArea = NewInstance("Frame", content, {
        Name            = "ElementArea",
        Size            = UDim2.new(1, -138, 1, 0),
        Position        = UDim2.new(0, 138, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    -- Divider between tabbar and element area
    NewInstance("Frame", content, {
        Size            = UDim2.new(0, 1, 1, 0),
        Position        = UDim2.new(0, 130, 0, 0),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
    })

    -- ── Draggable ──────────────────────────────────────────
    MakeDraggable(main, topBar)

    -- ── Minimizer toggle ───────────────────────────────────
    local isOpen      = true
    local openSize    = UDim2.new(0, 560, 0, 390)
    local closedSize  = UDim2.new(0, 560, 0, 48)
    local tweenInfo   = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    minBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            minBtn.Text = "─"
            Tween(main, tweenInfo, { Size = openSize })
        else
            minBtn.Text = "□"
            Tween(main, tweenInfo, { Size = closedSize })
        end
    end)

    minBtn.MouseEnter:Connect(function()
        Tween(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover })
    end)
    minBtn.MouseLeave:Connect(function()
        Tween(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element })
    end)

    -- ── Window Object ──────────────────────────────────────
    local Window = {}
    Window._tabBar     = tabBar
    Window._elementArea = elementArea
    Window._main       = main
    Window._screenGui  = screenGui
    Window._isOpen     = isOpen
    Window._minBtn     = minBtn
    Window._activeTab  = nil
    Window._tabs       = {}

    -- ── Window:NewMinimizer ────────────────────────────────
    function Window:NewMinimizer(cfg2)
        cfg2 = cfg2 or {}
        local keyCode = cfg2.KeyCode

        if keyCode then
            UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.KeyCode == keyCode then
                    isOpen = not isOpen
                    if isOpen then
                        minBtn.Text = "─"
                        Tween(main, tweenInfo, { Size = openSize })
                    else
                        minBtn.Text = "□"
                        Tween(main, tweenInfo, { Size = closedSize })
                    end
                end
            end)
        end

        local Minimizer = {}

        -- ── Minimizer:CreateMobileMinimizer ────────────────
        function Minimizer:CreateMobileMinimizer(cfg3)
            cfg3 = cfg3 or {}
            local mobileBtn = NewInstance("ImageButton", screenGui, {
                Name            = "MobileMinimizer",
                Size            = UDim2.new(0, 52, 0, 52),
                Position        = UDim2.new(0, 14, 1, -80),
                BackgroundColor3 = cfg3.BackgroundColor3 or Color3.fromRGB(30,30,42),
                Image           = cfg3.Image or "",
                BorderSizePixel = 0,
                ZIndex          = 10,
            })
            NewInstance("UICorner", mobileBtn, { CornerRadius = UDim.new(0, 12) })
            NewInstance("UIStroke", mobileBtn, {
                Color = Theme.Accent, Thickness = 2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })

            -- fallback icon text
            if cfg3.Image == "rbxassetid://0" or cfg3.Image == "" then
                NewInstance("TextLabel", mobileBtn, {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "☰",
                    Font = Enum.Font.GothamBold,
                    TextSize = 22,
                    TextColor3 = Theme.Text,
                })
            end

            -- Draggable mobile button (with click-vs-drag detection)
            local mbDragging, mbDragInput, mbDragStart, mbStartPos
            local mbDragged = false

            mobileBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    mbDragging = true
                    mbDragged  = false
                    mbDragStart = input.Position
                    mbStartPos  = mobileBtn.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            mbDragging = false
                        end
                    end)
                end
            end)

            mobileBtn.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    mbDragInput = input
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input == mbDragInput and mbDragging then
                    local delta = input.Position - mbDragStart
                    -- Only count as drag if moved more than 4px
                    if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
                        mbDragged = true
                    end
                    mobileBtn.Position = UDim2.new(
                        mbStartPos.X.Scale, mbStartPos.X.Offset + delta.X,
                        mbStartPos.Y.Scale, mbStartPos.Y.Offset + delta.Y
                    )
                end
            end)

            -- Only toggle if it was a tap, not a drag
            mobileBtn.MouseButton1Click:Connect(function()
                if mbDragged then return end
                isOpen = not isOpen
                main.Visible = isOpen
            end)

            return mobileBtn
        end

        return Minimizer
    end

    -- ── Window:MakeTab ─────────────────────────────────────
    function Window:MakeTab(cfg2)
        cfg2 = cfg2 or {}
        local tabTitle = cfg2.Title or "Tab"
        local tabIcon  = cfg2.Icon  or ""

        -- Tab Button
        local tabBtn = NewInstance("TextButton", tabBar, {
            Name            = tabTitle,
            Size            = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tab,
            BorderSizePixel = 0,
            Text            = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabTitle,
            Font            = Enum.Font.Gotham,
            TextSize        = 13,
            TextColor3      = Theme.SubText,
            TextXAlignment  = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        })
        NewInstance("UIPadding", tabBtn, { PaddingLeft = UDim.new(0, 10) })
        NewInstance("UICorner",  tabBtn, { CornerRadius = UDim.new(0, 7) })

        -- Accent left indicator
        local indicator = NewInstance("Frame", tabBtn, {
            Name            = "Indicator",
            Size            = UDim2.new(0, 3, 0, 18),
            Position        = UDim2.new(0, -3, 0.5, -9),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible         = false,
        })
        NewInstance("UICorner", indicator, { CornerRadius = UDim.new(0, 4) })

        -- Scroll frame for elements
        local scroll = NewInstance("ScrollingFrame", elementArea, {
            Name            = tabTitle,
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize      = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible         = false,
        })
        NewInstance("UIPadding", scroll, {
            PaddingTop   = UDim.new(0, 8),
            PaddingLeft  = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 8),
        })
        NewInstance("UIListLayout", scroll, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
        })

        -- activate on click
        local function Activate()
            -- deactivate others
            for _, t in pairs(Window._tabs) do
                t._btn.BackgroundColor3 = Theme.Tab
                t._btn.TextColor3       = Theme.SubText
                t._indicator.Visible    = false
                t._scroll.Visible       = false
                t._btn.Font             = Enum.Font.Gotham
            end
            tabBtn.BackgroundColor3 = Theme.TabActive
            tabBtn.TextColor3       = Theme.Text
            tabBtn.Font             = Enum.Font.GothamBold
            indicator.Visible       = true
            scroll.Visible          = true
        end

        tabBtn.MouseButton1Click:Connect(Activate)

        tabBtn.MouseEnter:Connect(function()
            if scroll.Visible then return end
            Tween(tabBtn, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ElementHover })
        end)
        tabBtn.MouseLeave:Connect(function()
            if scroll.Visible then return end
            Tween(tabBtn, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Tab })
        end)

        local Tab = {}
        Tab._btn       = tabBtn
        Tab._indicator = indicator
        Tab._scroll    = scroll
        Tab._order     = 0

        table.insert(Window._tabs, Tab)

        -- auto-activate first tab
        if #Window._tabs == 1 then
            Activate()
        end

        -- ── Helper: element container ──────────────────────
        local function ElementFrame(height)
            Tab._order = Tab._order + 1
            local f = NewInstance("Frame", scroll, {
                Size            = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                LayoutOrder     = Tab._order,
            })
            NewInstance("UICorner", f, { CornerRadius = UDim.new(0, 8) })
            NewInstance("UIStroke", f, {
                Color = Theme.Stroke, Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            return f
        end

        local function ElementLabel(parent, text, x, y, w, h, size, color, font, xAlign)
            return NewInstance("TextLabel", parent, {
                Size            = UDim2.new(w or 0.6, 0, 0, h or 36),
                Position        = UDim2.new(x or 0, 14, y or 0, 0),
                BackgroundTransparency = 1,
                Text            = text,
                Font            = font or Enum.Font.Gotham,
                TextSize        = size or 13,
                TextColor3      = color or Theme.Text,
                TextXAlignment  = xAlign or Enum.TextXAlignment.Left,
                TextTruncate    = Enum.TextTruncate.AtEnd,
            })
        end

        -- ════════════════════════════════════════════════════
        --  Tab:AddButton
        -- ════════════════════════════════════════════════════
        function Tab:AddButton(cfg3)
            cfg3 = cfg3 or {}
            local name     = cfg3.Name     or "Button"
            local debounce = cfg3.Debounce or 0
            local callback = cfg3.Callback or function() end

            local frame  = ElementFrame(38)
            local btn    = NewInstance("TextButton", frame, {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                AutoButtonColor = false,
            })
            ElementLabel(frame, name)

            -- right arrow
            NewInstance("TextLabel", frame, {
                Size            = UDim2.new(0, 24, 1, 0),
                Position        = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text            = "›",
                Font            = Enum.Font.GothamBold,
                TextSize        = 20,
                TextColor3      = Theme.Accent,
                TextXAlignment  = Enum.TextXAlignment.Center,
            })

            local cd = false
            btn.MouseButton1Click:Connect(function()
                if cd then return end
                cd = true
                Tween(frame, TweenInfo.new(0.1), { BackgroundColor3 = Theme.AccentHover })
                task.delay(0.1, function()
                    Tween(frame, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element })
                end)
                task.spawn(callback)
                task.delay(debounce, function() cd = false end)
            end)
            btn.MouseEnter:Connect(function()
                Tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ElementHover })
            end)
            btn.MouseLeave:Connect(function()
                Tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Element })
            end)
        end

        -- ════════════════════════════════════════════════════
        --  Tab:AddToggle
        -- ════════════════════════════════════════════════════
        function Tab:AddToggle(cfg3)
            cfg3 = cfg3 or {}
            local name     = cfg3.Name     or "Toggle"
            local default  = cfg3.Default  or false
            local callback = cfg3.Callback or function() end

            local frame  = ElementFrame(38)
            ElementLabel(frame, name)

            local trackW, trackH = 42, 22
            local track = NewInstance("Frame", frame, {
                Size     = UDim2.new(0, trackW, 0, trackH),
                Position = UDim2.new(1, -(trackW + 12), 0.5, -(trackH / 2)),
                BackgroundColor3 = default and Theme.Toggle_On or Theme.Toggle_Off,
                BorderSizePixel = 0,
            })
            NewInstance("UICorner", track, { CornerRadius = UDim.new(1, 0) })

            local knob = NewInstance("Frame", track, {
                Size     = UDim2.new(0, 16, 0, 16),
                Position = default
                    and UDim2.new(1, -19, 0.5, -8)
                    or  UDim2.new(0,  3,  0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
            })
            NewInstance("UICorner", knob, { CornerRadius = UDim.new(1, 0) })

            local enabled = default
            local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quart)

            local btn = NewInstance("TextButton", frame, {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
            })
            btn.MouseButton1Click:Connect(function()
                enabled = not enabled
                if enabled then
                    Tween(track, ti, { BackgroundColor3 = Theme.Toggle_On })
                    Tween(knob,  ti, { Position = UDim2.new(1, -19, 0.5, -8) })
                else
                    Tween(track, ti, { BackgroundColor3 = Theme.Toggle_Off })
                    Tween(knob,  ti, { Position = UDim2.new(0, 3,  0.5, -8) })
                end
                task.spawn(callback, enabled)
            end)
            btn.MouseEnter:Connect(function()
                Tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ElementHover })
            end)
            btn.MouseLeave:Connect(function()
                Tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Element })
            end)
        end

        -- ════════════════════════════════════════════════════
        --  Tab:AddSlider
        -- ════════════════════════════════════════════════════
        function Tab:AddSlider(cfg3)
            cfg3 = cfg3 or {}
            local name      = cfg3.Name      or "Slider"
            local minV      = cfg3.Min       or 0
            local maxV      = cfg3.Max       or 100
            local increment = cfg3.Increment or 1
            local default   = cfg3.Default   or minV
            local callback  = cfg3.Callback  or function() end

            local frame = ElementFrame(56)
            ElementLabel(frame, name, 0, 0, 0.65, 28)

            local valLabel = NewInstance("TextLabel", frame, {
                Size  = UDim2.new(0.3, -14, 0, 28),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text  = tostring(default),
                Font  = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
            })

            local trackH = 6
            local track = NewInstance("Frame", frame, {
                Size     = UDim2.new(1, -28, 0, trackH),
                Position = UDim2.new(0, 14, 1, -(trackH + 10)),
                BackgroundColor3 = Theme.Slider_Track,
                BorderSizePixel  = 0,
            })
            NewInstance("UICorner", track, { CornerRadius = UDim.new(1, 0) })

            local pct = math.clamp((default - minV) / (maxV - minV), 0, 1)
            local fill = NewInstance("Frame", track, {
                Size     = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = Theme.Slider_Fill,
                BorderSizePixel  = 0,
            })
            NewInstance("UICorner", fill, { CornerRadius = UDim.new(1, 0) })

            -- thumb
            local thumb = NewInstance("Frame", track, {
                Size     = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(pct, -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                ZIndex           = 3,
            })
            NewInstance("UICorner", thumb, { CornerRadius = UDim.new(1, 0) })

            local function SetValue(v)
                v = math.clamp(
                    math.round(v / increment) * increment,
                    minV, maxV
                )
                -- round to avoid floating noise
                v = math.floor(v * 10000 + 0.5) / 10000
                local p2 = (v - minV) / (maxV - minV)
                fill.Size     = UDim2.new(p2, 0, 1, 0)
                thumb.Position = UDim2.new(p2, -7, 0.5, -7)
                valLabel.Text  = tostring(v)
                task.spawn(callback, v)
            end

            local sliding = false
            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and (
                    inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch
                ) then
                    local trackAbs = track.AbsolutePosition
                    local trackSz  = track.AbsoluteSize
                    local rel = (inp.Position.X - trackAbs.X) / trackSz.X
                    SetValue(minV + rel * (maxV - minV))
                end
            end)

            SetValue(default)
        end

        -- ════════════════════════════════════════════════════
        --  Tab:AddDropdown
        -- ════════════════════════════════════════════════════
        function Tab:AddDropdown(cfg3)
            cfg3 = cfg3 or {}
            local name        = cfg3.Name        or "Dropdown"
            local options     = cfg3.Options      or {}
            local multiSelect = cfg3.MultiSelect  or false
            local callback    = cfg3.Callback     or function() end

            -- Resolve default
            local selected  -- single: string | multi: {string}
            if multiSelect then
                selected = {}
                if type(cfg3.Default) == "table" then
                    for _, v in pairs(cfg3.Default) do
                        selected[v] = true
                    end
                end
            else
                selected = cfg3.Default or (options[1] or "")
            end

            local function DisplayText()
                if multiSelect then
                    local list = {}
                    for k, _ in pairs(selected) do table.insert(list, k) end
                    return #list == 0 and "None" or table.concat(list, ", ")
                else
                    return tostring(selected)
                end
            end

            local frame    = ElementFrame(38)
            local isOpen2  = false

            -- ── header ─────────────────────────────────────
            ElementLabel(frame, name, 0, 0, 0.42)

            local valLabel = NewInstance("TextLabel", frame, {
                Size     = UDim2.new(0.42, 0, 1, 0),
                Position = UDim2.new(0.45, 0, 0, 0),
                BackgroundTransparency = 1,
                Text     = DisplayText(),
                Font     = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.SubText,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local arrow = NewInstance("TextLabel", frame, {
                Size     = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text     = "▾",
                Font     = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Center,
            })

            -- ── dropdown panel (appended to scroll, not frame) ─
            local panelHeight = #options * 30 + 8
            local panel = NewInstance("Frame", scroll, {
                Name     = name .. "_Panel",
                Size     = UDim2.new(1, 0, 0, panelHeight),
                BackgroundColor3 = Theme.Dropdown_BG,
                BorderSizePixel  = 0,
                Visible  = false,
                ZIndex   = 5,
                LayoutOrder = Tab._order + 0.5,  -- right after header
            })
            NewInstance("UICorner",  panel, { CornerRadius = UDim.new(0, 8) })
            NewInstance("UIStroke",  panel, {
                Color = Theme.Accent, Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            NewInstance("UIPadding", panel, { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) })
            NewInstance("UIListLayout", panel, {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 2),
            })

            local optionBtns = {}

            local function UpdateOptionColors()
                for _, ob in pairs(optionBtns) do
                    local active = multiSelect and selected[ob._val]
                        or (not multiSelect and selected == ob._val)
                    ob._bg.BackgroundColor3 = active and Theme.TabActive or Theme.Dropdown_BG
                    ob._lbl.TextColor3      = active and Theme.Text or Theme.SubText
                end
            end

            for i, opt in ipairs(options) do
                local optBg = NewInstance("TextButton", panel, {
                    Size            = UDim2.new(1, -8, 0, 28),
                    BackgroundColor3 = Theme.Dropdown_BG,
                    BorderSizePixel  = 0,
                    Text             = "",
                    AutoButtonColor  = false,
                    LayoutOrder      = i,
                    ZIndex           = 6,
                })
                NewInstance("UICorner", optBg, { CornerRadius = UDim.new(0, 6) })
                NewInstance("UIPadding", optBg, { PaddingLeft = UDim.new(0, 10) })

                local optLbl = NewInstance("TextLabel", optBg, {
                    Size     = UDim2.new(1, -20, 1, 0),
                    BackgroundTransparency = 1,
                    Text     = tostring(opt),
                    Font     = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                })

                local checkLbl = NewInstance("TextLabel", optBg, {
                    Size     = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text     = "",
                    Font     = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = Theme.Accent,
                    ZIndex = 7,
                })

                local entry = { _val = opt, _bg = optBg, _lbl = optLbl, _check = checkLbl }
                table.insert(optionBtns, entry)

                optBg.MouseButton1Click:Connect(function()
                    if multiSelect then
                        if selected[opt] then
                            selected[opt] = nil
                        else
                            selected[opt] = true
                        end
                        local list = {}
                        for k,_ in pairs(selected) do table.insert(list, k) end
                        task.spawn(callback, list)
                    else
                        selected = opt
                        task.spawn(callback, selected)
                        -- close
                        isOpen2 = false
                        panel.Visible = false
                        arrow.Text    = "▾"
                    end
                    valLabel.Text = DisplayText()
                    UpdateOptionColors()
                end)

                optBg.MouseEnter:Connect(function()
                    Tween(optBg, TweenInfo.new(0.1), { BackgroundColor3 = Theme.ElementHover })
                end)
                optBg.MouseLeave:Connect(function()
                    local active = multiSelect and selected[opt] or selected == opt
                    Tween(optBg, TweenInfo.new(0.1), {
                        BackgroundColor3 = active and Theme.TabActive or Theme.Dropdown_BG
                    })
                end)
            end

            UpdateOptionColors()

            -- header click
            local headerBtn = NewInstance("TextButton", frame, {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false,
            })
            headerBtn.MouseButton1Click:Connect(function()
                isOpen2 = not isOpen2
                panel.Visible = isOpen2
                arrow.Text    = isOpen2 and "▴" or "▾"
            end)
            headerBtn.MouseEnter:Connect(function()
                Tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ElementHover })
            end)
            headerBtn.MouseLeave:Connect(function()
                Tween(frame, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Element })
            end)
        end

        -- ════════════════════════════════════════════════════
        --  Tab:AddTextBox
        -- ════════════════════════════════════════════════════
        function Tab:AddTextBox(cfg3)
            cfg3 = cfg3 or {}
            local name         = cfg3.Name         or "TextBox"
            local default      = cfg3.Default      or ""
            local placeholder  = cfg3.Placeholder  or "Type here..."
            local clearOnFocus = cfg3.ClearOnFocus
            if clearOnFocus == nil then clearOnFocus = true end
            local callback = cfg3.Callback or function() end

            local frame = ElementFrame(52)
            ElementLabel(frame, name, 0, 0, 1, 24)

            local boxBg = NewInstance("Frame", frame, {
                Size     = UDim2.new(1, -28, 0, 24),
                Position = UDim2.new(0, 14, 1, -30),
                BackgroundColor3 = Theme.Dropdown_BG,
                BorderSizePixel  = 0,
            })
            NewInstance("UICorner", boxBg, { CornerRadius = UDim.new(0, 6) })
            NewInstance("UIStroke", boxBg, {
                Color = Theme.Stroke, Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })

            local tb = NewInstance("TextBox", boxBg, {
                Size     = UDim2.new(1, -8, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text     = default,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Theme.SubText,
                Font     = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = clearOnFocus,
            })

            tb.Focused:Connect(function()
                Tween(boxBg, TweenInfo.new(0.15), { BackgroundColor3 = Theme.TabActive })
            end)
            tb.FocusLost:Connect(function(enterPressed)
                Tween(boxBg, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Dropdown_BG })
                task.spawn(callback, tb.Text)
            end)
        end

        return Tab
    end -- MakeTab

    return Window
end -- MakeWindow

return SGUI
