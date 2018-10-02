local Blink = {}
local myHero = nil
local blink = nil

Blink.optionEnable = Menu.AddOptionBool({"Utility", "Blink Out"}, "Enable", false)
Blink.activationKey = Menu.AddKeyOption({"Utility", "Blink Out"}, "Activation Key", Enum.ButtonCode.KEY_G)

function Blink.blinkToCursorPosition()
    if Ability.GetCooldown(blink) == 0 then
        Ability.CastPosition(blink, Input.GetWorldCursorPos())
    end
end

function Blink.OnUpdate()
    myHero = Heroes.GetLocal()
    if not myHero or not Menu.IsEnabled(Blink.optionEnable) or not Menu.IsKeyDown(Blink.activationKey) then return end
    if NPC.HasItem(myHero, "item_blink") then
        blink = NPC.GetItem(myHero, "item_blink")
        Blink.blinkToCursorPosition()
    end       
end

return Blink