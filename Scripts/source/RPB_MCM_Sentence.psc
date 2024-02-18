Scriptname RPB_MCM_Sentence hidden

import RPB_Utility
import RPB_MCM

bool function ShouldHandleEvent(RPB_MCM mcm, int aiPrisonerFormID = 0) global
    return StringUtil.Find(mcm.CurrentPage, "Sentence - " + aiPrisonerFormID) != -1
    ; return mcm.CurrentPage == "Sentence" || mcm.RPB_CurrentPage == "Sentence"
endFunction

function Render(RPB_MCM mcm, int aiPrisonerFormID) global
    if (! ShouldHandleEvent(mcm, aiPrisonerFormID))
        return
    endif

    int emptySpacesLeft     = 0
    int emptySpacesRight    = 0

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
; ==========================================================
;                           Left
; ==========================================================

    RPB_Prison playerPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    RPB_Prisoner player = playerPrison.GetPrisonerReference(mcm.Config.Player)

    ; if (!player || !player.IsImprisoned)
    ;     return
    ; endif

    RPB_Prison actorPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    RPB_Prisoner prisoner = actorPrison.GetPrisonerReference(Game.GetFormEx(aiPrisonerFormID) as Actor)

    string currentTimeFormatted                 = RPB_Utility.GetCurrentDateFormatted()
    string arrestTimeFormatted                  = actorPrison.GetTimeOfArrestFormatted(prisoner)
    string imprisonmentTimeFormatted            = actorPrison.GetTimeOfImprisonmentFormatted(prisoner)
    string timeElapsedSinceArrest               = actorPrison.GetTimeElapsedSinceArrest(prisoner)
    string timeElapsedSinceImprisonment         = actorPrison.GetTimeElapsedSinceImprisonment(prisoner)
    string timeLeftFormatted                    = actorPrison.GetTimeLeftOfSentenceFormatted(prisoner)
    string releaseTimeFormatted                 = actorPrison.GetTimeOfReleaseFormatted(prisoner)

    mcm.AddOptionText("", currentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
    emptySpacesLeft += 1

    if (prisoner.TimeOfArrest)
        mcm.AddOptionText("\t\t\t\tTime of Arrest", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", arrestTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        if (timeElapsedSinceArrest)
            mcm.AddOptionText("", timeElapsedSinceArrest + " Ago", defaultFlags = mcm.OPTION_DISABLED)
        endif
        mcm.AddEmptyOption()
        emptySpacesLeft += 1
    endif

    if (prisoner.TimeOfImprisonment)
        mcm.AddOptionText("\t\t\t\tTime of Imprisonment", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", imprisonmentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        if (timeElapsedSinceImprisonment)
            mcm.AddOptionText("", timeElapsedSinceImprisonment + " Ago", defaultFlags = mcm.OPTION_DISABLED)
        endif
        mcm.AddEmptyOption()
        emptySpacesLeft += 1
    endif

    if (prisoner.ShowReleaseTime && !prisoner.IsUndeterminedSentence)
        mcm.AddOptionText("\t\t\t\tTime of Release", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", releaseTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", timeLeftFormatted + " from Now", defaultFlags = mcm.OPTION_DISABLED)
        ; mcm.AddOptionText("", "Execution Time: " + xBenchmark + " ms", defaultFlags = mcm.OPTION_DISABLED)
    endif

;     if (prisoner.IsReleaseOnWeekend())
;         mcm.AddOptionText("Release rounded to Morndas.", defaultFlags = mcm.OPTION_DISABLED)
;     endif

    ; RPB_Tests.DisplayNextDaysOfWeek()
    ; RPB_Tests.DisplayPreviousDaysOfWeek()

    mcm.AddEmptyOption()
    emptySpacesLeft += 1
    ; RPB_MCM_Stats.RenderPrisonLeft(mcm, "Castle Dour Dungeon")

    mcm.SetCursorPosition(1)
; ==========================================================
;                           Right
; ==========================================================

    string sentenceFormatted    = actorPrison.GetSentenceFormatted(prisoner)
    string timeServedFormatted  = actorPrison.GetTimeServedFormatted(prisoner)

    float currentHourWithMinutes = RPB_Utility.GetCurrentHourFloat()
    string dayOfWeek       = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear()))
    string currentHour     = RPB_Utility.GetTimeAs12Hour(RPB_Utility.GetCurrentHour(), RPB_Utility.GetMinutesFromHour(currentHourWithMinutes))
    string currentDay      = RPB_Utility.ToOrdinalNthDay(RPB_Utility.GetCurrentDay())
    string currentMonth    = RPB_Utility.GetMonthName(RPB_Utility.GetCurrentMonth())
    string currentYear     = "4E " + RPB_Utility.GetCurrentYear()

    string prisonHold   = prisoner.Prison.Hold
    string prisonCity   = prisoner.Prison.City
    string prisonName   = prisoner.Prison.Name
    string prisonCell   = prisoner.JailCell.ID

    mcm.AddOptionText("", prisonHold + " | " + prisonCity + " | " + prisonName + " | " + prisonCell, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
    ; emptySpacesRight += 1
    
    if (prisoner.Bounty && prisoner.ShowBounty)
        mcm.AddOptionText("Bounty for Arrest", prisoner.BountyNonViolent + " Bounty" + string_if (prisoner.BountyViolent > 0, " / " + prisoner.BountyViolent + " Violent Bounty", ""), defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (prisoner.Captor)
        mcm.AddOptionText("Captured By", prisoner.Captor.GetBaseObject().GetName(), defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (prisoner.ShowSentence && !prisoner.IsUndeterminedSentence)
        mcm.AddOptionText("Sentence", sentenceFormatted, defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (prisoner.ShowTimeLeftInSentence)
        if (!prisoner.IsUndeterminedSentence)
            mcm.AddOptionText("Time Remaining", timeLeftFormatted, defaultFlags = mcm.OPTION_DISABLED)
        else
            mcm.AddOptionText("Time Remaining", "Undetermined", defaultFlags = mcm.OPTION_DISABLED)
        endif
    endif

    if (prisoner.ShowTimeServed && prisoner.TimeServed >= 1)
        mcm.AddOptionText(string_if (!prisoner.IsUndeterminedSentence, "Time Served", "Time in Prison"), timeServedFormatted, defaultFlags = mcm.OPTION_DISABLED)
    endif

    mcm.AddEmptyOption()
    ; emptySpacesRight += 1

    while (emptySpacesRight < emptySpacesLeft)
        mcm.AddEmptyOption()
        emptySpacesRight += 1
    endWhile

    ; RPB_MCM_Stats.RenderPrisonRight(mcm, "Castle Dour Dungeon")
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RPB_MCM mcm, string option) global

endFunction

function OnOptionDefault(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RPB_MCM mcm, string option) global

endFunction

function OnOptionSliderOpen(RPB_MCM mcm, string option) global

endFunction

function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
   
endFunction

function OnOptionMenuOpen(RPB_MCM mcm, string option) global

endFunction

function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global

endFunction

function OnOptionColorOpen(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RPB_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionInputAccept(RPB_MCM mcm, string option, string input) global
    
endFunction

function OnOptionKeymapChange(RPB_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    mcm.Trace(mcm, "Stats::OnHighlght", "Option ID: " + oid)

    
    ; OnOptionHighlight(mcm, mcm.TemporaryGetStatKeyFromOID(oid))
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

endFunction

function OnSelect(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderAccept(RPB_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
endFunction

function OnMenuOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnMenuAccept(RPB_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
endFunction

function OnColorOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnColorAccept(RPB_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
endFunction

function OnKeymapChange(RPB_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnInputAccept(RPB_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
endFunction
