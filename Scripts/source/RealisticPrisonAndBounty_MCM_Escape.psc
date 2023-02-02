Scriptname RealisticPrisonAndBounty_MCM_Escape hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Escape"
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
    mcm.AddOptionSliderEx("Escape Bounty (% of Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSliderEx("Escape Bounty (Flat)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggleEx("Allow Surrendering",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggleEx("Frisk Search upon Captured",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggleEx("Undress upon Captured",  mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER, index)
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

    ; int escapeBountyPercent = mcm.GetOptionInListByOID(mcm.oid_escape_escapeBountyPercent, oid)
    ; int escapeBountyFlat    = mcm.GetOptionInListByOID(mcm.oid_escape_escapeBountyFlat, oid)
    ; int allowSurrender      = mcm.GetOptionInListByOID(mcm.oid_escape_allowSurrender, oid)
    ; int friskUponCapture    = mcm.GetOptionInListByOID(mcm.oid_escape_friskUponCapture, oid)
    ; int undressUponCapture  = mcm.GetOptionInListByOID(mcm.oid_escape_undressUponCapture, oid)

    ; ; mcm.SetInfoText( \
    ; ;     string_if (oid == escapeBountyPercent, "The bounty added as a percentage of your current bounty, when escaping prison in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == escapeBountyFlat, "The bounty added when escaping prison in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == allowSurrender, "Whether the guards will allow you to surrender after escaping prison in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == friskUponCapture, "Whether to allow a frisk upon being captured in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "(Note: The frisk will only take place if the conditions are met in Frisking)", \
    ; ;     string_if (oid == undressUponCapture, "Whether to allow being undressed upon being captured in " + holds[mcm.CurrentOptionIndex] + ".\n (Note: Undressing will only take place if the conditions are met in Undressing)", \
    ; ;     "No description defined for this option." \
    ; ;     ))))) \
    ; ; )

    ; if (oid == escapeBountyPercent)
    ;     mcm.SetInfoText("The bounty added as a percentage of your current bounty, when escaping prison in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == escapeBountyFlat)
    ;     mcm.SetInfoText("The bounty added when escaping prison in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == allowSurrender)
    ;     mcm.SetInfoText("Whether the guards will allow you to surrender after escaping prison in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == friskUponCapture)
    ;     mcm.SetInfoText("Whether to allow a frisk upon being captured in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "(Note: The frisk will only take place if the conditions are met in Frisking)")
    ; elseif (oid == undressUponCapture)
    ;     mcm.SetInfoText("Whether to allow being undressed upon being captured in " + holds[mcm.CurrentOptionIndex] + ".\n (Note: Undressing will only take place if the conditions are met in Undressing)")
    ; endif

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
