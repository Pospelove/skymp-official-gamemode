local DirtyHacks = {}

-- Fix zero stamina regen
-- We apply a new StaminaRateMult value => game starts regen

function AddToStaminaRateMult(pl, count)
    local val = pl:GetBaseAV("StaminaRateMult")
    val = val + count
    pl:SetBaseAV("StaminaRateMult", val)
end

function DirtyHacks.OnPlayerSpawn(pl)
    local v = 0.5
    if math.ceil(v) == v then error("incorrect v") end

    AddToStaminaRateMult(pl, v)
    SetTimer(250, function()
        local base = pl:GetBaseAV("StaminaRateMult")
        if base ~= math.ceil(base) then
            AddToStaminaRateMult(pl, -v)
        end
    end)

    return true
end

return DirtyHacks
