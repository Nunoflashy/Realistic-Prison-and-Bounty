scriptname RealisticPrisonAndBounty_Clothing extends Quest

import RPB_Utility
import RPB_Config

RPB_Config property config
    RPB_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RPB_Config
    endFunction
endProperty

Armor headClothing  = none
Armor bodyClothing  = none
Armor handsClothing = none
Armor feetClothing  = none


RealisticPrisonAndBounty_Outfit property _outfit
    RealisticPrisonAndBounty_Outfit function get()
        return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RealisticPrisonAndBounty_Outfit
    endFunction
endProperty

RealisticPrisonAndBounty_Outfit function __getOutfitObject()
    return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RealisticPrisonAndBounty_Outfit
endFunction

bool function validate()
    return !(headClothing == none || bodyClothing == none || handsClothing == none || feetClothing == none)
endFunction

function WearOutfit(Actor actorToClothe, RealisticPrisonAndBounty_Outfit outfitToWear, bool undressActor = true)
    if (undressActor)
        actorToClothe.UnequipAll()
    endif

    actorToClothe.EquipItem(outfitToWear.Head, abSilent = true)
    actorToClothe.EquipItem(outfitToWear.Body, abSilent = true)
    actorToClothe.EquipItem(outfitToWear.Hands, abSilent = true)
    actorToClothe.EquipItem(outfitToWear.Feet, abSilent = true)
endFunction

function UnwearOutfit(Actor actorToUndress, bool preventEquip = false)
    actorToUndress.UnequipItem(headClothing, preventEquip, true)
    actorToUndress.UnequipItem(bodyClothing, preventEquip, true)
    actorToUndress.UnequipItem(handsClothing, preventEquip, true)
    actorToUndress.UnequipItem(feetClothing, preventEquip, true)
endFunction


RealisticPrisonAndBounty_Outfit function GetOutfit(string outfitName)

    RealisticPrisonAndBounty_Outfit outfitInstance = __getOutfitObject()

    outfitInstance.Head = config.mcm.GetOutfitPart(outfitName, "Head") 
    outfitInstance.Body = config.mcm.GetOutfitPart(outfitName, "Body") 
    outfitInstance.Hands = config.mcm.GetOutfitPart(outfitName, "Hands") 
    outfitInstance.Feet = config.mcm.GetOutfitPart(outfitName, "Feet")
    outfitInstance.IsConditional = config.IsClothingOutfitConditionalFromID(outfitName)
    outfitInstance.MinimumBounty = config.GetClothingOutfitMinimumBountyFromID(outfitName)
    outfitInstance.MaximumBounty = config.GetClothingOutfitMaximumBountyFromID(outfitName)

    return outfitInstance
endFunction

RealisticPrisonAndBounty_Outfit function GetCurrentOutfit()
    return __getOutfitObject()
endFunction

;/
    Returns a container with the outfit parts with the format of:
    Outfit["Head"] = HeadClothing (Armor)
    Outfit["Body"] = BodyClothing (Armor)
    Outfit["Hands"] = HandsClothing (Armor)
    Outfit["Feet"] = FeetClothing (Armor)

    returns [JMap]: The container with the default outfit. 
/;
RealisticPrisonAndBounty_Outfit function GetDefaultOutfit(bool includeFeetClothing = true)
    Armor defaultHeadClothing  = none
    Armor defaultBodyClothing  = none
    Armor defaultHandsClothing = none
    Armor defaultFeetClothing  = none

    ; Set default jail outfits
    int OUTFIT_DEFAULT_ROUGHSPUN_TUNIC  = 0
    int OUTFIT_DEFAULT_RAGGED_TROUSERS  = 1
    int OUTFIT_DEFAULT_RAGGED_ROBES     = 2

    int whichDefaultOutfit = Utility.RandomInt(0, 2)

    if (whichDefaultOutfit == OUTFIT_DEFAULT_ROUGHSPUN_TUNIC)
        defaultBodyClothing = Game.GetFormEx(0x3C9FE) as Armor ; Roughspun Tunic
        defaultFeetClothing = form_if (includeFeetClothing, Game.GetFormEx(0x3CA00), none) as Armor ; Footwraps

    elseif (whichDefaultOutfit == OUTFIT_DEFAULT_RAGGED_TROUSERS)
        defaultBodyClothing = Game.GetFormEx(0x8F19A) as Armor ; Ragged Trousers
        defaultFeetClothing = form_if (includeFeetClothing, Game.GetFormEx(0x3CA00), none) as Armor ; Footwraps

    elseif (whichDefaultOutfit == OUTFIT_DEFAULT_RAGGED_ROBES)
        defaultBodyClothing = Game.GetFormEx(0x13105) as Armor ; Ragged Robes
        defaultFeetClothing = form_if (includeFeetClothing, Game.GetFormEx(0x3CA00), none) as Armor ; Footwraps
    endif

    __getOutfitObject().Body = defaultBodyClothing
    __getOutfitObject().Feet = defaultFeetClothing

    return __getOutfitObject()
endFunction