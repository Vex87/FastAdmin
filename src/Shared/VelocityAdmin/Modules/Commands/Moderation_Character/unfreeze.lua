local Cmd = {}
local Helper = require(game.ReplicatedStorage.VelocityAdmin.Modules.Helper)

----------------------------------------------------------------------

Cmd.Description = "Makes the player movable"

Cmd.Arguments = {
    [1] = {
        ["Title"] = "player",
        ["Description"] = "The player you want to unfreeze.",
        ["Choices"] = function()
            local Players = {}
            for _,p in pairs(game.Players:GetPlayers()) do
                table.insert(Players, p.Name)
            end
            return Players
        end
    },
}

Cmd.Run = function(CurrentPlayer, Player)

    -- Check if necessary arguments are there
    if not Player then
        return false, "Player Argument Missing"
    end

    -- Run Command
    local Players = Helper.FindPlayer(Player, CurrentPlayer)
    if Players then
        local Info = {}
        for _,p in pairs(Players) do
            local Char = p.Character
            if Char then
                local Root = Char:WaitForChild("HumanoidRootPart")
                Root.Anchored = false

                Info:insert({
                    Success = true,
                    Status = Player .. " was unfrozen."
                })
            else
                Info:insert({
                    false,
                    Status = Player .. "'s character does not exist."
                })
            end   
        end    
        return Info          
    else
        return false, Player .. " is not a valid player."
    end

end

----------------------------------------------------------------------

return Cmd