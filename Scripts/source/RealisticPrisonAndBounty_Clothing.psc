scriptname RealisticPrisonAndBounty_Clothing extends Quest

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

Armor headClothing  = none
Armor bodyClothing  = none
Armor handsClothing = none
Armor feetClothing  = none

; int __internalOutfitInstanceHolder

; event OnInit()
;     __internalOutfitInstanceHolder = JMap.object()
;     JValue.retain(__internalOutfitInstanceHolder)
;     Debug(self, "Clothing::OnInit", "Initialized instance holder")
; endEvent

; function __setOutfitInstance(string outfitKey, Armor clothingPart)
;     JMap.setForm(__internalOutfitInstanceHolder, outfitKey, clothingPart)
; endFunction

; bool function __hasOutfitInstance(string outfitKey)
;     string headKey = outfitKey + "::" + "Head"
;     string bodyKey = outfitKey + "::" + "Body"
;     string handsKey = outfitKey + "::" + "Hands"
;     string feetKey = outfitKey + "::" + "Feet"

;     return \
;         !JMap.hasKey(__internalOutfitInstanceHolder, headKey) && \
;         !JMap.hasKey(__internalOutfitInstanceHolder, bodyKey) && \
;         !JMap.hasKey(__internalOutfitInstanceHolder, handsKey) && \
;         !JMap.hasKey(__internalOutfitInstanceHolder, feetKey)
; endFunction

; RealisticPrisonAndBounty_Outfit function __getOutfitInstance(string outfitKey)

;     if (!__hasOutfitInstance(outfitKey))
;         return none
;     endif

;     string headKey = outfitKey + "::" + "Head"
;     string bodyKey = outfitKey + "::" + "Body"
;     string handsKey = outfitKey + "::" + "Hands"
;     string feetKey = outfitKey + "::" + "Feet"

;     RealisticPrisonAndBounty_Outfit outfitInstance = __getOutfitObject()
    
;     outfitInstance.Head             = JMap.getForm(__internalOutfitInstanceHolder, headKey) as Armor
;     outfitInstance.Body             = JMap.getForm(__internalOutfitInstanceHolder, bodyKey) as Armor
;     outfitInstance.Hands            = JMap.getForm(__internalOutfitInstanceHolder, handsKey) as Armor
;     outfitInstance.Feet             = JMap.getForm(__internalOutfitInstanceHolder, feetKey) as Armor
;     outfitInstance.IsConditional    = config.IsClothingOutfitConditional(outfitKey)
;     outfitInstance.MinimumBounty    = config.GetClothingOutfitMinimumBounty(outfitKey)
;     outfitInstance.MaximumBounty    = config.GetClothingOutfitMaximumBounty(outfitKey)

;     return outfitInstance
; endFunction


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

; function WearOutfit(Actor actorToClothe, bool undressActor = true)
;     if (!validate())
;         return
;     endif

;     if (undressActor)
;         actorToClothe.UnequipAll()
;     endif

;     actorToClothe.EquipItem(headClothing)
;     actorToClothe.EquipItem(bodyClothing)
;     actorToClothe.EquipItem(handsClothing)
;     actorToClothe.EquipItem(feetClothing)
; endFunction

; function WearOutfit(Actor actorToClothe, bool undressActor = true)
;     if (undressActor)
;         actorToClothe.UnequipAll()
;     endif

;     actorToClothe.EquipItem(_outfit.Head)
;     actorToClothe.EquipItem(_outfit.Body)
;     actorToClothe.EquipItem(_outfit.Hands)
;     actorToClothe.EquipItem(_outfit.Feet)

;     Debug(self, "Clothing::WearOutfit", "\n" + \
;         "Equipped Head: " + _outfit.Head + "\n" + \
;         "Equipped Body: " + _outfit.Body + "\n" + \
;         "Equipped Hands: " + _outfit.Hands + "\n" + \
;         "Equipped Feet: " + _outfit.Feet + "\n" +  \
;         "Undressed: " + undressActor + "\n" \
;     )
; endFunction

function WearOutfit(Actor actorToClothe, RealisticPrisonAndBounty_Outfit outfitToWear, bool undressActor = true)
    if (undressActor)
        actorToClothe.UnequipAll()
    endif

    actorToClothe.EquipItem(outfitToWear.Head, abSilent = true)
    actorToClothe.EquipItem(outfitToWear.Body, abSilent = true)
    actorToClothe.EquipItem(outfitToWear.Hands, abSilent = true)
    actorToClothe.EquipItem(outfitToWear.Feet, abSilent = true)

    ; Debug(self, "Clothing::WearOutfit", "\n" + \
    ;     "Equipped Head: " + outfitToWear.Head + "\n" + \
    ;     "Equipped Body: " + outfitToWear.Body + "\n" + \
    ;     "Equipped Hands: " + outfitToWear.Hands + "\n" + \
    ;     "Equipped Feet: " + outfitToWear.Feet + "\n" +  \
    ;     "Undressed: " + undressActor + "\n" \
    ; )
