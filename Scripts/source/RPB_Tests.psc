scriptname RPB_Tests hidden

import RPB_Utility

function DisplayNextDaysOfWeek() global
    int firstDayOfWeek  = RPB_Utility.GetDayOfWeekByName("Sundas")
    int lastDayOfWeek   = RPB_Utility.GetDayOfWeekByName("Loredas")

    int currentDayOfWeek = firstDayOfWeek
    while (currentDayOfWeek <= lastDayOfWeek)
        int nextDayOfWeek = RPB_Utility.GetNextDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), currentDayOfWeek)
        int daysTillDayOfWeek = RPB_Utility.GetStructMemberInt(nextDayOfWeek, "daysFromNow")
        string dayOfWeekName = RPB_Utility.GetDayOfWeekName(currentDayOfWeek)
        string dayOfWeekFormatted = RPB_Utility.GetNextDayOfWeekDateFormatted(dayOfWeekName)
        
        RPB_Utility.Debug("Tests::DisplayNextDaysOfWeek", "Next " + dayOfWeekName + ": ")
        RPB_Utility.Debug("Tests::DisplayNextDaysOfWeek", dayOfWeekFormatted)
        RPB_Utility.Debug("Tests::DisplayNextDaysOfWeek", "In " + daysTillDayOfWeek + " Days\n")

        currentDayOfWeek += 1
    endWhile
endFunction

function DisplayPreviousDaysOfWeek() global
    int firstDayOfWeek  = RPB_Utility.GetDayOfWeekByName("Sundas")
    int lastDayOfWeek   = RPB_Utility.GetDayOfWeekByName("Loredas")

    int currentDayOfWeek = firstDayOfWeek
    while (currentDayOfWeek <= lastDayOfWeek)
        int previousDayOfWeek = RPB_Utility.GetPreviousDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), currentDayOfWeek)
        int daysFromDayOfWeek = RPB_Utility.GetStructMemberInt(previousDayOfWeek, "daysAgo")
        string dayOfWeekName = RPB_Utility.GetDayOfWeekName(currentDayOfWeek)
        string dayOfWeekFormatted = RPB_Utility.GetPreviousDayOfWeekDateFormatted(dayOfWeekName)
        
        RPB_Utility.Debug("Tests::DisplayPreviousDaysOfWeek", "Previous " + dayOfWeekName + ": ")
        RPB_Utility.Debug("Tests::DisplayPreviousDaysOfWeek", dayOfWeekFormatted)
        RPB_Utility.Debug("Tests::DisplayPreviousDaysOfWeek", daysFromDayOfWeek + " Days Ago\n")

        currentDayOfWeek += 1
    endWhile
endFunction

bool function Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk() global
    int twentyFiveDaysAfter26thFrostfall = RPB_Utility.GetDateFromDaysPassed(26, 10, 201, 25)
    int day     = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "day")
    int month   = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "month")
    int year    = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "year")

    RPB_Utility.Debug("Tests::Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk", "Date: " + RPB_Utility.GetDateInFormat(day, month, year, format = "d M Y"))
endFunction

; function Test_GetDateFromDaysPassedOldVsNew() global
;     int day     = 10
;     int month   = 1
;     int year    = 201

;     int yearIndex = 201
;     int monthIndex = 1
;     int dayIndex = 1
    
;     string firstMonthName   = RPB_Utility.GetMonthName(month)
;     string firstDayOrdinal  = RPB_Utility.ToOrdinalNthDay(day)

;     int daysProcessed = 1
;     while (monthIndex <= 12)
;         string monthName = RPB_Utility.GetMonthName(monthIndex)
;         while (dayIndex <= RPB_Utility.GetDaysOfMonth(monthIndex))
;             string dayOrdinal = RPB_Utility.ToOrdinalNthDay(dayIndex)
            
;             int newAlgorithmResult = RPB_Utility.GetDateFromDaysPassedFast(day, month, year, daysProcessed)
;             int oldAlgorithmResult = RPB_Utility.GetDateFromDaysPassedStruct(day, month, year, daysProcessed)

;             int newAlgorithmDay = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "day")
;             int oldAlgorithmDay = RPB_Utility.GetStructMemberInt(oldAlgorithmResult, "day")

;             int newAlgorithmMonth = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "month")
;             int oldAlgorithmMonth = RPB_Utility.GetStructMemberInt(oldAlgorithmResult, "month")

;             int newAlgorithmYear = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "year")
;             int oldAlgorithmYear = RPB_Utility.GetStructMemberInt(oldAlgorithmResult, "year")
;             int newAlgorithmMonthsAdvanced = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "debug_monthsIncreased")
;             int newAlgorithmDaysIncreased = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "debug_daysIncreased")

;             string oldAlgorithmDate = RPB_Utility.GetDateInFormat(oldAlgorithmDay, oldAlgorithmMonth, oldAlgorithmYear)
;             string newAlgorithmDate = RPB_Utility.GetDateInFormat(newAlgorithmDay, newAlgorithmMonth, newAlgorithmYear)

;             bool hasDayPassedTest = newAlgorithmDay == oldAlgorithmDay
;             string testResultStr = string_if (hasDayPassedTest, "[PASSED]", "[FAILED]")
;             RPB_Utility.Debug("Tests::Test_GetDateFromDaysPassedOldVsNew", testResultStr + " - Testing " + (daysProcessed) + " days after " + firstDayOrdinal + " of " + firstMonthName + "... " + string_if (!hasDayPassedTest, "("+ "Expected: " + oldAlgorithmDate + ", Got: " + newAlgorithmDate +")" + " ["+ "Months Advanced: " + newAlgorithmMonthsAdvanced +"]" + " ["+ "Days Increased: " + newAlgorithmDaysIncreased +"]", "(Result: "+ newAlgorithmDate +")"))

;             dayIndex += 1
;             daysProcessed += 1
;         endWhile

;         dayIndex = 1
;         monthIndex += 1
;     endWhile
; endFunction