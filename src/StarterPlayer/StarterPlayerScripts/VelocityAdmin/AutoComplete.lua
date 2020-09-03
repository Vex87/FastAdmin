-- // Variables \\ --

local Module = {}

local RunService = game:GetService("RunService")

local Core = require(game.ReplicatedStorage.Core)
local Settings = require(script.Parent.Settings)

local Velocity = require(game.ReplicatedStorage.Velocity)
local Commands = Velocity.Commands

local CommandBar = game.Players.LocalPlayer.PlayerGui:WaitForChild("VelocityAdmin").CommandBar
local TextBox = CommandBar.TextBox
local AutoComplete = CommandBar.AutoComplete
local Hint = CommandBar.Hint

-- // Functions \\ --

function Module.RunAutoComplete(SelectedField)
    local Args = string.split(TextBox.Text, Settings.CommandBar.AutoComplete.ArgSplit)
    table.remove(Args, #Args)
    table.insert(Args, SelectedField.Title.Text)

    TextBox.CursorPosition = 1
    RunService.RenderStepped:Wait()
    TextBox.Text = table.concat(Args, Settings.CommandBar.AutoComplete.ArgSplit) .. Settings.CommandBar.AutoComplete.ArgSplit
    TextBox.CursorPosition = #TextBox.Text + 1
end

function Module.HandleAutoComplete(Step)
    local OldSelectedField
    for _,Field in pairs(Core.Get(AutoComplete, "TextButton")) do
        if Field.IsSelected.Value then
            OldSelectedField = Field
            break
        end
    end

    if OldSelectedField then
        local NewSelectedField = AutoComplete:FindFirstChild(OldSelectedField.Name + Step)
        if NewSelectedField then
            OldSelectedField.BackgroundColor3 = Settings.CommandBar.AutoComplete.UnselectedColor
            OldSelectedField.IsSelected.Value = false       
            NewSelectedField.BackgroundColor3 = Settings.CommandBar.AutoComplete.SelectedColor
            NewSelectedField.IsSelected.Value = true
        end
    end
end

function Module.UpdateHint()
    local Args = string.split(TextBox.Text, Settings.CommandBar.AutoComplete.ArgSplit)
    for Name, Info in pairs(Commands) do
        if string.lower(Name) == string.lower(Args[1]) then
            local ArgumentInfo = Info.Arguments[#Args-1]
            if ArgumentInfo then
                Hint.Title.Text = ArgumentInfo.Title
                Hint.Description.Text = ArgumentInfo.Description
                Hint.Visible = true
                Hint.Title.Size = UDim2.new(0, Hint.Title.TextBounds.X + Settings.CommandBar.Hint.Spacing, 1, 0)
                Hint.Description.Size = UDim2.new(0, Hint.Description.TextBounds.X + Settings.CommandBar.Hint.Spacing, 1, 0)
                Hint.Size = UDim2.new(0, Hint.Title.Size.X.Offset + Hint.Description.Size.X.Offset, 0, Settings.CommandBar.Hint.DefaultSize.Y.Offset)                
                return
            end
        end
    end
    Hint.Visible = false
end

function Module.CreateFields(PossibleFields)
    local BiggestSize = 0
    for i, Field in pairs(PossibleFields) do
        local NewField = AutoComplete.ListLayout.Template:Clone() do
            NewField.Title.Text = Field.Title
            NewField.Description.Text = Field.Description
            NewField.Name, NewField.LayoutOrder = i, i
        end
        
        if i == 1 then
            NewField.IsSelected.Value = true
            NewField.BackgroundColor3 = Settings.CommandBar.AutoComplete.SelectedColor
        end

        NewField.Parent = AutoComplete
        NewField.Title.Size = UDim2.new(0, NewField.Title.TextBounds.X, 1, 0)

        local X = NewField.Description.TextBounds.X
        local FinalY = Core.Round(X/Settings.CommandBar.AutoComplete.MaxDescriptionSize) + 1            
        if FinalY > 1 then
            NewField.Description.Size = UDim2.new(0, X/FinalY, 1, 0)
            NewField.Description.TextWrapped = true
            NewField.Size = UDim2.new(0, Settings.CommandBar.AutoComplete.MaxDescriptionSize, FinalY, 0)
        else
            NewField.Description.Size = UDim2.new(0, X, 1, 0)
            NewField.Size = UDim2.new(0, Settings.CommandBar.AutoComplete.MaxDescriptionSize, 1, 0)
        end

        local GoalX = NewField.Description.Size.X.Offset + NewField.Title.Size.X.Offset + Settings.CommandBar.AutoComplete.FieldSpacing
        if GoalX > BiggestSize then
            BiggestSize = GoalX
        end

        NewField.MouseButton1Click:Connect(function()
            Module.RunAutoComplete(NewField)
        end)
    end

    for _,Field in pairs(Core.Get(AutoComplete, "TextButton")) do
        Field.Size = UDim2.new(0, BiggestSize, Field.Size.Y.Scale, 0)
    end
end

function Module.CheckDifference(Title, Description, LastArg, Table)
    -- Check if already in table
    local Found
    for _,Info in pairs(Table) do
        if Info.Title == Title then
            Found = true
            break
        end
    end

    -- Check differences in chars
    for Char = #LastArg, 1, -1 do
        if string.sub(string.lower(LastArg), 1, Char) == string.sub(string.lower(Title), 1, Char) and not Found then
            table.insert(Table, {
                ["Title"] = Title,
                ["Description"] = Description
            })        
        end
        break
    end
end

function Module.GetFields(Text)
    local Args = string.split(Text, Settings.CommandBar.AutoComplete.ArgSplit)
    local PossibleFields = {}

    if #Args == 1 then
        for Title, Info in pairs(Commands) do
            Module.CheckDifference(Title, Info.Description, Args[#Args], PossibleFields)
        end
    elseif #Args > 1 then
        local Command = Commands[Args[1]]
        if Command then
            local Argument = Command.Arguments[#Args-1]
            if Argument then
                local Choices                    
                if typeof(Argument.Choices) == "function" then
                    Choices = Argument.Choices()
                elseif typeof(Argument.Choices) == "table" then
                    Choices = Argument.Choices
                end

                if Choices then
                    for _,Title in pairs(Choices) do
                        Module.CheckDifference(Title, "", Args[#Args], PossibleFields)
                    end
                end
            end
        end       
    end

    return PossibleFields
end

function Module.CheckAutoComplete()
    CommandBar.Size = Settings.CommandBar.DefaultSize + UDim2.new(0, TextBox.TextBounds.X, 0, 0)

    for _,Field in pairs(Core.Get(AutoComplete, "TextButton")) do
        Field:Destroy()
    end

    local PossibleFields = Module.GetFields(TextBox.Text)
    if PossibleFields then
        Module.CreateFields(PossibleFields)
        Module.UpdateHint()
    end
    
    AutoComplete.Size = Settings.CommandBar.AutoComplete.FieldSize + UDim2.new(0, AutoComplete.ListLayout.AbsoluteContentSize.X, 0, 0)
end

return Module