endFunction

function UnwearOutfit(Actor actorToUndress, bool preventEquip = false)
    actorToUndress.UnequipItem(headClothing, preventEquip, true)
    actorToUndress.UnequipItem(bodyClothing, preventEquip, true)
    actorToUndress.UnequipItem(handsClothing, preventEquip, true)
    actorToUndress.UnequipItem(feetClothing, preventEquip, true)
endFunction

; function SetOutfit(string outfitName)
;     _outfit.Head = config.mcm.GetOutfitPart(outfitName, "Head") 
;     _outfit.Body = config.mcm.GetOutfitPart(outfitName, "Body") 
;     _outfit.Hands = config.mcm.GetOutfitPart(outfitName, "Hands") 
;     _outfit.Feet = config.mcm.GetOutfitPart(outfitName, "Feet")

;     Debug(self, "Clothing::SetOutfit", "\n" + \
;         "Head: " + _outfit.Head + "\n" + \
;         "Body: " + _outfit.Body + "\n" + \
;         "Hands: " + _outfit.Hands + "\n" + \
;         "Feet: " + _outfit.Feet + "\n" \
;     )
; endFunction

RealisticPrisonAndBounty_Outfit function GetOutfit(string outfitName)
    ; RealisticPrisonAndBounty_Outfit cachedOutfit = __getOutfitInstance(outfitName)
    ; if (cachedOutfit)
    ;     Debug(self, "Clothing::GetOutfit (Cached)", "\n" + \
    ;         "Head: " + cachedOutfit.Head + "\n" + \
    ;         "Body: " + cachedOutfit.Body + "\n" + \
    ;         "Hands: " + cachedOutfit.Hands + "\n" + \
    ;         "Feet: " + cachedOutfit.Feet + "\n" + \
    ;         "Conditional: " + cachedOutfit.IsConditional + "\n" + \
    ;         "Minimum Bounty: " + cachedOutfit.MinimumBounty + "\n" + \
    ;         "Maximum Bounty: " + cachedOutfit.MaximumBounty + "\n"\
    ;     )
    ;     return cachedOutfit
    ; endif

    RealisticPrisonAndBounty_Outfit outfitInstance = __getOutfitObject()

    outfitInstance.Head = config.mcm.GetOutfitPart(outfitName, "Head") 
    outfitInstance.Body = config.mcm.GetOutfitPart(outfitName, "Body") 
    outfitInstance.Hands = config.mcm.GetOutfitPart(outfitName, "Hands") 
    outfitInstance.Feet = config.mcm.GetOutfitPart(outfitName, "Feet")
    outfitInstance.IsConditional = config.IsClothingOutfitConditionalFromID(outfitName)
    outfitInstance.MinimumBounty = config.GetClothingOutfitMinimumBountyFromID(outfitName)
    outfitInstance.MaximumBounty = config.GetClothingOutfitMaximumBountyFromID(outfitName)

    ; Debug(self, "Clothing::GetOutfit", "\n" + \
    ;     "Head: " + outfitInstance.Head + "\n" + \
    ;     "Body: " + outfitInstance.Body + "\n" + \
    ;     "Hands: " + outfitInstance.Hands + "\n" + \
    ;     "Feet: " + outfitInstance.Feet + "\n" \
    ; )

    ; __setOutfitInstance(outfitName + "::" + "Head", outfitInstance.Head)
    ; __setOutfitInstance(outfitName + "::" + "Body", outfitInstance.Body)
    ; __setOutfitInstance(outfitName + "::" + "Hands", outfitInstance.Hands)
    ; __setOutfitInstance(outfitName + "::" + "Feet", outfitInstance.Feet)

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

    ; string outfitKey = "Default" + whichDefaultOutfit
    ; RealisticPrisonAndBounty_Outfit cachedOutfit = __getOutfitInstance(outfitKey)
    ; if (cachedOutfit)
    ;     return cachedOutfit
    ; endif

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

    ; __setOutfitInstance(outfitKey + "::" + "Head", __getOutfitObject().Head)
    ; __setOutfitInstance(outfitKey + "::" + "Body", __getOutfitObject().Body)
    ; __setOutfitInstance(outfitKey + "::" + "Hands", __getOutfitObject().Hands)
    ; __setOutfitInstance(outfitKey + "::" + "Feet", __getOutfitObject().Feet)

    ; Debug(self, "Clothing::GetDefaultOutfit", "\n" + \
    ;     "Body: " + defaultBodyClothing + " ("+ defaultBodyClothing.GetName() +")" + "\n" + \
    ;     "Feet: " + defaultFeetClothing + " ("+ defaultFeetClothing.GetName() +")" + "\n" + \
    ;     "whichDefaultOutfit: " +whichDefaultOutfit + "\n" \
    ; )

    return __getOutfitObject()
endFunction