Scriptname RPB_MCM_02_Holds hidden

import RPB_Utility
import RPB_MCM_02

bool function ShouldHandleEvent(RPB_MCM_02 mcm) global
    return mcm.IsHoldCurrentPage()
endFunction

function RenderPrisonLeft(RPB_MCM_02 mcm, string asPrisonName) global
    string prisonCity = "Solitude"

    ; ==========================================================
    ;                           Left
    ; ==========================================================
    mcm.AddOptionCategory(asPrisonName + " ("+ prisonCity +")", flags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Time Jailed", RPB_Utility.GetTimeFormatted(100), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Longest Sentence", RPB_Utility.GetTimeFormatted(30*4), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Current Infamy", "50", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("Last Jailed", RPB_Utility.GetDateFormat(17, 12, 201, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
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
    mcm.AddOptionText("", hold + " Statistics", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
    mcm.AddOptionText("", "Last Jailed At " + RPB_Utility.GetDateFormat(17, 12, 201, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "In " + "Castle Dour Dungeon", defaultFlags = mcm.OPTION_DISABLED)
    
    ; mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    ; mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)

    RenderPrisonLeft(mcm, "Castle Dour Dungeon")
    RenderPrisonLeft(mcm, "Another Test Prison")

    mcm.SetCursorPosition(1)
    ; ==========================================================
    ;                           Right
    ; ==========================================================

    mcm.AddOptionText("", "Bounty: 250 | Violent Bounty: 50", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "Largest Bounty: 4000 | Total Bounty: 7000", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "Times Arrested: 0 | Times Frisked: 0", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "Arrests Eluded: 0 | Arrests Resisted: 0", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "Bounties Paid: 0", defaultFlags = mcm.OPTION_DISABLED)

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