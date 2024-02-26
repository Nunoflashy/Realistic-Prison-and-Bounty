Scriptname RPB_MCM_02_Prison hidden

import RPB_Utility

bool function ShouldHandleEvent(RPB_MCM_02 mcm, RPB_Prisoner apPrisoner = none) global
    RPB_Prison prison       = apPrisoner.Prison
    return StringUtil.Find(mcm.CurrentPage, prison.Name + " - " + apPrisoner.Name + " (#"+ apPrisoner.Number +")") != -1
endFunction

function Render(RPB_MCM_02 mcm, RPB_Prisoner apPrisoner) global
    if (! ShouldHandleEvent(mcm, apPrisoner))
        return
    endif

    int emptySpacesLeft     = 0
    int emptySpacesRight    = 0

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
; ==========================================================
;                           Left
; ==========================================================

    RPB_Prison prison       = apPrisoner.Prison
    RPB_Prisoner prisoner   = apPrisoner

    if (!prisoner.IsImprisoned)
        Warn("The prisoner " + prisoner.Name + " (Prisoner #"+ prisoner.Number +") " + " is not imprisoned, no stats to show.")
        return
    endif

    Debug("MCM_02_Prison::Render", "prison: " + prison + ", prisoner: " + prisoner)


    string currentTimeFormatted                 = RPB_Utility.GetCurrentDateFormatted()
    string arrestTimeFormatted                  = prison.GetTimeOfArrestFormatted(prisoner)
    string imprisonmentTimeFormatted            = prison.GetTimeOfImprisonmentFormatted(prisoner)
    string timeElapsedSinceArrest               = prison.GetTimeElapsedSinceArrest(prisoner)
    string timeElapsedSinceImprisonment         = prison.GetTimeElapsedSinceImprisonment(prisoner)
    string timeLeftFormatted                    = prison.GetTimeLeftOfSentenceFormatted(prisoner)
    string releaseTimeFormatted                 = prison.GetTimeOfReleaseFormatted(prisoner)

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
    ; RPB_MCM_02_Stats.RenderPrisonLeft(mcm, "Castle Dour Dungeon")

    mcm.SetCursorPosition(1)
; ==========================================================
;                           Right
; ==========================================================

    string sentenceFormatted    = prison.GetSentenceFormatted(prisoner)
    string timeServedFormatted  = prison.GetTimeServedFormatted(prisoner)

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
    string prisonerName = prisoner.Name

    string prisonTemplate = RPB_Data.MCM_GetPrisonTemplate()

    int placeholders = JArray.object()
    int replacements = JArray.object()

    JArray.addStr(placeholders, "hold")
    JArray.addStr(placeholders, "city")
    JArray.addStr(placeholders, "prison")
    JArray.addStr(placeholders, "cell")
    JArray.addStr(placeholders, "prisoner")

    JArray.addStr(replacements, prisonHold)
    JArray.addStr(replacements, prisonCity)
    JArray.addStr(replacements, prisonName)
    JArray.addStr(replacements, prisonCell)
    JArray.addStr(replacements, prisonerName)

    string header = RPB_Utility.Replace(prisonTemplate, JArray.asStringArray(placeholders), JArray.asStringArray(replacements))

    mcm.AddOptionText("", header, defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", prisonHold + " | " + prisonCity + " | " + prisonName + " | " + prisonCell, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
    ; emptySpacesRight += 1
    
    if (prisoner.Bounty && prisoner.ShowBounty)
        mcm.AddOptionText("Bounty for Arrest", \ 
            string_if (prisoner.BountyNonViolent > 0, prisoner.BountyNonViolent + " Bounty") + \ 
            string_if (prisoner.BountyNonViolent && prisoner.BountyViolent, " / ") + \
            string_if (prisoner.BountyViolent > 0, prisoner.BountyViolent + " Violent Bounty"), \ 
            defaultFlags = mcm.OPTION_DISABLED \
        )
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

    ; RPB_MCM_02_Stats.RenderPrisonRight(mcm, "Castle Dour Dungeon")
endFunction