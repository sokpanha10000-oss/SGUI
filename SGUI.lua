local UI = {} 
UI.__index = UI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create main ScreenGui
local function createScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "CustomUIHub"
    sg.ResetOnSpawn = false
    sg.Parent = playerGui
    return sg
end

function UI:CreateWindow(config)
    local self = setmetatable({}, UI)
    
    self.ScreenGui = createScreenGui()
    
    -- Main Window
    self.Window = Instance.new("Frame")
    self.Window.Name = "Window"
    self.Window.Size = UDim2.new(0, 520, 0, 380)
    self.Window.Position = UDim2.new(0.5, -260, 0.5, -190)
    self.Window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    self.Window.BorderSizePixel = 0
    self.Window.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.Window
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1.5
    stroke.Parent = self.Window
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 50)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Window
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = self.TitleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Script Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = self.TitleBar
    
    -- Author
    if config.Author then
        local author = Instance.new("TextLabel")
        author.Size = UDim2.new(0.4, 0, 1, 0)
        author.Position = UDim2.new(0.6, 0, 0, 0)
        author.BackgroundTransparency = 1
        author.Text = config.Author
        author.TextColor3 = Color3.fromRGB(180, 180, 190)
        author.TextXAlignment = Enum.TextXAlignment.Right
        author.Font = Enum.Font.Gotham
        author.TextSize = 14
        author.Parent = self.TitleBar
    end
    
    -- Icon (simple text for now, replace with ImageLabel + Lucide if needed)
    if config.Icon then
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0, 15, 0.5, -15)
        icon.BackgroundTransparency = 1
        icon.Text = config.Icon -- e.g. "🚪" or use real icon
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.TextSize = 20
        icon.Parent = self.TitleBar
    end
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = self.TitleBar
    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui.Enabled = false
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -75, 0, 10)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = self.TitleBar
    
    -- Draggable
    self:MakeDraggable(self.TitleBar)
    
    -- Tab Container
    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, 0, 0, 40)
    self.TabBar.Position = UDim2.new(0, 0, 0, 50)
    self.TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    self.TabBar.BorderSizePixel = 0
    self.TabBar.Parent = self.Window
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = self.TabBar
    
    -- Content Area
    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1, 0, 1, -90)
    self.Content.Position = UDim2.new(0, 0, 0, 90)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Window
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Minimize logic
    self.Minimized = false
    minBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.Content.Visible = false
            self.TabBar.Visible = false
            self.Window.Size = UDim2.new(0, 520, 0, 50)
        else
            self.Content.Visible = true
            self.TabBar.Visible = true
            self.Window.Size = UDim2.new(0, 520, 0, 380)
        end
    end)
    
    -- Create minimize button outside (as per your usage)
    self:CreateMinimize(config.Minimize or {})
    
    return self
end

function UI:MakeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function UI:CreateMinimize(config)
    local openBtn = Instance.new("TextButton")
    openBtn.Name = "OpenUI"
    openBtn.Size = UDim2.new(0, 140, 0, 40)
    openBtn.Position = UDim2.new(0, 20, 1, -60)
    openBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Red as example
    openBtn.Text = config.Name or "Open UI"
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 16
    openBtn.Parent = self.ScreenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = openBtn
    
    openBtn.MouseButton1Click:Connect(function()
        self.ScreenGui.Enabled = true
        if self.Minimized then
            self.Minimized = false
            self.Content.Visible = true
            self.TabBar.Visible = true
            self.Window.Size = UDim2.new(0, 520, 0, 380)
        end
    end)
end

