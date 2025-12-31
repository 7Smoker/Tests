local runService = game:GetService('RunService')
local playerService = game:GetService('Players')
local httpService = game:GetService('HttpService')
local textService = game:GetService('TextService')
local tweenService = game:GetService('TweenService')
local userInputService = game:GetService('UserInputService')

local localEntity = playerService.LocalPlayer

local createMaid = function(tab)
	if typeof(tab) ~= 'table' then
		print('not a table')
		return
	end
	if table.isfrozen(tab) then
		print('table frozen')
		return
	end

	tab.collection = {}

	function tab:Clean(t, f)
		if typeof(t) == 'RBXScriptConnection' then
			table.insert(self.collection, t)
		elseif t and typeof(t) == 'function' then
			table.insert(self.collection, runService.Heartbeat:Connect(t))
		elseif t and f and typeof(f) == 'function' then
			table.insert(self.collection, t:Connect(f))
		else
			table.insert(self.collection, t)
		end
	end

	function tab:CleanTable()
		for i,v in self.collection do
			if typeof(v) == 'RBXScriptConnection' then
				v:Disconnect()
			else
				v:Destroy()
			end
		end
	end

	return tab
end

local guiLibrary = createMaid({
	connections = {},
	windows = {},
	api = {},

	theme = {
		color1 = Color3.fromRGB(200, 90, 255),
		color2 = Color3.fromRGB(90, 90, 255),

		changed = Instance.new('BindableEvent'),
		dropdownstyle = 1,
	},

	placeId = game.PlaceId,
})

local config, cfg = {}, {}
function cfg.save()
	if runService:IsStudio() then
		return
	end

	writefile('Nova/Configs/'..game.PlaceId..'.json', httpService:JSONEncode(config))
end

if not runService:IsStudio() and isfile('Nova/Configs/'..game.PlaceId..'.json') then
	config = httpService:JSONDecode(readfile('Nova/Configs/'..game.PlaceId..'.json'))
end

local screenGui = Instance.new('ScreenGui')
screenGui.Parent = localEntity.PlayerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
local uiScale = Instance.new('UIScale')
uiScale.Parent = screenGui
uiScale.Scale = math.max(screenGui.AbsoluteSize.X / 1920, 0.8)
local clickGuiFrame = Instance.new('Frame')
clickGuiFrame.Parent = screenGui
clickGuiFrame.Position = UDim2.fromOffset(100, 100)
clickGuiFrame.Size = UDim2.fromScale(1, 1)
clickGuiFrame.BackgroundTransparency = 1
local arrayListFrame = Instance.new('Frame')
arrayListFrame.Parent = screenGui
arrayListFrame.Position = UDim2.fromScale(0.7, 0.05)
arrayListFrame.Size = UDim2.fromScale(0.295, 0.7)
arrayListFrame.BackgroundTransparency = 1
local arrayListSort = Instance.new('UIListLayout')
arrayListSort.Parent = arrayListFrame
arrayListSort.SortOrder = Enum.SortOrder.LayoutOrder
arrayListSort.HorizontalAlignment = Enum.HorizontalAlignment.Right
arrayListSort.VerticalAlignment = Enum.VerticalAlignment.Top

guiLibrary:Clean(userInputService.InputBegan, function(input: InputObject)
	if not userInputService:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.RightShift then
		clickGuiFrame.Visible = not clickGuiFrame.Visible
	end
end)

local aids = 0
function guiLibrary.api.createCoolEffect(par)
	local Frame = Instance.new('Frame')
	Frame.Parent = par
	Frame.Size = UDim2.fromScale(0, 1)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	tweenService:Create(Frame, TweenInfo.new(1), {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}):Play()
	task.delay(1.1, function()
		Frame:Destroy()
		Frame = nil
	end)
end
function guiLibrary.api.recieveTab(Name: string)
	if guiLibrary.windows[Name] then
		return guiLibrary.windows[Name]
	else
		return warn('Tab does not exist.')
	end
