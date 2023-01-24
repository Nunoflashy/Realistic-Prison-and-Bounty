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
    if (! mcm.GetOptionValue(mcm.oid_frisking_allow[index]))
        flags = mcm.OPTION_FLAG_DISABLED
    endif

    mcm.oid_frisking_allow[index]                        = mcm.AddToggleOption("Allow Frisk Search",                    mcm.GetOptionValue(mcm.oid_frisking_allow[index]))
    mcm.oid_frisking_minimumBounty[index]                = mcm.AddSliderOption("Minimum Bounty for Frisking",           mcm.GetOptionValue(mcm.oid_frisking_minimumBounty[index]), "{0}", flags)
    mcm.oid_frisking_guaranteedPayableBounty[index]      = mcm.AddSliderOption("Guaranteed Payable Bounty",             mcm.GetOptionValue(mcm.oid_frisking_guaranteedPayableBounty[index]), "{0}", flags)  ; -1 to Disable
    mcm.oid_frisking_maximumPayableBounty[index]         = mcm.AddSliderOption("Maximum Payable Bounty",                mcm.GetOptionValue(mcm.oid_frisking_maximumPayableBounty[index]), "{0}", flags)  ; -1 to Disable
    mcm.oid_frisking_maximumPayableBountyChance[index]   = mcm.AddSliderOption("Maximum Payable Bounty (Chance)",       mcm.GetOptionValue(mcm.oid_frisking_maximumPayableBountyChance[index]), "{0}%", flags)  ; -1 to Disable
    mcm.oid_frisking_friskSearchThoroughness[index]      = mcm.AddSliderOption("Frisk Search Thoroughness",             mcm.GetOptionValue(mcm.oid_frisking_friskSearchThoroughness[index]), "{0}", flags) ; -1 to Disable
    mcm.oid_frisking_confiscateStolenItems[index]        = mcm.AddToggleOption("Confiscate Stolen Items",               mcm.GetOptionValue(mcm.oid_frisking_confiscateStolenItems[index]), flags)
    mcm.oid_frisking_stripSearchStolenItems[index]       = mcm.AddToggleOption("Strip Search if Stolen Items Found",    mcm.GetOptionValue(mcm.oid_frisking_stripSearchStolenItems[index]), flags)
    mcm.oid_frisking_stripSearchStolenItemsNumber[index] = mcm.AddSliderOption("Minimum No. of Stolen Items Required",  mcm.GetOptionValue(mcm.oid_frisking_stripSearchStolenItemsNumber[index]), "{0}", flags) ; -1 to Disable
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

