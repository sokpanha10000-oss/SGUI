local SGUI = {}
SGUI.__index = SGUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

-- ── Helpers ──────────────────────────────────────────────────
local function Tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function New(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos, lastInp
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then lastInp = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == lastInp and dragging then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ── Theme ─────────────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(18,  18,  24),
    TopBar      = Color3.fromRGB(28,  28,  38),
    Accent      = Color3.fromRGB(100, 80,  220),
    AccentHov   = Color3.fromRGB(120, 100, 240),
    TabBG       = Color3.fromRGB(24,  24,  34),
    TabActive   = Color3.fromRGB(38,  38,  55),
    Elem        = Color3.fromRGB(30,  30,  42),
    ElemHov     = Color3.fromRGB(42,  42,  58),
    Text        = Color3.fromRGB(230, 230, 255),
    SubText     = Color3.fromRGB(140, 140, 170),
    TogOff      = Color3.fromRGB(55,  55,  70),
    TogOn       = Color3.fromRGB(100, 80,  220),
    SliderTrack = Color3.fromRGB(50,  50,  65),
    SliderFill  = Color3.fromRGB(100, 80,  220),
    Stroke      = Color3.fromRGB(55,  50,  80),
    DropBG      = Color3.fromRGB(22,  22,  32),
    White       = Color3.fromRGB(255, 255, 255),
}

