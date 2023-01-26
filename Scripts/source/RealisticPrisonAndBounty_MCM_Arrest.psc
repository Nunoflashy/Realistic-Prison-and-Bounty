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
    mcm.oid_arrest_minimumBounty[index]                         = mcm.AddSliderOption("Minimum Bounty to Arrest",                           GetOptionValue(mcm.oid_arrest_minimumBounty[index]))
    mcm.oid_arrest_guaranteedPayableBounty[index]               = mcm.AddSliderOption("Guaranteed Payable Bounty",                          GetOptionValue(mcm.oid_arrest_guaranteedPayableBounty[index]))
    mcm.oid_arrest_maximumPayableBounty[index]                  = mcm.AddSliderOption("Maximum Payable Bounty",                             GetOptionValue(mcm.oid_arrest_maximumPayableBounty[index]))
    mcm.oid_arrest_additionalBountyWhenResistingPercent[index]  = mcm.AddSliderOption("Additional Bounty when Resisting (% of Bounty)",     GetOptionValue(mcm.oid_arrest_additionalBountyWhenResistingPercent[index]))
    mcm.oid_arrest_additionalBountyWhenResistingFlat[index]     = mcm.AddSliderOption("Additional Bounty when Resisting (Flat)",            GetOptionValue(mcm.oid_arrest_additionalBountyWhenResistingFlat[index]))
    mcm.oid_arrest_additionalBountyWhenDefeatedPercent[index]   = mcm.AddSliderOption("Additional Bounty when Defeated (% of Bounty)",      GetOptionValue(mcm.oid_arrest_additionalBountyWhenDefeatedPercent[index]))
    mcm.oid_arrest_additionalBountyWhenDefeatedFlat[index]      = mcm.AddSliderOption("Additional Bounty when Defeated (Flat)",             GetOptionValue(mcm.oid_arrest_additionalBountyWhenDefeatedFlat[index]))
    mcm.oid_arrest_allowCivilianCapture[index]                  = mcm.AddToggleOption("Allow Civilian Capture",                             GetOptionValue(mcm.oid_arrest_allowCivilianCapture[index]))
    mcm.oid_arrest_allowArrestTransfer[index]                   = mcm.AddToggleOption("Allow Arrest Transfer",                              GetOptionValue(mcm.oid_arrest_allowArrestTransfer[index]))
    mcm.oid_arrest_allowUnconsciousArrest[index]                = mcm.AddToggleOption("Allow Unconscious Arrest",                           GetOptionValue(mcm.oid_arrest_allowUnconsciousArrest[index]))
    mcm.oid_arrest_unequipHandBounty[index]                     = mcm.AddSliderOption("Unequip Hand Garments (Minimum Bounty)",             GetOptionValue(mcm.oid_arrest_unequipHandBounty[index])) ; -1 to Disable
    mcm.oid_arrest_unequipHeadBounty[index]                     = mcm.AddSliderOption("Unequip Head Garments (Minimum Bounty)",             GetOptionValue(mcm.oid_arrest_unequipHeadBounty[index])) ; -1 to Disable
    mcm.oid_arrest_unequipFootBounty[index]                     = mcm.AddSliderOption("Unequip Foot Garments (Minimum Bounty)",             GetOptionValue(mcm.oid_arrest_unequipFootBounty[index])) ; -1 to Disable
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

    int minimumBounty                           = mcm.GetOptionInListByID(mcm.oid_arrest_minimumBounty, oid)
    int guaranteedPayableBounty                 = mcm.GetOptionInListByID(mcm.oid_arrest_guaranteedPayableBounty, oid)
    int maximumPayableBounty                    = mcm.GetOptionInListByID(mcm.oid_arrest_maximumPayableBounty, oid)
    int additionalBountyWhenResistingPercent    = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenResistingPercent, oid)
    int additionalBountyWhenResistingFlat       = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenResistingFlat, oid)
    int additionalBountyWhenDefeatedPercent     = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenDefeatedPercent, oid)
    int additionalBountyWhenDefeatedFlat        = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenDefeatedFlat, oid)
    int allowCivilianCapture                    = mcm.GetOptionInListByID(mcm.oid_arrest_allowCivilianCapture, oid)
    int allowArrestTransfer                     = mcm.GetOptionInListByID(mcm.oid_arrest_allowArrestTransfer, oid)
    int allowUnconsciousArrest                  = mcm.GetOptionInListByID(mcm.oid_arrest_allowUnconsciousArrest, oid)
    int unequipHandBounty                       = mcm.GetOptionInListByID(mcm.oid_arrest_unequipHandBounty, oid)
    int unequipHeadBounty                       = mcm.GetOptionInListByID(mcm.oid_arrest_unequipHeadBounty, oid)
    int unequipFootBounty                       = mcm.GetOptionInListByID(mcm.oid_arrest_unequipFootBounty, oid)

    ; mcm.SetInfoText( \
    ;     string_if (oid == minimumBounty, "The minimum bounty required in order to be arrested in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == guaranteedPayableBounty, "The guaranteed amount of bounty that a guard will accept as payment before arresting you in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == maximumPayableBounty, "The maximum amount of bounty that is payable before arresting you in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == additionalBountyWhenResistingPercent, "The bounty that will be added as a percentage of your current bounty, when resisting arrest in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.", \
    ;     string_if (oid == additionalBountyWhenResistingFlat, "The bounty that will be added when resisting arrest in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == additionalBountyWhenDefeatedPercent, "The bounty that will be added as a percentage of your current bounty, when defeated and arrested in " + holds[mcm.CurrentOptionIndex] + ".", \
    ;     string_if (oid == additionalBountyWhenDefeatedFlat, "The bounty that will be added when defeated and arrested in " + holds[mcm.CurrentOptionIndex], \
    ;     string_if (oid == allowCivilianCapture, "Whether to allow civilians to bring you to a guard, to be arrested in " + holds[mcm.CurrentOptionIndex], \
    ;     string_if (oid == allowArrestTransfer, "Whether to allow a guard to take over the arrest if the current one dies.", \
    ;     string_if (oid == allowUnconsciousArrest, "Whether to allow an unconscious arrest after being defeated (You will wake up in prison).", \
    ;     string_if (oid == unequipHandBounty, "Whether to unequip any hand garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required", \
    ;     string_if (oid == unequipHeadBounty, "Whether to unequip any head garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required", \
    ;     string_if (oid == unequipFootBounty, "Whether to unequip any foot garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required", \
    ;     "No description defined for this option." \
    ;     ))))))))))))) \
    ; )

    if (oid == minimumBounty) 
        "The minimum bounty required in order to be arrested in " + holds[mcm.CurrentOptionIndex] + "."

    elseif (oid == guaranteedPayableBounty)
            mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept as payment before arresting you in " + holds[mcm.CurrentOptionIndex] + ".")

    elseif (oid == maximumPayableBounty)
            mcm.SetInfoText("The maximum amount of bounty that is payable before arresting you in " + holds[mcm.CurrentOptionIndex] + ".")

    elseif (oid == additionalBountyWhenResistingPercent)
            mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when resisting arrest in "  + holds[mcm.CurrentOptionIndex] + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.")

    elseif (oid == additionalBountyWhenResistingFlat)
            mcm.SetInfoText("The bounty that will be added when resisting arrest in " + holds[mcm.CurrentOptionIndex] + ".")

    elseif (oid == additionalBountyWhenDefeatedPercent)
            mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when defeated and arrested in " + holds[mcm.CurrentOptionIndex] + ".")

    elseif (oid == additionalBountyWhenDefeatedFlat)
            mcm.SetInfoText("The bounty that will be added when defeated and arrested in " + holds[mcm.CurrentOptionIndex])

    elseif (oid == allowCivilianCapture)
            mcm.SetInfoText("Whether to allow civilians to bring you to a guard, to be arrested in " + holds[mcm.CurrentOptionIndex])

    elseif (oid == allowArrestTransfer)
            mcm.SetInfoText("Whether to allow a guard to take over the arrest if the current one dies.")

    elseif (oid == allowUnconsciousArrest)
            mcm.SetInfoText("Whether to allow an unconscious arrest after being defeated (You will wake up in prison).")

    elseif (oid == unequipHandBounty)
            mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (oid == unequipHeadBounty)
            mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (oid == unequipFootBounty)
            mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
    endif


endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

    bool optionState = mcm.ToggleOption(oid)

endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    int optionValue = GetOptionValue(oid)

    ; Slider Options
    int minimumBounty                           = mcm.GetOptionInListByID(mcm.oid_arrest_minimumBounty, oid)
    int guaranteedPayableBounty                 = mcm.GetOptionInListByID(mcm.oid_arrest_guaranteedPayableBounty, oid)
    int maximumPayableBounty                    = mcm.GetOptionInListByID(mcm.oid_arrest_maximumPayableBounty, oid)
    int additionalBountyWhenResistingPercent    = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenResistingPercent, oid)
    int additionalBountyWhenResistingFlat       = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenResistingFlat, oid)
    int additionalBountyWhenDefeatedPercent     = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenDefeatedPercent, oid)
    int additionalBountyWhenDefeatedFlat        = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenDefeatedFlat, oid)
    int unequipHandBounty                       = mcm.GetOptionInListByID(mcm.oid_arrest_unequipHandBounty, oid)
    int unequipHeadBounty                       = mcm.GetOptionInListByID(mcm.oid_arrest_unequipHeadBounty, oid)
    int unequipFootBounty                       = mcm.GetOptionInListByID(mcm.oid_arrest_unequipFootBounty, oid)

    if (oid == minimumBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = int_if(optionValue, optionValue, 500))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == guaranteedPayableBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 1000, startValue = int_if(optionValue, optionValue, 1000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == maximumPayableBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 2000, startValue = int_if(optionValue, optionValue, 2000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == additionalBountyWhenResistingPercent)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100, intervalSteps = 1, defaultValue = 25, startValue = int_if(optionValue, optionValue, 25))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == additionalBountyWhenResistingFlat)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 400, startValue = int_if(optionValue, optionValue, 400))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == additionalBountyWhenDefeatedPercent)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == additionalBountyWhenDefeatedFlat)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == unequipHandBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == unequipHeadBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == unequipFootBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 10, startValue = int_if(optionValue, optionValue, 10))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")
    endif

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

    ; Slider Options
    int additionalBountyWhenResistingPercent    = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenResistingPercent, oid)
    int additionalBountyWhenDefeatedPercent     = mcm.GetOptionInListByID(mcm.oid_arrest_additionalBountyWhenDefeatedPercent, oid)

    mcm.SetSliderOptionValue(oid, value, string_if (oid == additionalBountyWhenResistingPercent || oid == additionalBountyWhenDefeatedPercent, "{0}%", "{0}"))
    
    ; Store value persistently
    SetOptionValueInt(oid, value as int)

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
