Scriptname RPB_MCM_Sentence hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == "Sentence" || mcm.RPB_CurrentPage == "Sentence"
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

function Left(RealisticPrisonAndBounty_MCM mcm) global
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
    if (!player)
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

    ; int[] releaseDate = RPB_Utility.GetDateFromDaysPassed(player.DayOfImprisonment, player.MonthOfImprisonment, player.YearOfImprisonment, playerSentence)
    ; int release_day = releaseDate[0]
    ; int release_month = releaseDate[1]
    ; int release_year = releaseDate[2]

    ; string release_dayOfWeek   = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(release_day, release_month, release_year))
    ; string release_hour        = RPB_Utility.GetTimeAs12Hour(player.ReleaseHour, player.ReleaseMinute)
    ; string release_maxHour     = RPB_Utility.GetTimeAs12Hour(playerPrison.ReleaseTimeMaximumHour)
    ; float release_midpointHourAndMins = (player.ReleaseHour + playerPrison.ReleaseTimeMaximumHour) / 2
    ; int release_midpointHour = math.floor(release_midpointHourAndMins)
    ; int release_midpointMinutes = Round((release_midpointHourAndMins - math.floor(release_midpointHourAndMins)) * 60)
    ; string release_midpointHourFormatted = RPB_Utility.GetTimeAs12Hour(release_midpointHour, release_midpointMinutes)
    ; string release_hourShown = string_if (release_day> 10, "~" + release_midpointHourFormatted, release_hour + " - " + release_maxHour)
    ; string release_dayOrdinal  = RPB_Utility.ToOrdinalNthDay(release_day)
    ; string release_monthName   = RPB_Utility.GetMonthName(release_month)
    ; string release_yearString  = "4E " + release_year

    ; int arrest_day = player.DayOfArrest
    ; int arrest_month = player.MonthOfArrest
    ; int arrest_year = player.YearOfArrest

    ; string arrest_dayOfWeek   = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(arrest_day, arrest_month, arrest_year))
    ; string arrest_hour        = RPB_Utility.GetTimeAs12Hour(player.HourOfArrest, player.MinuteOfArrest)
    ; string arrest_dayOrdinal  = RPB_Utility.ToOrdinalNthDay(arrest_day)
    ; string arrest_monthName   = RPB_Utility.GetMonthName(arrest_month)
    ; string arrest_yearString  = "4E " + arrest_year

    ; int imprisonment_day = player.DayOfImprisonment
    ; int imprisonment_month = player.MonthOfImprisonment
    ; int imprisonment_year = player.YearOfImprisonment

    ; string imprisonment_dayOfWeek   = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(imprisonment_day, imprisonment_month, imprisonment_year))
    ; string imprisonment_hour        = RPB_Utility.GetTimeAs12Hour(player.HourOfImprisonment, player.MinuteOfImprisonment)
    ; string imprisonment_dayOrdinal  = RPB_Utility.ToOrdinalNthDay(imprisonment_day)
    ; string imprisonment_monthName   = RPB_Utility.GetMonthName(imprisonment_month)
    ; string imprisonment_yearString  = "4E " + imprisonment_year

    ; ; mcm.AddOptionCategory("Sentence")
    mcm.AddOptionText("\t\t\t\tCurrent Time", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", currentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", dayOfWeek + ", " + currentHour + ", " + currentDay + " of " + currentMonth + ", " + currentYear, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tTime of Arrest", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", arrest_dayOfWeek + ", " + arrest_hour + ", " + arrest_dayOrdinal + " of " + arrest_monthName + ", " + arrest_yearString, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", arrestTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", timeElapsedSinceArrest + " Ago", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tTime of Imprisonment", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", imprisonment_dayOfWeek + ", " + imprisonment_hour + ", " + imprisonment_dayOrdinal + " of " + imprisonment_monthName + ", " + imprisonment_yearString, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", imprisonmentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", timeElapsedSinceImprisonment + " Ago", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", (Round(player.DayOfImprisonment)) + " Days Ago", defaultFlags = mcm.OPTION_DISABLED)

    ; mcm.AddEmptyOption()

    mcm.AddOptionText("\t\t\t\tTime of Release", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", releaseTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", timeLeftFormatted + " from Now", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", release_dayOfWeek + ", " + release_hourShown + ", " + release_dayOrdinal + " of " + release_monthName + ", " + release_yearString, defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("\t\t\t\t("+ (Round(player.TimeLeftInSentence)) + " Days from Now" +")", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddOptionText("", (Round(player.TimeLeftInSentence)) + " Days from Now", defaultFlags = mcm.OPTION_DISABLED)

    int[] nextSundas = RPB_Utility.GetNextDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), RPB_Utility.GetDayOfWeekByName("Sundas"))
    int sundasDay = nextSundas[0]
    int sundasMonth = nextSundas[1]
    int sundasYear = nextSundas[2]
    int daysTillSundas = nextSundas[3]
    string sundasDateFormatted = RPB_Utility.GetFormattedDate(sundasDay, sundasMonth, sundasYear, RPB_Utility.GetCurrentHour(), RPB_Utility.GetCurrentMinute())

    mcm.AddOptionText("\t\t\t\tNext Sundas", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", sundasDateFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "In " + daysTillSundas + " Days", defaultFlags = mcm.OPTION_DISABLED)

    if (player.IsReleaseOnWeekend())
        mcm.AddOptionText("Release rounded to Morndas.", defaultFlags = mcm.OPTION_DISABLED)
    endif
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    RPB_Prison playerPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    RPB_Prisoner player = playerPrison.GetPrisonerReference(mcm.Config.Player)
    RPB_Utility.Debug("MCM::Sentence::Right", "playerPrison: " + playerPrison.City + ", Prisoners: " + playerPrison.Prisoners.GetKeys())
    if (!player)
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

RPB_Prison function GetPlayerPrison(RealisticPrisonAndBounty_MCM mcm) global
    RPB_Prison playerPrison = RPB_Prison.GetPrisonForImprisonedActor(mcm.Config.Player)
    
    if (!playerPrison)
        return none
    endif

    return playerPrison
    ; return playerPrison.GetPrisoner(mcm.Config.Player)
endFunction

RPB_Prisoner function GetPlayerPrisonerReference(RealisticPrisonAndBounty_MCM mcm) global
    return GetPlayerPrison(mcm).GetPrisonerReference(mcm.Config.Player)
endFunction


; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
   
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

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
    
    mcm.Trace(mcm, "Stats::OnHighlght", "Option ID: " + oid)

    
    ; OnOptionHighlight(mcm, mcm.TemporaryGetStatKeyFromOID(oid))
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    ; OnOptionDefault(mcm, mcm.TemporaryGetStatKeyFromOID(oid))
    ; OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
endFunction