function UI:Tab(config)
    local tab = {}
    tab.Title = config.Title or "Tab"
    tab.Locked = config.Locked or false
    
    -- Tab Button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    tabBtn.Text = tab.Title
    tabBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 15
    tabBtn.Parent = self.TabBar
    
    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 8)
    tbCorner.Parent = tabBtn
    
    -- Content Frame (with Scroll)
    tab.ContentFrame = Instance.new("ScrollingFrame")
    tab.ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    tab.ContentFrame.BackgroundTransparency = 1
    tab.ContentFrame.ScrollBarThickness = 6
    tab.ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    tab.ContentFrame.Parent = self.Content
    tab.ContentFrame.Visible = false
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = tab.ContentFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = tab.ContentFrame
    
    -- Auto canvas size
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    tabBtn.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            self.CurrentTab.ContentFrame.Visible = false
        end
        tab.ContentFrame.Visible = true
        self.CurrentTab = tab
    end)
    
    -- Select first tab by default
    if not self.CurrentTab then
        tab.ContentFrame.Visible = true
        self.CurrentTab = tab
    end
    
    self.Tabs[#self.Tabs + 1] = tab
    
    -- Element creators
    function tab:Button(elementConfig)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 50)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = elementConfig.Title or "Button"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 16
        btn.Parent = tab.ContentFrame
        
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 8)
        bCorner.Parent = btn
        
        if elementConfig.Desc then
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(1, 0, 0, 20)
            desc.Position = UDim2.new(0, 0, 1, 2)
            desc.BackgroundTransparency = 1
            desc.Text = elementConfig.Desc
            desc.TextColor3 = Color3.fromRGB(160, 160, 170)
            desc.TextSize = 13
            desc.Font = Enum.Font.Gotham
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = btn
        end
        
        btn.MouseButton1Click:Connect(function()
            if elementConfig.Callback then
                elementConfig.Callback()
            end
        end)
        
        return btn
    end
    
    function tab:Dropdown(elementConfig)
        local drop = Instance.new("Frame")
        drop.Size = UDim2.new(1, 0, 0, 50)
        drop.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        drop.Parent = tab.ContentFrame
        
        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(0, 8)
        dCorner.Parent = drop
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0.7, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = elementConfig.Title or "Dropdown"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 16
        title.Parent = drop
        
        local selected = Instance.new("TextLabel")
        selected.Size = UDim2.new(0.3, 0, 1, 0)
        selected.Position = UDim2.new(0.7, 0, 0, 0)
        selected.BackgroundTransparency = 1
        selected.Text = elementConfig.Value or "Select..."
        selected.TextColor3 = Color3.fromRGB(180, 180, 190)
        selected.TextXAlignment = Enum.TextXAlignment.Right
        selected.Parent = drop
        
        -- Dropdown List (square, medium, front, scroll)
        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0, 280, 0, 220) -- medium square-ish
        listFrame.Position = UDim2.new(0.5, -140, 0.5, -110) -- middle front
        listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        listFrame.Visible = false
        listFrame.ZIndex = 100
        listFrame.Parent = self.Window.Parent -- on top level
        
        local lCorner = Instance.new("UICorner")
        lCorner.CornerRadius = UDim.new(0, 10)
        lCorner.Parent = listFrame
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -10)
        scroll.Position = UDim2.new(0, 5, 0, 5)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 5
        scroll.Parent = listFrame
        
        local ll = Instance.new("UIListLayout")
        ll.Padding = UDim.new(0, 4)
        ll.Parent = scroll
        
        for _, val in ipairs(elementConfig.Values or {}) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1, 0, 0, 35)
            opt.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            opt.Text = val
            opt.TextColor3 = Color3.fromRGB(255, 255, 255)
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 15
            opt.Parent = scroll
            
            local oc = Instance.new("UICorner")
            oc.CornerRadius = UDim.new(0, 6)
            oc.Parent = opt
            
            opt.MouseButton1Click:Connect(function()
                selected.Text = val
                listFrame.Visible = false
                if elementConfig.Callback then
                    elementConfig.Callback(val)
                end
            end)
        end
        
        -- Auto canvas
        ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y)
        end)
        
        drop.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                listFrame.Visible = not listFrame.Visible
            end
        end)
        
        return drop
    end
    
    function tab:Toggle(elementConfig)
        local togFrame = Instance.new("Frame")
        togFrame.Size = UDim2.new(1, 0, 0, 50)
        togFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        togFrame.Parent = tab.ContentFrame
        
        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 8)
        tc.Parent = togFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0.75, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = elementConfig.Title or "Toggle"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Font = Enum.Font.GothamSemibold
        title.Parent = togFrame
        
        if elementConfig.Desc then
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(0.75, 0, 0, 18)
            d.Position = UDim2.new(0, 0, 0.6, 0)
            d.BackgroundTransparency = 1
            d.Text = elementConfig.Desc
            d.TextColor3 = Color3.fromRGB(160, 160, 170)
            d.TextSize = 13
            d.Parent = togFrame
        end
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 26)
        toggleBtn.Position = UDim2.new(1, -65, 0.5, -13)
        toggleBtn.BackgroundColor3 = elementConfig.Value and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(80, 80, 90)
        toggleBtn.Text = ""
        toggleBtn.Parent = togFrame
        
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(1, 0)
        tCorner.Parent = toggleBtn
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.Position = elementConfig.Value and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = toggleBtn
        
        local kCorner = Instance.new("UICorner")
        kCorner.CornerRadius = UDim.new(1, 0)
        kCorner.Parent = knob
        
        local state = elementConfig.Value or false
        
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(80, 80, 90)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
            if elementConfig.Callback then
                elementConfig.Callback(state)
            end
        end)
        
        return togFrame
    end
    
    function tab:Slider(elementConfig)
        local sFrame = Instance.new("Frame")
        sFrame.Size = UDim2.new(1, 0, 0, 70)
        sFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        sFrame.Parent = tab.ContentFrame
        
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(0, 8)
        sc.Parent = sFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundTransparency = 1
        title.Text = (elementConfig.Title or "Slider") .. " : " .. (elementConfig.Value.Default or 0)
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamSemibold
        title.Parent = sFrame
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -30, 0, 8)
        bar.Position = UDim2.new(0, 15, 0, 45)
        bar.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        bar.Parent = sFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 4)
        barCorner.Parent = bar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0.5, 0, 1, 0) -- default
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.Parent = bar
        
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 4)
        fCorner.Parent = fill
        
        -- Simple slider logic (you can expand with dragging)
        local min = elementConfig.Value.Min or 0
        local max = elementConfig.Value.Max or 100
        local default = elementConfig.Value.Default or min
        local step = elementConfig.Step or 1
        
        local function updateSlider(val)
            val = math.clamp(math.floor(val / step) * step, min, max)
            local percent = (val - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            title.Text = (elementConfig.Title or "Slider") .. " : " .. val
            if elementConfig.Callback then
                elementConfig.Callback(val)
            end
        end
        
        updateSlider(default)
        
        -- Basic click on bar (improve with drag if needed)
        bar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relX = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                        local val = min + (max - min) * math.clamp(relX, 0, 1)
                        updateSlider(val)
                    end
                end)
                UserInputService.InputEnded:Connect(function(endInp)
                    if endInp.UserInputType == Enum.UserInputType.MouseButton1 then
                        conn:Disconnect()
                    end
                end)
            end
        end)
        
        return sFrame
    end
    
    function tab:Input(elementConfig)
        local inFrame = Instance.new("Frame")
        inFrame.Size = UDim2.new(1, 0, 0, 60)
        inFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        inFrame.Parent = tab.ContentFrame
        
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 8)
        ic.Parent = inFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundTransparency = 1
        title.Text = elementConfig.Title or "Input"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamSemibold
        title.Parent = inFrame
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -30, 0, 30)
        box.Position = UDim2.new(0, 15, 0, 28)
        box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        box.PlaceholderText = elementConfig.Placeholder or "Enter text..."
        box.Text = elementConfig.Value or ""
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.ClearTextOnFocus = false
        box.Parent = inFrame
        
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = box
        
        box.FocusLost:Connect(function(enter)
            if elementConfig.Callback then
                elementConfig.Callback(box.Text)
            end
        end)
        
        return inFrame
    end
    
    return tab
end

-- Return the library
return UI
