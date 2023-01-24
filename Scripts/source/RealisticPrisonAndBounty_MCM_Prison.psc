Scriptname RealisticPrisonAndBounty_MCM_Prison hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Prison"
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
    mcm.oid_prison_bountyToDays[index]                  = mcm.AddSliderOption("Bounty to Days", 1.0, "{0} Bounty")
    mcm.oid_prison_minimumSentenceDays[index]           = mcm.AddSliderOption("Minimum Sentence (Days)", 1.0)
    mcm.oid_prison_maximumSentenceDays[index]           = mcm.AddSliderOption("Maximum Sentence (Days)", 1.0)
    mcm.oid_prison_allowBountylessImprisonment[index]   = mcm.AddToggleOption("Allow Bountyless Imprisonment", true)
    mcm.oid_prison_sentencePaysBounty[index]            = mcm.AddToggleOption("Sentence pays Bounty", true)
    mcm.oid_prison_fastForward[index]                   = mcm.AddToggleOption("Fast Forward", false)
    mcm.oid_prison_dayToFastForwardFrom[index]          = mcm.AddSliderOption("Day to fast forward from", 1.0)
    mcm.oid_prison_handsBoundInPrison[index]            = mcm.AddToggleOption("Hands Bound in Prison", false)
    mcm.oid_prison_handsBoundMinimumBounty[index]       = mcm.AddSliderOption("Hands Bound (Minimum Bounty)", 1.0)
    mcm.oid_prison_handsBoundRandomize[index]           = mcm.AddToggleOption("Hands Bound (Randomize)", true)
    mcm.oid_prison_cellLockLevel[index]                 = mcm.AddMenuOption("Cell Lock Level", "SELECT")
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    mcm.AddHeaderOption("General")
    mcm.oid_prison_prisonTimeScale = mcm.AddSliderOption("Timescale in Prison", int_if(mcm.PrisonTimescale.GetValueInt() != 0, mcm.PrisonTimescale.GetValueInt(), 10))

    int i = mcm.LeftPanelIndex
    while (i < mcm.LeftPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    mcm.AddEmptyOption() ; Padding
    mcm.AddEmptyOption() ; Padding

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

    if (oid == mcm.oid_prison_bountyToDays[index])
        mcm.SetInfoText("Sets the relation between bounty and days in prison.")
        return

    elseif (oid == mcm.oid_prison_minimumSentenceDays[index])
        mcm.SetInfoText("Determines the minimum sentence in prison for " + holds[index] + ".")
        return

    elseif (oid == mcm.oid_prison_maximumSentenceDays[index])
        mcm.SetInfoText("Determines the maximum sentence in prison for " + holds[index] + ".")
        return

    elseif (oid == mcm.oid_prison_allowBountylessImprisonment[index])
        mcm.SetInfoText("Whether to allow unconditional imprisonment without a bounty.\n" + \
                        "The sentence will be the minimum possible configured.")
        return

    elseif (oid == mcm.oid_prison_sentencePaysBounty[index])
        mcm.SetInfoText("Determines if serving the sentence pays the bounty.\nIf disabled, the bounty must be paid after serving the sentence.")
        return

    elseif (oid == mcm.oid_prison_fastForward[index])
        mcm.SetInfoText("Whether to fast forward to release.")
        return

    elseif (oid == mcm.oid_prison_dayToFastForwardFrom[index])
        mcm.SetInfoText("The day to start fast forward to release." )
        return

    elseif (oid == mcm.oid_prison_handsBoundInPrison[index])
        mcm.SetInfoText("Whether to have bound hands during imprisonment.")
        return

    elseif (oid == mcm.oid_prison_handsBoundMinimumBounty[index])
        mcm.SetInfoText("The minimum bounty required to have hands bound.")
        return
        
    elseif (oid == mcm.oid_prison_handsBoundRandomize[index])
        mcm.SetInfoText("Whether to randomize if the hands are bound or not if the bounty is met.")
        return

    elseif (oid == mcm.oid_prison_cellLockLevel[index])
        mcm.SetInfoText("Determines the cell's door lock level.")
        return
    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction



function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    if (oid == mcm.oid_prison_allowBountylessImprisonment[index])
        mcm.oid_prison_allowBountylessImprisonment_checked[index] = ! mcm.oid_prison_allowBountylessImprisonment_checked[index]
        mcm.SetToggleOptionValue(oid, mcm.oid_prison_allowBountylessImprisonment_checked[index])

    elseif (oid == mcm.oid_prison_sentencePaysBounty[index])
        mcm.oid_prison_sentencePaysBounty_checked[index] = ! mcm.oid_prison_sentencePaysBounty_checked[index]
        mcm.SetToggleOptionValue(oid, mcm.oid_prison_sentencePaysBounty_checked[index])
    endif
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    if (oid == mcm.oid_prison_bountyToDays[index])
        mcm.SetSliderDialogStartValue(1.0)
        mcm.SetSliderDialogRange(0, 10000)
        mcm.SetSliderDialogInterval(1)
    elseif (oid == mcm.oid_prison_minimumSentenceDays[index])
        mcm.SetSliderDialogStartValue(1.0)
        mcm.SetSliderDialogRange(0, 365)
        mcm.SetSliderDialogInterval(1)
    elseif (oid == mcm.oid_prison_maximumSentenceDays[index])
        mcm.SetSliderDialogStartValue(1.0)
        mcm.SetSliderDialogRange(0, 365)
        mcm.SetSliderDialogInterval(1)
    elseif (oid == mcm.oid_prison_dayToFastForwardFrom[index])
        mcm.SetSliderDialogStartValue(1.0)
        mcm.SetSliderDialogRange(0, 365)
        mcm.SetSliderDialogInterval(1)
    elseif (oid == mcm.oid_prison_handsBoundMinimumBounty[index])
        mcm.SetSliderDialogStartValue(1.0)
        mcm.SetSliderDialogRange(0, 10000)
        mcm.SetSliderDialogInterval(1)
    endif
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value, int index) global
    
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    string[] holds = mcm.GetHoldNames()

    if (oid == mcm.oid_prison_bountyToDays[index])
        mcm.SetInfoText("Sets the relation between bounty and days in prison.")
    elseif (oid == mcm.oid_prison_minimumSentenceDays[index])
        mcm.SetInfoText("Determines the minimum sentence in prison for " + holds[index] + ".")
    elseif (oid == mcm.oid_prison_maximumSentenceDays[index])
        mcm.SetInfoText("Determines the maximum sentence in prison for " + holds[index] + ".")
    elseif (oid == mcm.oid_prison_allowBountylessImprisonment[index])
        mcm.SetInfoText("Whether to allow unconditional imprisonment without a bounty.")
    elseif (oid == mcm.oid_prison_sentencePaysBounty[index])
        mcm.SetInfoText("Determines if serving the sentence pays the bounty.\nIf disabled, the bounty must be paid after serving the sentence.")
    elseif (oid == mcm.oid_prison_fastForward[index])
        mcm.SetInfoText("Whether to fast forward to release.")
    elseif (oid == mcm.oid_prison_dayToFastForwardFrom[index])
        mcm.SetInfoText("The day to start fast forward to release.")
    elseif (oid == mcm.oid_prison_handsBoundInPrison[index])
        mcm.SetInfoText("Whether to have bound hands during imprisonment.")
    elseif (oid == mcm.oid_prison_handsBoundMinimumBounty[index])
        mcm.SetInfoText("The minimum bounty required to have hands bound.")
    elseif (oid == mcm.oid_prison_handsBoundRandomize[index])
        mcm.SetInfoText("Whether to randomize if the hands are bound or not if the bounty is met.")
    elseif (oid == mcm.oid_prison_cellLockLevel[index])
        mcm.SetInfoText("Determines the cell's door lock level.")
    endif
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
    if (oid == mcm.oid_prison_prisonTimeScale)
        mcm.SetInfoText("Sets the timescale while imprisoned.")
        Log(mcm, "Prison::OnSingleOptionHighlight", "(oid: " + oid + ")")
    endif
endFunction

function OnSingleOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (oid == mcm.oid_prison_prisonTimeScale)
        mcm.SetSliderDialogStartValue(mcm.PrisonTimescale.GetValueInt())
        mcm.SetSliderDialogRange(0, 1000)
        mcm.SetSliderDialogInterval(1)
        mcm.SetSliderDialogDefaultValue(mcm.PrisonTimescale.GetValueInt())
        Log(mcm, "Prison::OnSingleOptionSliderOpen", "(oid: " + oid + ")")
    endif
endFunction

function OnSingleOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (oid == mcm.oid_prison_prisonTimeScale)
        mcm.SetSliderOptionValue(oid, value)
        mcm.PrisonTimescale.SetValueInt((value as int))
        Log(mcm, "Prison::OnSingleOptionSliderAccept", "(oid: " + oid + ")")
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