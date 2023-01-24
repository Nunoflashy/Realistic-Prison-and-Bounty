Scriptname RealisticPrisonAndBounty_MCM_Frisking hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "FRISKING"
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
    mcm.oid_frisking_allow[index]                        = mcm.AddToggleOption("Allow Frisk Search", true)
    mcm.oid_frisking_minimumBounty[index]                = mcm.AddSliderOption("Minimum Bounty for Frisking", mcm.GetOptionOID(mcm.oid_frisking_minimumBounty[index]))
    mcm.oid_frisking_guaranteedPayableBounty[index]      = mcm.AddSliderOption("Guaranteed Payable Bounty", mcm.GetOptionOID(mcm.oid_frisking_guaranteedPayableBounty[index]))  ; -1 to Disable
    mcm.oid_frisking_maximumPayableBounty[index]         = mcm.AddSliderOption("Maximum Payable Bounty", mcm.GetOptionOID(mcm.oid_frisking_maximumPayableBounty[index]))  ; -1 to Disable
    mcm.oid_frisking_maximumPayableBountyChance[index]   = mcm.AddSliderOption("Maximum Payable Bounty (Chance)", mcm.GetOptionOID(mcm.oid_frisking_maximumPayableBountyChance[index]))  ; -1 to Disable
    mcm.oid_frisking_friskSearchThoroughness[index]      = mcm.AddSliderOption("Frisk Search Thoroughness", mcm.GetOptionOID(mcm.oid_frisking_friskSearchThoroughness[index])) ; -1 to Disable
    mcm.oid_frisking_confiscateStolenItems[index]        = mcm.AddToggleOption("Confiscate Stolen Items", true)
    mcm.oid_frisking_stripSearchStolenItems[index]       = mcm.AddToggleOption("Strip Search if Stolen Items Found", true)
    mcm.oid_frisking_stripSearchStolenItemsNumber[index] = mcm.AddSliderOption("Minimum No. of Stolen Items Required", mcm.GetOptionOID(mcm.oid_frisking_stripSearchStolenItemsNumber[index])) ; -1 to Disable
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

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    string[] holds = mcm.GetHoldNames()

    if (oid == mcm.oid_frisking_allow[index])
        mcm.SetInfoText("Determines if you can be frisk searched in " + holds[index] + ".")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_minimumBounty[index])
        mcm.SetInfoText("The minimum bounty required to be frisk searched in " + holds[index] + ".")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_guaranteedPayableBounty[index])
        mcm.SetInfoText("The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + holds[index] + ".")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_maximumPayableBounty[index])
        mcm.SetInfoText("The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + holds[index] + ".\n" + \ 
                        "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_maximumPayableBountyChance[index])
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_friskSearchThoroughness[index])
        mcm.SetInfoText("The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.")  
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_confiscateStolenItems[index])
        mcm.SetInfoText("Whether to confiscate any stolen items found during the frisking.")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_frisking_stripSearchStolenItems[index])
        mcm.SetInfoText("Whether to have the player undressed if stolen items are found.")
        Log(mcm, "Frisking::OnOptionHighlight", "Option = " + oid)
        return
        
    elseif (oid == mcm.oid_frisking_stripSearchStolenItemsNumber[index])
        mcm.SetInfoText("The minimum number of stolen items required to have the player undressed.")
        return
    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    if (oid == mcm.oid_frisking_allow[index])
        int flags = int_if(mcm.oid_frisking_allow_state[index], mcm.OPTION_FLAG_DISABLED, mcm.OPTION_FLAG_NONE)

        mcm.SetOptionFlags(mcm.oid_frisking_minimumBounty[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_guaranteedPayableBounty[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_maximumPayableBounty[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_maximumPayableBountyChance[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_friskSearchThoroughness[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_confiscateStolenItems[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_stripSearchStolenItems[index], flags)
        mcm.SetOptionFlags(mcm.oid_frisking_stripSearchStolenItemsNumber[index], flags)

        mcm.oid_frisking_allow_state[index] = ! mcm.oid_frisking_allow_state[index]
        mcm.SetToggleOptionValue(oid, mcm.oid_frisking_allow_state[index])

    elseif (oid == mcm.oid_frisking_stripSearchStolenItems[index])
        int flags = int_if(mcm.oid_frisking_stripSearchStolenItems_state[index], mcm.OPTION_FLAG_DISABLED, mcm.OPTION_FLAG_NONE)

        mcm.oid_frisking_stripSearchStolenItems_state[index] = ! mcm.oid_frisking_stripSearchStolenItems_state[index]
        mcm.SetToggleOptionValue(oid, mcm.oid_frisking_stripSearchStolenItems_state[index])
        mcm.SetOptionFlags(mcm.oid_frisking_stripSearchStolenItemsNumber[index], flags)
    endif
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    mcm.SetSliderDialogRange(0, 1000)
    mcm.SetSliderDialogInterval(1)
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value, int index) global
    mcm.SetSliderOptionValue(oid, value)
    mcm.SetOptionOID(oid, value as int)
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

    string[] holds = mcm.GetHoldNames()

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionHighlight(mcm, oid, i)
        i += 1
    endWhile
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

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionSelect(mcm, oid, i)
        i += 1
    endWhile
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
