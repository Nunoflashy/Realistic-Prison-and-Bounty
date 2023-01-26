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

    int flags = mcm.OPTION_FLAG_NONE

    ; Allow Frisk search is off, disable all options
    if (! GetOptionValue(mcm.oid_frisking_allow[index]))
        flags = mcm.OPTION_FLAG_DISABLED
    endif

    mcm.oid_frisking_allow[index]                        = mcm.AddToggleOption("Allow Frisk Search",                    GetOptionValue(mcm.oid_frisking_allow[index]))
    mcm.oid_frisking_minimumBounty[index]                = mcm.AddSliderOption("Minimum Bounty for Frisking",           GetOptionValue(mcm.oid_frisking_minimumBounty[index]), "{0}", flags)
    mcm.oid_frisking_guaranteedPayableBounty[index]      = mcm.AddSliderOption("Guaranteed Payable Bounty",             GetOptionValue(mcm.oid_frisking_guaranteedPayableBounty[index]), "{0}", flags)  ; -1 to Disable
    mcm.oid_frisking_maximumPayableBounty[index]         = mcm.AddSliderOption("Maximum Payable Bounty",                GetOptionValue(mcm.oid_frisking_maximumPayableBounty[index]), "{0}", flags)  ; -1 to Disable
    mcm.oid_frisking_maximumPayableBountyChance[index]   = mcm.AddSliderOption("Maximum Payable Bounty (Chance)",       GetOptionValue(mcm.oid_frisking_maximumPayableBountyChance[index]), "{0}%", flags)  ; -1 to Disable
    mcm.oid_frisking_friskSearchThoroughness[index]      = mcm.AddSliderOption("Frisk Search Thoroughness",             GetOptionValue(mcm.oid_frisking_friskSearchThoroughness[index]), "{0}", flags) ; -1 to Disable
    mcm.oid_frisking_confiscateStolenItems[index]        = mcm.AddToggleOption("Confiscate Stolen Items",               GetOptionValue(mcm.oid_frisking_confiscateStolenItems[index]), flags)
    mcm.oid_frisking_stripSearchStolenItems[index]       = mcm.AddToggleOption("Strip Search if Stolen Items Found",    GetOptionValue(mcm.oid_frisking_stripSearchStolenItems[index]), flags)
    mcm.oid_frisking_stripSearchStolenItemsNumber[index] = mcm.AddSliderOption("Minimum No. of Stolen Items Required",  GetOptionValue(mcm.oid_frisking_stripSearchStolenItemsNumber[index]), "{0}", flags) ; -1 to Disable

    mcm.SetOptionDependencyBool( \
        mcm.oid_frisking_stripSearchStolenItems[index], \ 
        GetOptionValue(mcm.oid_frisking_confiscateStolenItems[index]) \
    )
    mcm.SetOptionDependencyBool( \
        mcm.oid_frisking_stripSearchStolenItemsNumber[index], \ 
        GetOptionValue(mcm.oid_frisking_confiscateStolenItems[index]) && \
        GetOptionValue(mcm.oid_frisking_confiscateStolenItems[index]) \
    )

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

    int highlightedOption = oid

    float startTime = Utility.GetCurrentRealTime()

    int allowFrisking               = mcm.GetOptionInListByOID(mcm.oid_frisking_allow, oid)
    int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, highlightedOption)
    int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, highlightedOption)
    int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, highlightedOption)
    int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, highlightedOption)
    int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, highlightedOption)     
    int confiscateStolenItems       = mcm.GetOptionInListByOID(mcm.oid_frisking_confiscateStolenItems, highlightedOption)
    int stripSearchStolenItems      = mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItems, highlightedOption)  
    int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, highlightedOption)


    ; mcm.SetInfoText( \
    ;     string_if (oid == allowFrisking, "Determines if you can be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == minimumBounty, "The minimum bounty required to be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == guaranteedPayableBounty, "The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == maximumPayableBounty, "The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.", \
    ;     string_if (oid == maximumPayableBountyChance, "The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.", \
    ;     string_if (oid == friskSearchThoroughness, "The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.", \
    ;     string_if (oid == confiscateStolenItems, "Whether to confiscate any stolen items found during the frisking.", \
    ;     string_if (oid == stripSearchStolenItems, "Whether to have the player undressed if stolen items are found.", \
    ;     string_if (oid == stripSearchStolenItemsNumber, "The minimum number of stolen items required to have the player undressed.", \
    ;     "No description defined for this option." \
    ;     ))))))))) \
    ; )

    if (oid == allowFrisking)
        mcm.SetInfoText("Determines if you can be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == minimumBounty)
        mcm.SetInfoText("The minimum bounty required to be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == guaranteedPayableBounty)
        mcm.SetInfoText("The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == maximumPayableBounty)
        mcm.SetInfoText("The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.")
    elseif (oid == maximumPayableBountyChance)
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")
    elseif (oid == friskSearchThoroughness)
        mcm.SetInfoText("The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.")
    elseif (oid == confiscateStolenItems)
        mcm.SetInfoText("Whether to confiscate any stolen items found during the frisking.")
    elseif (oid == stripSearchStolenItems)
        mcm.SetInfoText("Whether to have the player undressed if stolen items are found.")
    elseif (oid == stripSearchStolenItemsNumber)
        mcm.SetInfoText("The minimum number of stolen items required to have the player undressed.")
    endif

    Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)

    float endTime = Utility.GetCurrentRealTime()
    float elapsedTime = endTime - startTime
    Log(mcm, "Frisking::OnHighlight", "execution took " + elapsedTime + " seconds.")
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

    bool optionState = mcm.ToggleOption(oid)

    int allowFrisking               = mcm.GetOptionInListByOID(mcm.oid_frisking_allow, oid)
    int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, oid)
    int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, oid)
    int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, oid)
    int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, oid)
    int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, oid)     
    int confiscateStolenItems       = mcm.GetOptionInListByOID(mcm.oid_frisking_confiscateStolenItems, oid)
    int stripSearchStolenItems      = mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItems, oid)  
    int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, oid)

    if (oid == allowFrisking)
        ; Enable all options except confiscating/stripping related, if allowFrisking is enabled, otherwise disable them.
        mcm.SetOptionDependencyBool(mcm.oid_frisking_minimumBounty[mcm.CurrentOptionIndex], GetOptionValue(oid))
        mcm.SetOptionDependencyBool(mcm.oid_frisking_guaranteedPayableBounty[mcm.CurrentOptionIndex], GetOptionValue(oid))
        mcm.SetOptionDependencyBool(mcm.oid_frisking_maximumPayableBounty[mcm.CurrentOptionIndex], GetOptionValue(oid))
        mcm.SetOptionDependencyBool(mcm.oid_frisking_maximumPayableBountyChance[mcm.CurrentOptionIndex], GetOptionValue(oid))
        mcm.SetOptionDependencyBool(mcm.oid_frisking_friskSearchThoroughness[mcm.CurrentOptionIndex], GetOptionValue(oid))
        mcm.SetOptionDependencyBool(mcm.oid_frisking_confiscateStolenItems[mcm.CurrentOptionIndex], GetOptionValue(oid))

        ; Only enable stripSearchStolenItems if allowFrisking and confiscateStolenItems are active, otherwise disable it.
        mcm.SetOptionDependencyBool( \
            mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex], \
            optionState && \ 
            GetOptionValue(mcm.oid_frisking_confiscateStolenItems[mcm.CurrentOptionIndex]) \
        )

        ; Only enable stripSearchStolenItemsNumber if allowFrisking, confiscateStolenItems and stripSearchStolenItems are active, otherwise disable it.
        mcm.SetOptionDependencyBool( \
            mcm.oid_frisking_stripSearchStolenItemsNumber[mcm.CurrentOptionIndex], \
            optionState && GetOptionValue(mcm.oid_frisking_confiscateStolenItems[mcm.CurrentOptionIndex]) && \
            GetOptionValue(mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex]) \
        )
    endif

    ; if the option selected is confiscateStolenItems
    if (oid == confiscateStolenItems)

        ; Only enable stripSearchStolenItems if this toggle is active, otherwise disable it.
        mcm.SetOptionDependencyBool( \
            mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex], \
            optionState \
        )

        ; Only enable stripSearchStolenItemsNumber if this and the toggle stripSearchStolenItems is active, otherwise disable it.
        mcm.SetOptionDependencyBool( \
            mcm.oid_frisking_stripSearchStolenItemsNumber[mcm.CurrentOptionIndex], \
            optionState && \
            GetOptionValue(mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex]) \
         )

    endif

    if (oid == stripSearchStolenItems)
        ; Only enable stripSearchStolenItemsNumber if this toggle is active, otherwise disable it.
        mcm.SetOptionDependencyBool( \
            mcm.oid_frisking_stripSearchStolenItemsNumber[mcm.CurrentOptionIndex], \
            optionState \
        )
    endif
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    int optionValue = GetOptionValue(oid)

    int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, oid)
    int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, oid)
    int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, oid)
    int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, oid)
    int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, oid)     
    int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, oid)

    if (oid == minimumBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = int_if(optionValue, optionValue, 500))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == guaranteedPayableBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 1000, startValue = int_if(optionValue, optionValue, 1000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == maximumPayableBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 2000, startValue = int_if(optionValue, optionValue, 2000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == maximumPayableBountyChance)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100, intervalSteps = 1, defaultValue = 25, startValue = int_if(optionValue, optionValue, 25))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == friskSearchThoroughness)
        mcm.SetSliderOptions(minRange = 1, maxRange = 1000, intervalSteps = 1, defaultValue = 400, startValue = int_if(optionValue, optionValue, 400))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == stripSearchStolenItemsNumber)
        mcm.SetSliderOptions(minRange = 1, maxRange = 10000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")
    endif
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

    ; int allowFrisking               = mcm.GetOptionInListByOID(mcm.oid_frisking_allow, oid)
    ; int minimumBounty               = mcm.GetOptionInListByOID(mcm.oid_frisking_minimumBounty, oid)
    ; int guaranteedPayableBounty     = mcm.GetOptionInListByOID(mcm.oid_frisking_guaranteedPayableBounty, oid)
    ; int maximumPayableBounty        = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBounty, oid)
    int maximumPayableBountyChance  = mcm.GetOptionInListByOID(mcm.oid_frisking_maximumPayableBountyChance, oid)
    ; int friskSearchThoroughness     = mcm.GetOptionInListByOID(mcm.oid_frisking_friskSearchThoroughness, oid)     
    ; int confiscateStolenItems       = mcm.GetOptionInListByOID(mcm.oid_frisking_confiscateStolenItems, oid)
    ; int stripSearchStolenItems      = mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItems, oid)  
    ; int stripSearchStolenItemsNumber= mcm.GetOptionInListByOID(mcm.oid_frisking_stripSearchStolenItemsNumber, oid)

    mcm.SetSliderOptionValue(oid, value, string_if(oid == maximumPayableBountyChance, "{0}%", "{0}"))
    SetOptionValueInt(oid, value as int)
    ; if (oid == mcm.oid_frisking_minimumBounty[index])
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.SetOptionValue(oid, value as int)

    ; elseif (oid == mcm.oid_frisking_guaranteedPayableBounty[index])
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.SetOptionValue(oid, value as int)

    ; elseif (oid == mcm.oid_frisking_maximumPayableBounty[index])
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.SetOptionValue(oid, value as int)

    ; elseif (oid == mcm.oid_frisking_maximumPayableBountyChance[index])
    ;     mcm.SetSliderOptionValue(oid, value, "{0}%")
    ;     mcm.SetOptionValue(oid, value as int)

    ; elseif (oid == mcm.oid_frisking_friskSearchThoroughness[index])
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.SetOptionValue(oid, value as int)
        
    ; elseif (oid == mcm.oid_frisking_stripSearchStolenItemsNumber[index])
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.SetOptionValue(oid, value as int)
    ; endif
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
