local Cmd = {}
local Helper = require(game.ReplicatedStorage.VelocityAdmin.Modules.Helper)

----------------------------------------------------------------------

Cmd.Description = "Sets the player's health to infinite."

Cmd.Arguments = {
    [1] = {
        ["Title"] = "player",
        ["Description"] = "The player you want to god.",
        ["Choices"] = Helper.GetPlayers
    }
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
                local Hum = Char:WaitForChild("Humanoid")
                if not Helper.Data[CurrentPlayer.Name].God then                      
                    Helper.Data[CurrentPlayer.Name].God = {
                        Health = Hum.Health,
                        MaxHealth = Hum.MaxHealth
                    }
                    Hum.MaxHealth, Hum.Health = math.huge, math.huge

                    table.insert(Info, {
                        Success = true,
                        Status = p.Name .. " was godded."
                    })
                else
                    table.insert(Info, {
                        Success = true,
                        Status = p.Name .. " is already godded."
                    })
                end
            else
                table.insert(Info, {
                    Success = false,
                    Status = p.Name .. "'s character does not exist."
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