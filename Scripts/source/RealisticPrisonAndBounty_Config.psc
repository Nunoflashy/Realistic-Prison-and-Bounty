Scriptname RealisticPrisonAndBounty_Config extends Quest

import RealisticPrisonAndBounty_Util
import PO3_SKSEFunctions


string function GetPluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

RealisticPrisonAndBounty_MCM property mcm
    RealisticPrisonAndBounty_MCM function get()
        return Game.GetFormFromFile(0x0D61, GetPluginName()) as RealisticPrisonAndBounty_MCM
    endFunction
endProperty

Actor property Player
    Actor function get()
        return Game.GetForm(0x00014) as Actor
    endFunction
endProperty

int factionMap
function InitializeFactions()
    factionMap = JMap.object()
    JValue.retain(factionMap)

    JMap.setForm(factionMap, "Whiterun",    Game.GetForm(0x000267EA))
    JMap.setForm(factionMap, "Winterhold",  Game.GetForm(0x0002816F))
    JMap.setForm(factionMap, "Eastmarch",   Game.GetForm(0x000267E3))
    JMap.setForm(factionMap, "Falkreath",   Game.GetForm(0x00028170))
    JMap.setForm(factionMap, "Haafingar",   Game.GetForm(0x00029DB0))
    JMap.setForm(factionMap, "Hjaalmarch",  Game.GetForm(0x0002816D))
    JMap.setForm(factionMap, "The Rift",    Game.GetForm(0x0002816B))
    JMap.setForm(factionMap, "The Reach",   Game.GetForm(0x0002816C))
    JMap.setForm(factionMap, "The Pale",    Game.GetForm(0x0002816E))

    ; TODO: Possibly load more factions from a file (custom factions and holds?)

    mcm.Debug("InitializeFactions", "Factions were initialized.")
endFunction

Faction function GetFaction(string factionName)
    if (JMap.hasKey(factionMap, factionName))
        return JMap.getForm(factionMap, factionName) as Faction
    endif

    return none
endFunction

event OnInit()
    InitializeFactions()
endEvent

function IncrementStat(string hold, string stat)
    mcm.IncrementStat(hold, stat)
endFunction

function DecrementStat(string hold, string stat)
    mcm.DecrementStat(hold, stat)
endFunction

