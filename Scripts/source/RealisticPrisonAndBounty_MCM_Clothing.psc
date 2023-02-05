Scriptname RealisticPrisonAndBounty_MCM_Clothing hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Clothing"
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
    mcm.AddOptionToggle("Allow Wearing Clothes",            mcm.CLOTHING_DEFAULT_ALLOW_CLOTHES, index)
    mcm.AddOptionToggle("When Defeated",           mcm.CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED, index)
    mcm.AddOptionSlider("Maximum Bounty",                    mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY, index)

    if (index == mcm.INDEX_THE_REACH)
        mcm.AddTextOption("", "In Cidhna Mine", mcm.OPTION_DISABLED)
        mcm.AddOptionToggleWithKey("Allow Wearing Clothes", "Allow Wearing Clothes (Cidhna Mine)",  mcm.CLOTHING_DEFAULT_ALLOW_CLOTHES)
        mcm.AddOptionToggleWithKey("When Defeated", "When Defeated (Cidhna Mine)",                  mcm.CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED)
        mcm.AddTextOption("", "OR")
        mcm.AddOptionSliderWithKey("Maximum Bounty",  "Maximum Bounty (Cidhna Mine)",                     mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY)
    endif
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

    if (option == "Allow Wearing Clothes")
        mcm.SetInfoText("Determines if you are allowed to wear any clothes when imprisoned in " + hold + ".")

    elseif (option == "Allow Wearing Clothes (Cidhna Mine)")
        mcm.SetInfoText("Determines if you are allowed to wear any clothes when imprisoned in Cidhna Mine.")

    elseif (option == "When Defeated")
        mcm.SetInfoText("Determines if you are given clothes when defeated and imprisoned in " + hold + "'s prison.")

    elseif (option == "When Defeated (Cidhna Mine)")
        mcm.SetInfoText("Determines if you are given clothes when defeated and imprisoned in Cidhna Mine.")

    elseif (option == "Maximum Bounty")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothes when imprisoned in " + hold + ".")
    
    elseif (option == "Maximum Bounty (Cidhna Mine)")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothes when imprisoned in Cidhna Mine.")
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

    if (option == "Maximum Bounty")
        mcm.SetSliderOptions(minRange = 1, \
        maxRange = 100000, \
        intervalSteps = 1, \
        defaultValue = mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY, \
        startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY))
    elseif (option == "Maximum Bounty (Cidhna Mine)")
        mcm.SetSliderOptions(minRange = 1, \
        maxRange = 100000, \
        intervalSteps = 1, \
        defaultValue = mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY, \
        startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY))
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
