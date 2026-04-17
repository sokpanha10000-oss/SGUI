local UI = {}
UI.__index = UI

-- // Services
local Players         = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- // Utility
local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.2, style, dir), props):Play()
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- // Color Palette
local Colors = {
    Background    = Color3.fromRGB(15,  15,  20),
    Surface       = Color3.fromRGB(22,  22,  30),
    Panel         = Color3.fromRGB(28,  28,  38),
    Border        = Color3.fromRGB(50,  50,  70),
    Accent        = Color3.fromRGB(120, 80,  255),
    AccentHover   = Color3.fromRGB(140, 100, 255),
    Text          = Color3.fromRGB(230, 230, 240),
    TextMuted     = Color3.fromRGB(130, 130, 150),
    TabActive     = Color3.fromRGB(120, 80,  255),
    TabInactive   = Color3.fromRGB(35,  35,  50),
    ToggleOn      = Color3.fromRGB(100, 220, 130),
    ToggleOff     = Color3.fromRGB(60,  60,  80),
    SliderFill    = Color3.fromRGB(120, 80,  255),
    SliderTrack   = Color3.fromRGB(40,  40,  60),
    InputBg       = Color3.fromRGB(20,  20,  30),
    Red           = Color3.fromRGB(255, 80,  80),
    Green         = Color3.fromRGB(80,  220, 130),
    Blue          = Color3.fromRGB(80,  160, 255),
    Orange        = Color3.fromRGB(255, 160, 60),
    White         = Color3.fromRGB(240, 240, 255),
}

local function ParseColor(c)
    if type(c) == "string" then
        return Colors[c] or Colors.Accent
    end
    return c or Colors.Accent
end

