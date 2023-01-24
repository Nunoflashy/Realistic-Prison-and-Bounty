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
    mcm.oid_arrest_minimumBounty[index]                         = mcm.AddSliderOption("Minimum Bounty to Arrest", 1.0)
    mcm.oid_arrest_guaranteedPayableBounty[index]               = mcm.AddSliderOption("Guaranteed Payable Bounty", 1.0)
    mcm.oid_arrest_maximumPayableBounty[index]                  = mcm.AddSliderOption("Maximum Payable Bounty", 1.0)
    mcm.oid_arrest_additionalBountyWhenResistingPercent[index]  = mcm.AddSliderOption("Additional Bounty when Resisting (% of Bounty)", 1.0)
    mcm.oid_arrest_additionalBountyWhenResistingFlat[index]     = mcm.AddSliderOption("Additional Bounty when Resisting (Flat)", 1.0)
    mcm.oid_arrest_additionalBountyWhenDefeatedPercent[index]   = mcm.AddSliderOption("Additional Bounty when Defeated (% of Bounty)", 1.0)
    mcm.oid_arrest_additionalBountyWhenDefeatedFlat[index]      = mcm.AddSliderOption("Additional Bounty when Defeated (Flat)", 1.0)
    mcm.oid_arrest_allowCivilianCapture[index]                  = mcm.AddToggleOption("Allow Civilian Capture", true)
    mcm.oid_arrest_allowArrestTransfer[index]                   = mcm.AddToggleOption("Allow Arrest Transfer", true)
    mcm.oid_arrest_allowUnconsciousArrest[index]                = mcm.AddToggleOption("Allow Unconscious Arrest", true)
    mcm.oid_arrest_unequipHandBounty[index]                     = mcm.AddSliderOption("Unequip Hand Garments (Minimum Bounty)", 1.0) ; -1 to Disable
    mcm.oid_arrest_unequipHeadBounty[index]                     = mcm.AddSliderOption("Unequip Head Garments (Minimum Bounty)", 1.0) ; -1 to Disable
    mcm.oid_arrest_unequipFootBounty[index]                     = mcm.AddSliderOption("Unequip Foot Garments (Minimum Bounty)", 1.0) ; -1 to Disable
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

    if (oid == mcm.oid_arrest_minimumBounty[index])
        mcm.SetInfoText("The minimum bounty required to be arrested in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_guaranteedPayableBounty[index])
        mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept before arresting in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_maximumPayableBounty[index])
        mcm.SetInfoText("The maximum amount of bounty that is payable before being arrested in " + holds[index] + ".\n(Note: The chance will be determined)")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_additionalBountyWhenResistingPercent[index])
        mcm.SetInfoText("The amount of bounty that will be added as a percentage of the current bounty, when resisting arrest in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_additionalBountyWhenResistingFlat[index])
        mcm.SetInfoText("The amount of bounty that will be added when resisting arrest in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_additionalBountyWhenDefeatedPercent[index])
        mcm.SetInfoText("The amount of bounty that will be added as a percentage of the current bounty, when defeated in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_additionalBountyWhenDefeatedFlat[index])
        mcm.SetInfoText("The amount of bounty that will be added when defeated in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_allowCivilianCapture[index])
        mcm.SetInfoText("Whether to allow civilians to bring the player to a guard in " + holds[index] + ".")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_allowArrestTransfer[index])
        mcm.SetInfoText("Whether to allow a guard to take over the arrest if the current captor dies.")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_allowUnconsciousArrest[index])
        mcm.SetInfoText("Whether to allow an unconscious arrest after defeated (the player will wake up in prison).")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_unequipHandBounty[index])
        mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_unequipHeadBounty[index])
        mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return

    elseif (oid == mcm.oid_arrest_unequipFootBounty[index])
        mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
        Log(mcm, "Arrest::OnOptionHighlight", "Option = " + oid)
        return
    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    if (oid == mcm.oid_arrest_additionalBountyWhenResistingFlat[index])
        
    endif
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value, int index) global
    
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