end
function guiLibrary.api.createTab(Name: string)
	local Frame = Instance.new('Frame')
	Frame.Parent = clickGuiFrame
	Frame.Position = UDim2.fromOffset(0 + (aids * 210), 0)
	Frame.Size = UDim2.fromOffset(205, 30)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	local FrameName = Instance.new('TextLabel')
	FrameName.Parent = Frame
	FrameName.Size = UDim2.fromScale(1, 1)
	FrameName.BackgroundTransparency = 1
	FrameName.TextXAlignment = Enum.TextXAlignment.Left
	FrameName.TextStrokeTransparency = 0.5
	FrameName.TextColor3 = Color3.fromRGB(255, 255, 255)
	FrameName.TextSize = 22
	FrameName.Text = '  ' .. Name
	FrameName.Font = Enum.Font.SourceSans
	local FrameCount = Instance.new('TextLabel')
	FrameCount.Parent = Frame
	FrameCount.Size = UDim2.fromScale(1, 1)
	FrameCount.BackgroundTransparency = 1
	FrameCount.TextXAlignment = Enum.TextXAlignment.Right
	FrameCount.TextStrokeTransparency = 0.5
	FrameCount.TextColor3 = Color3.fromRGB(255, 255, 255)
	FrameCount.TextSize = 22
	FrameCount.Text = '[0]  '
	FrameCount.Font = Enum.Font.SourceSans
	local ModulesFrame = Instance.new('Frame')
	ModulesFrame.Parent = Frame
	ModulesFrame.Position = UDim2.fromScale(0, 1)
	ModulesFrame.Size = UDim2.fromScale(1, 0)
	ModulesFrame.AutomaticSize = Enum.AutomaticSize.Y
	ModulesFrame.BackgroundTransparency = 1
	local ModulesSort = Instance.new('UIListLayout')
	ModulesSort.Parent = ModulesFrame
	ModulesSort.SortOrder = Enum.SortOrder.LayoutOrder
	local currModules = 0

	aids += 1

	guiLibrary.windows[Name] = {
		modules = {},
		createModule = function(self, Table)
			if not config[Table.Name] then
				config[Table.Name] = {
					enabled = Table.Default::boolean and true or false,
					keybind = 'Unknown',
					toggles = {},
					sliders = {},
					textboxs = {},
					selectors = {},
				}
			end
			
			currModules += 1
			FrameCount.Text = '['..currModules..']  '

			local ModuleFrame = Instance.new('Frame')
			ModuleFrame.Parent = ModulesFrame
			ModuleFrame.Size = UDim2.new(1, 0, 0, 30)
			ModuleFrame.BorderSizePixel = 0
			ModuleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			local PopupFrame = Instance.new('Frame')
			PopupFrame.Parent = ModuleFrame
			PopupFrame.Size = UDim2.fromScale(0, 1)
			PopupFrame.BorderSizePixel = 0
			PopupFrame.BackgroundColor3 = guiLibrary.theme.color1
			local ModuleName = Instance.new('TextButton')
			ModuleName.Parent = ModuleFrame
			ModuleName.Size = UDim2.fromScale(1, 1)
			ModuleName.BackgroundTransparency = 1
			ModuleName.TextXAlignment = Enum.TextXAlignment.Left
			ModuleName.TextStrokeTransparency = 0.5
			ModuleName.TextColor3 = Color3.fromRGB(255, 255, 255)
			ModuleName.TextSize = 20
			ModuleName.Text = '   ' .. Table.Name::string
			ModuleName.Font = Enum.Font.SourceSans
			local DropdownFrame = Instance.new('Frame')
			DropdownFrame.Parent = ModulesFrame
			DropdownFrame.Size = UDim2.fromScale(1, 0)
			DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
			DropdownFrame.BackgroundTransparency = 1
			DropdownFrame.Visible = false
			local DropdownSort = Instance.new('UIListLayout')
			DropdownSort.Parent = DropdownFrame
			DropdownSort.SortOrder = Enum.SortOrder.LayoutOrder

			local ModuleReturn = createMaid({enabled = false})			
			function ModuleReturn:toggle(silent: boolean)
				self.enabled = not self.enabled
				config[Table.Name].enabled = self.enabled

				tweenService:Create(PopupFrame, TweenInfo.new(0.5), {
					Size = self.enabled and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 1)
				}):Play()

				if not self.enabled then
					self:CleanTable()
				end
				if Table.Function then
					task.spawn(Table.Function, self.enabled)
				end

				cfg.save()
			end

			function ModuleReturn.createToggle(Tab)
				if not config[Table.Name].toggles[Tab.Name] then
					config[Table.Name].toggles[Tab.Name] = {enabled = false}
				end

				local ToggleFrame = Instance.new('Frame')
				ToggleFrame.Parent = DropdownFrame
				ToggleFrame.Size = UDim2.new(1, 0, 0, 27)
				ToggleFrame.BorderSizePixel = 0
				ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				local ToggleName = Instance.new('TextButton')
				ToggleName.Parent = ToggleFrame
				ToggleName.Size = UDim2.fromScale(1, 1)
				ToggleName.BackgroundTransparency = 1
				ToggleName.TextXAlignment = Enum.TextXAlignment.Left
				ToggleName.TextStrokeTransparency = 0.75
				ToggleName.TextColor3 = Color3.fromRGB(200, 200, 200)
				ToggleName.TextSize = 20
				ToggleName.Text = '   ' .. Tab.Name
				ToggleName.Font = Enum.Font.SourceSans
				local ToggleCircle = Instance.new('Frame')
				ToggleCircle.Parent = ToggleFrame
				ToggleCircle.Position = UDim2.new(1, -25, 0.5, 0)
				ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
				ToggleCircle.Size = UDim2.fromOffset(18, 18)
				ToggleCircle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				local ToggleCorner = Instance.new('UICorner')
				ToggleCorner.Parent = ToggleCircle
				ToggleCorner.CornerRadius = UDim.new(1, 0)
				local ToggleStroke = Instance.new('UIStroke')
				ToggleStroke.Parent = ToggleCircle
				ToggleStroke.Color = Color3.fromRGB(0, 0, 0)
				ToggleStroke.Transparency = 0.65

				local ToggleReturn = createMaid({enabled = false})
				function ToggleReturn:toggle()
					self.enabled = not self.enabled
					config[Table.Name].toggles[Tab.Name].enabled = self.enabled

					tweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
						BackgroundColor3 = self.enabled and guiLibrary.theme.color1 or Color3.fromRGB(50, 50, 50)
					}):Play()

					if Tab.Function then
						task.spawn(Tab.Function, self.enabled)
					end

					cfg.save()
				end

				table.insert(guiLibrary.connections, ToggleName.MouseButton1Down:Connect(function()
					ToggleReturn:toggle()
				end))
				table.insert(guiLibrary.connections, guiLibrary.theme.changed.Event:Connect(function()
					if ToggleReturn.enabled then
						ToggleCircle.BackgroundColor3 = guiLibrary.theme.color1
					end
				end))

				if config[Table.Name].toggles[Tab.Name].enabled then
					ToggleReturn:toggle()
				end

				return ToggleReturn
			end
			
			function ModuleReturn.createSelector(Tab)
				if not config[Table.Name].selectors[Tab.Name] then
					config[Table.Name].selectors[Tab.Name] = {value = Tab.Default or Tab.Selections[1]}
				end

				local SelectorFrame = Instance.new('Frame')
				SelectorFrame.Parent = DropdownFrame
				SelectorFrame.Size = UDim2.new(1, 0, 0, 27)
				SelectorFrame.BorderSizePixel = 0
				SelectorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				local SelectorName = Instance.new('TextButton')
				SelectorName.Parent = SelectorFrame
				SelectorName.Size = UDim2.fromScale(1, 1)
				SelectorName.BackgroundTransparency = 1
				SelectorName.TextXAlignment = Enum.TextXAlignment.Left
				SelectorName.TextStrokeTransparency = 0.75
				SelectorName.TextColor3 = Color3.fromRGB(200, 200, 200)
				SelectorName.TextSize = 20
				SelectorName.Text = '   ' .. Tab.Name
				SelectorName.Font = Enum.Font.SourceSans
				local SelectorSelected = Instance.new('TextLabel')
				SelectorSelected.Parent = SelectorFrame
				SelectorSelected.Size = UDim2.fromScale(1, 1)
				SelectorSelected.BackgroundTransparency = 1
				SelectorSelected.TextXAlignment = Enum.TextXAlignment.Right
				SelectorSelected.TextStrokeTransparency = 0.75
				SelectorSelected.TextColor3 = Color3.fromRGB(255, 255, 255)
				SelectorSelected.TextSize = 20
				SelectorSelected.Text =  config[Table.Name].selectors[Tab.Name].value .. '   '
				SelectorSelected.Font = Enum.Font.SourceSans

				local SelectorReturn = {value = config[Table.Name].selectors[Tab.Name].value}
				function SelectorReturn:Select(thingy: string)
					self.value = thingy
					config[Table.Name].selectors[Tab.Name].value = self.value

					SelectorSelected.Text =  self.value .. '   '

					cfg.save()
				end

				local Index = 1
				for i,v in Tab.Selections do
					if v == SelectorReturn.value then
						Index = i
						break
					end
				end

				table.insert(guiLibrary.connections, SelectorName.MouseButton1Down:Connect(function()
					Index += 1

					if Index > #Tab.Selections then
						Index = 1
					end

					SelectorReturn:Select(Tab.Selections[Index])
				end))

				table.insert(guiLibrary.connections, SelectorName.MouseButton2Down:Connect(function()
					Index -= 1

					if Index < 1 then
						Index = #Tab.Selections
					end

					SelectorReturn:Select(Tab.Selections[Index])
				end))

				return SelectorReturn
			end
			
			function ModuleReturn.createSlider(Tab)
				if not config[Table.Name].sliders[Tab.Name] then
					config[Table.Name].sliders[Tab.Name] = {value = Tab.Default or Tab.Minimum}
				end

				local SliderFrame = Instance.new('Frame')
				SliderFrame.Parent = DropdownFrame
				SliderFrame.Size = UDim2.new(1, 0, 0, 40)
				SliderFrame.BorderSizePixel = 0
				SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				local SliderName = Instance.new('TextButton')
				SliderName.Parent = SliderFrame
				SliderName.Size = UDim2.new(1, 0, 0, 27)
				SliderName.BackgroundTransparency = 1
				SliderName.TextXAlignment = Enum.TextXAlignment.Left
				SliderName.TextStrokeTransparency = 0.75
				SliderName.TextColor3 = Color3.fromRGB(200, 200, 200)
				SliderName.TextSize = 20
				SliderName.Text = '   ' .. Tab.Name
				SliderName.Font = Enum.Font.SourceSans
				local SliderValue = Instance.new('TextLabel')
				SliderValue.Parent = SliderFrame
				SliderValue.Size = UDim2.new(1, 0, 0, 27)
				SliderValue.BackgroundTransparency = 1
				SliderValue.TextXAlignment = Enum.TextXAlignment.Right
				SliderValue.TextStrokeTransparency = 0.75
				SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
				SliderValue.TextSize = 20
				SliderValue.Text =  '['..config[Table.Name].sliders[Tab.Name].value .. ']   '
				SliderValue.Font = Enum.Font.SourceSans
				local SliderBGFrame = Instance.new('Frame')
				SliderBGFrame.Parent = SliderFrame
				SliderBGFrame.Position = UDim2.fromOffset(9, 28)
				SliderBGFrame.Size = UDim2.new(1, -18, 0, 5)
				SliderBGFrame.BorderSizePixel = 1
				SliderBGFrame.BorderColor3 = Color3.fromRGB(30, 30, 30)
				SliderBGFrame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
				local SliderFillIn = Instance.new('Frame')
				SliderFillIn.Parent = SliderBGFrame
				SliderFillIn.Size = UDim2.fromScale(1, 1)
				SliderFillIn.BorderSizePixel = 0
				SliderFillIn.BackgroundColor3 = guiLibrary.theme.color1
				local SliderDot = Instance.new('Frame')
				SliderDot.Parent = SliderFillIn
				SliderDot.Position = UDim2.fromScale(1, 0.5)
				SliderDot.AnchorPoint = Vector2.new(0.5, 0.5)
				SliderDot.Size = UDim2.fromOffset(8, 8)
				SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Instance.new('UICorner', SliderDot).CornerRadius = UDim.new(1, 0)
				Instance.new('UIStroke', SliderDot).Color = Color3.fromRGB(30, 30, 30)
				
				Tab.Step = (Tab.Step or 1)
				
				local SliderReturn = createMaid({value = config[Table.Name].sliders[Tab.Name].value})
				function SliderReturn:Set(val)
					val = math.clamp(math.floor(val / Tab.Step + 0.5) * Tab.Step, Tab.Minimum, Tab.Maximum)
					
					config[Table.Name].sliders[Tab.Name].value = val
					local percent = (val - Tab.Minimum) / (Tab.Maximum - Tab.Minimum)
					SliderValue.Text = "["..val.."]  "
					SliderReturn.value = val
					tweenService:Create(SliderFillIn, TweenInfo.new(0.25), {Size = UDim2.fromScale(percent, 1)}):Play()

					cfg.save()
				end
				
				local Dragging = false
				table.insert(guiLibrary.connections, SliderBGFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
					end
				end))

				table.insert(guiLibrary.connections, userInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
					end
				end))

				table.insert(guiLibrary.connections, runService.RenderStepped:Connect(function()
					if Dragging then
						local mouse = userInputService:GetMouseLocation().X
						local absPos = SliderBGFrame.AbsolutePosition.X
						local absSize = SliderBGFrame.AbsoluteSize.X
						local percent = math.clamp((mouse - absPos) / absSize, 0, 1)
						local val = Tab.Minimum + (Tab.Maximum - Tab.Minimum) * percent
						
						SliderReturn:Set(val)
					end
				end))

				SliderReturn:Set(config[Table.Name].sliders[Tab.Name].value)
				
				table.insert(guiLibrary.connections, guiLibrary.theme.changed.Event:Connect(function()
					SliderFillIn.BackgroundColor3 = guiLibrary.theme.color1
				end))

				return
			end

			local hovering = false
			table.insert(guiLibrary.connections, guiLibrary.theme.changed.Event:Connect(function()
				PopupFrame.BackgroundColor3 = guiLibrary.theme.color1
			end))
			table.insert(guiLibrary.connections, ModuleFrame.MouseEnter:Connect(function()
				hovering = true
			end))
			table.insert(guiLibrary.connections, ModuleFrame.MouseLeave:Connect(function()
				hovering = false
			end))
			table.insert(guiLibrary.connections, userInputService.InputBegan:Connect(function(input)
				if not userInputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name == config[Table.Name].keybind then
					ModuleReturn:toggle(false)
				end

				if not userInputService:GetFocusedTextBox() and input.UserInputType == Enum.UserInputType.MouseButton3 and hovering then
					local conn; conn = userInputService.InputBegan:Connect(function(input2)
						if input2.KeyCode ~= Enum.KeyCode.Unknown then
							task.wait()
							if input2.KeyCode.Name == config[Table.Name].keybind then
								config[Table.Name].keybind = 'Unknown'
								ModuleName.Text = '   ' .. Table.Name::string
								cfg.save()
								conn:Disconnect()
								
								return
							end

							config[Table.Name].keybind = input2.KeyCode.Name
							ModuleName.Text = '   ['..config[Table.Name].keybind..'] ' .. Table.Name::string
							cfg.save()
							conn:Disconnect()
						end
					end)
				end
			end))
			table.insert(guiLibrary.connections, ModuleName.MouseButton1Down:Connect(function()
				ModuleReturn:toggle(false)
			end))
			table.insert(guiLibrary.connections, ModuleName.MouseButton2Down:Connect(function()
				DropdownFrame.Visible = not DropdownFrame.Visible
				guiLibrary.api.createCoolEffect(ModuleName)
			end))

			if config[Table.Name].enabled then
				ModuleReturn:toggle(true)
			end

			self.modules[Table.Name] = ModuleReturn

			return ModuleReturn
		end,
	}

	return guiLibrary.windows[Name]
end