-- ╔══════════════════════════════════════════════════════════╗
--  SGUI:MakeWindow
-- ╚══════════════════════════════════════════════════════════╝
function SGUI:MakeWindow(cfg)
    cfg = cfg or {}
    local title    = cfg.Title        or "Script Hub"
    local subtitle = cfg.SubTitle     or ""
    local folder   = cfg.ScriptFolder or "SGUI"

    pcall(function()
        if not isfolder(folder) then makefolder(folder) end
    end)

    -- ── ScreenGui ─────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name            = folder .. "_ScreenGui"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder    = 999
    sg.Enabled         = true
    pcall(function() if syn       then syn.protect_gui(sg)  end end)
    pcall(function() if protect_gui then protect_gui(sg)    end end)
    if not pcall(function() sg.Parent = game:GetService("CoreGui") end) then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── Main frame ────────────────────────────────────────
    local main = New("Frame", sg, {
        Name             = "Main",
        Size             = UDim2.new(0, 560, 0, 390),
        Position         = UDim2.new(0.5, -280, 0.5, -195),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
    })
    New("UICorner", main, { CornerRadius = UDim.new(0, 10) })
    New("UIStroke", main, {
        Color = T.Stroke, Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })

    -- ── Top bar ───────────────────────────────────────────
    local topBar = New("Frame", main, {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = T.TopBar,
        BorderSizePixel  = 0,
        Active           = true,
        ZIndex           = 3,
    })
    New("UICorner", topBar, { CornerRadius = UDim.new(0, 10) })
    New("Frame", topBar, {   -- fill bottom rounded corners
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = T.TopBar,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    })
    New("Frame", main, {    -- accent line below topbar
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    })
    New("TextLabel", topBar, {
        Size               = UDim2.new(1, -110, 1, 0),
        Position           = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text               = title,
        Font               = Enum.Font.GothamBold,
        TextSize           = 15,
        TextColor3         = T.Text,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 4,
    })
    New("TextLabel", topBar, {
        Size               = UDim2.new(1, -110, 0, 14),
        Position           = UDim2.new(0, 14, 1, -17),
        BackgroundTransparency = 1,
        Text               = subtitle,
        Font               = Enum.Font.Gotham,
        TextSize           = 11,
        TextColor3         = T.SubText,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 4,
    })

    -- Minimize button
    local minBtn = New("TextButton", topBar, {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = T.Elem,
        BorderSizePixel  = 0,
        Text             = "─",
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = T.SubText,
        AutoButtonColor  = false,
        ZIndex           = 5,
    })
    New("UICorner", minBtn, { CornerRadius = UDim.new(0, 6) })

    -- ── Content ───────────────────────────────────────────
    local content = New("Frame", main, {
        Size             = UDim2.new(1, 0, 1, -50),
        Position         = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 2,
    })
    local tabBar = New("ScrollingFrame", content, {
        Size                = UDim2.new(0, 130, 1, 0),
        BackgroundColor3    = T.TabBG,
        BorderSizePixel     = 0,
        ScrollBarThickness  = 0,
        CanvasSize          = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants    = true,
        ZIndex              = 2,
    })
    New("UIPadding", tabBar, {
        PaddingTop = UDim.new(0,8), PaddingLeft  = UDim.new(0,8),
        PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8),
    })
    New("UIListLayout", tabBar, { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,5) })
    New("Frame", content, {  -- divider
        Size = UDim2.new(0,1,1,0), Position = UDim2.new(0,130,0,0),
        BackgroundColor3 = T.Stroke, BorderSizePixel = 0, ZIndex = 2,
    })
    local elemArea = New("Frame", content, {
        Size             = UDim2.new(1,-138,1,0),
        Position         = UDim2.new(0,138,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 2,
    })

    -- ── Drag & minimize ───────────────────────────────────
    MakeDraggable(main, topBar)

    local isOpen   = true
    local openSz   = UDim2.new(0, 560, 0, 390)
    local closedSz = UDim2.new(0, 560, 0, 48)

    local function Toggle()
        isOpen = not isOpen
        if isOpen then
            minBtn.Text = "─"
            Tween(main, 0.35, { Size = openSz })
        else
            minBtn.Text = "□"
            Tween(main, 0.35, { Size = closedSz })
        end
    end

    minBtn.MouseButton1Click:Connect(Toggle)
    minBtn.MouseEnter:Connect(function() Tween(minBtn, 0.12, { BackgroundColor3 = T.ElemHov }) end)
    minBtn.MouseLeave:Connect(function() Tween(minBtn, 0.12, { BackgroundColor3 = T.Elem    }) end)

    -- ── Window object ─────────────────────────────────────
    local Window = { _tabs = {} }

    -- ── Window:NewMinimizer ───────────────────────────────
    function Window:NewMinimizer(cfg2)
        cfg2 = cfg2 or {}
        if cfg2.KeyCode then
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not gpe and inp.KeyCode == cfg2.KeyCode then Toggle() end
            end)
        end
        local Minimizer = {}

        function Minimizer:CreateMobileMinimizer(cfg3)
            cfg3 = cfg3 or {}
            local mob = New("ImageButton", sg, {
                Size             = UDim2.new(0, 52, 0, 52),
                Position         = UDim2.new(0, 14, 1, -80),
                BackgroundColor3 = cfg3.BackgroundColor3 or T.Elem,
                Image            = cfg3.Image or "",
                BorderSizePixel  = 0,
                Active           = true,
                ZIndex           = 10,
            })
            New("UICorner", mob, { CornerRadius = UDim.new(0, 12) })
            New("UIStroke", mob, {
                Color = T.Accent, Thickness = 2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            local img = cfg3.Image or ""
            if img == "" or img == "rbxassetid://0" then
                New("TextLabel", mob, {
                    Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                    Text = "☰", Font = Enum.Font.GothamBold, TextSize = 22,
                    TextColor3 = T.Text, ZIndex = 11,
                })
            end

            -- Draggable with click vs drag detection
            local mbDrag, mbStart, mbStartPos, mbLastInp, mbMoved
            mob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    mbDrag = true; mbMoved = false
                    mbStart = inp.Position; mbStartPos = mob.Position
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then mbDrag = false end
                    end)
                end
            end)
            mob.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then mbLastInp = inp end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if inp == mbLastInp and mbDrag then
                    local d = inp.Position - mbStart
                    if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then mbMoved = true end
                    mob.Position = UDim2.new(mbStartPos.X.Scale, mbStartPos.X.Offset + d.X,
                                             mbStartPos.Y.Scale, mbStartPos.Y.Offset + d.Y)
                end
            end)
            mob.MouseButton1Click:Connect(function()
                if mbMoved then return end
                isOpen = not isOpen
                main.Visible = isOpen
            end)
            return mob
        end

        return Minimizer
    end

    -- ── Window:MakeTab ────────────────────────────────────
    function Window:MakeTab(cfg2)
        cfg2 = cfg2 or {}
        local tabTitle = cfg2.Title or "Tab"
        local tabIcon  = cfg2.Icon  or ""

        local tabBtn = New("TextButton", tabBar, {
            Name             = tabTitle,
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = T.TabBG,
            BorderSizePixel  = 0,
            Text             = (tabIcon ~= "" and tabIcon.."  " or "")..tabTitle,
            Font             = Enum.Font.Gotham,
            TextSize         = 13,
            TextColor3       = T.SubText,
            TextXAlignment   = Enum.TextXAlignment.Left,
            AutoButtonColor  = false,
            ZIndex           = 3,
        })
        New("UIPadding", tabBtn, { PaddingLeft = UDim.new(0, 10) })
        New("UICorner",  tabBtn, { CornerRadius = UDim.new(0, 7) })

        local ind = New("Frame", tabBtn, {
            Size = UDim2.new(0,3,0,18), Position = UDim2.new(0,-3,0.5,-9),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0,
            Visible = false, ZIndex = 4,
        })
        New("UICorner", ind, { CornerRadius = UDim.new(0,4) })

        local scroll = New("ScrollingFrame", elemArea, {
            Name                = tabTitle.."_Scroll",
            Size                = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            ScrollBarThickness  = 3,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize          = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible             = false,
            ZIndex              = 2,
        })
        New("UIPadding", scroll, {
            PaddingTop = UDim.new(0,8), PaddingLeft  = UDim.new(0,8),
            PaddingRight = UDim.new(0,12), PaddingBottom = UDim.new(0,8),
        })
        New("UIListLayout", scroll, { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6) })

        local function Activate()
            for _, t in pairs(Window._tabs) do
                t._btn.BackgroundColor3 = T.TabBG
                t._btn.TextColor3       = T.SubText
                t._btn.Font             = Enum.Font.Gotham
                t._ind.Visible          = false
                t._scroll.Visible       = false
            end
            tabBtn.BackgroundColor3 = T.TabActive
            tabBtn.TextColor3       = T.Text
            tabBtn.Font             = Enum.Font.GothamBold
            ind.Visible             = true
            scroll.Visible          = true
        end

        tabBtn.MouseButton1Click:Connect(Activate)
        tabBtn.MouseEnter:Connect(function()
            if scroll.Visible then return end
            Tween(tabBtn, 0.12, { BackgroundColor3 = T.ElemHov })
        end)
        tabBtn.MouseLeave:Connect(function()
            if scroll.Visible then return end
            Tween(tabBtn, 0.12, { BackgroundColor3 = T.TabBG })
        end)

        local Tab = { _btn = tabBtn, _ind = ind, _scroll = scroll, _order = 0 }
        table.insert(Window._tabs, Tab)
        if #Window._tabs == 1 then Activate() end

        -- ── Element helpers ───────────────────────────────
        local function ElemFrame(h)
            Tab._order = Tab._order + 1
            local f = New("Frame", scroll, {
                Size             = UDim2.new(1,0,0,h),
                BackgroundColor3 = T.Elem,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order,
                ZIndex           = 3,
            })
            New("UICorner", f, { CornerRadius = UDim.new(0,8) })
            New("UIStroke", f, { Color = T.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            return f
        end

        -- ══════════════════════════════════════════════════
        --  Tab:AddButton
        -- ══════════════════════════════════════════════════
        function Tab:AddButton(cfg3)
            cfg3 = cfg3 or {}
            local name     = cfg3.Name     or "Button"
            local debounce = cfg3.Debounce or 0
            local callback = cfg3.Callback or function() end

            local frame = ElemFrame(38)
            -- Labels FIRST (lower z), button overlay LAST (higher z, captures clicks)
            New("TextLabel", frame, {
                Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,14,0,0),
                BackgroundTransparency = 1, Text = name,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
            })
            New("TextLabel", frame, {
                Size = UDim2.new(0,24,1,0), Position = UDim2.new(1,-30,0,0),
                BackgroundTransparency = 1, Text = "›",
                Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = T.Accent,
                TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
            })
            local btn = New("TextButton", frame, {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, ZIndex = 5,
            })

            local cd = false
            btn.MouseButton1Click:Connect(function()
                if cd then return end
                cd = true
                Tween(frame, 0.08, { BackgroundColor3 = T.AccentHov })
                task.delay(0.12, function() Tween(frame, 0.15, { BackgroundColor3 = T.Elem }) end)
                task.spawn(callback)
                if debounce > 0 then
                    task.delay(debounce, function() cd = false end)
                else
                    cd = false
                end
            end)
            btn.MouseEnter:Connect(function() Tween(frame, 0.12, { BackgroundColor3 = T.ElemHov }) end)
            btn.MouseLeave:Connect(function() Tween(frame, 0.12, { BackgroundColor3 = T.Elem    }) end)
        end

        -- ══════════════════════════════════════════════════
        --  Tab:AddToggle
        -- ══════════════════════════════════════════════════
        function Tab:AddToggle(cfg3)
            cfg3 = cfg3 or {}
            local name     = cfg3.Name     or "Toggle"
            local state    = cfg3.Default  or false
            local callback = cfg3.Callback or function() end

            local frame = ElemFrame(38)
            New("TextLabel", frame, {
                Size = UDim2.new(1,-70,1,0), Position = UDim2.new(0,14,0,0),
                BackgroundTransparency = 1, Text = name,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
            })

            local tw, th = 42, 22
            local track = New("Frame", frame, {
                Size = UDim2.new(0,tw,0,th), Position = UDim2.new(1,-(tw+12),0.5,-(th/2)),
                BackgroundColor3 = state and T.TogOn or T.TogOff,
                BorderSizePixel = 0, ZIndex = 4,
            })
            New("UICorner", track, { CornerRadius = UDim.new(1,0) })
            local knob = New("Frame", track, {
                Size = UDim2.new(0,16,0,16),
                Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                BackgroundColor3 = T.White, BorderSizePixel = 0, ZIndex = 5,
            })
            New("UICorner", knob, { CornerRadius = UDim.new(1,0) })

            local btn = New("TextButton", frame, {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, ZIndex = 6,
            })
            btn.MouseButton1Click:Connect(function()
                state = not state
                Tween(track, 0.2, { BackgroundColor3 = state and T.TogOn or T.TogOff })
                Tween(knob,  0.2, { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) })
                task.spawn(callback, state)
            end)
            btn.MouseEnter:Connect(function() Tween(frame, 0.12, { BackgroundColor3 = T.ElemHov }) end)
            btn.MouseLeave:Connect(function() Tween(frame, 0.12, { BackgroundColor3 = T.Elem    }) end)
        end

        -- ══════════════════════════════════════════════════
        --  Tab:AddSlider
        -- ══════════════════════════════════════════════════
        function Tab:AddSlider(cfg3)
            cfg3 = cfg3 or {}
            local name     = cfg3.Name      or "Slider"
            local minV     = cfg3.Min       or 0
            local maxV     = cfg3.Max       or 100
            local inc      = cfg3.Increment or 1
            local def      = cfg3.Default;  if def == nil then def = minV end
            local callback = cfg3.Callback  or function() end

            local frame = ElemFrame(58)
            New("TextLabel", frame, {
                Size = UDim2.new(0.65,-14,0,30), Position = UDim2.new(0,14,0,4),
                BackgroundTransparency = 1, Text = name,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
            })
            local valLbl = New("TextLabel", frame, {
                Size = UDim2.new(0.35,-14,0,30), Position = UDim2.new(0.65,0,0,4),
                BackgroundTransparency = 1, Text = tostring(def),
                Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.Accent,
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4,
            })

            -- Active=true on the hit area so Frame.InputBegan fires
            local hitArea = New("Frame", frame, {
                Size = UDim2.new(1,-28,0,20), Position = UDim2.new(0,14,1,-26),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                Active = true, ZIndex = 4,
            })
            local track = New("Frame", hitArea, {
                Size = UDim2.new(1,0,0,6), Position = UDim2.new(0,0,0.5,-3),
                BackgroundColor3 = T.SliderTrack, BorderSizePixel = 0, ZIndex = 4,
            })
            New("UICorner", track, { CornerRadius = UDim.new(1,0) })

            local pct  = math.clamp((def - minV) / (maxV - minV), 0, 1)
            local fill = New("Frame", track, {
                Size = UDim2.new(pct,0,1,0), BackgroundColor3 = T.SliderFill,
                BorderSizePixel = 0, ZIndex = 5,
            })
            New("UICorner", fill, { CornerRadius = UDim.new(1,0) })
            local thumb = New("Frame", hitArea, {
                Size = UDim2.new(0,14,0,14), Position = UDim2.new(pct,-7,0.5,-7),
                BackgroundColor3 = T.White, BorderSizePixel = 0, ZIndex = 6,
            })
            New("UICorner", thumb, { CornerRadius = UDim.new(1,0) })

            local function SetValue(v)
                v = math.clamp(math.round(v / inc) * inc, minV, maxV)
                v = math.floor(v * 1e4 + 0.5) / 1e4
                local p = math.clamp((v - minV) / (maxV - minV), 0, 1)
                fill.Size      = UDim2.new(p, 0, 1, 0)
                thumb.Position = UDim2.new(p, -7, 0.5, -7)
                valLbl.Text    = tostring(v)
                task.spawn(callback, v)
            end

            local sliding = false
            hitArea.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    local rel = math.clamp((inp.Position.X - hitArea.AbsolutePosition.X) / hitArea.AbsoluteSize.X, 0, 1)
                    SetValue(minV + rel * (maxV - minV))
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not sliding then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    local rel = math.clamp((inp.Position.X - hitArea.AbsolutePosition.X) / hitArea.AbsoluteSize.X, 0, 1)
                    SetValue(minV + rel * (maxV - minV))
                end
            end)

            SetValue(def)
        end

        -- ══════════════════════════════════════════════════
        --  Tab:AddDropdown
        -- ══════════════════════════════════════════════════
        function Tab:AddDropdown(cfg3)
            cfg3 = cfg3 or {}
            local name     = cfg3.Name       or "Dropdown"
            local options  = cfg3.Options     or {}
            local multi    = cfg3.MultiSelect or false
            local callback = cfg3.Callback    or function() end

            local selected
            if multi then
                selected = {}
                if type(cfg3.Default) == "table" then
                    for _, v in ipairs(cfg3.Default) do selected[v] = true end
                end
            else
                selected = cfg3.Default or (options[1] or "")
            end

            local function DispText()
                if multi then
                    local t = {}
                    for k in pairs(selected) do t[#t+1] = k end
                    return #t == 0 and "None" or table.concat(t, ", ")
                end
                return tostring(selected)
            end

            local frame  = ElemFrame(38)
            local opened = false

            New("TextLabel", frame, {
                Size = UDim2.new(0.45,-14,1,0), Position = UDim2.new(0,14,0,0),
                BackgroundTransparency = 1, Text = name,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
            })
            local valLbl = New("TextLabel", frame, {
                Size = UDim2.new(0.42,0,1,0), Position = UDim2.new(0.46,0,0,0),
                BackgroundTransparency = 1, Text = DispText(),
                Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.SubText,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
            })
            local arrow = New("TextLabel", frame, {
                Size = UDim2.new(0,24,1,0), Position = UDim2.new(1,-30,0,0),
                BackgroundTransparency = 1, Text = "▾",
                Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.Accent,
                TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
            })

            local panelH = #options * 30 + 8
            local panel  = New("Frame", scroll, {
                Name = name.."_Panel",
                Size = UDim2.new(1,0,0,panelH),
                BackgroundColor3 = T.DropBG, BorderSizePixel = 0,
                Visible = false, LayoutOrder = Tab._order + 0.5, ZIndex = 6,
            })
            New("UICorner",   panel, { CornerRadius = UDim.new(0,8) })
            New("UIStroke",   panel, { Color = T.Accent, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            New("UIPadding",  panel, { PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4) })
            New("UIListLayout", panel, { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2) })

            local optBtns = {}
            local function RefreshColors()
                for _, ob in ipairs(optBtns) do
                    local on = multi and selected[ob.val] or (selected == ob.val)
                    ob.bg.BackgroundColor3 = on and T.TabActive or T.DropBG
                    ob.lbl.TextColor3      = on and T.Text      or T.SubText
                end
            end

            for i, opt in ipairs(options) do
                local bg = New("TextButton", panel, {
                    Size = UDim2.new(1,-8,0,28), BackgroundColor3 = T.DropBG,
                    BorderSizePixel = 0, Text = "", AutoButtonColor = false,
                    LayoutOrder = i, ZIndex = 7,
                })
                New("UICorner",  bg, { CornerRadius = UDim.new(0,6) })
                New("UIPadding", bg, { PaddingLeft = UDim.new(0,10) })
                local lbl = New("TextLabel", bg, {
                    Size = UDim2.new(1,-20,1,0), BackgroundTransparency = 1,
                    Text = tostring(opt), Font = Enum.Font.Gotham, TextSize = 12,
                    TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
                })
                table.insert(optBtns, { val = opt, bg = bg, lbl = lbl })
                bg.MouseButton1Click:Connect(function()
                    if multi then
                        if selected[opt] then selected[opt] = nil else selected[opt] = true end
                        local list = {}; for k in pairs(selected) do list[#list+1] = k end
                        task.spawn(callback, list)
                    else
                        selected = opt
                        task.spawn(callback, selected)
                        opened = false; panel.Visible = false; arrow.Text = "▾"
                    end
                    valLbl.Text = DispText()
                    RefreshColors()
                end)
                bg.MouseEnter:Connect(function() Tween(bg, 0.1, { BackgroundColor3 = T.ElemHov }) end)
                bg.MouseLeave:Connect(function()
                    local on = multi and selected[opt] or selected == opt
                    Tween(bg, 0.1, { BackgroundColor3 = on and T.TabActive or T.DropBG })
                end)
            end
            RefreshColors()

            local hdr = New("TextButton", frame, {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, ZIndex = 5,
            })
            hdr.MouseButton1Click:Connect(function()
                opened = not opened
                panel.Visible = opened
                arrow.Text    = opened and "▴" or "▾"
            end)
            hdr.MouseEnter:Connect(function() Tween(frame, 0.12, { BackgroundColor3 = T.ElemHov }) end)
            hdr.MouseLeave:Connect(function() Tween(frame, 0.12, { BackgroundColor3 = T.Elem    }) end)
        end

        -- ══════════════════════════════════════════════════
        --  Tab:AddTextBox
        -- ══════════════════════════════════════════════════
        function Tab:AddTextBox(cfg3)
            cfg3 = cfg3 or {}
            local name       = cfg3.Name        or "TextBox"
            local default    = cfg3.Default      or ""
            local holder     = cfg3.Placeholder  or "Type here..."
            local clearFocus = cfg3.ClearOnFocus
            if clearFocus == nil then clearFocus = true end
            local callback = cfg3.Callback or function() end

            local frame = ElemFrame(62)
            New("TextLabel", frame, {
                Size = UDim2.new(1,-28,0,22), Position = UDim2.new(0,14,0,8),
                BackgroundTransparency = 1, Text = name,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
            })

            local boxBg = New("Frame", frame, {
                Size = UDim2.new(1,-28,0,26), Position = UDim2.new(0,14,1,-34),
                BackgroundColor3 = T.DropBG, BorderSizePixel = 0, ZIndex = 4,
            })
            New("UICorner", boxBg, { CornerRadius = UDim.new(0,6) })
            local stroke = New("UIStroke", boxBg, {
                Color = T.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })

            local tb = New("TextBox", boxBg, {
                Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,8,0,0),
                BackgroundTransparency = 1, Text = tostring(default),
                PlaceholderText = holder, PlaceholderColor3 = T.SubText,
                Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = clearFocus, ZIndex = 5,
            })
            tb.Focused:Connect(function()
                Tween(boxBg,  0.15, { BackgroundColor3 = T.TabActive })
                Tween(stroke, 0.15, { Color = T.Accent })
            end)
            tb.FocusLost:Connect(function()
                Tween(boxBg,  0.15, { BackgroundColor3 = T.DropBG })
                Tween(stroke, 0.15, { Color = T.Stroke })
                task.spawn(callback, tb.Text)
            end)
        end

        return Tab
    end -- MakeTab

    return Window
end -- MakeWindow

return SGUI