; Events

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


    mcm.SetInfoText( \
        string_if (oid == allowFrisking, "Determines if you can be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".", \
        string_if (oid == minimumBounty, "The minimum bounty required to be frisk searched in " + holds[mcm.CurrentOptionIndex] + ".", \
        string_if (oid == guaranteedPayableBounty, "The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + holds[mcm.CurrentOptionIndex] + ".", \
        string_if (oid == maximumPayableBounty, "The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.", \
        string_if (oid == maximumPayableBountyChance, "The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.", \
        string_if (oid == friskSearchThoroughness, "The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.", \
        string_if (oid == confiscateStolenItems, "Whether to confiscate any stolen items found during the frisking.", \
        string_if (oid == stripSearchStolenItems, "Whether to have the player undressed if stolen items are found.", \
        string_if (oid == stripSearchStolenItemsNumber, "The minimum number of stolen items required to have the player undressed.", \
        "No description defined for this option." \
        ))))))))) \
    )

    Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)

    float endTime = Utility.GetCurrentRealTime()
    float elapsedTime = endTime - startTime
    Log(mcm, "Frisking::OnHighlight", "execution took " + elapsedTime + " seconds.")
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

    bool optionState = mcm.GetOptionValue(oid) as bool
    mcm.SetToggleOptionValue(oid, bool_if(optionState, false, true))
    mcm.SetOptionValueBool(oid, bool_if(optionState, false, true))
    optionState = mcm.GetOptionValue(oid) as bool

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
        int flags = int_if(!optionState, mcm.OPTION_FLAG_DISABLED, mcm.OPTION_FLAG_NONE)

        mcm.SetOptionFlags(mcm.oid_frisking_minimumBounty[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_guaranteedPayableBounty[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_maximumPayableBounty[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_maximumPayableBountyChance[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_friskSearchThoroughness[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_confiscateStolenItems[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_stripSearchStolenItems[mcm.CurrentOptionIndex], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_stripSearchStolenItemsNumber[mcm.CurrentOptionIndex], flags)

        ; mcm.oid_frisking_allow_state[index] = ! mcm.oid_frisking_allow_state[index]
        ; mcm.SetToggleOptionValue(oid, mcm.oid_frisking_allow_state[index])
        ; mcm.SetOptionValue(oid, mcm.oid_frisking_allow_state[index] as int)
        return

    elseif (oid == stripSearchStolenItems)
        mcm.SetOptionFlags( \
        stripSearchStolenItemsNumber, \
            int_if(optionState, mcm.OPTION_FLAG_NONE, mcm.OPTION_FLAG_DISABLED) \
        )
        return

    endif
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global

    int optionValue = mcm.GetOptionValue(oid)

    if (oid == mcm.oid_frisking_minimumBounty[index])
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = int_if(optionValue, optionValue, 500))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == mcm.oid_frisking_guaranteedPayableBounty[index])
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 1000, startValue = int_if(optionValue, optionValue, 1000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == mcm.oid_frisking_maximumPayableBounty[index])
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 2000, startValue = int_if(optionValue, optionValue, 2000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == mcm.oid_frisking_maximumPayableBountyChance[index])
        mcm.SetSliderOptions(minRange = 1, maxRange = 100, intervalSteps = 1, defaultValue = 25, startValue = int_if(optionValue, optionValue, 25))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == mcm.oid_frisking_friskSearchThoroughness[index])
        mcm.SetSliderOptions(minRange = 1, maxRange = 1000, intervalSteps = 1, defaultValue = 400, startValue = int_if(optionValue, optionValue, 400))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == mcm.oid_frisking_stripSearchStolenItemsNumber[index])
        mcm.SetSliderOptions(minRange = 1, maxRange = 10000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")
    endif
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value, int index) global
    if (oid == mcm.oid_frisking_minimumBounty[index])
        mcm.SetSliderOptionValue(oid, value)
        mcm.SetOptionValue(oid, value as int)

    elseif (oid == mcm.oid_frisking_guaranteedPayableBounty[index])
        mcm.SetSliderOptionValue(oid, value)
        mcm.SetOptionValue(oid, value as int)

    elseif (oid == mcm.oid_frisking_maximumPayableBounty[index])
        mcm.SetSliderOptionValue(oid, value)
        mcm.SetOptionValue(oid, value as int)

    elseif (oid == mcm.oid_frisking_maximumPayableBountyChance[index])
        mcm.SetSliderOptionValue(oid, value, "{0}%")
        mcm.SetOptionValue(oid, value as int)

    elseif (oid == mcm.oid_frisking_friskSearchThoroughness[index])
        mcm.SetSliderOptionValue(oid, value)
        mcm.SetOptionValue(oid, value as int)
        
    elseif (oid == mcm.oid_frisking_stripSearchStolenItemsNumber[index])
        mcm.SetSliderOptionValue(oid, value)
        mcm.SetOptionValue(oid, value as int)
    endif
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex, int itemIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color, int index) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string input, int index) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keyCode, string conflictControl, string conflictName, int index) global
    
endFunction



function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionHighlight(mcm, oid)

    ; int i = 0
    ; while (i < mcm.GetHoldCount())
    ;     OnOptionHighlight(mcm, oid, i)
    ;     i += 1
    ; endWhile
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionDefault(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, oid)


    ; int i = 0
    ; while (i < mcm.GetHoldCount())
    ;     OnOptionSelect(mcm, oid, i)
    ;     i += 1
    ; endWhile

    ; bool optionState = mcm.GetOptionValue(oid) as bool

    ; mcm.SetToggleOptionValue(oid, bool_if(optionState, false, true))
    ; mcm.SetOptionValueBool(oid, bool_if(optionState, false, true))

endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionSliderOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionSliderAccept(mcm, oid, value, i)
        i += 1
    endWhile
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionMenuOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionMenuAccept(mcm, oid, menuIndex, i)
        i += 1
    endWhile
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionColorOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionColorAccept(mcm, oid, color, i)
        i += 1
    endWhile
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    
    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionKeymapChange(mcm, oid, keycode, conflictControl, conflictName, i)
        i += 1
    endWhile
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionInputOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global

    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionInputAccept(mcm, oid, inputValue, i)
        i += 1
    endWhile
endFunction
