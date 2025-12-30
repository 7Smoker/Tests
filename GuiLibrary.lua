local library = {}
library.Flags = {}
library.DefaultColor = Color3.fromRGB(56, 66, 207)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local DataFolder = "Nova/Data"

local function ensureFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end
ensureFolder("Nova")
ensureFolder(DataFolder)

local GameId = tostring(game.PlaceId)
local ConfigFile = DataFolder.."/"..GameId..".json"

local function loadConfig()
    if isfile(ConfigFile) then
        local content = readfile(ConfigFile)
        local success, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and type(data) == "table" then
            for k,v in pairs(data) do
                library.Flags[k] = v
            end
        end
    end
end

local function saveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(library.Flags))
end

loadConfig()

function library:GetXY(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px/Max, Py/May
end

function library:Window(Info)
	Info.Text = Info.Text or "Nova"
	local window = {}
	
	local NovaGui = Instance.new("ScreenGui")
	NovaGui.Name = "Nova"
	NovaGui.Parent = game:GetService("CoreGui")
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.BackgroundColor3 = Color3.fromRGB(36,36,36)
	mainFrame.Position = UDim2.fromScale(0.3,0.3)
	mainFrame.Size = UDim2.fromOffset(300,400)
	mainFrame.Parent = NovaGui
	
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0,6)
	uICorner.Parent = mainFrame
	
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.BackgroundColor3 = Color3.fromRGB(29,29,29)
	topbar.Size = UDim2.new(1,0,0,30)
	topbar.Parent = mainFrame
	
	local topbarText = Instance.new("TextLabel")
	topbarText.Text = Info.Text
	topbarText.TextColor3 = Color3.fromRGB(214,214,214)
	topbarText.TextSize = 14
	topbarText.Font = Enum.Font.GothamBold
	topbarText.BackgroundTransparency = 1
	topbarText.Size = UDim2.new(1,0,1,0)
	topbarText.Parent = topbar
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(214,214,214)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Size = UDim2.new(0,30,1,0)
	closeBtn.Position = UDim2.new(1,-30,0,0)
	closeBtn.Parent = topbar
	closeBtn.MouseButton1Click:Connect(function()
		NovaGui:Destroy()
	end)
	
	local dragging = false
	local dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
	
	local tabsContainer = Instance.new("Frame")
	tabsContainer.Name = "TabsContainer"
	tabsContainer.Size = UDim2.new(0,80,1,-30)
	tabsContainer.Position = UDim2.new(0,0,0,30)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = mainFrame
	
	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Padding = UDim.new(0,2)
	tabsLayout.Parent = tabsContainer
	
	local modulesContainer = Instance.new("Frame")
	modulesContainer.Name = "ModulesContainer"
	modulesContainer.Size = UDim2.new(1,-80,1,-30)
	modulesContainer.Position = UDim2.new(0,80,0,30)
	modulesContainer.BackgroundTransparency = 1
	modulesContainer.Parent = mainFrame
	
	local activeTab = nil
	
	function window:Tab(TabName)
		local tab = {}
		local tabButton = Instance.new("TextButton")
		tabButton.Text = TabName
		tabButton.TextColor3 = Color3.fromRGB(214,214,214)
		tabButton.TextSize = 13
		tabButton.Font = Enum.Font.GothamBold
		tabButton.Size = UDim2.new(1,0,0,30)
		tabButton.Parent = tabsContainer
		
		local tabModules = Instance.new("Frame")
		tabModules.Size = UDim2.new(1,0,1,0)
		tabModules.BackgroundTransparency = 1
		tabModules.Visible = false
		tabModules.Parent = modulesContainer
		
		tabButton.MouseButton1Click:Connect(function()
			if activeTab then activeTab.Visible = false end
			tabModules.Visible = true
			activeTab = tabModules
		end)
		
		function tab:Button(Info)
			Info.Text = Info.Text or "Button"
			local btn = Instance.new("TextButton")
			btn.Text = Info.Text
			btn.TextColor3 = Color3.fromRGB(214,214,214)
			btn.TextSize = 13
			btn.Font = Enum.Font.GothamBold
			btn.Size = UDim2.new(1,0,0,30)
			btn.Parent = tabModules
			btn.MouseButton1Click:Connect(function()
				pcall(Info.Callback)
			end)
		end
		
		function tab:Toggle(Info)
			Info.Text = Info.Text or "Toggle"
			Info.Flag = Info.Flag or Info.Text
			Info.Default = Info.Default or false
			library.Flags[Info.Flag] = library.Flags[Info.Flag] ~= nil and library.Flags[Info.Flag] or Info.Default
			
			local toggleFrame = Instance.new("Frame")
			toggleFrame.Size = UDim2.new(1,0,0,30)
			toggleFrame.BackgroundTransparency = 1
			toggleFrame.Parent = tabModules
			
			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Text = Info.Text .. (library.Flags[Info.Flag] and " [ON]" or " [OFF]")
			toggleBtn.TextColor3 = Color3.fromRGB(214,214,214)
			toggleBtn.Font = Enum.Font.GothamBold
			toggleBtn.TextSize = 13
			toggleBtn.BackgroundTransparency = 1
			toggleBtn.Size = UDim2.new(1,0,1,0)
			toggleBtn.Parent = toggleFrame
			
			local state = library.Flags[Info.Flag]
			toggleBtn.MouseButton1Click:Connect(function()
				state = not state
				library.Flags[Info.Flag] = state
				toggleBtn.Text = Info.Text .. (state and " [ON]" or " [OFF]")
				pcall(Info.Callback, state)
				saveConfig()
			end)
		end
		
		function tab:Slider(Info)
			Info.Text = Info.Text or "Slider"
			Info.Flag = Info.Flag or Info.Text
			Info.Min = Info.Min or 0
			Info.Max = Info.Max or 100
			Info.Default = Info.Default or Info.Min
			library.Flags[Info.Flag] = library.Flags[Info.Flag] ~= nil and library.Flags[Info.Flag] or Info.Default
			
			local sliderFrame = Instance.new("Frame")
			sliderFrame.Size = UDim2.new(1,0,0,30)
			sliderFrame.BackgroundTransparency = 1
			sliderFrame.Parent = tabModules
			
			local sliderText = Instance.new("TextLabel")
			sliderText.Text = Info.Text.." ["..library.Flags[Info.Flag].."]"
			sliderText.Size = UDim2.new(1,0,1,0)
			sliderText.TextColor3 = Color3.fromRGB(214,214,214)
			sliderText.Font = Enum.Font.GothamBold
			sliderText.TextSize = 13
			sliderText.BackgroundTransparency = 1
			sliderText.Parent = sliderFrame
			
			local dragging = false
			local sliderBar = Instance.new("Frame")
			sliderBar.Size = UDim2.new(1,0,1,0)
			sliderBar.BackgroundTransparency = 1
			sliderBar.Parent = sliderFrame
			
			sliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			
			sliderBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local x = math.clamp((Mouse.X - sliderBar.AbsolutePosition.X)/sliderBar.AbsoluteSize.X,0,1)
					local value = math.floor(Info.Min + (Info.Max - Info.Min)*x)
					library.Flags[Info.Flag] = value
					sliderText.Text = Info.Text.." ["..value.."]"
					pcall(Info.Callback,value)
					saveConfig()
				end
			end)
		end
		
		function tab:Dropdown(Info)
			Info.Text = Info.Text or "Dropdown"
			Info.Flag = Info.Flag or Info.Text
			Info.List = Info.List or {}
			Info.Default = Info.Default or Info.List[1]
			library.Flags[Info.Flag] = library.Flags[Info.Flag] ~= nil and library.Flags[Info.Flag] or Info.Default
			
			local dropdownFrame = Instance.new("Frame")
			dropdownFrame.Size = UDim2.new(1,0,0,30)
			dropdownFrame.BackgroundTransparency = 1
			dropdownFrame.Parent = tabModules
			
			local dropdownBtn = Instance.new("TextButton")
			dropdownBtn.Text = Info.Text.." ["..library.Flags[Info.Flag].."]"
			dropdownBtn.Size = UDim2.new(1,0,1,0)
			dropdownBtn.TextColor3 = Color3.fromRGB(214,214,214)
			dropdownBtn.Font = Enum.Font.GothamBold
			dropdownBtn.TextSize = 13
			dropdownBtn.BackgroundTransparency = 1
			dropdownBtn.Parent = dropdownFrame
			
			local listFrame = Instance.new("Frame")
			listFrame.Size = UDim2.new(1,0,0,#Info.List*25)
			listFrame.Position = UDim2.new(0,0,1,0)
			listFrame.BackgroundColor3 = Color3.fromRGB(29,29,29)
			listFrame.Visible = false
			listFrame.Parent = dropdownFrame
			
			for i,v in pairs(Info.List) do
				local item = Instance.new("TextButton")
				item.Text = v
				item.Size = UDim2.new(1,0,0,25)
				item.Position = UDim2.new(0,0,0,(i-1)*25)
				item.TextColor3 = Color3.fromRGB(214,214,214)
				item.BackgroundTransparency = 1
				item.Font = Enum.Font.GothamBold
				item.TextSize = 13
				item.Parent = listFrame
				
				item.MouseButton1Click:Connect(function()
					library.Flags[Info.Flag] = v
					dropdownBtn.Text = Info.Text.." ["..v.."]"
					listFrame.Visible = false
					pcall(Info.Callback,v)
					saveConfig()
				end)
			end
			
			dropdownBtn.MouseButton1Click:Connect(function()
				listFrame.Visible = not listFrame.Visible
			end)
		end
		
		function tab:Keybind(Info)
			Info.Text = Info.Text or "Keybind"
			Info.Flag = Info.Flag or Info.Text
			Info.Default = Info.Default or Enum.KeyCode.Unknown
			library.Flags[Info.Flag] = library.Flags[Info.Flag] ~= nil and library.Flags[Info.Flag] or Info.Default
			
			local keyFrame = Instance.new("Frame")
			keyFrame.Size = UDim2.new(1,0,0,30)
			keyFrame.BackgroundTransparency = 1
			keyFrame.Parent = tabModules
			
			local keyBtn = Instance.new("TextButton")
			keyBtn.Text = Info.Text.." ["..library.Flags[Info.Flag].Name.."]"
			keyBtn.Size = UDim2.new(1,0,1,0)
			keyBtn.TextColor3 = Color3.fromRGB(214,214,214)
			keyBtn.Font = Enum.Font.GothamBold
			keyBtn.TextSize = 13
			keyBtn.BackgroundTransparency = 1
			keyBtn.Parent = keyFrame
			
			local waiting = false
			keyBtn.MouseButton1Click:Connect(function()
				waiting = true
				keyBtn.Text = Info.Text.." [Press key]"
			end)
			
			UserInputService.InputBegan:Connect(function(input)
				if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
					library.Flags[Info.Flag] = input.KeyCode
					keyBtn.Text = Info.Text.." ["..input.KeyCode.Name.."]"
					waiting = false
					saveConfig()
				elseif library.Flags[Info.Flag] and input.KeyCode == library.Flags[Info.Flag] then
					pcall(Info.Callback)
				end
			end)
		end
		
		return tab
	end
	
	local arrayList = Instance.new("Frame")
	arrayList.Name = "ArrayList"
	arrayList.Size = UDim2.new(0,150,1,0)
	arrayList.Position = UDim2.new(1,10,0,0)
	arrayList.BackgroundColor3 = Color3.fromRGB(29,29,29)
	arrayList.Parent = NovaGui
	
	local arrayListLayout = Instance.new("UIListLayout")
	arrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	arrayListLayout.Padding = UDim.new(0,2)
	arrayListLayout.Parent = arrayList
	
	function library:UpdateArrayList()
		for i,v in pairs(arrayList:GetChildren()) do
			if v:IsA("TextLabel") then v:Destroy() end
		end
		for k,v in pairs(library.Flags) do
			if v and typeof(v) == "boolean" and v then
				local label = Instance.new("TextLabel")
				label.Text = k
				label.TextColor3 = Color3.fromRGB(214,214,214)
				label.Font = Enum.Font.GothamBold
				label.TextSize = 13
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1,0,0,25)
				label.Parent = arrayList
			end
		end
	end
	
	RunService.RenderStepped:Connect(function()
		library:UpdateArrayList()
	end)
	
	return window
end

return library
