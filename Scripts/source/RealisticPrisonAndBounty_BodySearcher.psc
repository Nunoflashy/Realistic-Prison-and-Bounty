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

    elseif (strippingThoroughness >= 2)
        ; Strip to underwear, leaving high chance for lockpicks and 1 key

    elseif (strippingThoroughness >= 0)
        ; Strip to underwear, leaving high chance for lockpicks and high chance for keys
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

    actorToStrip.RemoveAllItems(akTransferTo = transferItemsTo, abRemoveQuestItems = true)
endFunction

function UnequipWeaponsFromActor(Actor akActor)
    
endFunction

function RemoveKeysFromActor(Actor akActor, ObjectReference akTransferContainer = none)

endFunction

function RemoveLockpicksFromActor(Actor akActor, ObjectReference akTransferContainer = none)
    
endFunction

function RemoveWeaponsFromActor(Actor akActor, ObjectReference akTransferContainer = none)
    
endFunction