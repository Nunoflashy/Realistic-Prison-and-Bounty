scriptname RealisticPrisonAndBounty_BodySearcher extends Quest

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

function FriskActor(Actor actorToFrisk, float friskingThoroughness, ObjectReference transferItemsTo = none)
    Debug(self, "FriskActor", "Frisked Actor: " + actorToFrisk)
endFunction

function StripActor(Actor actorToStrip, float strippingThoroughness, ObjectReference transferItemsTo = none)
    int underwearTopSlotMask = GetSlotMaskValue(config.UnderwearTopSlot)
    int underwearBottomSlotMask = GetSlotMaskValue(config.UnderwearBottomSlot)

    Armor underwearTop = actorToStrip.GetWornForm(underwearTopSlotMask) as Armor
    Armor underwearBottom = actorToStrip.GetWornForm(underwearBottomSlotMask) as Armor

    Debug(self, "BodySearcher::StripActor", "\n" + \
        "Underwear (Top): ["+ "Slot: " + config.UnderwearTopSlot +", Slot Mask: "+ underwearTopSlotMask +", FormID: "+ underwearTop +"]" + "\n" + \
        "Underwear (Bottom): ["+ "Slot: " + config.UnderwearBottomSlot +", Slot Mask: "+ underwearBottomSlotMask +", FormID: "+ underwearBottom +"]" + "\n" \ 
    )

    actorToStrip.RemoveAllItems(transferItemsTo, true, true)
    ; transferItemsTo.RemoveAllItems(actorToStrip, false, true)

    ; Determine what to strip based on thoroughness
    if (strippingThoroughness >= 100.0)
        ; Strip naked, ask to spread cheeks, etc...
    
    elseif (strippingThoroughness >= 80.0)
    
    elseif (strippingThoroughness >= 60.0)
    
    elseif (strippingThoroughness >= 40.0)

    elseif (strippingThoroughness >= 20.0)
        ; Strip naked, leaving no chance for lockpicks

    elseif (strippingThoroughness >= 10.0)
        ; Strip naked, leaving very little chance for lockpicks

    elseif (strippingThoroughness >= 8)
        ; Strip naked, leaving little chance for lockpicks

    elseif (strippingThoroughness >= 6)
        ; Strip naked, leaving some chance for lockpicks

    elseif (strippingThoroughness >= 4)
        ; Strip to underwear, leaving average chance for lockpicks
        transferItemsTo.RemoveItem(underwearTop, abSilent = true, akOtherContainer = actorToStrip)
        transferItemsTo.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = actorToStrip)
        actorToStrip.EquipItem(underwearTop, false, true)
        actorToStrip.EquipItem(underwearBottom, false, true)

    elseif (strippingThoroughness >= 2)
        ; Strip to underwear, leaving high chance for lockpicks and 1 key
        transferItemsTo.RemoveItem(underwearTop, abSilent = true, akOtherContainer = actorToStrip)
        transferItemsTo.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = actorToStrip)
        actorToStrip.EquipItem(underwearTop, false, true)
        actorToStrip.EquipItem(underwearBottom, false, true)

    elseif (strippingThoroughness >= 0)
        ; Strip to underwear, leaving high chance for lockpicks and high chance for keys
        transferItemsTo.RemoveItem(underwearTop, abSilent = true, akOtherContainer = actorToStrip)
        transferItemsTo.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = actorToStrip)
        actorToStrip.EquipItem(underwearTop, false, true)
        actorToStrip.EquipItem(underwearBottom, false, true)
    endif

    ; Stripping naked should only be allowed if a nude body mod is installed
    ; Likewise, stripping to underwear should only be allowed if a nude body mod AND a wearable underwear mod are installed, or if no nude body mod is installed (underwear by default)

    ; int itemCount = actorToStrip.GetNumItems()
    ; int i = 0
    ; while (i < itemCount)
    ;     Form currentItem = actorToStrip.GetNthForm(i)
    ;     actorToStrip.RemoveItem(currentItem, absilent = true)
    ;     i += 1
    ; endWhile

endFunction

function UnequipWeaponsFromActor(Actor akActor)
    
endFunction

function RemoveKeysFromActor(Actor akActor, ObjectReference akTransferContainer = none)

endFunction

function RemoveLockpicksFromActor(Actor akActor, ObjectReference akTransferContainer = none)
    
endFunction

function RemoveWeaponsFromActor(Actor akActor, ObjectReference akTransferContainer = none)
    
endFunction