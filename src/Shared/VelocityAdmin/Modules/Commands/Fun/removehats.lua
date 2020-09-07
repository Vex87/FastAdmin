local Cmd = {}
local Helper = require(game.ReplicatedStorage.VelocityAdmin.Modules.Helper)

----------------------------------------------------------------------

Cmd.Description = "Removes all the accessory on the player."

Cmd.Arguments = {
    [1] = {
        ["Title"] = "player",
        ["Description"] = "The player you want to remove all the accessories of.",
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
    local Players = Velocity.Helper.FindPlayer(Player, CurrentPlayer)
    if Players then
        for _,p in pairs(Players) do
            local Char = p.Character
            if Char then
                local Items = {}
                for _,Accessory in pairs(Char:GetDescendants()) do
                    if Accessory:IsA("Accessory") then
                        table.insert(Items, Accessory.Name)
                        Accessory:Destroy()
                    end
                end
                if Items then
                    return true, "Removed the following accessories from " .. Player .. "... " .. table.concat(Items, ", ")
                else
                    return true, "No accessories detected for " .. Player
                end
            else
                return false, Player .. "'s character does not exist."
            end   
        end              
    else
        return false, Player .. " is not a valid player."
    end

end

----------------------------------------------------------------------

return Cmd