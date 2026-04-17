local UILibrary = {}
UILibrary.__index = UILibrary

-- Utility function to generate unique IDs
local function GenerateID()
    return tostring(math.random(100000, 999999))
end

-- Main UI Creator
function UILibrary.new()
    local self = setmetatable({}, UILibrary)
    self.Windows = {}
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibraryHub"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    return self
end

function UILibrary:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "Window"
    local Icon = Config.Icon or "square"
    local Author = Config.Author or "Unknown"
    
    local Window = {}
    Window.__index = Window
    Window = setmetatable(Window, Window)
    
    Window.Name = Title
    Window.Author = Author
    Window.Icon = Icon
    Window.Tabs = {}
    Window.IsOpen = true
    
    -- Create Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Window_" .. GenerateID()
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = self.ScreenGui
    
    -- Add corner radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Create Header
    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Name = "Header"
    HeaderFrame.Size = UDim2.new(1, 0, 0, 50)
    HeaderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = HeaderFrame
    
    -- Window Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = Title .. " | By: " .. Author
    TitleLabel.Parent = HeaderFrame
    
    -- Close/Open Toggle Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleBtn"
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
    ToggleButton.Position = UDim2.new(1, -50, 0, 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "−"
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = HeaderFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -50)
    ContentFrame.Position = UDim2.new(0, 0, 0, 50)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Tab Container (Left Side)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, 0)
    TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = ContentFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer
    
    -- Tab Content (Right Side)
    local TabContentFrame = Instance.new("Frame")
    TabContentFrame.Name = "TabContent"
    TabContentFrame.Size = UDim2.new(1, -130, 1, 0)
    TabContentFrame.Position = UDim2.new(0, 130, 0, 0)
    TabContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabContentFrame.BorderSizePixel = 0
    TabContentFrame.Parent = ContentFrame
    
    -- Draggable functionality
    local Dragging = false
    local DragStart = nil
    local StartPos = nil
    
    HeaderFrame.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = MainFrame.Position
        end
    end)
    
    HeaderFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(Input, GameProcessed)
        if Dragging and DragStart then
            local Delta = Input.Position - DragStart
            MainFrame.Position = StartPos + UDim2.new(0, Delta.X, 0, Delta.Y)
        end
    end)
    
    -- Toggle Button Functionality
    ToggleButton.MouseButton1Click:Connect(function()
        Window.IsOpen = not Window.IsOpen
        TabContentFrame.Visible = Window.IsOpen
        TabContainer.Visible = Window.IsOpen
        ToggleButton.Text = Window.IsOpen and "−" or "+"
    end)
    
    -- Tab Creation Function
    function Window:Tab(Config)
        Config = Config or {}
        local TabTitle = Config.Title or "Tab"
        local TabIcon = Config.Icon or "square"
        
        local Tab = {}
        Tab.__index = Tab
        Tab = setmetatable(Tab, Tab)
        
        Tab.Name = TabTitle
        Tab.Icon = TabIcon
        Tab.Elements = {}
        
        -- Create Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabTitle
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = TabIcon .. " " .. TabTitle
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabContainer
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton
        
        -- Create Tab Content Frame
        local TabFrame = Instance.new("Frame")
        TabFrame.Name = "Tab_" .. TabTitle
        TabFrame.Size = UDim2.new(1, -10, 1, -10)
        TabFrame.Position = UDim2.new(0, 5, 0, 5)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = (#self.Tabs == 0) -- Show first tab by default
        TabFrame.Parent = TabContentFrame
        
        -- Scrolling Frame
        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
        ScrollFrame.BackgroundTransparency = 1
        ScrollFrame.ScrollBarThickness = 6
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        ScrollFrame.Parent = TabFrame
        
        local ElementLayout = Instance.new("UIListLayout")
        ElementLayout.Padding = UDim.new(0, 10)
        ElementLayout.Parent = ScrollFrame
        
        ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ElementLayout.AbsoluteContentSize.Y)
        end)
        
        -- Tab Button Click Handler
        TabButton.MouseButton1Click:Connect(function()
            for _, Frame in pairs(TabContentFrame:GetChildren()) do
                if Frame:IsA("Frame") and Frame.Name ~= "UIListLayout" then
                    Frame.Visible = false
                end
            end
            TabFrame.Visible = true
            
            -- Change button color
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                end
            end
            TabButton.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
        end)
        
        -- Button Element
        function Tab:Button(Config)
            Config = Config or {}
            local Title = Config.Title or "Button"
            local Desc = Config.Desc or ""
            local Callback = Config.Callback or function() end
            
            local Element = Instance.new("Frame")
            Element.Name = Title
            Element.Size = UDim2.new(1, 0, 0, 65)
            Element.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Element.BorderSizePixel = 0
            Element.Parent = ScrollFrame
            
            local ElementCorner = Instance.new("UICorner")
            ElementCorner.CornerRadius = UDim.new(0, 8)
            ElementCorner.Parent = Element
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = Title
            TitleLabel.Parent = Element
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
            DescLabel.Position = UDim2.new(0, 0, 0.5, 0)
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            DescLabel.TextSize = 12
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Text = Desc
            DescLabel.Parent = Element
            
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0.25, 0, 0, 35)
            Button.Position = UDim2.new(0.7, 0, 0.15, 0)
            Button.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 12
            Button.Font = Enum.Font.GothamBold
            Button.Text = "Activate"
            Button.BorderSizePixel = 0
            Button.Parent = Element
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(Callback)
            
            return Element
        end
        
        -- Dropdown Element
        function Tab:Dropdown(Config)
            Config = Config or {}
            local Title = Config.Title or "Dropdown"
            local Desc = Config.Desc or ""
            local Values = Config.Values or {}
            local Value = Config.Value or Values[1]
            local Callback = Config.Callback or function() end
            
            local Element = Instance.new("Frame")
            Element.Name = Title
            Element.Size = UDim2.new(1, 0, 0, 65)
            Element.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Element.BorderSizePixel = 0
            Element.Parent = ScrollFrame
            
            local ElementCorner = Instance.new("UICorner")
            ElementCorner.CornerRadius = UDim.new(0, 8)
            ElementCorner.Parent = Element
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = Title
            TitleLabel.Parent = Element
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
            DescLabel.Position = UDim2.new(0, 0, 0.5, 0)
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            DescLabel.TextSize = 12
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Text = Desc
            DescLabel.Parent = Element
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0.35, 0, 0, 35)
            DropdownButton.Position = UDim2.new(0.6, 0, 0.15, 0)
            DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownButton.TextSize = 12
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.Text = Value
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Parent = Element
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownButton
            
            local DropdownMenu = Instance.new("Frame")
            DropdownMenu.Name = "DropdownMenu"
            DropdownMenu.Size = UDim2.new(0.35, 0, 0, #Values * 25)
            DropdownMenu.Position = UDim2.new(0.6, 0, 1, 5)
            DropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            DropdownMenu.BorderSizePixel = 0
            DropdownMenu.Visible = false
            DropdownMenu.ZIndex = 100
            DropdownMenu.Parent = Element
            
            local MenuCorner = Instance.new("UICorner")
            MenuCorner.CornerRadius = UDim.new(0, 6)
            MenuCorner.Parent = DropdownMenu
            
            local MenuLayout = Instance.new("UIListLayout")
            MenuLayout.Padding = UDim.new(0, 0)
            MenuLayout.Parent = DropdownMenu
            
            for _, option in pairs(Values) do
                local MenuItem = Instance.new("TextButton")
                MenuItem.Size = UDim2.new(1, 0, 0, 25)
                MenuItem.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                MenuItem.TextColor3 = Color3.fromRGB(200, 200, 220)
                MenuItem.TextSize = 11
                MenuItem.Font = Enum.Font.Gotham
                MenuItem.Text = option
                MenuItem.BorderSizePixel = 0
                MenuItem.Parent = DropdownMenu
                
                MenuItem.MouseButton1Click:Connect(function()
                    DropdownButton.Text = option
                    DropdownMenu.Visible = false
                    Callback(option)
                end)
                
                MenuItem.MouseEnter:Connect(function()
                    MenuItem.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
                end)
                
                MenuItem.MouseLeave:Connect(function()
                    MenuItem.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                end)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                DropdownMenu.Visible = not DropdownMenu.Visible
            end)
            
            return Element
        end
        
        -- Toggle Element
        function Tab:Toggle(Config)
            Config = Config or {}
            local Title = Config.Title or "Toggle"
            local Desc = Config.Desc or ""
            local Value = Config.Value or false
            local Callback = Config.Callback or function() end
            
            local Element = Instance.new("Frame")
            Element.Name = Title
            Element.Size = UDim2.new(1, 0, 0, 65)
            Element.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Element.BorderSizePixel = 0
            Element.Parent = ScrollFrame
            
            local ElementCorner = Instance.new("UICorner")
            ElementCorner.CornerRadius = UDim.new(0, 8)
            ElementCorner.Parent = Element
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = Title
            TitleLabel.Parent = Element
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
            DescLabel.Position = UDim2.new(0, 0, 0.5, 0)
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            DescLabel.TextSize = 12
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Text = Desc
            DescLabel.Parent = Element
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(0.25, 0, 0, 25)
            ToggleFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
            ToggleFrame.BackgroundColor3 = Value and Color3.fromRGB(70, 150, 100) or Color3.fromRGB(100, 100, 120)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = Element
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0.5, 0)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0.4, 0, 1, 0)
            ToggleButton.Position = Value and UDim2.new(0.6, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.TextTransparency = 1
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Parent = ToggleFrame
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0.5, 0)
            ButtonCorner.Parent = ToggleButton
            
            local Toggled = Value
            
            ToggleButton.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                ToggleFrame.BackgroundColor3 = Toggled and Color3.fromRGB(70, 150, 100) or Color3.fromRGB(100, 100, 120)
                
                local TweenService = game:GetService("TweenService")
                local Tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {Position = Toggled and UDim2.new(0.6, 0, 0, 0) or UDim2.new(0, 0, 0, 0)})
                Tween:Play()
                
                Callback(Toggled)
            end)
            
            return Element
        end
        
        -- Slider Element
        function Tab:Slider(Config)
            Config = Config or {}
            local Title = Config.Title or "Slider"
            local Desc = Config.Desc or ""
            local Step = Config.Step or 1
            local Value = Config.Value or {}
            local Min = Value.Min or 0
            local Max = Value.Max or 100
            local Default = Value.Default or Min
            local Callback = Config.Callback or function() end
            
            local Element = Instance.new("Frame")
            Element.Name = Title
            Element.Size = UDim2.new(1, 0, 0, 80)
            Element.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Element.BorderSizePixel = 0
            Element.Parent = ScrollFrame
            
            local ElementCorner = Instance.new("UICorner")
            ElementCorner.CornerRadius = UDim.new(0, 8)
            ElementCorner.Parent = Element
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = Title
            TitleLabel.Parent = Element
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
            ValueLabel.Position = UDim2.new(0.65, 0, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = Color3.fromRGB(70, 150, 200)
            ValueLabel.TextSize = 14
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Text = tostring(Default)
            ValueLabel.Parent = Element
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, 0, 0.3, 0)
            DescLabel.Position = UDim2.new(0, 0, 0.35, 0)
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            DescLabel.TextSize = 11
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Text = Desc
            DescLabel.Parent = Element
            
            local SliderBackground = Instance.new("Frame")
            SliderBackground.Size = UDim2.new(0.8, 0, 0, 4)
            SliderBackground.Position = UDim2.new(0, 0, 0.65, 0)
            SliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            SliderBackground.BorderSizePixel = 0
            SliderBackground.Parent = Element
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(70, 150, 200)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBackground
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(0, 14, 0, 14)
            SliderButton.Position = UDim2.new((Default - Min) / (Max - Min), -7, 0.5, -7)
            SliderButton.BackgroundColor3 = Color3.fromRGB(70, 150, 200)
            SliderButton.TextTransparency = 1
            SliderButton.BorderSizePixel = 0
            SliderButton.Parent = SliderBackground
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0.5, 0)
            ButtonCorner.Parent = SliderButton
            
            local Dragging = false
            
            SliderButton.MouseButton1Down:Connect(function()
                Dragging = true
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(Input)
                if Dragging then
                    local Mouse = game:GetService("Mouse")
                    local SliderPos = SliderBackground.AbsolutePosition.X
                    local SliderSize = SliderBackground.AbsoluteSize.X
                    local MousePos = Mouse.X - SliderPos
                    
                    local Percentage = math.max(0, math.min(1, MousePos / SliderSize))
                    local Value = Min + (Max - Min) * Percentage
                    Value = math.round(Value / Step) * Step
                    
                    SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
                    SliderButton.Position = UDim2.new(Percentage, -7, 0.5, -7)
                    ValueLabel.Text = tostring(Value)
                    
                    Callback(Value)
                end
            end)
            
            return Element
        end
        
        -- Input Element
        function Tab:Input(Config)
            Config = Config or {}
            local Title = Config.Title or "Input"
            local Desc = Config.Desc or ""
            local Value = Config.Value or ""
            local Placeholder = Config.Placeholder or "Enter text..."
            local InputType = Config.Type or "Input"
            local Callback = Config.Callback or function() end
            
            local Element = Instance.new("Frame")
            Element.Name = Title
            Element.Size = UDim2.new(1, 0, 0, InputType == "Textarea" and 120 or 75)
            Element.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Element.BorderSizePixel = 0
            Element.Parent = ScrollFrame
            
            local ElementCorner = Instance.new("UICorner")
            ElementCorner.CornerRadius = UDim.new(0, 8)
            ElementCorner.Parent = Element
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, 0, 0.3, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = Title
            TitleLabel.Parent = Element
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, 0, 0.2, 0)
            DescLabel.Position = UDim2.new(0, 0, 0.25, 0)
            DescLabel.BackgroundTransparency = 1
            DescLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            DescLabel.TextSize = 11
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Text = Desc
            DescLabel.Parent = Element
            
            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(1, -10, InputType == "Textarea" and 0.5 or 0.35, 0)
            InputBox.Position = UDim2.new(0, 5, InputType == "Textarea" and 0.45 or 0.55, 0)
            InputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.TextSize = 13
            InputBox.Font = Enum.Font.Gotham
            InputBox.PlaceholderText = Placeholder
            InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
            InputBox.Text = Value
            InputBox.ClearTextOnFocus = false
            InputBox.MultiLine = InputType == "Textarea"
            InputBox.BorderSizePixel = 0
            InputBox.Parent = Element
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 6)
            InputCorner.Parent = InputBox
            
            InputBox.FocusLost:Connect(function(EnterPressed)
                if EnterPressed then
                    Callback(InputBox.Text)
                end
            end)
            
            InputBox.Changed:Connect(function()
                Callback(InputBox.Text)
            end)
            
            return Element
        end
        
        table.insert(self.Tabs, Tab)
        return Tab
    end
    
    Window.MainFrame = MainFrame
    table.insert(self.Windows, Window)
    
    return Window
end

return UILibrary.new()
