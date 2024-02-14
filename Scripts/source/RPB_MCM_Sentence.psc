Scriptname RPB_MCM_Sentence hidden

import RealisticPrisonAndBounty_Util
import RPB_MCM

bool function ShouldHandleEvent(RPB_MCM mcm) global
    return mcm.CurrentPage == "Sentence" || mcm.RPB_CurrentPage == "Sentence"
endFunction

function Render(RPB_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)
endFunction

function Left(RPB_MCM mcm) global
    ; float currentHourWithMinutes = RPB_Utility.GetCurrentHourFloat()
    ; string dayOfWeek       = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear()))
    ; string currentHour     = RPB_Utility.GetTimeAs12Hour(RPB_Utility.GetCurrentHour(), RPB_Utility.GetMinutesFromHour(currentHourWithMinutes))
    ; string currentDay      = RPB_Utility.ToOrdinalNthDay(RPB_Utility.GetCurrentDay())
    ; string currentMonth    = RPB_Utility.GetMonthName(RPB_Utility.GetCurrentMonth())
    ; string currentYear     = "4E " + RPB_Utility.GetCurrentYear()

    ; int release_day = 21
    ; int release_month = 11
    ; int release_year = 201

    RPB_Prison playerPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    RPB_Prisoner player = playerPrison.GetPrisonerReference(mcm.Config.Player)
    RPB_Utility.Debug("MCM::Sentence::Right", "playerPrison: " + playerPrison.City + ", Prisoners: " + playerPrison.Prisoners.GetKeys())
    if (!player || !player.IsImprisoned)
        return
    endif

    ; RPB_Prisoner playerPrisonerReference = GetPlayerPrisonerReference(mcm)
    ; RPB_Utility.Debug("MCM::Sentence::Right", "playerPrisonerReference: " + playerPrisonerReference)

    ; int[] releaseDate = RPB_Utility.GetDateFromDaysPassed(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), 25)

    string currentTimeFormatted                 = RPB_Utility.GetCurrentDateFormatted()
    string arrestTimeFormatted                  = playerPrison.GetTimeOfArrestFormatted(player)
    string imprisonmentTimeFormatted            = playerPrison.GetTimeOfImprisonmentFormatted(player)
    string timeElapsedSinceArrest               = playerPrison.GetTimeElapsedSinceArrest(player)
    string timeElapsedSinceImprisonment         = playerPrison.GetTimeElapsedSinceImprisonment(player)
    string releaseTimeFormatted                 = playerPrison.GetTimeOfReleaseFormatted(player)
    string timeLeftFormatted                    = playerPrison.GetTimeLeftOfSentenceFormatted(player)

    mcm.AddOptionText("\t\t\t\tCurrent Time", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", currentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tTime of Arrest", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", arrestTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    if (timeElapsedSinceArrest)
        mcm.AddOptionText("", timeElapsedSinceArrest + " Ago", defaultFlags = mcm.OPTION_DISABLED)
    endif
    mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tTime of Imprisonment", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", imprisonmentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    if (timeElapsedSinceImprisonment)
        mcm.AddOptionText("", timeElapsedSinceImprisonment + " Ago", defaultFlags = mcm.OPTION_DISABLED)
    endif
    mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tTime of Release", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", releaseTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", timeLeftFormatted + " from Now", defaultFlags = mcm.OPTION_DISABLED)

    int[] nextSundas = RPB_Utility.GetNextDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), RPB_Utility.GetDayOfWeekByName("Sundas"))
    int[] previousSundas = RPB_Utility.GetPreviousDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), RPB_Utility.GetDayOfWeekByName("Sundas"))
    ; int sundasDay = nextSundas[0]
    ; int sundasMonth = nextSundas[1]
    ; int sundasYear = nextSundas[2]
    int daysTillSundas = nextSundas[3]
    int daysFromPreviousSundas = previousSundas[3]
    ; string sundasDateFormatted = RPB_Utility.GetFormattedDate(sundasDay, sundasMonth, sundasYear, RPB_Utility.GetCurrentHour(), RPB_Utility.GetCurrentMinute(), abShowTime = false)
    string sundasDateFormatted          = RPB_Utility.GetNextDayOfWeekDateFormatted("Sundas")
    string previousSundasDateFormatted  = RPB_Utility.GetPreviousDayOfWeekDateFormatted("Sundas")
 
