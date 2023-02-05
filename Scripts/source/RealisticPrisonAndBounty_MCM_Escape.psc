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
    mcm.AddOptionSlider("Escape Bounty (% of Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSlider("Escape Bounty (Flat)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggle("Allow Surrendering",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggle("Frisk Search upon Captured",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggle("Undress upon Captured",  mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER, index)
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

    if (option == "Escape Bounty (% of Bounty)")
        mcm.SetInfoText("The bounty added as a percentage of your current bounty, when escaping prison in " + hold + ".")

    elseif (option == "Escape Bounty (Flat)")
        mcm.SetInfoText("The bounty added when escaping prison in " + hold + ".")

    elseif (option == "Allow Surrendering")
        mcm.SetInfoText("Whether the guards will allow you to surrender after escaping prison in " + hold + ".")

    elseif (option == "Frisk Search upon Captured")
        mcm.SetInfoText("Whether to allow a frisk upon being captured in "  + hold + ".\n" + "(Note: The frisk will only take place if the conditions are met in Frisking)")

    elseif (option == "Undress upon Captured")
        mcm.SetInfoText("Whether to allow being undressed upon being captured in " + hold + ".\n (Note: Undressing will only take place if the conditions are met in Undressing)")
    endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = GetPageName() + "::" + option

    mcm.ToggleOption(optionKey)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    int sliderOptionValue = mcm.GetOptionSliderValue(option)

    if (option == "Escape Bounty (% of Bounty)")
        mcm.SetSliderOptions(minRange = 1, \
         maxRange = 100, \
         intervalSteps = 1, \
         defaultValue = mcm.ESCAPE_DEFAULT_BOUNTY_PERCENT, \
         startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.ESCAPE_DEFAULT_BOUNTY_PERCENT))
    elseif (option == "Escape Bounty (Flat)")
        mcm.SetSliderOptions(minRange = 1, \
         maxRange = 100000, \
         intervalSteps = 1, \
         defaultValue = mcm.ESCAPE_DEFAULT_BOUNTY_FLAT, \
         startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.ESCAPE_DEFAULT_BOUNTY_FLAT))
    endif
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    mcm.SetOptionSliderValue(option, value)
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
