Scriptname RealisticPrisonAndBounty_MCM_Arrest hidden

import RealisticPrisonAndBounty_Util


string function GetPageName() global
    return "Arrest"
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
    mcm.AddOptionSliderEx("Minimum Bounty to Arrest",                         mcm.ARREST_DEFAULT_MIN_BOUNTY, index)
    mcm.AddOptionSliderEx("Guaranteed Payable Bounty",                        mcm.ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY, index)
    mcm.AddOptionSliderEx("Maximum Payable Bounty",                           mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY, index)
    mcm.AddOptionSliderEx("Additional Bounty when Resisting (% of Bounty)",   mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT, index)
    mcm.AddOptionSliderEx("Additional Bounty when Resisting (Flat)",          mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT, index)
    mcm.AddOptionSliderEx("Additional Bounty when Defeated (% of Bounty)",    mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT, index)
    mcm.AddOptionSliderEx("Additional Bounty when Defeated (Flat)",           mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggleEx("Allow Civilian Capture",                           mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggleEx("Allow Arrest Transfer",                            mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER, index)
    mcm.AddOptionToggleEx("Allow Unconscious Arrest",                         mcm.ARREST_DEFAULT_ALLOW_UNCONSCIOUS_ARREST, index)
    mcm.AddOptionSliderEx("Unequip Hand Garments (Minimum Bounty)",           mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY, index)
    mcm.AddOptionSliderEx("Unequip Head Garments (Minimum Bounty)",           mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY, index)
    mcm.AddOptionSliderEx("Unequip Foot Garments (Minimum Bounty)",           mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY, index)
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

    if (option == "Minimum Bounty to Arrest") 
        mcm.SetInfoText("The minimum bounty required in order to be arrested in " + hold + ".")

    elseif (option == "Guaranteed Payable Bounty")
            mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept as payment before arresting you in " + hold + ".")

    elseif (option == "Maximum Payable Bounty")
            mcm.SetInfoText("The maximum amount of bounty that is payable before arresting you in " + hold + ".")

    elseif (option == "Additional Bounty when Resisting (% of Bounty)")
            mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when resisting arrest in "  + hold + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.")

    elseif (option == "Additional Bounty when Resisting (Flat)")
            mcm.SetInfoText("The bounty that will be added when resisting arrest in " + hold + ".")

    elseif (option == "Additional Bounty when Defeated (% of Bounty)")
            mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when defeated and arrested in " + hold + ".")

    elseif (option == "Additional Bounty when Defeated (Flat)")
            mcm.SetInfoText("The bounty that will be added when defeated and arrested in " + hold)

    elseif (option == "Allow Civilian Capture")
            mcm.SetInfoText("Whether to allow civilians to bring you to a guard, to be arrested in " + hold)

    elseif (option == "Allow Arrest Transfer")
            mcm.SetInfoText("Whether to allow a guard to take over the arrest if the current one dies.")

    elseif (option == "Allow Unconscious Arrest")
            mcm.SetInfoText("Whether to allow an unconscious arrest after being defeated (You will wake up in prison).")

    elseif (option == "Unequip Hand Garments (Minimum Bounty)")
            mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (option == "Unequip Head Garments (Minimum Bounty)")
            mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (option == "Unequip Foot Garments (Minimum Bounty)")
            mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
    endif


endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global

    ; bool optionState = mcm.ToggleOption(mcm.GetKeyFromOption(oid))

    string optionKey = option

    mcm.ToggleOption(optionKey)

endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

    ; int optionValue = GetOptionIntValue(oid)

    ; if (oid == mcm.GetOption("arrest::minimumBountyToArrest")) 
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_MIN_BOUNTY, \
    ;      startValue = int_if(optionValue, optionValue, 500))

    ; elseif (oid == mcm.GetOption("arrest::guaranteedPayableBounty"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY, \
    ;      startValue = int_if(optionValue, optionValue, 1000))

    ; elseif (oid == mcm.GetOption("arrest::maximumPayableBounty"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY, \
    ;      startValue = int_if(optionValue, optionValue, 2000))

    ; elseif (oid == mcm.GetOption("arrest::additionalBountyWhenResisting(%ofBounty)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT, \
    ;      startValue = int_if(optionValue, optionValue, 25))

    ; elseif (oid == mcm.GetOption("arrest::additionalBountyWhenResisting(flat)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT, \
    ;      startValue = int_if(optionValue, optionValue, 400))

    ; elseif (oid == mcm.GetOption("arrest::additionalBountyWhenDefeated(%ofBounty)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT, \
    ;      startValue = int_if(optionValue, optionValue, 10))

    ; elseif (oid == mcm.GetOption("arrest::additionalBountyWhenDefeated(flat)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, \
    ;      startValue = int_if(optionValue, optionValue, 10))

    ; elseif (oid == mcm.GetOption("arrest::unequipHandGarments(minimumBounty)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY, \
    ;      startValue = int_if(optionValue, optionValue, 10))

    ; elseif (oid == mcm.GetOption("arrest::unequipHeadGarments(minimumBounty)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY, \
    ;      startValue = int_if(optionValue, optionValue, 10))

    ; elseif (oid == mcm.GetOption("arrest::unequipFootGarments(minimumBounty)"))
    ;     mcm.SetSliderOptions(minRange = 1, \
    ;      maxRange = 100000, \
    ;      intervalSteps = 1, \
    ;      defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY, \
    ;      startValue = int_if(optionValue, optionValue, 10))

    ; endif

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    
    ; mcm.SetSliderOptionValue(oid, value, string_if (oid == mcm.GetOption("arrest::additionalBountyWhenResisting(%ofBounty)") || oid == mcm.GetOption("arrest::additionalBountyWhenDefeated(%ofBounty)"), "{0}%", "{0}"))
    
    ; ; Store value persistently
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
