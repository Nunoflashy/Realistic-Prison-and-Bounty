Scriptname RealisticPrisonAndBounty_MCM_Undress hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Undressing"
endFunction

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == GetPageName()
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)
endFunction

function RenderOptions(RealisticPrisonAndBounty_MCM mcm, int index) global
    mcm.AddOptionToggleEx("Allow Undressing",                 mcm.UNDRESSING_DEFAULT_ALLOW, index)
    mcm.AddOptionSliderEx("Minimum Bounty to Undress",        mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, index)
    mcm.AddOptionToggleEx("Undress when Defeated",            mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED, index)
    mcm.AddOptionToggleEx("Undress at Cell",                  mcm.UNDRESSING_DEFAULT_AT_CELL, index)
    mcm.AddOptionToggleEx("Undress at Chest",                 mcm.UNDRESSING_DEFAULT_AT_CHEST, index)
    mcm.AddOptionSliderEx("Forced Undressing (Bounty)",       mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY, index)
    mcm.AddOptionToggleEx("Forced Undressing when Defeated",  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED, index)
    mcm.AddOptionSliderEx("Strip Search Thoroughness",        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, index)
    ; mcm.AddOptionToggleEx("Allow Wearing Clothes",            mcm.UNDRESSING_DEFAULT_ALLOW_CLOTHES, index)
    ; mcm.AddOptionSliderEx("Bounty to Re-dress",               mcm.UNDRESSING_DEFAULT_REDRESS_BOUNTY, index)
    ; mcm.AddOptionToggleEx("Re-dress when Defeated",           mcm.UNDRESSING_DEFAULT_REDRESS_WHEN_DEFEATED, index)
    ; mcm.AddOptionToggleEx("Re-dress at Cell",                 mcm.UNDRESSING_DEFAULT_REDRESS_AT_CELL, index)
    ; mcm.AddOptionToggleEx("Re-dress at Chest",                mcm.UNDRESSING_DEFAULT_REDRESS_AT_CHEST, index)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    int i = mcm.LeftPanelIndex
    while (i < mcm.LeftPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    int i = mcm.RightPanelIndex
    while (i < mcm.RightPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction


; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    string[] holds = mcm.GetHoldNames()

    string hold = holds[mcm.CurrentOptionIndex]

    if (oid == mcm.GetOption("undressing::allowUndressing"))
        mcm.SetInfoText("Determines if you can be undressed while imprisoned in " + hold + ".")

    elseif (oid == mcm.GetOption("undressing::minimumBountyToUndress"))
        mcm.SetInfoText("The minimum bounty required to be undressed in " + hold + "'s prison.")

    elseif (oid == mcm.GetOption("undressing::undressWhenDefeated"))
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + hold + ".")

    elseif (oid == mcm.GetOption("undressing::undressAtCell"))
        mcm.SetInfoText("Whether to be undressed at the cell in " + hold + "'s prison.")

    elseif (oid == mcm.GetOption("undressing::undressAtChest"))
        mcm.SetInfoText("Whether to be undressed at the chest in "  + hold + "'s prison.")

    elseif (oid == mcm.GetOption("undressing::forcedUndressing(bounty)"))
        mcm.SetInfoText("The minimum bounty required to be force undressed (You will have no possibility of action)")

    elseif (oid == mcm.GetOption("undressing::forcedUndressingWhenDefeated"))
        mcm.SetInfoText("Whether to be force undressed when defeated and imprisoned in " + hold + ".")

    elseif (oid == mcm.GetOption("undressing::stripSearchThoroughness"))
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped bare.")

    elseif (oid == mcm.GetOption("undressing::allowWearingClothes"))
        mcm.SetInfoText("Whether to allow wearing clothes while imprisoned in " + hold + ".")

    elseif (oid == mcm.GetOption("undressing::bountyToRe-dress"))
        mcm.SetInfoText("The maximum bounty you can have in order to be re-dressed while imprisoned in " + hold + ".")

    elseif (oid == mcm.GetOption("undressing::Re-dressWhenDefeated"))
        mcm.SetInfoText("Whether to have you re-dressed when defeated (Note: If the bounty exceeds the maximum, this option will have no effect.)")

    elseif (oid == mcm.GetOption("undressing::Re-dressAtCell"))
        mcm.SetInfoText("Whether to be re-dressed at the cell in " + hold + "'prison.")

    elseif (oid == mcm.GetOption("undressing::Re-dressAtChest"))
        mcm.SetInfoText("Whether to be re-dressed at the chest in " + hold + "'prison.")
    endif

    Debug(mcm, "OnOptionHighlight", "Expected OID: " + oid, mcm.IS_DEBUG)

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    string optionKey = mcm.GetKeyFromOption(oid)

    if (oid == mcm.GetOption("undressing::allowUndressing"))
        ; mcm.ToggleOption("undressing::allowUndressing")
    endif

    mcm.ToggleOption(optionKey)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    string optionKey = mcm.GetKeyFromOption(oid)
    Log(mcm, "OnOptionSliderOpen", "Option ID: " + oid + " (" + optionKey + ")")

    if (optionKey == "undressing::minimumBountyToUndress")
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY)
    elseif (optionKey == "undressing::stripSearchThoroughness")
        mcm.SetSliderOptions(minRange = 1, maxRange = 1000, intervalSteps = 1, defaultValue = 200, startValue = mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS)
    endif

    ; int optionValue = GetOptionIntValue(oid)

    ; int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    ; int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    ; int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    ; int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)

    ; if (oid == minimumBounty)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = int_if(optionValue, optionValue, 500))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == forcedUndressingMinBounty)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 1000, startValue = int_if(optionValue, optionValue, 1000))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == stripSearchThoroughness)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 1000, intervalSteps = 1, defaultValue = 200, startValue = int_if(optionValue, optionValue, 200))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == redressBounty)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 25, startValue = int_if(optionValue, optionValue, 25))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")
    ; endif

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

    ; int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    ; int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    ; int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    ; int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)

    ; mcm.SetSliderOptionValue(oid, value, string_if(oid == stripSearchThoroughness, "{0}", "{0} Bounty"))
    ; ; if (oid == minimumBounty)
    ; ;     SetOptionValueIntByKey("oid_undressing_minimumBounty" + mcm.CurrentOptionIndex , value as int)
    ; ; elseif (oid == forcedUndressingMinBounty)
    ; ;     SetOptionValueIntByKey("oid_undressing_forcedUndressingMinBounty" + mcm.CurrentOptionIndex , value as int)
    ; ; elseif (oid == stripSearchThoroughness)
    ; ;     SetOptionValueIntByKey("oid_undressing_stripSearchThoroughness" + mcm.CurrentOptionIndex , value as int)
    ; ; elseif (oid == redressBounty)
    ; ;     SetOptionValueIntByKey("oid_undressing_redressBounty" + mcm.CurrentOptionIndex , value as int)
    ; ; endif

    ; SetOptionValueInt(oid, value as int)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string input) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    mcm.UpdateIndex(oid)
    OnOptionHighlight(mcm, oid)
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, oid)
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, oid)
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, oid)
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, oid, value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, oid)
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, oid, menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, oid)
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, oid, color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, oid, keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, oid)
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, oid, inputValue)
endFunction
