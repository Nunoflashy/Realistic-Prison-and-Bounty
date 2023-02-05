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
    mcm.AddOptionToggle("Allow Undressing",                 mcm.UNDRESSING_DEFAULT_ALLOW, index)
    mcm.AddOptionSlider("Minimum Bounty to Undress",        mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, index)
    mcm.AddOptionToggle("Undress when Defeated",            mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED, index)
    mcm.AddOptionToggle("Undress at Cell",                  mcm.UNDRESSING_DEFAULT_AT_CELL, index)
    mcm.AddOptionToggle("Undress at Chest",                 mcm.UNDRESSING_DEFAULT_AT_CHEST, index)
    mcm.AddOptionSlider("Forced Undressing (Bounty)",       mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY, index)
    mcm.AddOptionToggle("Forced Undressing when Defeated",  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED, index)
    mcm.AddOptionSlider("Strip Search Thoroughness",        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, index)
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

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

    string hold = mcm.CurrentHold

    int optionId = mcm.GetOption(option)

    mcm.Debug("OnOptionHighlight", "Option ID: " + optionId)

    if (option == "Allow Undressing")
        mcm.SetInfoText("Determines if you can be undressed while imprisoned in " + hold + ".")

    elseif (option == "Minimum Bounty to Undress")
        mcm.SetInfoText("The minimum bounty required to be undressed in " + hold + "'s prison.")

    elseif (option == "Undress when Defeated")
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + hold + ".")

    elseif (option == "Undress at Cell")
        mcm.SetInfoText("Whether to be undressed at the cell in " + hold + "'s prison.")

    elseif (option == "Undress at Chest")
        mcm.SetInfoText("Whether to be undressed at the chest in "  + hold + "'s prison.")

    elseif (option == "Forced Undressing (Bounty)")
        mcm.SetInfoText("The minimum bounty required to be force undressed (You will have no possibility of action)")

    elseif (option == "Forced Undressing when Defeated")
        mcm.SetInfoText("Whether to be force undressed when defeated and imprisoned in " + hold + ".")

    elseif (option == "Strip Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped bare.")

    elseif (option == "undressing::allowWearingClothes")
        mcm.SetInfoText("Whether to allow wearing clothes while imprisoned in " + hold + ".")

    elseif (option == "undressing::bountyToRe-dress")
        mcm.SetInfoText("The maximum bounty you can have in order to be re-dressed while imprisoned in " + hold + ".")

    elseif (option == "undressing::Re-dressWhenDefeated")
        mcm.SetInfoText("Whether to have you re-dressed when defeated (Note: If the bounty exceeds the maximum, this option will have no effect.)")

    elseif (option == "undressing::Re-dressAtCell")
        mcm.SetInfoText("Whether to be re-dressed at the cell in " + hold + "'prison.")

    elseif (option == "undressing::Re-dressAtChest")
        mcm.SetInfoText("Whether to be re-dressed at the chest in " + hold + "'prison.")
    endif

    ; Debug(mcm, "OnOptionHighlight", "Expected OID: " + oid, mcm.IS_DEBUG)

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = GetPageName() + "::" + option

    ; if (oid == mcm.GetOption("undressing::allowUndressing"))
    ;     ; mcm.ToggleOption("undressing::allowUndressing")
    ; endif

    ; mcm.GetOptionValueBool("Undressing", "Allow Undressing", mcm.CurrentOptionIndex)
    ; mcm.GetOptionValueBool("Undressing", "Allow Undressing", mcm.INDEX_EASTMARCH)
    ; mcm.GetOptionValueBool("Clothing", "Allow Wearing Clothes", mcm.CurrentOptionIndex)

    ; mcm.Debug("Test", "OptionKey: " + optionKey)
    mcm.ToggleOption(optionKey)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = option
    ; Log(mcm, "OnOptionSliderOpen", "Option ID: " + oid + " (" + optionKey + ")")

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

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

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

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, string option, string input) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    mcm.UpdateIndex(oid)
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid), inputValue)
endFunction
