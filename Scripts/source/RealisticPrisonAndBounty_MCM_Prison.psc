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
    mcm.AddOptionSlider("Bounty to Days",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSlider("Minimum Sentence (Days)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSlider("Maximum Sentence (Days)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggle("Allow Bountyless Imprisonment",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggle("Sentence pays Bounty",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggle("Fast Forward",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionSlider("Day to fast forward from",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggle("Hands Bound in Prison",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionSlider("Hands Bound (Minimum Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggle("Hands Bound (Randomize)",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionMenuEx("Cell Lock Level", "SELECT", index)

endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    mcm.AddHeaderOption("General")
    mcm.AddOptionSlider("Timescale in Prison", 10)

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


; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global
    string hold = mcm.CurrentHold

    if (option == "Timescale in Prison")
        mcm.SetInfoText("Sets the timescale while imprisoned.")

    elseif (option == "Bounty to Days")
        mcm.SetInfoText("Sets the relation between bounty and days in " + hold + "'s prison.")

    elseif (option == "Minimum Sentence (Days)")
        mcm.SetInfoText("Determines the minimum sentence in days for " + hold + "'s prison.")

    elseif (option == "Maximum Sentence (Days)")
        mcm.SetInfoText("Determines the maximum sentence in days for " + hold + "'s prison.")

    elseif (option == "Allow Bountyless Imprisonment")
        mcm.SetInfoText("Whether to allow unconditional imprisonment without a bounty in " + hold + "'s prison.")

    elseif (option == "Sentence pays Bounty")
        mcm.SetInfoText("Determines if serving the sentence pays the bounty in "  + hold + ".\nIf disabled, the bounty must be paid after serving the sentence.")

    elseif (option == "Fast Forward")
        mcm.SetInfoText("Whether to fast forward to the release in " + hold + ".")

    elseif (option == "Day to fast forward from")
        mcm.SetInfoText("The day to fast forward from to release in " + hold + ".")

    elseif (option == "Hands Bound in Prison")
        mcm.SetInfoText("Whether to have hands restrained during imprisonment in " + hold + ".")

    elseif (option == "Hands Bound (Minimum Bounty)")
        mcm.SetInfoText("The minimum bounty required to have hands restrained during imprisonment in " + hold + ".")

    elseif (option == "Hands Bound (Randomize)") 
        mcm.SetInfoText("Randomize whether to be restrained or not, while in prison in " + hold + ".")

    elseif (option == "Cell Lock Level")
        mcm.SetInfoText("Determines the cell's door lock level")

    endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction



function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = option

    mcm.ToggleOption(optionKey)
    ; bool optionState = mcm.ToggleOption(oid)

    ; int bountyToDays                    = mcm.GetOptionInListByOID(mcm.oid_prison_bountyToDays, oid)
    ; int minimumSentenceDays             = mcm.GetOptionInListByOID(mcm.oid_prison_minimumSentenceDays, oid)
    ; int maximumSentenceDays             = mcm.GetOptionInListByOID(mcm.oid_prison_maximumSentenceDays, oid)
    ; int allowUnconditionalImprisonment  = mcm.GetOptionInListByOID(mcm.oid_prison_allowBountylessImprisonment, oid)
    ; int sentencePaysBounty              = mcm.GetOptionInListByOID(mcm.oid_prison_sentencePaysBounty, oid)
    ; int fastForward                     = mcm.GetOptionInListByOID(mcm.oid_prison_fastForward, oid)
    ; int dayToFastForwardFrom            = mcm.GetOptionInListByOID(mcm.oid_prison_dayToFastForwardFrom, oid)
    ; int handsBoundInPrison              = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundInPrison, oid)
    ; int handsBoundMinimumBounty         = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundMinimumBounty, oid)
    ; int handsBoundRandomize             = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundRandomize, oid)
    ; int cellLockLevel                   = mcm.GetOptionInListByOID(mcm.oid_prison_cellLockLevel, oid)

    ; if (oid == handsBoundInPrison)
    ;     mcm.SetOptionDependencyBool(mcm.oid_prison_handsBoundMinimumBounty, optionState)
    ;     mcm.SetOptionDependencyBool(mcm.oid_prison_handsBoundMinimumBounty, optionState)
    ;     mcm.SetOptionDependencyBool(mcm.oid_prison_handsBoundRandomize, optionState)
    ; endif

endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    float startTime = Utility.GetCurrentRealTime()
    string[] holds = mcm.GetHoldNames()

    ; if (oid == mcm.oid_prison_prisonTimeScale)
    ;     mcm.SetSliderDialogStartValue(mcm.PrisonTimescale.GetValueInt())
    ;     mcm.SetSliderDialogRange(0, 1000)
    ;     mcm.SetSliderDialogInterval(1)
    ;     mcm.SetSliderDialogDefaultValue(mcm.PrisonTimescale.GetValueInt())
    ;     Log(mcm, "Prison::OnSingleOptionSliderOpen", "(oid: " + oid + ")")
    ; endif

    ; int bountyToDays = mcm.GetOptionInListByOID(mcm.oid_prison_bountyToDays, oid)
    ; int minimumSentenceDays = mcm.GetOptionInListByOID(mcm.oid_prison_minimumSentenceDays, oid)
    ; int maximumSentenceDays = mcm.GetOptionInListByOID(mcm.oid_prison_maximumSentenceDays, oid)
    ; int allowUnconditionalImprisonment = mcm.GetOptionInListByOID(mcm.oid_prison_allowBountylessImprisonment, oid)
    ; int sentencePaysBounty = mcm.GetOptionInListByOID(mcm.oid_prison_sentencePaysBounty, oid)
    ; int fastForward = mcm.GetOptionInListByOID(mcm.oid_prison_fastForward, oid)
    ; int dayToFastForwardFrom = mcm.GetOptionInListByOID(mcm.oid_prison_dayToFastForwardFrom, oid)
    ; int handsBoundInPrison = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundInPrison, oid)
    ; int handsBoundMinimumBounty = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundMinimumBounty, oid)
    ; int handsBoundRandomize = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundRandomize, oid)
    ; int cellLockLevel = mcm.GetOptionInListByOID(mcm.oid_prison_cellLockLevel, oid)

    ; if (oid == bountyToDays)
    ;     mcm.SetSliderDialogStartValue(1.0)
    ;     mcm.SetSliderDialogRange(0, 10000)
    ;     mcm.SetSliderDialogInterval(1)
    ; elseif (oid == minimumSentenceDays)
    ;     mcm.SetSliderDialogStartValue(1.0)
    ;     mcm.SetSliderDialogRange(0, 365)
    ;     mcm.SetSliderDialogInterval(1)
    ; elseif (oid == maximumSentenceDays)
    ;     mcm.SetSliderDialogStartValue(1.0)
    ;     mcm.SetSliderDialogRange(0, 365)
    ;     mcm.SetSliderDialogInterval(1)
    ; elseif (oid == dayToFastForwardFrom)
    ;     mcm.SetSliderDialogStartValue(1.0)
    ;     mcm.SetSliderDialogRange(0, 365)
    ;     mcm.SetSliderDialogInterval(1)
    ; elseif (oid == handsBoundMinimumBounty)
    ;     mcm.SetSliderDialogStartValue(1.0)
    ;     mcm.SetSliderDialogRange(0, 10000)
    ;     mcm.SetSliderDialogInterval(1)
    ; endif

    ; float endTime = Utility.GetCurrentRealTime()
    ; float elapsedTime = endTime - startTime

    ; Log(mcm, "OnOptionSliderOpen", "This is the new way without loops! (took " + elapsedTime + " seconds)")
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    ; if (oid == mcm.oid_prison_prisonTimeScale)
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.PrisonTimescale.SetValueInt((value as int))
    ;     Log(mcm, "Prison::OnSingleOptionSliderAccept", "(oid: " + oid + ")")
    ; endif
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    float startTime = Utility.GetCurrentRealTime()
    string[] holds = mcm.GetHoldNames()

    ; int bountyToDays = mcm.GetOptionInListByOID(mcm.oid_prison_bountyToDays, oid)
    ; int minimumSentenceDays = mcm.GetOptionInListByOID(mcm.oid_prison_minimumSentenceDays, oid)
    ; int maximumSentenceDays = mcm.GetOptionInListByOID(mcm.oid_prison_maximumSentenceDays, oid)
    ; int allowUnconditionalImprisonment = mcm.GetOptionInListByOID(mcm.oid_prison_allowBountylessImprisonment, oid)
    ; int sentencePaysBounty = mcm.GetOptionInListByOID(mcm.oid_prison_sentencePaysBounty, oid)
    ; int fastForward = mcm.GetOptionInListByOID(mcm.oid_prison_fastForward, oid)
    ; int dayToFastForwardFrom = mcm.GetOptionInListByOID(mcm.oid_prison_dayToFastForwardFrom, oid)
    ; int handsBoundInPrison = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundInPrison, oid)
    ; int handsBoundMinimumBounty = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundMinimumBounty, oid)
    ; int handsBoundRandomize = mcm.GetOptionInListByOID(mcm.oid_prison_handsBoundRandomize, oid)
    ; int cellLockLevel = mcm.GetOptionInListByOID(mcm.oid_prison_cellLockLevel, oid)
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
