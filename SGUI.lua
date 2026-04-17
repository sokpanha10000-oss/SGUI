local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer
local Mouse        = LP:GetMouse()

-- ─────────────────────────────────────────────
--  Utility
-- ─────────────────────────────────────────────
local function T(obj, t, goal)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
end

local COLORS = {
    Red     = Color3.fromRGB(215, 55,  55),
    Blue    = Color3.fromRGB(55,  110, 215),
    Green   = Color3.fromRGB(55,  185, 100),
    Purple  = Color3.fromRGB(125, 55,  215),
    Orange  = Color3.fromRGB(215, 125, 35),
    Pink    = Color3.fromRGB(215, 75,  155),
    Cyan    = Color3.fromRGB(35,  175, 215),
    Default = Color3.fromRGB(70,  100, 200),
}
local function GetColor(name) return COLORS[name] or COLORS.Default end

-- Draggable: drag Target by Handle
local function Draggable(Handle, Target)
    local drag, ds, sp = false, nil, nil
    local MOUSE = Enum.UserInputType.MouseButton1
    local MOVE  = Enum.UserInputType.MouseMovement

    Handle.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.UserInputType == MOUSE then
            drag = true; ds = i.Position; sp = Target.Position
        end
    end)
    Handle.InputEnded:Connect(function(i)
        if i.UserInputType == MOUSE then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == MOVE then
            local d = i.Position - ds
            Target.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

-- ─────────────────────────────────────────────
--  ScreenGui
-- ─────────────────────────────────────────────
local SG              = Instance.new("ScreenGui")
SG.Name               = "UILibHub"
SG.ResetOnSpawn       = false
SG.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset     = true
do
    local ok = pcall(function() SG.Parent = game:GetService("CoreGui") end)
    if not ok then SG.Parent = LP:WaitForChild("PlayerGui") end
end

-- ─────────────────────────────────────────────
--  Helper builders
-- ─────────────────────────────────────────────
local function Corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = p end
local function Pad(p, t, b, l, r)
    local u = Instance.new("UIPadding"); u.PaddingTop = UDim.new(0,t); u.PaddingBottom = UDim.new(0,b)
    u.PaddingLeft = UDim.new(0,l); u.PaddingRight = UDim.new(0,r); u.Parent = p
end

local function MakeLabel(parent, props)
    local L = Instance.new("TextLabel")
    L.BackgroundTransparency = 1
    L.TextXAlignment = Enum.TextXAlignment.Left
    for k,v in pairs(props) do L[k] = v end
    L.Parent = parent
    return L
end

-- ─────────────────────────────────────────────
--  Library
-- ─────────────────────────────────────────────
local UILib = {}

function UILib:CreateWindow(Cfg)
    Cfg = Cfg or {}
    local Title  = Cfg.Title  or "Hub"
    local Author = Cfg.Author or ""

    -- ── Drop shadow
    local Shadow      = Instance.new("Frame")
    Shadow.Name       = "Shadow"
    Shadow.Size       = UDim2.new(0, 528, 0, 630)
    Shadow.Position   = UDim2.new(0.5, -264, 0.5, -315)
    Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Shadow.BackgroundTransparency = 0.5
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = 1
    Shadow.Parent = SG
    Corner(Shadow, 16)

    -- ── Main frame
    local Win       = Instance.new("Frame")
    Win.Name        = "Win"
    Win.Size        = UDim2.new(0, 518, 0, 620)
    Win.Position    = UDim2.new(0.5, -259, 0.5, -310)
    Win.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Win.BorderSizePixel  = 0
    Win.ClipsDescendants = true
    Win.ZIndex = 2
    Win.Parent = SG
    Corner(Win, 12)

    -- shadow follows win
    RunService.RenderStepped:Connect(function()
        Shadow.Position = UDim2.new(
            Win.Position.X.Scale, Win.Position.X.Offset - 5,
            Win.Position.Y.Scale, Win.Position.Y.Offset - 5)
        Shadow.Visible = Win.Visible
    end)

    -- ── Header
    local Hdr = Instance.new("Frame")
    Hdr.Name  = "Header"
    Hdr.Size  = UDim2.new(1, 0, 0, 54)
    Hdr.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    Hdr.BorderSizePixel  = 0
    Hdr.ZIndex = 3
    Hdr.Parent = Win
    Corner(Hdr, 12)
    -- fill bottom corners of header
    local HdrFill = Instance.new("Frame")
    HdrFill.Size = UDim2.new(1,0,0,12); HdrFill.Position = UDim2.new(0,0,1,-12)
    HdrFill.BackgroundColor3 = Color3.fromRGB(12,12,20); HdrFill.BorderSizePixel = 0
    HdrFill.ZIndex = 3; HdrFill.Parent = Hdr

    -- accent line
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(1,0,0,2); Accent.Position = UDim2.new(0,0,1,0)
    Accent.BackgroundColor3 = Color3.fromRGB(70,100,200); Accent.BorderSizePixel = 0
    Accent.ZIndex = 4; Accent.Parent = Hdr

    -- title
    MakeLabel(Hdr,{
        Size   = UDim2.new(1,-120,0,22), Position = UDim2.new(0,14,0,8),
        TextColor3 = Color3.fromRGB(235,235,255), TextSize = 16,
        Font = Enum.Font.GothamBold, Text = Title, ZIndex = 4,
    })
    MakeLabel(Hdr,{
        Size   = UDim2.new(1,-120,0,16), Position = UDim2.new(0,14,0,32),
        TextColor3 = Color3.fromRGB(100,100,145), TextSize = 11,
        Font = Enum.Font.Gotham, Text = Author, ZIndex = 4,
    })

    -- ── Minimize button (─)
    local BtnMin = Instance.new("TextButton")
    BtnMin.Size  = UDim2.new(0,32,0,32); BtnMin.Position = UDim2.new(1,-80,0.5,-16)
    BtnMin.BackgroundColor3 = Color3.fromRGB(38,38,58)
    BtnMin.TextColor3 = Color3.fromRGB(200,200,220)
    BtnMin.TextSize = 16; BtnMin.Font = Enum.Font.GothamBold
    BtnMin.Text = "─"; BtnMin.BorderSizePixel = 0; BtnMin.AutoButtonColor = false
    BtnMin.ZIndex = 5; BtnMin.Parent = Hdr
    Corner(BtnMin, 8)

    -- ── Close button (✕)
    local BtnClose = Instance.new("TextButton")
    BtnClose.Size  = UDim2.new(0,32,0,32); BtnClose.Position = UDim2.new(1,-42,0.5,-16)
    BtnClose.BackgroundColor3 = Color3.fromRGB(170,40,40)
    BtnClose.TextColor3 = Color3.fromRGB(255,255,255)
    BtnClose.TextSize = 13; BtnClose.Font = Enum.Font.GothamBold
    BtnClose.Text = "✕"; BtnClose.BorderSizePixel = 0; BtnClose.AutoButtonColor = false
    BtnClose.ZIndex = 5; BtnClose.Parent = Hdr
    Corner(BtnClose, 8)

    -- hover effects on header buttons
    for _, b in ipairs({BtnMin, BtnClose}) do
        local orig = b.BackgroundColor3
        b.MouseEnter:Connect(function() T(b, 0.12, {BackgroundColor3 = b.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.15)}) end)
        b.MouseLeave:Connect(function() T(b, 0.12, {BackgroundColor3 = orig}) end)
    end

    -- ── Body
    local Body      = Instance.new("Frame")
    Body.Name       = "Body"
    Body.Size       = UDim2.new(1,0,1,-56)
    Body.Position   = UDim2.new(0,0,0,56)
    Body.BackgroundTransparency = 1
    Body.ClipsDescendants = true
    Body.ZIndex = 3
    Body.Parent = Win

    -- Left tab list (scrollable)
    local TabList   = Instance.new("ScrollingFrame")
    TabList.Size    = UDim2.new(0,118,1,-10)
    TabList.Position = UDim2.new(0,6,0,6)
    TabList.BackgroundColor3 = Color3.fromRGB(13,13,22)
    TabList.BorderSizePixel  = 0
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize  = UDim2.new(0,0,0,0)
    TabList.ZIndex = 4
    TabList.Parent = Body
    Corner(TabList, 10)

    local TabLL = Instance.new("UIListLayout")
    TabLL.Padding = UDim.new(0,5); TabLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLL.Parent = TabList
    Pad(TabList, 8, 8, 0, 0)
    TabLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0,0,0,TabLL.AbsoluteContentSize.Y+16)
    end)

    -- Right content area
    local Content   = Instance.new("Frame")
    Content.Name    = "Content"
    Content.Size    = UDim2.new(1,-132,1,-10)
    Content.Position = UDim2.new(0,128,0,6)
    Content.BackgroundColor3 = Color3.fromRGB(13,13,22)
    Content.BorderSizePixel  = 0
    Content.ClipsDescendants = true
    Content.ZIndex = 4
    Content.Parent = Body
    Corner(Content, 10)

    -- ── Window state
    local WObj       = {}
    local tabs       = {}
    local isMinimized = false
    local isHidden    = false
    local floatBtn    = nil
    local WIN_H = 620

    local function ShowWindow(show)
        isHidden = not show
        Win.Visible    = show
        Shadow.Visible = show
        if floatBtn then
            floatBtn.Text = show and "☰" or "■"
            T(floatBtn, 0.15, { BackgroundColor3 = show and floatBtn._color or Color3.fromRGB(170,40,40) })
        end
    end

    -- Minimize → collapse to header only
    BtnMin.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            T(Win,    0.28, { Size = UDim2.new(0, 518, 0, 54) })
            T(Shadow, 0.28, { Size = UDim2.new(0, 528, 0, 64) })
            BtnMin.Text = "□"
        else
            T(Win,    0.28, { Size = UDim2.new(0, 518, 0, WIN_H) })
            T(Shadow, 0.28, { Size = UDim2.new(0, 528, 0, WIN_H + 10) })
            BtnMin.Text = "─"
        end
    end)

    -- Close → fully hide
    BtnClose.MouseButton1Click:Connect(function()
        ShowWindow(false)
    end)

    -- Draggable window
    Draggable(Hdr, Win)

    -- ── CreateMinimize  (floating toggle button)
    function WObj:CreateMinimize(Cfg2)
        Cfg2 = Cfg2 or {}
        local fName  = Cfg2.Name  or "Toggle"
        local fColor = GetColor(Cfg2.Color or "Default")

        local Btn = Instance.new("TextButton")
        Btn.Name  = "FloatBtn"
        Btn.Size  = UDim2.new(0, 46, 0, 46)
        Btn.Position = UDim2.new(0, 22, 0.5, 20)
        Btn.BackgroundColor3 = fColor
        Btn.TextColor3 = Color3.fromRGB(255,255,255)
        Btn.TextSize = 20; Btn.Font = Enum.Font.GothamBold
        Btn.Text = "☰"; Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false
        Btn.ZIndex = 20; Btn.Parent = SG
        Btn._color = fColor
        Corner(Btn, 23)

        -- glow ring
        local Ring = Instance.new("Frame")
        Ring.Size = UDim2.new(1,10,1,10); Ring.Position = UDim2.new(0,-5,0,-5)
        Ring.BackgroundTransparency = 1; Ring.BorderSizePixel = 3
        Ring.BorderColor3 = fColor; Ring.ZIndex = 19; Ring.Parent = Btn
        Corner(Ring, 27)

        -- name label
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0,90,0,14); NameLbl.Position = UDim2.new(0.5,-45,1,5)
        NameLbl.BackgroundTransparency = 1
        NameLbl.TextColor3 = Color3.fromRGB(190,190,215); NameLbl.TextSize = 10
        NameLbl.Font = Enum.Font.Gotham; NameLbl.Text = fName; NameLbl.ZIndex = 20
        NameLbl.Parent = Btn

        -- draggable float button
        Draggable(Btn, Btn)

        floatBtn = Btn

        -- hover
        Btn.MouseEnter:Connect(function()
            T(Btn, 0.15, { Size = UDim2.new(0,52,0,52), Position = UDim2.new(Btn.Position.X.Scale, Btn.Position.X.Offset-3, Btn.Position.Y.Scale, Btn.Position.Y.Offset-3) })
        end)
        Btn.MouseLeave:Connect(function()
            T(Btn, 0.15, { Size = UDim2.new(0,46,0,46) })
        end)

        -- click: toggle window visibility
        Btn.MouseButton1Click:Connect(function()
            ShowWindow(isHidden)   -- isHidden true → show; false → hide
        end)

        return Btn
    end

    -- ── Tab builder
    function WObj:Tab(Cfg2)
        Cfg2 = Cfg2 or {}
        local tabTitle = Cfg2.Title or "Tab"
        local tabIcon  = Cfg2.Icon  or ""

        -- Tab list button
        local TBtn = Instance.new("TextButton")
        TBtn.Size  = UDim2.new(1,-8,0,36)
        TBtn.BackgroundColor3 = Color3.fromRGB(26,26,40)
        TBtn.TextColor3 = Color3.fromRGB(145,145,185); TBtn.TextSize = 12
        TBtn.Font = Enum.Font.Gotham
        TBtn.Text = (tabIcon ~= "" and tabIcon.."  " or "")..tabTitle
        TBtn.BorderSizePixel = 0; TBtn.AutoButtonColor = false
        TBtn.ZIndex = 5; TBtn.Parent = TabList
        Corner(TBtn, 8)

        -- Scroll frame for this tab's elements
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size  = UDim2.new(1,0,1,0)
        Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
        Scroll.ScrollBarThickness = 4
        Scroll.ScrollBarImageColor3 = Color3.fromRGB(70,100,200)
        Scroll.CanvasSize = UDim2.new(0,0,0,0)
        Scroll.Visible = false; Scroll.ZIndex = 5; Scroll.Parent = Content

        local ELL = Instance.new("UIListLayout")
        ELL.Padding = UDim.new(0,8); ELL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ELL.Parent = Scroll
        Pad(Scroll, 10, 10, 8, 8)
        ELL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0,0,0, ELL.AbsoluteContentSize.Y + 20)
        end)

        -- Activate function
        local function Activate()
            for _, t in ipairs(tabs) do
                t.scroll.Visible = false
                T(t.btn, 0.15, { BackgroundColor3 = Color3.fromRGB(26,26,40), TextColor3 = Color3.fromRGB(145,145,185) })
            end
            Scroll.Visible = true
            T(TBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(70,100,200), TextColor3 = Color3.fromRGB(255,255,255) })
        end

        TBtn.MouseButton1Click:Connect(Activate)
        table.insert(tabs, { btn = TBtn, scroll = Scroll })
        if #tabs == 1 then Activate() end

        -- ── Element helpers ───────────────────
        local function ElemFrame(h)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1,0,0,h)
            F.BackgroundColor3 = Color3.fromRGB(24,24,38)
            F.BorderSizePixel  = 0; F.ZIndex = 6; F.Parent = Scroll
            Corner(F, 10)
            -- left accent
            local A = Instance.new("Frame")
            A.Size = UDim2.new(0,3,0.55,0); A.Position = UDim2.new(0,0,0.225,0)
            A.BackgroundColor3 = Color3.fromRGB(70,100,200); A.BorderSizePixel = 0
            A.ZIndex = 7; A.Parent = F; Corner(A, 4)
            return F
        end

        local function TitleLbl(p, txt, zi)
            return MakeLabel(p,{ Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(225,225,255), TextSize = 13,
                Font = Enum.Font.GothamBold, Text = txt, ZIndex = zi or 7 })
        end
        local function DescLbl(p, txt, zi)
            return MakeLabel(p,{ Size = UDim2.new(1,0,0,14), BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(105,105,150), TextSize = 11,
                Font = Enum.Font.Gotham, Text = txt, ZIndex = zi or 7 })
        end

        local API = {}

        -- ── BUTTON
        function API:Button(C)
            C = C or {}
            local F = ElemFrame(64)
            local TL = TitleLbl(F, C.Title or "Button"); TL.Size = UDim2.new(0.6,0,0,18); TL.Position = UDim2.new(0,14,0,12)
            local DL = DescLbl(F,  C.Desc  or "");       DL.Size = UDim2.new(0.6,0,0,14); DL.Position = UDim2.new(0,14,0,34)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0,88,0,34); Btn.Position = UDim2.new(1,-98,0.5,-17)
            Btn.BackgroundColor3 = Color3.fromRGB(70,100,200)
            Btn.TextColor3 = Color3.fromRGB(255,255,255); Btn.TextSize = 12
            Btn.Font = Enum.Font.GothamBold; Btn.Text = "Execute"
            Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false; Btn.ZIndex = 8; Btn.Parent = F
            Corner(Btn, 8)

            Btn.MouseEnter:Connect(function() T(Btn,.12,{BackgroundColor3=Color3.fromRGB(88,120,225)}) end)
            Btn.MouseLeave:Connect(function() T(Btn,.12,{BackgroundColor3=Color3.fromRGB(70,100,200)}) end)
            Btn.MouseButton1Click:Connect(function()
                T(Btn,.08,{BackgroundColor3=Color3.fromRGB(50,78,168)})
                task.delay(.12,function() T(Btn,.15,{BackgroundColor3=Color3.fromRGB(70,100,200)}) end)
                if C.Callback then C.Callback() end
            end)
            return F
        end

        -- ── TOGGLE
        function API:Toggle(C)
            C = C or {}
            local state = C.Value or false
            local F = ElemFrame(64)
            local TL = TitleLbl(F, C.Title or "Toggle"); TL.Size = UDim2.new(0.65,0,0,18); TL.Position = UDim2.new(0,14,0,12)
            local DL = DescLbl(F,  C.Desc  or "");       DL.Size = UDim2.new(0.65,0,0,14); DL.Position = UDim2.new(0,14,0,34)

            local ON  = Color3.fromRGB(65,195,110)
            local OFF = Color3.fromRGB(50,50,72)

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0,48,0,26); Track.Position = UDim2.new(1,-60,0.5,-13)
            Track.BackgroundColor3 = state and ON or OFF
            Track.BorderSizePixel = 0; Track.ZIndex = 8; Track.Parent = F
            Corner(Track, 13)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0,20,0,20)
            Knob.Position = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
            Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Knob.BorderSizePixel = 0; Knob.ZIndex = 9; Knob.Parent = Track
            Corner(Knob, 10)

            local TB = Instance.new("TextButton")
            TB.Size = UDim2.new(1,0,1,0); TB.BackgroundTransparency = 1
            TB.Text = ""; TB.ZIndex = 10; TB.Parent = Track

            TB.MouseButton1Click:Connect(function()
                state = not state
                T(Track,.2,{BackgroundColor3 = state and ON or OFF})
                T(Knob, .2,{Position = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)})
                if C.Callback then C.Callback(state) end
            end)
            return F
        end

        -- ── SLIDER
        function API:Slider(C)
            C = C or {}
            local V   = C.Value or {}
            local Min = V.Min or 0; local Max = V.Max or 100
            local Def = math.clamp(V.Default or Min, Min, Max)
            local Step = C.Step or 1
            local F = ElemFrame(84)

            local TL = TitleLbl(F, C.Title or "Slider"); TL.Size = UDim2.new(0.62,0,0,18); TL.Position = UDim2.new(0,14,0,10)
            local VL = MakeLabel(F,{
                Size = UDim2.new(0.3,0,0,18), Position = UDim2.new(0.66,0,0,10),
                BackgroundTransparency=1, TextColor3=Color3.fromRGB(65,155,235), TextSize=13,
                Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right,
                Text=tostring(Def), ZIndex=7
            })
            local DL = DescLbl(F, C.Desc or ""); DL.Size = UDim2.new(1,-28,0,13); DL.Position = UDim2.new(0,14,0,30)

            local TrackBG = Instance.new("Frame")
            TrackBG.Size = UDim2.new(1,-28,0,6); TrackBG.Position = UDim2.new(0,14,0,62)
            TrackBG.BackgroundColor3 = Color3.fromRGB(38,38,58); TrackBG.BorderSizePixel = 0
            TrackBG.ZIndex = 7; TrackBG.Parent = F; Corner(TrackBG, 3)

            local pct0 = (Max > Min) and ((Def-Min)/(Max-Min)) or 0

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(pct0,0,1,0)
            Fill.BackgroundColor3 = Color3.fromRGB(70,120,220); Fill.BorderSizePixel = 0
            Fill.ZIndex = 8; Fill.Parent = TrackBG; Corner(Fill, 3)

            local Handle = Instance.new("Frame")
            Handle.Size = UDim2.new(0,16,0,16); Handle.Position = UDim2.new(pct0,-8,0.5,-8)
            Handle.BackgroundColor3 = Color3.fromRGB(255,255,255); Handle.BorderSizePixel = 0
            Handle.ZIndex = 9; Handle.Parent = TrackBG; Corner(Handle, 8)

            local DragArea = Instance.new("TextButton")
            DragArea.Size = UDim2.new(1,0,0,28); DragArea.Position = UDim2.new(0,0,0.5,-14)
            DragArea.BackgroundTransparency = 1; DragArea.Text = ""; DragArea.ZIndex = 10; DragArea.Parent = TrackBG

            local sldrag = false
            DragArea.MouseButton1Down:Connect(function() sldrag = true end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sldrag = false end end)
            UIS.InputChanged:Connect(function(i)
                if not sldrag then return end
                if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                local rel = math.clamp((Mouse.X - TrackBG.AbsolutePosition.X) / TrackBG.AbsoluteSize.X, 0, 1)
                local raw = Min + (Max-Min)*rel
                local val = math.round(raw/Step)*Step
                local p2  = (val-Min)/(Max-Min)
                Fill.Size     = UDim2.new(p2,0,1,0)
                Handle.Position = UDim2.new(p2,-8,0.5,-8)
                VL.Text = tostring(val)
                if C.Callback then C.Callback(val) end
            end)
            return F
        end

        -- ── DROPDOWN  (opens scrollable overlay panel)
        function API:Dropdown(C)
            C = C or {}
            local Values   = C.Values   or {}
            local Selected = C.Value    or Values[1] or "Select..."
            local F = ElemFrame(64)

            local TL = TitleLbl(F, C.Title or "Dropdown"); TL.Size = UDim2.new(0.52,0,0,18); TL.Position = UDim2.new(0,14,0,12)
            local DL = DescLbl(F,  C.Desc  or "");         DL.Size = UDim2.new(0.52,0,0,14); DL.Position = UDim2.new(0,14,0,34)

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0,134,0,36); DropBtn.Position = UDim2.new(1,-142,0.5,-18)
            DropBtn.BackgroundColor3 = Color3.fromRGB(34,34,54)
            DropBtn.TextColor3 = Color3.fromRGB(205,205,240); DropBtn.TextSize = 11
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Text = Selected.."  ▾"
            DropBtn.BorderSizePixel = 0; DropBtn.AutoButtonColor = false; DropBtn.ZIndex = 8; DropBtn.Parent = F
            Corner(DropBtn, 8)
            DropBtn.MouseEnter:Connect(function() T(DropBtn,.12,{BackgroundColor3=Color3.fromRGB(44,44,68)}) end)
            DropBtn.MouseLeave:Connect(function() T(DropBtn,.12,{BackgroundColor3=Color3.fromRGB(34,34,54)}) end)

            -- ── Overlay (medium, draggable, scrollable)
            local ITEM_H   = 36
            local MAX_VIS  = 8
            local PANEL_H  = math.min(#Values, MAX_VIS) * (ITEM_H + 4) + 54

            local Ov = Instance.new("Frame")
            Ov.Name  = "DropOverlay"; Ov.Size = UDim2.new(0,230,0,0)
            Ov.Position = UDim2.new(0,200,0,200)
            Ov.BackgroundColor3 = Color3.fromRGB(22,22,36)
            Ov.BorderSizePixel = 0; Ov.Visible = false
            Ov.ZIndex = 50; Ov.ClipsDescendants = true; Ov.Parent = SG
            Corner(Ov, 12)

            -- overlay shadow
            local OvS = Instance.new("Frame")
            OvS.Size = UDim2.new(1,10,1,10); OvS.Position = UDim2.new(0,-5,0,-5)
            OvS.BackgroundColor3 = Color3.fromRGB(0,0,0); OvS.BackgroundTransparency = 0.55
            OvS.BorderSizePixel = 0; OvS.Visible = false; OvS.ZIndex = 49; OvS.Parent = SG
            Corner(OvS, 16)
            RunService.RenderStepped:Connect(function()
                if Ov.Visible then
                    OvS.Position = UDim2.new(Ov.Position.X.Scale, Ov.Position.X.Offset-5, Ov.Position.Y.Scale, Ov.Position.Y.Offset-5)
                end
                OvS.Visible = Ov.Visible
            end)

            -- overlay header (drag handle)
            local OvHdr = Instance.new("Frame")
            OvHdr.Size = UDim2.new(1,0,0,40); OvHdr.BackgroundColor3 = Color3.fromRGB(14,14,24)
            OvHdr.BorderSizePixel = 0; OvHdr.ZIndex = 52; OvHdr.Parent = Ov
            Corner(OvHdr, 12)
            local OvHFill = Instance.new("Frame")
            OvHFill.Size = UDim2.new(1,0,0,12); OvHFill.Position = UDim2.new(0,0,1,-12)
            OvHFill.BackgroundColor3 = Color3.fromRGB(14,14,24); OvHFill.BorderSizePixel = 0; OvHFill.ZIndex = 52; OvHFill.Parent = OvHdr

            MakeLabel(OvHdr,{
                Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,12,0,0),
                BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,255), TextSize=13,
                Font=Enum.Font.GothamBold, Text=C.Title or "Select Option", ZIndex=53
            })

            local OvX = Instance.new("TextButton")
            OvX.Size = UDim2.new(0,26,0,26); OvX.Position = UDim2.new(1,-32,0.5,-13)
            OvX.BackgroundColor3 = Color3.fromRGB(165,38,38); OvX.TextColor3 = Color3.fromRGB(255,255,255)
            OvX.TextSize = 11; OvX.Font = Enum.Font.GothamBold; OvX.Text = "✕"
            OvX.BorderSizePixel = 0; OvX.AutoButtonColor = false; OvX.ZIndex = 53; OvX.Parent = OvHdr
            Corner(OvX, 7)
            OvX.MouseEnter:Connect(function() T(OvX,.1,{BackgroundColor3=Color3.fromRGB(200,50,50)}) end)
            OvX.MouseLeave:Connect(function() T(OvX,.1,{BackgroundColor3=Color3.fromRGB(165,38,38)}) end)

            -- accent under header
            local OvAccent = Instance.new("Frame")
            OvAccent.Size = UDim2.new(1,0,0,2); OvAccent.Position = UDim2.new(0,0,0,40)
            OvAccent.BackgroundColor3 = Color3.fromRGB(70,100,200); OvAccent.BorderSizePixel = 0
            OvAccent.ZIndex = 52; OvAccent.Parent = Ov

            -- item scroll
            local OvScroll = Instance.new("ScrollingFrame")
            OvScroll.Size = UDim2.new(1,-10,1,-50); OvScroll.Position = UDim2.new(0,5,0,46)
            OvScroll.BackgroundTransparency = 1; OvScroll.BorderSizePixel = 0
            OvScroll.ScrollBarThickness = 4; OvScroll.ScrollBarImageColor3 = Color3.fromRGB(70,100,200)
            OvScroll.CanvasSize = UDim2.new(0,0,0,0); OvScroll.ZIndex = 52; OvScroll.Parent = Ov

            local ItemLL = Instance.new("UIListLayout")
            ItemLL.Padding = UDim.new(0,4); ItemLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ItemLL.Parent = OvScroll
            Pad(OvScroll, 4, 4, 0, 0)
            ItemLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                OvScroll.CanvasSize = UDim2.new(0,0,0,ItemLL.AbsoluteContentSize.Y+8)
            end)

            -- items
            local itemBtns = {}
            for _, opt in ipairs(Values) do
                local active = (opt == Selected)
                local Item = Instance.new("TextButton")
                Item.Size = UDim2.new(1,0,0,ITEM_H)
                Item.BackgroundColor3 = active and Color3.fromRGB(70,100,200) or Color3.fromRGB(30,30,48)
                Item.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,225)
                Item.TextSize = 12; Item.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
                Item.Text = opt; Item.BorderSizePixel = 0; Item.AutoButtonColor = false
                Item.ZIndex = 53; Item.Parent = OvScroll
                Corner(Item, 7)
                table.insert(itemBtns, Item)

                Item.MouseEnter:Connect(function()
                    if Item.Text ~= Selected then T(Item,.1,{BackgroundColor3=Color3.fromRGB(44,55,88)}) end
                end)
                Item.MouseLeave:Connect(function()
                    if Item.Text ~= Selected then T(Item,.1,{BackgroundColor3=Color3.fromRGB(30,30,48)}) end
                end)
                Item.MouseButton1Click:Connect(function()
                    -- reset all items
                    for _, ib in ipairs(itemBtns) do
                        ib.Font = Enum.Font.Gotham
                        T(ib,.1,{BackgroundColor3=Color3.fromRGB(30,30,48), TextColor3=Color3.fromRGB(185,185,225)})
                    end
                    Item.Font = Enum.Font.GothamBold
                    T(Item,.1,{BackgroundColor3=Color3.fromRGB(70,100,200), TextColor3=Color3.fromRGB(255,255,255)})
                    Selected = opt
                    DropBtn.Text = opt.."  ▾"
                    -- close
                    T(Ov,.2,{Size=UDim2.new(0,230,0,0)})
                    task.delay(.21,function() Ov.Visible=false end)
                    if C.Callback then C.Callback(opt) end
                end)
            end

            Draggable(OvHdr, Ov)

            local function CloseOv()
                T(Ov,.2,{Size=UDim2.new(0,230,0,0)})
                task.delay(.21,function() Ov.Visible=false end)
            end
            OvX.MouseButton1Click:Connect(CloseOv)

            local open = false
            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local abs = DropBtn.AbsolutePosition
                    Ov.Position = UDim2.new(0, abs.X - 50, 0, abs.Y + 42)
                    Ov.Size     = UDim2.new(0, 230, 0, 0)
                    Ov.Visible  = true
                    T(Ov,.25,{Size=UDim2.new(0,230,0,PANEL_H)})
                else
                    CloseOv()
                end
            end)

            return F
        end

        -- ── INPUT / TEXTAREA
        function API:Input(C)
            C = C or {}
            local isArea = (C.Type == "Textarea")
            local F = ElemFrame(isArea and 115 or 72)

            local TL = TitleLbl(F, C.Title or "Input"); TL.Size = UDim2.new(1,-28,0,18); TL.Position = UDim2.new(0,14,0,10)
            local DL = DescLbl(F,  C.Desc  or "");      DL.Size = UDim2.new(1,-28,0,13); DL.Position = UDim2.new(0,14,0,30)

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1,-28,0,isArea and 56 or 28)
            Box.Position = UDim2.new(0,14,0,isArea and 54 or 38)
            Box.BackgroundColor3 = Color3.fromRGB(32,32,50)
            Box.TextColor3 = Color3.fromRGB(215,215,255); Box.TextSize = 12
            Box.Font = Enum.Font.Gotham
            Box.PlaceholderText = C.Placeholder or "Enter text..."
            Box.PlaceholderColor3 = Color3.fromRGB(80,80,120)
            Box.Text = C.Value or ""
            Box.ClearTextOnFocus = false; Box.MultiLine = isArea
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.TextYAlignment = isArea and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
            Box.BorderSizePixel = 0; Box.ZIndex = 8; Box.Parent = F
            Corner(Box, 7)
            Pad(Box, isArea and 4 or 0, 0, 8, 8)

            -- focus highlight
            Box.Focused:Connect(function() T(Box,.15,{BackgroundColor3=Color3.fromRGB(40,40,62)}) end)
            Box.FocusLost:Connect(function(enter)
                T(Box,.15,{BackgroundColor3=Color3.fromRGB(32,32,50)})
                if enter or isArea then if C.Callback then C.Callback(Box.Text) end end
            end)
            return F
        end

        return API
    end

    return WObj
end

-- ─────────────────────────────────────────────
--  Return
-- ─────────────────────────────────────────────
return UILib
