Scriptname RealisticPrisonAndBounty_MCM_Bounty hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Bounty"
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
    mcm.AddTextOption("", "Stats", mcm.OPTION_FLAG_DISABLED)
    mcm.oid_bounty_currentBounty[index] = mcm.AddTextOption("Current Bounty ", 4000.0 as int)
    mcm.oid_bounty_largestBounty[index] = mcm.AddTextOption("Largest Bounty ", 15000.0 as int)
    mcm.AddTextOption("Bounty History", 15000.0 as int)
    mcm.AddEmptyOption()

    mcm.AddTextOption("", "Bounty Decay", mcm.OPTION_FLAG_DISABLED)
    mcm.oid_bounty_enableBountyDecay[index] = mcm.AddToggleOption("Enable Bounty Decay", true)
    mcm.oid_bounty_decayInPrison[index]     = mcm.AddToggleOption("Decay while Imprisoned", true)
    mcm.oid_bounty_bountyLostPercent[index] = mcm.AddSliderOption("Bounty Lost (% of Bounty)", 1.0)
    mcm.oid_bounty_bountyLostFlat[index]    = mcm.AddSliderOption("Bounty Lost (Flat)", 1.0)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    mcm.oid_bounty_enableBountyDecayGeneral = mcm.AddToggleOption("Enable Bounty Decay", true)
    mcm.oid_bounty_updateInterval           = mcm.AddSliderOption("Update Interval (In-Game Time)", 1.0)

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

    int currentBounty   = mcm.GetOptionInListByOID(mcm.oid_bounty_currentBounty, oid)
    int largestBounty   = mcm.GetOptionInListByOID(mcm.oid_bounty_largestBounty, oid)
    int enableBountyDecay   = mcm.GetOptionInListByOID(mcm.oid_bounty_enableBountyDecay, oid)
    int decayInPrison       = mcm.GetOptionInListByOID(mcm.oid_bounty_decayInPrison, oid)
    int bountyLostPercent   = mcm.GetOptionInListByOID(mcm.oid_bounty_bountyLostPercent, oid)
    int bountyLostFlat      = mcm.GetOptionInListByOID(mcm.oid_bounty_bountyLostFlat, oid)

    ; mcm.SetInfoText( \
    ;     string_if (oid == currentBounty, "Your current bounty in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == largestBounty, "The largest bounty you acquired in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == enableBountyDecay, "Whether to enable bounty decaying for " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == decayInPrison, "Whether to allow bounty decaying while imprisoned in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == bountyLostPercent, "The amount of bounty lost as a percentage of the current bounty in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == bountyLostFlat, "The amount of bounty lost in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     "No description defined for this property." \
    ;     )))))) \
    ; )

    if (oid == currentBounty)
        mcm.SetInfoText("Your current bounty in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == largestBounty)
        mcm.SetInfoText("The largest bounty you acquired in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == enableBountyDecay)
        mcm.SetInfoText("Whether to enable bounty decaying for " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == decayInPrison)
        mcm.SetInfoText("Whether to allow bounty decaying while imprisoned in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == bountyLostPercent)
        mcm.SetInfoText("The amount of bounty lost as a percentage of the current bounty in " + holds[mcm.CurrentOptionIndex] + ".")
    elseif (oid == bountyLostFlat)
        mcm.SetInfoText("The amount of bounty lost in " + holds[mcm.CurrentOptionIndex] + ".")
    endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

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
