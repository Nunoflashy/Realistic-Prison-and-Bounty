Scriptname RealisticPrisonAndBounty_MCM_General hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "General"
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
    mcm.oid_general_attackOnSightBounty[index] = mcm.AddSliderOption("Attack on Sight Bounty", 1.0)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    mcm.AddHeaderOption("General")
    mcm.oid_general_normalTimeScale = mcm.AddSliderOption("Timescale", mcm.NormalTimescale.GetValueInt())
    mcm.AddEmptyOption()

    int i = mcm.LeftPanelIndex
    while (i < mcm.LeftPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    ; Padding
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

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

    if (oid == mcm.oid_general_attackOnSightBounty[index])
        mcm.SetInfoText("Determines the minimum amount of bounty required to be attacked on sight in " + holds[index] + ".")
    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    if (oid == mcm.oid_general_attackOnSightBounty[index])
        mcm.SetSliderDialogStartValue(1.0)
        mcm.SetSliderDialogRange(0, 100000)
        mcm.SetSliderDialogInterval(1)
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

function OnSingleOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (oid == mcm.oid_general_normalTimeScale)
        mcm.SetInfoText("Sets the normal timescale when not in prison.\n" + \
                        "(Note: This value will be set to your game's timescale automatically, you don't need to touch this!)\n" + \
                        "Only do it if you'd like to change the Timescale or another mod is overwriting it.")
    endif
endFunction

function OnSingleOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (oid == mcm.oid_general_normalTimeScale)
        mcm.SetSliderDialogStartValue(mcm.NormalTimescale.GetValueInt())
        mcm.SetSliderDialogRange(0, 100)
        mcm.SetSliderDialogInterval(1)
        mcm.SetSliderDialogDefaultValue(mcm.NormalTimescale.GetValueInt())
    endif
endFunction

function OnSingleOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (oid == mcm.oid_general_normalTimeScale)
        mcm.SetSliderOptionValue(oid, value)
        mcm.NormalTimescale.SetValueInt((value as int))
        Log(mcm, "General::OnSingleOptionSliderAccept", "Normal timescale has been set to " + (value as int))
    endif
endFunction


function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnSingleOptionHighlight(mcm, oid)

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

    OnSingleOptionSliderOpen(mcm, oid)

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

    OnSingleOptionSliderAccept(mcm, oid, value)

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