mcm.AddEmptyOption()
mcm.AddEmptyOption()

mcm.AddOptionText("\t\t\t\tCurrent Time", defaultFlags = mcm.OPTION_DISABLED)
mcm.AddOptionText("", currentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tNext Sundas", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", sundasDateFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "In " + daysTillSundas + " Days", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tPrevious Sundas", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", previousSundasDateFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", daysFromPreviousSundas + " Days Ago", defaultFlags = mcm.OPTION_DISABLED)

    if (player.IsReleaseOnWeekend())
        mcm.AddOptionText("Release rounded to Morndas.", defaultFlags = mcm.OPTION_DISABLED)
    endif
endFunction

function Right(RPB_MCM mcm) global
    RPB_Prison playerPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    RPB_Prisoner player = playerPrison.GetPrisonerReference(mcm.Config.Player)
    RPB_Utility.Debug("MCM::Sentence::Right", "playerPrison: " + playerPrison.City + ", Prisoners: " + playerPrison.Prisoners.GetKeys())
    if (!player || !player.IsImprisoned)
        return
    endif

    string sentenceFormatted    = playerPrison.GetSentenceFormatted(player)
    string timeLeftFormatted    = playerPrison.GetTimeLeftOfSentenceFormatted(player)
    string timeServedFormatted  = playerPrison.GetTimeServedFormatted(player)


    float currentHourWithMinutes = RPB_Utility.GetCurrentHourFloat()
    string dayOfWeek       = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear()))
    string currentHour     = RPB_Utility.GetTimeAs12Hour(RPB_Utility.GetCurrentHour(), RPB_Utility.GetMinutesFromHour(currentHourWithMinutes))
    string currentDay      = RPB_Utility.ToOrdinalNthDay(RPB_Utility.GetCurrentDay())
    string currentMonth    = RPB_Utility.GetMonthName(RPB_Utility.GetCurrentMonth())
    string currentYear     = "4E " + RPB_Utility.GetCurrentYear()

    ; RPB_Prisoner playerPrisonerReference = GetPlayerPrisonerReference(mcm)
    ; RPB_Utility.Debug("MCM::Sentence::Right", "playerPrisonerReference: " + playerPrisonerReference)

    mcm.AddOptionText("Hold", "Haafingar", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("City", "Solitude", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Prison Location", "Castle Dour Dungeon", defaultFlags = mcm.OPTION_DISABLED)
    
    mcm.AddEmptyOption()
    
    mcm.AddOptionText("Bounty for Arrest", player.BountyNonViolent + " Bounty" + string_if (player.BountyViolent > 0, " / " + player.BountyViolent + " Violent Bounty", ""), defaultFlags = mcm.OPTION_DISABLED)

    if (player.Captor)
        mcm.AddOptionText("Captured By", player.Captor.GetBaseObject().GetName(), defaultFlags = mcm.OPTION_DISABLED)
    endif
    mcm.AddEmptyOption()

    ; mcm.AddOptionText("Sentence", math.floor(player.Sentence) + " Days", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Sentence", sentenceFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Time Served", timeServedFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Time Remaining", timeLeftFormatted, defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionCategoryKey("", "Sentence")
    ; mcm.AddOptionText(currentHour + ", " + currentDay + " of " + currentMonth)
    ; mcm.AddOptionText("")
    ; mcm.AddOptionText("")
    ; mcm.AddOptionText("")
    ; mcm.AddOptionText("")
endFunction

RPB_Prison function GetPlayerPrison(RPB_MCM mcm) global
    RPB_Prison playerPrison = RPB_Prison.GetPrisonForImprisonedActor(mcm.Config.Player)
    
    if (!playerPrison)
        return none
    endif

    return playerPrison
    ; return playerPrison.GetPrisoner(mcm.Config.Player)
endFunction

RPB_Prisoner function GetPlayerPrisonerReference(RPB_MCM mcm) global
    return GetPlayerPrison(mcm).GetPrisonerReference(mcm.Config.Player)
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

    ; OnOptionDefault(mcm, mcm.TemporaryGetStatKeyFromOID(oid))
    ; OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
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
