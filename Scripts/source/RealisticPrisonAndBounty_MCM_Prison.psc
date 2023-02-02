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
    mcm.AddOptionSliderEx("Bounty to Days",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSliderEx("Minimum Sentence (Days)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSliderEx("Maximum Sentence (Days)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggleEx("Allow Bountyless Imprisonment",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggleEx("Sentence pays Bounty",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggleEx("Fast Forward",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionSliderEx("Day to fast forward from",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggleEx("Hands Bound in Prison",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionSliderEx("Hands Bound (Minimum Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionToggleEx("Hands Bound (Randomize)",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
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

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    string[] holds = mcm.GetHoldNames()
    string hold = holds[mcm.CurrentOptionIndex]

    ; int prisonTimescale                 = mcm.oid_prison_prisonTimeScale 
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

    ; ; mcm.SetInfoText( \
    ; ;     string_if (oid == prisonTimescale, "Sets the timescale while imprisoned.", \
    ; ;     string_if (oid == bountyToDays, "Sets the relation between bounty and days in " + hold + "'s prison.", \
    ; ;     string_if (oid == minimumSentenceDays, "Determines the minimum sentence in days for " + hold + "'s prison.", \
    ; ;     string_if (oid == maximumSentenceDays, "Determines the maximum sentence in days for " + hold + "'s prison.", \
    ; ;     string_if (oid == allowUnconditionalImprisonment, "Whether to allow unconditional imprisonment without a bounty in " + hold + "'s prison.", \
    ; ;     string_if (oid == sentencePaysBounty, "Determines if serving the sentence pays the bounty in "  + hold + ".\nIf disabled, the bounty must be paid after serving the sentence.", \
    ; ;     string_if (oid == fastForward, "Whether to fast forward to the release in " + hold + ".", \
    ; ;     string_if (oid == dayToFastForwardFrom, "The day to fast forward from to release in " + hold + ".", \
    ; ;     string_if (oid == handsBoundInPrison, "Whether to have hands restrained during imprisonment in " + hold + ".", \
    ; ;     string_if (oid == handsBoundMinimumBounty, "The minimum bounty required to have hands restrained during imprisonment in " + hold + ".", \
    ; ;     string_if (oid == handsBoundRandomize, "Randomize whether to be restrained or not, while in prison in " + hold + ".", \
    ; ;     string_if (oid == cellLockLevel, "Determines the cell's door lock level", \
    ; ;     "No description defined for this option." \
    ; ;     )))))))))))) \
    ; ; )

    ; if (oid == prisonTimescale)
    ;     mcm.SetInfoText("Sets the timescale while imprisoned.")
    ; elseif (oid == bountyToDays)
    ;     mcm.SetInfoText("Sets the relation between bounty and days in " + hold + "'s prison.")
    ; elseif (oid == minimumSentenceDays)
    ;     mcm.SetInfoText("Determines the minimum sentence in days for " + hold + "'s prison.")
    ; elseif (oid == maximumSentenceDays)
    ;     mcm.SetInfoText("Determines the maximum sentence in days for " + hold + "'s prison.")
    ; elseif (oid == allowUnconditionalImprisonment)
    ;     mcm.SetInfoText("Whether to allow unconditional imprisonment without a bounty in " + hold + "'s prison.")
    ; elseif (oid == sentencePaysBounty)
    ;     mcm.SetInfoText("Determines if serving the sentence pays the bounty in "  + hold + ".\nIf disabled, the bounty must be paid after serving the sentence.")
    ; elseif (oid == fastForward)
    ;     mcm.SetInfoText("Whether to fast forward to the release in " + hold + ".")
    ; elseif (oid == dayToFastForwardFrom)
    ;     mcm.SetInfoText("The day to fast forward from to release in " + hold + ".")
    ; elseif (oid == handsBoundInPrison)
    ;     mcm.SetInfoText("Whether to have hands restrained during imprisonment in " + hold + ".")
    ; elseif (oid == handsBoundMinimumBounty)
    ;     mcm.SetInfoText("The minimum bounty required to have hands restrained during imprisonment in " + hold + ".")
    ; elseif (oid == handsBoundRandomize) 
    ;     mcm.SetInfoText("Randomize whether to be restrained or not, while in prison in " + hold + ".")
    ; elseif (oid == cellLockLevel)
    ;     mcm.SetInfoText("Determines the cell's door lock level")
    ; endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction



function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    string optionKey = mcm.GetKeyFromOption(oid)

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

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
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

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    ; if (oid == mcm.oid_prison_prisonTimeScale)
    ;     mcm.SetSliderOptionValue(oid, value)
    ;     mcm.PrisonTimescale.SetValueInt((value as int))
    ;     Log(mcm, "Prison::OnSingleOptionSliderAccept", "(oid: " + oid + ")")
    ; endif
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
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