-- ============================================================
--  CreateWindow
-- ============================================================
function UI:CreateWindow(cfg)
    cfg = cfg or {}
    local Title  = cfg.Title  or "Script Hub"
    local Author = cfg.Author or ""

    local ScreenGui = Create("ScreenGui", {
        Name            = "UILibrary",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
    })

    -- Try to parent to CoreGui, fallback to PlayerGui
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- // Main Window Frame
    local WindowFrame = Create("Frame", {
        Name            = "WindowFrame",
        Size            = UDim2.new(0, 560, 0, 350),
        Position        = UDim2.new(0.5, -280, 0.5, -100),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Active          = true,
        Parent          = ScreenGui,
    }, {
        Create("UICorner",  {CornerRadius = UDim.new(0, 10)}),
        Create("UIStroke",  {Color = Colors.Border, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}),
    })

    -- // Title Bar
    local TitleBar = Create("Frame", {
        Name            = "TitleBar",
        Size            = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Parent          = WindowFrame,
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
    })

    -- Fix bottom corners of title bar
    Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 10),
        Position        = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Parent          = TitleBar,
    })

    -- Accent left stripe
    Create("Frame", {
        Size            = UDim2.new(0, 3, 0, 22),
        Position        = UDim2.new(0, 12, 0.5, -11),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent          = TitleBar,
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

    local TitleLabel = Create("TextLabel", {
        Text            = Title,
        Size            = UDim2.new(1, -120, 1, 0),
        Position        = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        TextColor3      = Colors.Text,
        TextSize        = 15,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = TitleBar,
    })

    if Author ~= "" then
        Create("TextLabel", {
            Text            = Author,
            Size            = UDim2.new(0, 200, 1, 0),
            Position        = UDim2.new(0, 24, 0, 0),
            BackgroundTransparency = 1,
            TextColor3      = Colors.TextMuted,
            TextSize        = 11,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextYAlignment  = Enum.TextYAlignment.Bottom,
            Parent          = TitleBar,
        })
        TitleLabel.Position = UDim2.new(0, 24, 0, -6)
    end

    -- // Close Button
    local CloseBtn = Create("TextButton", {
        Text            = "✕",
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(60, 30, 30),
        TextColor3      = Colors.Red,
        TextSize        = 13,
        Font            = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent          = TitleBar,
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(WindowFrame, {Size = UDim2.new(0, 560, 0, 0)}, 0.25)
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Colors.Red}, 0.15)
        Tween(CloseBtn, {TextColor3 = Colors.White}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(60, 30, 30)}, 0.15)
        Tween(CloseBtn, {TextColor3 = Colors.Red}, 0.15)
    end)

    -- // Minimize Button (in titlebar)
    local MinBtn = Create("TextButton", {
        Text            = "−",
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -68, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        TextColor3      = Colors.TextMuted,
        TextSize        = 18,
        Font            = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent          = TitleBar,
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})

    -- // Content Area (below title bar)
    local ContentArea = Create("Frame", {
        Name            = "ContentArea",
        Size            = UDim2.new(1, 0, 1, -44),
        Position        = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent          = WindowFrame,
    })

    -- // Tab Bar (left side)
    local TabBar = Create("ScrollingFrame", {
        Name            = "TabBar",
        Size            = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent          = ContentArea,
    })

    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
        Parent        = TabBar,
    })

    Create("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Padding         = UDim.new(0, 5),
        Parent          = TabBar,
    })

    -- Bottom-left corner fix
    Create("Frame", {
        Size            = UDim2.new(0, 10, 1, 0),
        Position        = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Parent          = TabBar,
    })

    -- // Divider
    Create("Frame", {
        Size            = UDim2.new(0, 1, 1, 0),
        Position        = UDim2.new(0, 130, 0, 0),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0,
        Parent          = ContentArea,
    })

    -- // Tab Content Area
    local TabContent = Create("Frame", {
        Name            = "TabContent",
        Size            = UDim2.new(1, -131, 1, 0),
        Position        = UDim2.new(0, 131, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent          = ContentArea,
    })

    MakeDraggable(WindowFrame, TitleBar)

    -- Minimize logic
    local isMinimized = false
    local normalSize  = UDim2.new(0, 560, 0, 400)

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(WindowFrame, {Size = UDim2.new(0, 560, 0, 44)}, 0.25)
            ContentArea.Visible = false
            MinBtn.Text = "+"
        else
            ContentArea.Visible = true
            Tween(WindowFrame, {Size = normalSize}, 0.25)
            MinBtn.Text = "−"
        end
    end)

    -- // Window Object
    local Window      = {}
    Window._gui       = ScreenGui
    Window._frame     = WindowFrame
    Window._tabBar    = TabBar
    Window._tabContent = TabContent
    Window._tabs      = {}
    Window._activeTab = nil

    -- Dropdown overlay (created once per window)
    local DropdownOverlay = Create("Frame", {
        Name            = "DropdownOverlay",
        Size            = UDim2.new(0, 220, 0, 0),
        Position        = UDim2.new(0.5, -110, 0.5, -100),
        BackgroundColor3 = Colors.Panel,
        BorderSizePixel = 0,
        Visible         = false,
        ZIndex          = 20,
        Parent          = WindowFrame,
    }, {
        Create("UICorner",  {CornerRadius = UDim.new(0, 10)}),
        Create("UIStroke",  {Color = Colors.Accent, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}),
    })

    local DropdownTitle = Create("TextLabel", {
        Text            = "Select Option",
        Size            = UDim2.new(1, -10, 0, 32),
        Position        = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1,
        TextColor3      = Colors.Text,
        TextSize        = 13,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 21,
        Parent          = DropdownOverlay,
    })

    Create("Frame", {
        Size            = UDim2.new(1, -20, 0, 1),
        Position        = UDim2.new(0, 10, 0, 36),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0,
        ZIndex          = 21,
        Parent          = DropdownOverlay,
    })

    -- Close overlay button
    local DDCloseBtn = Create("TextButton", {
        Text            = "✕",
        Size            = UDim2.new(0, 24, 0, 24),
        Position        = UDim2.new(1, -30, 0, 6),
        BackgroundTransparency = 1,
        TextColor3      = Colors.TextMuted,
        TextSize        = 12,
        Font            = Enum.Font.GothamBold,
        ZIndex          = 22,
        Parent          = DropdownOverlay,
    })

    local DropdownScroll = Create("ScrollingFrame", {
        Name            = "DropdownScroll",
        Size            = UDim2.new(1, -10, 1, -48),
        Position        = UDim2.new(0, 5, 0, 44),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex          = 21,
        Parent          = DropdownOverlay,
    })

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 4),
        Parent    = DropdownScroll,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft   = UDim.new(0, 2),
        PaddingRight  = UDim.new(0, 2),
        Parent        = DropdownScroll,
    })

    Window._dropdownOverlay = DropdownOverlay
    Window._dropdownTitle   = DropdownTitle
    Window._dropdownScroll  = DropdownScroll

    DDCloseBtn.MouseButton1Click:Connect(function()
        Tween(DropdownOverlay, {Size = UDim2.new(0, 220, 0, 0)}, 0.18)
        task.wait(0.18)
        DropdownOverlay.Visible = false
    end)

    -- ========================================================
    --  CreateMinimize (floating button)
    -- ========================================================
    function Window:CreateMinimize(cfg2)
        cfg2 = cfg2 or {}
        local BtnName  = cfg2.Name  or "Open UI"
        local BtnColor = ParseColor(cfg2.Color or "Accent")

        local FloatBtn = Create("TextButton", {
            Text            = BtnName,
            Size            = UDim2.new(0, 110, 0, 32),
            Position        = UDim2.new(0, 10, 1, -50),
            BackgroundColor3 = BtnColor,
            TextColor3      = Colors.White,
            TextSize        = 12,
            Font            = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            Visible         = false,
            ZIndex          = 15,
            Parent          = ScreenGui,
        }, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})

        MakeDraggable(FloatBtn)

        local showing = true
        FloatBtn.MouseButton1Click:Connect(function()
            showing = not showing
            WindowFrame.Visible = showing
            FloatBtn.Text = showing and "Hide UI" or BtnName
        end)

        MinBtn.MouseButton1Click:Connect(function()
            -- already handled above; also toggle float button
        end)

        -- Show float button when window is fully minimized/closed via title bar
        CloseBtn.MouseButton1Click:Connect(function()
            FloatBtn.Visible = true
        end)

        return FloatBtn
    end

    -- ========================================================
    --  Tab
    -- ========================================================
    function Window:Tab(cfg3)
        cfg3 = cfg3 or {}
        local TabTitle  = cfg3.Title  or "Tab"
        local TabLocked = cfg3.Locked or false

        -- Tab button in sidebar
        local TabBtn = Create("TextButton", {
            Text            = TabTitle,
            Size            = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Colors.TabInactive,
            TextColor3      = Colors.TextMuted,
            TextSize        = 12,
            Font            = Enum.Font.GothamSemibold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent          = TabBar,
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 7)}),
        })

        if TabLocked then
            TabBtn.Text = "🔒 " .. TabTitle
            TabBtn.Active = false
        end

        -- Accent bar on active tab
        local ActiveBar = Create("Frame", {
            Size            = UDim2.new(0, 3, 0, 18),
            Position        = UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = Colors.Accent,
            BorderSizePixel = 0,
            Visible         = false,
            Parent          = TabBtn,
        }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

        -- Scroll frame for tab elements
        local TabFrame = Create("ScrollingFrame", {
            Name            = "TabFrame_" .. TabTitle,
            Size            = UDim2.new(1, -8, 1, -8),
            Position        = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Accent,
            CanvasSize      = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible         = false,
            BorderSizePixel = 0,
            Parent          = TabContent,
        })

        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 8),
            Parent    = TabFrame,
        })
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 10),
            Parent        = TabFrame,
        })

        table.insert(Window._tabs, {btn = TabBtn, frame = TabFrame, bar = ActiveBar})

        local function ActivateTab()
            if TabLocked then return end
            for _, t in ipairs(Window._tabs) do
                t.frame.Visible = false
                t.bar.Visible   = false
                Tween(t.btn, {BackgroundColor3 = Colors.TabInactive, TextColor3 = Colors.TextMuted}, 0.15)
            end
            TabFrame.Visible = true
            ActiveBar.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(35, 25, 65), TextColor3 = Colors.Text}, 0.15)
            Window._activeTab = TabFrame
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)
        TabBtn.MouseEnter:Connect(function()
            if TabFrame.Visible then return end
            Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 48)}, 0.12)
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabFrame.Visible then return end
            Tween(TabBtn, {BackgroundColor3 = Colors.TabInactive}, 0.12)
        end)

        -- Activate first tab automatically
        if #Window._tabs == 1 then
            ActivateTab()
        end

        -- ====================================================
        --  Helper: Element container
        -- ====================================================
        local function MakeElementBase(title, desc)
            local el = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, desc and 56 or 42),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                Parent          = TabFrame,
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke",  {Color = Colors.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}),
            })

            Create("TextLabel", {
                Text            = title,
                Size            = UDim2.new(0.6, 0, 0, 18),
                Position        = UDim2.new(0, 12, 0, desc and 8 or 12),
                BackgroundTransparency = 1,
                TextColor3      = Colors.Text,
                TextSize        = 13,
                Font            = Enum.Font.GothamSemibold,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = el,
            })

            if desc and desc ~= "" then
                Create("TextLabel", {
                    Text            = desc,
                    Size            = UDim2.new(0.8, 0, 0, 14),
                    Position        = UDim2.new(0, 12, 0, 30),
                    BackgroundTransparency = 1,
                    TextColor3      = Colors.TextMuted,
                    TextSize        = 11,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = el,
                })
            end

            return el
        end

        -- Tab object
        local Tab = {}

        -- ==================================================
        --  Button
        -- ==================================================
        function Tab:Button(cfg4)
            cfg4 = cfg4 or {}
            local el  = MakeElementBase(cfg4.Title or "Button", cfg4.Desc)
            local btn = Create("TextButton", {
                Text            = "Run",
                Size            = UDim2.new(0, 56, 0, 26),
                Position        = UDim2.new(1, -64, 0.5, -13),
                BackgroundColor3 = Colors.Accent,
                TextColor3      = Colors.White,
                TextSize        = 11,
                Font            = Enum.Font.GothamBold,
                BorderSizePixel = 0,
                Parent          = el,
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})

            if cfg4.Locked then
                btn.Text = "🔒"
                btn.Active = false
                btn.BackgroundColor3 = Colors.TabInactive
            end

            btn.MouseButton1Click:Connect(function()
                if cfg4.Locked then return end
                Tween(btn, {BackgroundColor3 = Colors.AccentHover}, 0.1)
                task.wait(0.1)
                Tween(btn, {BackgroundColor3 = Colors.Accent}, 0.1)
                if cfg4.Callback then
                    task.spawn(cfg4.Callback)
                end
            end)

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Colors.AccentHover}, 0.12)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Colors.Accent}, 0.12)
            end)

            return btn
        end

        -- ==================================================
        --  Dropdown
        -- ==================================================
        function Tab:Dropdown(cfg4)
            cfg4 = cfg4 or {}
            local values   = cfg4.Values  or {}
            local selected = cfg4.Value   or (values[1] or "")
            local el = MakeElementBase(cfg4.Title or "Dropdown", cfg4.Desc)

            local DropBtn = Create("TextButton", {
                Text            = selected .. "  ▾",
                Size            = UDim2.new(0, 130, 0, 26),
                Position        = UDim2.new(1, -138, 0.5, -13),
                BackgroundColor3 = Colors.InputBg,
                TextColor3      = Colors.Text,
                TextSize        = 11,
                Font            = Enum.Font.Gotham,
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Center,
                Parent          = el,
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = Colors.Border, Thickness = 1}),
            })

            DropBtn.MouseButton1Click:Connect(function()
                -- Clear old items
                for _, child in ipairs(Window._dropdownScroll:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                Window._dropdownTitle.Text = cfg4.Title or "Select Option"

                for _, option in ipairs(values) do
                    local optBtn = Create("TextButton", {
                        Text            = option,
                        Size            = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = option == selected
                            and Color3.fromRGB(40, 25, 75)
                            or Colors.Surface,
                        TextColor3      = option == selected
                            and Colors.Text
                            or Colors.TextMuted,
                        TextSize        = 12,
                        Font            = Enum.Font.Gotham,
                        BorderSizePixel = 0,
                        ZIndex          = 22,
                        Parent          = Window._dropdownScroll,
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    })

                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(40, 25, 75)}, 0.1)
                        Tween(optBtn, {TextColor3 = Colors.Text}, 0.1)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if optBtn.Text ~= selected then
                            Tween(optBtn, {BackgroundColor3 = Colors.Surface}, 0.1)
                            Tween(optBtn, {TextColor3 = Colors.TextMuted}, 0.1)
                        end
                    end)

                    optBtn.MouseButton1Click:Connect(function()
                        selected = option
                        DropBtn.Text = selected .. "  ▾"
                        Tween(Window._dropdownOverlay, {Size = UDim2.new(0, 220, 0, 0)}, 0.18)
                        task.wait(0.18)
                        Window._dropdownOverlay.Visible = false
                        if cfg4.Callback then
                            task.spawn(cfg4.Callback, option)
                        end
                    end)
                end

                local itemCount = math.min(#values, 6)
                local targetH   = 48 + (itemCount * 36)
                Window._dropdownOverlay.Size    = UDim2.new(0, 220, 0, 0)
                Window._dropdownOverlay.Visible = true
                Tween(Window._dropdownOverlay, {Size = UDim2.new(0, 220, 0, targetH)}, 0.2)
            end)

            DropBtn.MouseEnter:Connect(function()
                Tween(DropBtn, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}, 0.12)
            end)
            DropBtn.MouseLeave:Connect(function()
                Tween(DropBtn, {BackgroundColor3 = Colors.InputBg}, 0.12)
            end)

            return DropBtn
        end

        -- ==================================================
        --  Toggle
        -- ==================================================
        function Tab:Toggle(cfg4)
            cfg4 = cfg4 or {}
            local state = cfg4.Value or false
            local el    = MakeElementBase(cfg4.Title or "Toggle", cfg4.Desc)

            local Track = Create("Frame", {
                Size            = UDim2.new(0, 42, 0, 22),
                Position        = UDim2.new(1, -54, 0.5, -11),
                BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff,
                BorderSizePixel = 0,
                Parent          = el,
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local Knob = Create("Frame", {
                Size            = UDim2.new(0, 16, 0, 16),
                Position        = state
                    and UDim2.new(1, -19, 0.5, -8)
                    or  UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Colors.White,
                BorderSizePixel = 0,
                Parent          = Track,
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local ClickArea = Create("TextButton", {
                Text            = "",
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent          = Track,
            })

            ClickArea.MouseButton1Click:Connect(function()
                state = not state
                Tween(Track, {BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff}, 0.15)
                Tween(Knob, {
                    Position = state
                        and UDim2.new(1, -19, 0.5, -8)
                        or  UDim2.new(0, 3, 0.5, -8)
                }, 0.15)
                if cfg4.Callback then
                    task.spawn(cfg4.Callback, state)
                end
            end)

            return Track
        end

        -- ==================================================
        --  Slider
        -- ==================================================
        function Tab:Slider(cfg4)
            cfg4 = cfg4 or {}
            local valCfg = cfg4.Value or {}
            local minV   = valCfg.Min     or 0
            local maxV   = valCfg.Max     or 100
            local defV   = valCfg.Default or minV
            local step   = cfg4.Step      or 1
            local curV   = defV

            local el = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 70),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                Parent          = TabFrame,
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Colors.Border, Thickness = 1}),
            })

            Create("TextLabel", {
                Text            = cfg4.Title or "Slider",
                Size            = UDim2.new(0.6, 0, 0, 18),
                Position        = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                TextColor3      = Colors.Text,
                TextSize        = 13,
                Font            = Enum.Font.GothamSemibold,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = el,
            })

            if cfg4.Desc and cfg4.Desc ~= "" then
                Create("TextLabel", {
                    Text            = cfg4.Desc,
                    Size            = UDim2.new(0.8, 0, 0, 12),
                    Position        = UDim2.new(0, 12, 0, 26),
                    BackgroundTransparency = 1,
                    TextColor3      = Colors.TextMuted,
                    TextSize        = 11,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = el,
                })
            end

            local ValLabel = Create("TextLabel", {
                Text            = tostring(curV),
                Size            = UDim2.new(0, 40, 0, 18),
                Position        = UDim2.new(1, -50, 0, 8),
                BackgroundTransparency = 1,
                TextColor3      = Colors.Accent,
                TextSize        = 13,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Right,
                Parent          = el,
            })

            local Track = Create("Frame", {
                Size            = UDim2.new(1, -24, 0, 6),
                Position        = UDim2.new(0, 12, 0, 50),
                BackgroundColor3 = Colors.SliderTrack,
                BorderSizePixel = 0,
                Parent          = el,
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local pct  = (defV - minV) / (maxV - minV)
            local Fill = Create("Frame", {
                Size            = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = Colors.SliderFill,
                BorderSizePixel = 0,
                Parent          = Track,
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local Knob2 = Create("Frame", {
                Size            = UDim2.new(0, 14, 0, 14),
                Position        = UDim2.new(pct, -7, 0.5, -7),
                BackgroundColor3 = Colors.White,
                BorderSizePixel = 0,
                Parent          = Track,
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local draggingSlider = false
            Track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local trackPos = Track.AbsolutePosition.X
                    local trackSz  = Track.AbsoluteSize.X
                    local rel      = math.clamp((inp.Position.X - trackPos) / trackSz, 0, 1)
                    local raw      = minV + rel * (maxV - minV)
                    curV = math.round(raw / step) * step
                    curV = math.clamp(curV, minV, maxV)
                    local p = (curV - minV) / (maxV - minV)
                    Fill.Size     = UDim2.new(p, 0, 1, 0)
                    Knob2.Position = UDim2.new(p, -7, 0.5, -7)
                    ValLabel.Text  = tostring(curV)
                    if cfg4.Callback then
                        task.spawn(cfg4.Callback, curV)
                    end
                end
            end)

            return el
        end

        -- ==================================================
        --  Input
        -- ==================================================
        function Tab:Input(cfg4)
            cfg4 = cfg4 or {}
            local isTextArea = cfg4.Type == "Textarea"
            local h          = isTextArea and 80 or 56

            local el = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, h),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                Parent          = TabFrame,
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Colors.Border, Thickness = 1}),
            })

            Create("TextLabel", {
                Text            = cfg4.Title or "Input",
                Size            = UDim2.new(0.6, 0, 0, 18),
                Position        = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                TextColor3      = Colors.Text,
                TextSize        = 13,
                Font            = Enum.Font.GothamSemibold,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = el,
            })

            if cfg4.Desc and cfg4.Desc ~= "" then
                Create("TextLabel", {
                    Text            = cfg4.Desc,
                    Size            = UDim2.new(0.8, 0, 0, 12),
                    Position        = UDim2.new(0, 12, 0, 26),
                    BackgroundTransparency = 1,
                    TextColor3      = Colors.TextMuted,
                    TextSize        = 11,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = el,
                })
            end

            local inputY = cfg4.Desc and 42 or 30
            local inputH = isTextArea and (h - inputY - 8) or 24

            local InputBox = Create("TextBox", {
                Text            = cfg4.Value or "",
                PlaceholderText = cfg4.Placeholder or "Enter text...",
                Size            = UDim2.new(1, -20, 0, inputH),
                Position        = UDim2.new(0, 10, 0, inputY),
                BackgroundColor3 = Colors.InputBg,
                TextColor3      = Colors.Text,
                PlaceholderColor3 = Colors.TextMuted,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                MultiLine       = isTextArea,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextYAlignment  = isTextArea and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                Parent          = el,
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
            })

            InputBox.FocusLost:Connect(function(enter)
                if cfg4.Callback and (enter or isTextArea) then
                    task.spawn(cfg4.Callback, InputBox.Text)
                end
            end)

            InputBox.Focused:Connect(function()
                Tween(InputBox, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)}, 0.12)
            end)
            InputBox.FocusLost:Connect(function()
                Tween(InputBox, {BackgroundColor3 = Colors.InputBg}, 0.12)
            end)

            return InputBox
        end

        return Tab
    end -- Window:Tab

    return Window
end -- UI:CreateWindow

return UI
