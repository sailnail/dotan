local Autocast = {}
local ability = nil 
local myHero = nil
local abilityIndex = nil
local talantsRange = nil
local talantsLvl = nil

Autocast.ability = Menu.AddOptionBool({"Utility", "Auto-Cast Toggler"}, "Enable", false)

function Autocast.GetAbilityIndex()
    if NPC.GetUnitName(myHero) == "npc_dota_hero_huskar" then
         abilityIndex = 1
         talantsLvl = 25
         talantsRange = 150
    end    
    if NPC.GetUnitName(myHero) == "npc_dota_hero_silencer" then 
         abilityIndex = 1
    end    
    if NPC.GetUnitName(myHero) == "npc_dota_hero_drow_ranger" then 
         abilityIndex = 0
    end    
    if NPC.GetUnitName(myHero) == "npc_dota_hero_clinkz" then 
         abilityIndex = 1
         talantsLvl = 20
         talantsRange = 100
    end    
    if NPC.GetUnitName(myHero) == "npc_dota_hero_viper" then 
         abilityIndex = 0
         talantsLvl = 15
         talantsRange = 100
    end      
    if NPC.GetUnitName(myHero) == "npc_dota_hero_obsidian_destroyer" then 
         abilityIndex = 0
    end
end

function Autocast.OnUpdate()
    myHero = Heroes.GetLocal()
    if not myHero then return end
    Autocast.GetAbilityIndex()
    if abilityIndex == nil then return end    
    ability = NPC.GetAbilityByIndex(myHero, abilityIndex)
    if Menu.IsEnabled(Autocast.ability) and myHero ~= nil and Ability.GetLevel(ability) > 0 then 
        Autocast.ToggleAbility() 
    end
end

function Autocast.ToggleAbility()
    if NPC.IsAttacking(myHero) then
        local hero = Autocast.GetFaceTarget(myHero) 
            if Entity.IsHero(hero) then
                if not Ability.GetAutoCastState(ability) then
                    Ability.ToggleMod(ability)   
                end
            end
            if Entity.GetClassName(hero) == "C_DOTA_Unit_Roshan" then return end
            if not Entity.IsHero(hero) then 
                if Ability.GetAutoCastState(ability) then
                    Ability.ToggleMod(ability)   
                end
            end
        

    end
end
    
function Autocast.GetAngle(unit, unitPos, npcPos)
    local baseVec = (npcPos - unitPos):Normalized()
    local myRotation = Entity.GetRotation(unit):GetForward():Normalized()       
    local tempProcessing = baseVec:Dot2D(myRotation) / (baseVec:Length2D() * myRotation:Length2D())
    local searchAngleRad = math.acos(tempProcessing)
    local searchAngle = (180 / math.pi) * searchAngleRad
    return searchAngle
end

function Autocast.GetFaceTarget(unit)
    local range = Autocast.GetRange(unit)
    Log.Write(range)
    local unitsAround = Entity.GetUnitsInRadius(unit, range, Enum.TeamType.TEAM_ENEMY)
    if not unitsAround then return nil end
    local unitRet = nil
    local minAngle = 1000
    local unitPos = Entity.GetAbsOrigin(unit)
    for i = 1, #unitsAround do
        local npc = unitsAround[i]
        local npcPos = Entity.GetAbsOrigin(npc)
        local angleToNpc = Autocast.GetAngle(unit, unitPos, npcPos)
        if angleToNpc < minAngle then
            minAngle = angleToNpc
            unitRet = npc
        end
    end
    return unitRet
end

function Autocast.GetRange(unit)
    local range = NPC.GetAttackRange(unit) + 50
    if NPC.HasItem(unit, "item_hurricane_pike") or NPC.HasItem(unit, "item_dragon_lance")  then
        range = range + 140
    end
    if talantsLvl then 
        if NPC.GetCurrentLevel(unit) >= talantsLvl then
            range = range + talantsRange
        end
    end    
    return range
end    



return Autocast