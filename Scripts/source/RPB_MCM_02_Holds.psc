Scriptname RPB_MCM_02_Holds hidden

import RPB_Utility
import RPB_MCM_02

bool function ShouldHandleEvent(RPB_MCM_02 mcm) global
    return mcm.IsHoldCurrentPage()
endFunction

function RenderPrisonLeft(RPB_MCM_02 mcm, string asPrisonName) global
    string prisonCity = "Solitude"

    string hold = mcm.CurrentPage

    int holdObject = RPB_Data.GetRootObject(hold)
    Faction holdCrimeFaction = RPB_Data.Hold_GetCrimeFaction(holdObject)

    float timeJailed    = RPB_ActorVars.GetTimeJailed(holdCrimeFaction, Game.GetForm(0x14) as Actor)
    int lastSentence    = RPB_ActorVars.GetLastSentence(holdCrimeFaction, Game.GetForm(0x14) as Actor)

    ; ==========================================================
    ;                           Left
    ; ==========================================================
    mcm.AddOptionCategory(asPrisonName + " ("+ prisonCity +")", flags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("Time Jailed", RPB_Utility.GetTimeFormatted(100), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Time in Prison", RPB_Utility.GetTimeFormatted(timeJailed, asNullValue = "N/A"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Last Sentence", RPB_Utility.GetTimeFormatted(lastSentence, asNullValue = "N/A"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Longest Sentence", RPB_Utility.GetTimeFormatted(30*4), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Current Infamy", "50", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
endFunction

function RenderPrisonRight(RPB_MCM_02 mcm, string asPrisonName) global
    string prisonCity = "Solitude"

    ; ==========================================================
    ;                           Right
    ; ==========================================================
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)

    mcm.AddOptionText("Times Frisked", "1", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Times Stripped", "0", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Times Jailed", "1", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Times Escaped", "0", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
endFunction

function RenderTest(RPB_MCM_02 mcm) global
    string hold = mcm.CurrentPage

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    ; ==========================================================
    ;                           Left
    ; ==========================================================

    int holdObject = RPB_Data.GetRootObject(hold)
    Faction holdCrimeFaction = RPB_Data.Hold_GetCrimeFaction(holdObject)
    int prisonId            = RPB_StorageVars.GetIntOnForm("Last Jailed - Prison", holdCrimeFaction)
    int lastJailedDay       = RPB_StorageVars.GetIntOnForm("Last Jailed - Day", holdCrimeFaction)
    int lastJailedMonth     = RPB_StorageVars.GetIntOnForm("Last Jailed - Month", holdCrimeFaction)
    int lastJailedYear      = RPB_StorageVars.GetIntOnForm("Last Jailed - Year", holdCrimeFaction)
    int lastJailedHour      = RPB_StorageVars.GetIntOnForm("Last Jailed - Hour", holdCrimeFaction)
    int lastJailedMinute    = RPB_StorageVars.GetIntOnForm("Last Jailed - Minute", holdCrimeFaction)

    RPB_Prison lastJailedPrison = RPB_API.GetPrisonManager().GetPrisonByID(prisonId)

    mcm.AddOptionText("", hold + " Statistics", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    if (prisonId && lastJailedPrison)
        if (lastJailedDay == RPB_Utility.GetCurrentDay() && lastJailedMonth == RPB_Utility.GetCurrentMonth() && lastJailedYear == RPB_Utility.GetCurrentYear())
            mcm.AddOptionText("", "Currently Jailed In " + lastJailedPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
        else
            mcm.AddOptionText("", "Last Jailed At " + RPB_Utility.GetDateFormat(lastJailedDay, lastJailedMonth, lastJailedYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
            mcm.AddOptionText("", "In " + lastJailedPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
        endif
        mcm.AddEmptyOption()
        if (!RPB_StorageVars.GetBoolOnForm("Imprisoned", Game.GetForm(0x14)))
            int releaseDay       = RPB_StorageVars.GetIntOnForm("Last Released - Day", holdCrimeFaction)
            int releaseMonth     = RPB_StorageVars.GetIntOnForm("Last Released - Month", holdCrimeFaction)
            int releaseYear      = RPB_StorageVars.GetIntOnForm("Last Released - Year", holdCrimeFaction)
            int releaseHour      = RPB_StorageVars.GetIntOnForm("Last Released - Hour", holdCrimeFaction)
            int releaseMinute    = RPB_StorageVars.GetIntOnForm("Last Released - Minute", holdCrimeFaction)
            mcm.AddOptionText("", "Released On " + RPB_Utility.GetDateFormat(releaseDay, releaseMonth, releaseYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
        endif
    else
        mcm.AddOptionText("", "You have not yet been jailed", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", "In " + hold, defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddEmptyOption()        
        ; mcm.AddOptionText("", "In any of " + hold + "'s prisons", defaultFlags = mcm.OPTION_DISABLED) ; Saved for future updates when 1:N Hold to Prison
    endif
    
    ; mcm.AddEmptyOption()
    ; mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    ; mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)

    RenderPrisonLeft(mcm, "Castle Dour Dungeon")
    RenderPrisonLeft(mcm, "Another Test Prison")

    mcm.SetCursorPosition(1)
    ; ==========================================================
    ;                           Right
    ; ==========================================================
    
    string[] holdPlaceholders   = mcm.HoldStatsPlaceholders
    string[] holdStats          = mcm.ConstructHoldStatValues(250, 50, 4000, 7000, 1, 2, 1, 0, 4)

    int optionIndex = 0
    int optionCount = mcm.HoldStatsTemplate.Length
    while (optionIndex < optionCount)
        string currentStatLineTemplate = mcm.HoldStatsTemplate[optionIndex]
        string statLine = RPB_Utility.Replace(currentStatLineTemplate, holdPlaceholders, holdStats)
        mcm.AddOptionText("", statLine, defaultFlags = mcm.OPTION_DISABLED)
        optionIndex += 1
    endWhile

    ; Temporary
    if (prisonId && lastJailedPrison && !RPB_StorageVars.GetBoolOnForm("Imprisoned", Game.GetForm(0x14)))
        mcm.AddEmptyOption()
    endif

    ; mcm.AddOptionText("", "Bounty: 250 | Violent Bounty: 50", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "Largest Bounty: 4000 | Total Bounty: 7000", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "Times Arrested: 0 | Times Frisked: 0", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "Arrests Eluded: 0 | Arrests Resisted: 0", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "Bounties Paid: 0", defaultFlags = mcm.OPTION_DISABLED)

    ; mcm.AddOptionText("", "250 Bounty | 50 Violent Bounty", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "4000 Largest Bounty | 7000 Total Bounty", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "0 Times Arrested | 0 Bounties Paid", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", "0 Arrests Eluded | 0 Arrests Resisted", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()


    RenderPrisonRight(mcm, "Castle Dour Dungeon")
    RenderPrisonRight(mcm, "Another Test Prison")
endFunction

function Render(RPB_MCM_02 mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    RenderTest(mcm)

    return

    float x = StartBenchmark()
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    EndBenchmark(x)
endFunction

function Left(RPB_MCM_02 mcm) global
endFunction

function Right(RPB_MCM_02 mcm) global
endFunction

; =====================================================
; Events
; =====================================================