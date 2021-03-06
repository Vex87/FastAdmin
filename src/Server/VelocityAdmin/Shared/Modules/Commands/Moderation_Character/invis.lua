local Cmd = {}
local Helper = require(game.ReplicatedStorage.VelocityAdmin.Modules.Helper)

----------------------------------------------------------------------

Cmd.Description = "Makes the player invisible."

Cmd.Arguments = {
    [1] = {
        ["Title"] = "player",
        ["Description"] = "The player you want to make invisible",
        ["Choices"] = Helper.GetPlayers
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
                Helper.Data[CurrentPlayer.Name].InvisItems = {}
                for _,Part in pairs(Char:GetDescendants()) do
                    pcall(function()
                        if Part.Transparency ~= 1 then
                            Part.Transparency = 1
                            table.insert(Helper.Data[CurrentPlayer.Name].InvisItems, Part)
                        end
                    end)
                end

                table.insert(Info, {
                    Success = true,
                    Status = p.Name .. " made invisible."
                })
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