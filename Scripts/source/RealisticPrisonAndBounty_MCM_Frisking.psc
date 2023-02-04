Scriptname RealisticPrisonAndBounty_MCM_Frisking hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return " Frisking"
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
    mcm.AddOptionToggleEx("Allow Frisk Search",                     mcm.FRISKING_DEFAULT_ALLOW, index)
    mcm.AddOptionSliderEx("Minimum Bounty for Frisking",            mcm.FRISKING_DEFAULT_MIN_BOUNTY, index)
    mcm.AddOptionSliderEx("Guaranteed Payable Bounty",              mcm.FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY, index)
    mcm.AddOptionSliderEx("Maximum Payable Bounty",                 mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY, index)
    mcm.AddOptionSliderEx("Maximum Payable Bounty (Chance)",        mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE, index)
    mcm.AddOptionSliderEx("Frisk Search Thoroughness",              mcm.FRISKING_DEFAULT_FRISK_THOROUGHNESS, index)
    mcm.AddOptionToggleEx("Confiscate Stolen Items",                mcm.FRISKING_DEFAULT_CONFISCATE_ITEMS, index)
    mcm.AddOptionToggleEx("Strip Search if Stolen Items Found",     mcm.FRISKING_DEFAULT_STRIP_IF_STOLEN_FOUND, index)
    mcm.AddOptionSliderEx("Minimum No. of Stolen Items Required",   mcm.FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED, index)


    ; mcm.SetOptionDependencyBoolSingle( \
    ;     mcm.oid_frisking_confiscateStolenItems[index], \ 
    ;     GetOptionIntValue(mcm.oid_frisking_allow[index]) \
    ; )

    ; mcm.SetOptionDependencyBoolSingle( \
    ;     mcm.oid_frisking_stripSearchStolenItems[index], \ 
    ;     GetOptionIntValue(mcm.oid_frisking_confiscateStolenItems[index]) && \
    ;     GetOptionIntValue(mcm.oid_frisking_allow[index]) \
    ; )
    ; mcm.SetOptionDependencyBoolSingle( \
    ;     mcm.oid_frisking_stripSearchStolenItemsNumber[index], \ 
    ;     GetOptionIntValue(mcm.oid_frisking_confiscateStolenItems[index]) && \
    ;     GetOptionIntValue(mcm.oid_frisking_confiscateStolenItems[index]) && \
    ;     GetOptionIntValue(mcm.oid_frisking_allow[index]) \
    ; )

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
    string[] holds = mcm.GetHoldNames()
    string hold = holds[mcm.CurrentOptionIndex]

    ; float startTime = Utility.GetCurrentRealTime()

    ; int allowFrisking               = mcm.GetOptionInListByOID(mcm.oid_frisking_allow, oid)
    ; int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, highlightedOption)
    ; int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, highlightedOption)
    ; int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, highlightedOption)
    ; int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, highlightedOption)
    ; int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, highlightedOption)     
    ; int confiscateStolenItems       = mcm.GetOptionInListByOID(mcm.oid_frisking_confiscateStolenItems, highlightedOption)
    ; int stripSearchStolenItems      = mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItems, highlightedOption)  
    ; int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, highlightedOption)


    ; ; mcm.SetInfoText( \
    ; ;     string_if (oid == allowFrisking, "Determines if you can be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == minimumBounty, "The minimum bounty required to be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == guaranteedPayableBounty, "The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == maximumPayableBounty, "The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.", \
    ; ;     string_if (oid == maximumPayableBountyChance, "The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.", \
    ; ;     string_if (oid == friskSearchThoroughness, "The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.", \
    ; ;     string_if (oid == confiscateStolenItems, "Whether to confiscate any stolen items found during the frisking.", \
    ; ;     string_if (oid == stripSearchStolenItems, "Whether to have the player undressed if stolen items are found.", \
    ; ;     string_if (oid == stripSearchStolenItemsNumber, "The minimum number of stolen items required to have the player undressed.", \
    ; ;     "No description defined for this option." \
    ; ;     ))))))))) \
    ; ; )

    ; if (oid == allowFrisking)
    ;     mcm.SetInfoText("Determines if you can be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == minimumBounty)
    ;     mcm.SetInfoText("The minimum bounty required to be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == guaranteedPayableBounty)
    ;     mcm.SetInfoText("The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == maximumPayableBounty)
    ;     mcm.SetInfoText("The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.")
    ; elseif (oid == maximumPayableBountyChance)
    ;     mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")
    ; elseif (oid == friskSearchThoroughness)
    ;     mcm.SetInfoText("The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.")
    ; elseif (oid == confiscateStolenItems)
    ;     mcm.SetInfoText("Whether to confiscate any stolen items found during the frisking.")
    ; elseif (oid == stripSearchStolenItems)
    ;     mcm.SetInfoText("Whether to have the player undressed if stolen items are found.")
    ; elseif (oid == stripSearchStolenItemsNumber)
    ;     mcm.SetInfoText("The minimum number of stolen items required to have the player undressed.")
    ; endif

    ; Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)

    ; float endTime = Utility.GetCurrentRealTime()
    ; float elapsedTime = endTime - startTime
    ; Log(mcm, "Frisking::OnHighlight", "execution took " + elapsedTime + " seconds.")
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = option

    mcm.ToggleOption(optionKey)
    ; bool optionState = mcm.ToggleOption(oid)

    ; int allowFrisking               = mcm.GetOptionInListByOID(mcm.oid_frisking_allow, oid)
    ; int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, oid)
    ; int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, oid)
    ; int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, oid)
    ; int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, oid)
    ; int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, oid)     
    ; int confiscateStolenItems       = mcm.GetOptionInListByOID(mcm.oid_frisking_confiscateStolenItems, oid)
    ; int stripSearchStolenItems      = mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItems, oid)  
    ; int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, oid)

    ; if (oid == allowFrisking)
    ;     ; Enable all options except confiscating/stripping related, if allowFrisking is enabled, otherwise disable them.
    ;     mcm.SetOptionDependencyBool(mcm.oid_frisking_minimumBounty, GetOptionIntValue(oid))
    ;     mcm.SetOptionDependencyBool(mcm.oid_frisking_guaranteedPayableBounty, GetOptionIntValue(oid))
    ;     mcm.SetOptionDependencyBool(mcm.oid_frisking_maximumPayableBounty, GetOptionIntValue(oid))
    ;     mcm.SetOptionDependencyBool(mcm.oid_frisking_maximumPayableBountyChance, GetOptionIntValue(oid))
    ;     mcm.SetOptionDependencyBool(mcm.oid_frisking_friskSearchThoroughness, GetOptionIntValue(oid))
    ;     mcm.SetOptionDependencyBool(mcm.oid_frisking_confiscateStolenItems, GetOptionIntValue(oid))

    ;     ; ; Only enable stripSearchStolenItems if allowFrisking and confiscateStolenItems are active, otherwise disable it.
    ;     mcm.SetOptionDependencyBool( \
    ;         mcm.oid_frisking_stripSearchStolenItems, \
    ;         optionState && \ 
    ;         GetOptionIntValue(mcm.oid_frisking_confiscateStolenItems[mcm.CurrentOptionIndex]) \
    ;     )

    ;     ; Only enable stripSearchStolenItemsNumber if allowFrisking, confiscateStolenItems and stripSearchStolenItems are active, otherwise disable it.
    ;     mcm.SetOptionDependencyBool( \
    ;         mcm.oid_frisking_stripSearchStolenItemsNumber, \
    ;         optionState && GetOptionIntValue(mcm.oid_frisking_confiscateStolenItems[mcm.CurrentOptionIndex]) && \
    ;         GetOptionIntValue(mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex]) \
    ;     )
    ; endif

    ; ; if the option selected is confiscateStolenItems
    ; if (oid == confiscateStolenItems)

    ;     ; Only enable stripSearchStolenItems if this toggle is active, otherwise disable it.
    ;     mcm.SetOptionDependencyBool( \
    ;         mcm.oid_frisking_stripSearchStolenItems, \
    ;         optionState \
    ;     )

    ;     ; Only enable stripSearchStolenItemsNumber if this and the toggle stripSearchStolenItems is active, otherwise disable it.
    ;     mcm.SetOptionDependencyBool( \
    ;         mcm.oid_frisking_stripSearchStolenItemsNumber, \
    ;         optionState && \
    ;         GetOptionIntValue(mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex]) \
    ;      )

    ; endif

    ; if (oid == stripSearchStolenItems)
    ;     ; Only enable stripSearchStolenItemsNumber if this toggle is active, otherwise disable it.
    ;     mcm.SetOptionDependencyBool( \
    ;         mcm.oid_frisking_stripSearchStolenItemsNumber, \
    ;         optionState \
    ;     )
    ; endif
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

    ; int optionValue = GetOptionIntValue(oid)

    ; int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, oid)
    ; int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, oid)
    ; int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, oid)
    ; int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, oid)
    ; int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, oid)     
    ; int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, oid)

    ; if (oid == minimumBounty)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = int_if(optionValue != -1, optionValue, 500))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == guaranteedPayableBounty)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 1000, startValue = int_if(optionValue, optionValue, 1000))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == maximumPayableBounty)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 2000, startValue = int_if(optionValue, optionValue, 2000))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == maximumPayableBountyChance)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 100, intervalSteps = 1, defaultValue = 25, startValue = int_if(optionValue, optionValue, 25))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == friskSearchThoroughness)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 1000, intervalSteps = 1, defaultValue = 400, startValue = int_if(optionValue, optionValue, 400))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    ; elseif (oid == stripSearchStolenItemsNumber)
    ;     mcm.SetSliderOptions(minRange = 1, maxRange = 10000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
    ;     Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")
    ; endif
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

    ; ; int allowFrisking               = mcm.GetOptionInListByOID(mcm.oid_frisking_allow, oid)
    ; ; int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, oid)
    ; ; int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, oid)
    ; ; int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, oid)
    ; int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, oid)
    ; ; int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, oid)     
    ; ; int confiscateStolenItems       = mcm.GetOptionInListByOID(mcm.oid_frisking_confiscateStolenItems, oid)
    ; ; int stripSearchStolenItems      = mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItems, oid)  
    ; ; int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, oid)

    ; mcm.SetSliderOptionValue(oid, value, string_if(oid == maximumPayableBountyChance, "{0}%", "{0}"))
    ; SetOptionValueInt(oid, value as int)
    ; ; if (oid == mcm.oid_frisking_minimumBounty[index])
    ; ;     mcm.SetSliderOptionValue(oid, value)
    ; ;     mcm.SetOptionValue(oid, value as int)

    ; ; elseif (oid == mcm.oid_frisking_guaranteedPayableBounty[index])
    ; ;     mcm.SetSliderOptionValue(oid, value)
    ; ;     mcm.SetOptionValue(oid, value as int)

    ; ; elseif (oid == mcm.oid_frisking_maximumPayableBounty[index])
    ; ;     mcm.SetSliderOptionValue(oid, value)
    ; ;     mcm.SetOptionValue(oid, value as int)

    ; ; elseif (oid == mcm.oid_frisking_maximumPayableBountyChance[index])
    ; ;     mcm.SetSliderOptionValue(oid, value, "{0}%")
    ; ;     mcm.SetOptionValue(oid, value as int)

    ; ; elseif (oid == mcm.oid_frisking_friskSearchThoroughness[index])
    ; ;     mcm.SetSliderOptionValue(oid, value)
    ; ;     mcm.SetOptionValue(oid, value as int)
        
    ; ; elseif (oid == mcm.oid_frisking_stripSearchStolenItemsNumber[index])
    ; ;     mcm.SetSliderOptionValue(oid, value)
    ; ;     mcm.SetOptionValue(oid, value as int)
    ; ; endif
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