bool function isStrippingUnconditional(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Unconditionally"
endFunction

bool function isStrippingBasedOnSentence(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Minimum Sentence"
endFunction

bool function isStrippingBasedOnBounty(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Minimum Bounty"
endFunction

bool function isClothingUnconditional(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Clothing On") == "Unconditionally"
endFunction

bool function isClothingBasedOnSentence(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Clothing On") == "Maximum Sentence"
endFunction

bool function isClothingBasedOnBounty(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Stripping On") == "Maximum Bounty"
endFunction

Armor function GetActorEquippedClothingForBodyPart(Actor actorTarget, string bodyPart)
    int validSlotMasks = JArray.object()

    if (bodyPart == "Head")
        JArray.addInt(validSlotMasks, 0x00000001)
        JArray.addInt(validSlotMasks, 0x00000002)
        JArray.addInt(validSlotMasks, 0x00001000)
        JArray.addInt(validSlotMasks, 0x00002000)
    elseif (bodyPart == "Body")
        JArray.addInt(validSlotMasks, 0x00000004)
        JArray.addInt(validSlotMasks, 0x00000002)
        JArray.addInt(validSlotMasks, 0x00001000)
    elseif (bodyPart == "Hands")
        JArray.addInt(validSlotMasks, 0x00000008)
    elseif (bodyPart == "Feet")
        JArray.addInt(validSlotMasks, 0x00000080)
    endif

    int combinedSlotMask
    int i = 0
    while (i < JArray.count(validSlotMasks))
        int currentSlotMask = JArray.getInt(validSlotMasks, i)
        combinedSlotMask += currentSlotMask
        Armor armorPieceSingleSlot = actorTarget.GetWornForm(currentSlotMask) as Armor
        if (armorPieceSingleSlot)
            return armorPieceSingleSlot
        endif

        Armor armorPieceMultipleSlots = actorTarget.GetWornForm(combinedSlotMask) as Armor
        if (armorPieceMultipleSlots)
            return armorPieceMultipleSlots
        endif
        
        i += 1
    endWhile

    return none
endFunction

int function GetOutfitMinimumBounty(string outfitId)
    ; To be changed to GetInputOptionValue (to use defaults)
    string inputField = mcm.GetOptionInputValue(outfitId + "::BountyCondition", "Clothing")
    int minimumBountyLen = StringUtil.Find(inputField, "-")
    string minBountyString = StringUtil.Substring(inputField, 0, minimumBountyLen)

    int minimumBounty = StringToInt(minBountyString)

    return minimumBounty
endFunction

int function GetOutfitMaximumBounty(string outfitId)
    ; To be changed to GetInputOptionValue (to use defaults)
    string inputField = mcm.GetOptionInputValue(outfitId + "::BountyCondition", "Clothing")
    int minimumBountyLen = StringUtil.Find(inputField, "-")

    if (minimumBountyLen == -1)
        ; There's no maximum bounty
        return 0
    endif

    string maxBountyString = StringUtil.Substring(inputField, minimumBountyLen + 1)
    int maximumBounty = StringToInt(maxBountyString)
    
    return maximumBounty
endFunction

function WearOutfitOnActor(Actor actorTarget, string outfitId, bool unequipAllItems = true)
    Armor bodyPartHead = mcm.GetOutfitPart(outfitId, "Head")
    Armor bodyPartBody = mcm.GetOutfitPart(outfitId, "Body")
    Armor bodyPartHands = mcm.GetOutfitPart(outfitId, "Hands")
    Armor bodyPartFeet = mcm.GetOutfitPart(outfitId, "Feet")

    string actorName = actorTarget.GetActorBase().GetName()

    if (unequipAllItems)
        actorTarget.UnequipAll()
    endif

    mcm.Debug("WearOutfit", "Test call for this outfit for " + actorName + ", body parts: ["+ bodyPartHead + ", " + bodyPartBody + ", " + bodyPartHands + ", " + bodyPartFeet +"]")

    if (bodyPartHead != none)
        actorTarget.EquipItem(bodyPartHead, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartHead.GetName() + " from " + outfitId + "::Head" + " on " + actorName)
    endif

    if (bodyPartBody != none)
        actorTarget.EquipItem(bodyPartBody, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartBody.GetName() + " from " + outfitId + "::Body" + " on " + actorName)
    endif
    
    if (bodyPartHands != none)
        actorTarget.EquipItem(bodyPartHands, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartHands.GetName() + " from " + outfitId + "::Hands" + " on " + actorName)
    endif

    if (bodyPartFeet != none)
        actorTarget.EquipItem(bodyPartFeet, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartFeet.GetName() + " from " + outfitId + "::Feet" + " on " + actorName)
    endif

endFunction

function AddOutfit(string outfitId, Armor headClothing, Armor bodyClothing, Armor handsClothing, Armor feetClothing)
    ; if body overrides head (shares slots, remove head, since body will take up its slot)
    if (bodyClothing == headClothing)
        headClothing = none
    endif

    ; Set each outfit part's name in the input fields for the outfit
    mcm.SetOptionInputValue(outfitId + "::Head", headClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Body", bodyClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Hands", handsClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Feet", feetClothing.GetName())

    ; Add each clothing piece to this outfit (store persistently into the outfit list)
    mcm.AddOutfitPiece(outfitId, "Head", headClothing)
    mcm.AddOutfitPiece(outfitId, "Body", bodyClothing)
    mcm.AddOutfitPiece(outfitId, "Hands", handsClothing)
    mcm.AddOutfitPiece(outfitId, "Feet", feetClothing)

    mcm.Trace("AddOutfit", "headClothing: " + headClothing + ", bodyClothing: " + bodyClothing + ", handsClothing: " + handsClothing + ", feetClothing: " + feetClothing)
    mcm.Trace("AddOutfit", "Slot Masks [headClothing: " + headClothing.GetSlotMask() + ", bodyClothing: " + bodyClothing.GetSlotMask() + ", handsClothing: " + handsClothing.GetSlotMask() + ", feetClothing: " + feetClothing.GetSlotMask() + "]")
endFunction

; Player function aliases for param Actor

Armor function GetEquippedClothingForBodyPart(string bodyPart)
    return GetActorEquippedClothingForBodyPart(Player, bodyPart)
endFunction

function WearOutfit(string outfitName, bool unequipAllItems = true)
    WearOutfitOnActor(Player, outfitName, unequipAllItems)
endFunction

bool function Debug_OutfitMeetsCondition(Faction crimeFaction, string outfitId)
    int bounty = crimeFaction.GetCrimeGold()
    int outfitMinimumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
    int outfitMaximumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int

    bool onlyMinBountyRequired = outfitMinimumBounty == outfitMaximumBounty && bounty >= outfitMinimumBounty
    bool isBountyWithinRange = IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)
    bool hasCondition = mcm.GetToggleOptionValue("Clothing", outfitId + "::Conditional Outfit") as bool
    bool meetsCondition = !hasCondition || isBountyWithinRange && !onlyMinBountyRequired || onlyMinBountyRequired

    mcm.Debug("Debug_OutfitMeetsCondition", "Bounty for " + crimeFaction.GetName() + ": " + bounty)
    mcm.Debug("Debug_OutfitMeetsCondition", outfitId + " [Minimum Bounty: " + outfitMinimumBounty + ", Maximum Bounty: " + outfitMaximumBounty + "] ("+ "isBountyWithinRange: " + isBountyWithinRange + ", hasCondition: "+ hasCondition +") (meets condition: " + meetsCondition + ")")

    return meetsCondition
endFunction

; bool function Debug_OutfitMeetsCondition(Faction crimeFaction, string outfitId)
;     int bounty = crimeFaction.GetCrimeGold()
;     int outfitMinimumBounty = GetOutfitMinimumBounty(outfitId)
;     int outfitMaximumBounty = GetOutfitMaximumBounty(outfitId)

;     bool hasMinBounty = outfitMinimumBounty > 0
;     bool hasMaxBounty = outfitMaximumBounty > 0

;     bool isBountyRange = hasMinBounty && hasMaxBounty
;     bool isSingleBounty = hasMinBounty && !hasMaxBounty

;     bool isBountyWithinRange = !isSingleBounty && isBountyRange && IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)

;     bool hasCondition = mcm.GetToggleOptionValue("Clothing", outfitId + "::Conditional Outfit") as bool
;     bool meetsCondition = !hasCondition || (isSingleBounty && bounty >= outfitMinimumBounty) || isBountyWithinRange

;     mcm.Debug("Debug_OutfitMeetsCondition", "Bounty for " + crimeFaction.GetName() + ": " + bounty)
;     mcm.Debug("Debug_OutfitMeetsCondition", outfitId + " [Minimum Bounty: " + outfitMinimumBounty + ", Maximum Bounty: " + outfitMaximumBounty + "] ("+ "isBountyWithinRange: " + isBountyWithinRange + ", hasCondition: "+ hasCondition +") (meets condition: " + meetsCondition + ")")

;     return meetsCondition
; endFunction

bool function OutfitMeetsCondition(Faction crimeFaction, string outfitId)
    bool hasCondition = mcm.GetToggleOptionValue("Clothing", outfitId + "::Conditional Outfit") as bool

    if (!hasCondition)
        return true
    endif

    int bounty = crimeFaction.GetCrimeGold()
    int outfitMinimumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
    int outfitMaximumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int

    bool isBountyWithinRange = IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)
    bool meetsCondition = !hasCondition || isBountyWithinRange

    return meetsCondition
endFunction

