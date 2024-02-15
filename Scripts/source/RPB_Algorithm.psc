scriptname RPB_Algorithm hidden

import RPB_Utility
import Math

int function GetDateFromDaysPassedFast(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    int currentDay = aiDay + aiDaysPassed;
    int currentMonth = aiMonth;
    int currentYear = aiYear;

    while (currentDay > GetDaysOfMonth(currentMonth)) 
        currentDay -= GetDaysOfMonth(currentMonth);
        currentMonth += 1

        if (currentMonth > 12)
            currentYear += 1
            currentMonth = 1
        endif
    endWhile

    int struct = JMap.object();
    JMap.setInt(struct, "day", currentDay);
    JMap.setInt(struct, "month", currentMonth);
    JMap.setInt(struct, "year", currentYear);

    return struct;
endFunction

int function GetDateFromDaysPassed2(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    int totalDaysPassed = aiDaysPassed

    int currentYear = aiYear
    int currentMonth = aiMonth
    int currentDay = aiDay

    while (totalDaysPassed > 0)
        int daysInMonth = GetDaysOfMonth(currentMonth)
        int daysToAdvance = min(totalDaysPassed, daysInMonth - currentDay + 1) as int

        currentDay += daysToAdvance
        totalDaysPassed -= daysToAdvance

        if currentDay > daysInMonth
            currentDay = 1
            currentMonth += 1

            if currentMonth > 12
                currentYear += 1
                currentMonth = 1
            endif
        endif
    endwhile

    int struct = JMap.object()
    JMap.setInt(struct, "day", currentDay)
    JMap.setInt(struct, "month", currentMonth)
    JMap.setInt(struct, "year", currentYear)

    return struct
endFunction

int function GetDateFromDaysPassedSlow(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    ; Get the full days from the beginning of the year till the date passed in
    int daysPassedSinceStartOfYear = CalculateDaysPassedFromDate(aiDay, aiMonth, aiYear)

    ; Add the days to totalDaysPassed (if totalDaysPassed is 229 and we want to know what date is 30d from now)
    ; aiDaysPassed would be 30, resulting in 259 (which should give us the next month)
    int totalDaysPassed = daysPassedSinceStartOfYear + aiDaysPassed

    int currentDay = aiDay ; 17

    ; Now that we have 259 as total days passed, we need to find out what month this comes down to
    int currentMonth = aiMonth ; Assuming we start at Month 8, this starts at 8
    ; So now 229 days passed equals month 8 since that's what we pass to totalDaysPassed and that's the result

    int currentYear = aiYear

    int totalDaysProcessed = totalDaysPassed
    bool wasProcessedInLoop = false

    if ((aiDay + aiDaysPassed) <= GetDaysOfMonth(aiMonth))
        currentDay += aiDaysPassed
    else
        ; Debug("Utility::GetDateFromDaysPassed", "totalDaysProcessed: " + totalDaysProcessed + ", totalDaysProcessed: " + totalDaysProcessed)
        while ((totalDaysProcessed - daysPassedSinceStartOfYear) > 0) ; while there are days to process
            if (currentDay >= GetDaysOfMonth(currentMonth))
                currentDay = 1
                currentMonth += 1
            else
                currentDay += 1
            endif

            if (currentMonth > 12)
                currentYear += 1 ; Go to the next year
                currentMonth = 1 ; Start on 1st month of next year
            endif

            totalDaysProcessed -= 1
        endWhile
    endif

    ; int remainingDays = int_if (totalDaysProcessed < daysPassedSinceStartOfYear, (daysPassedSinceStartOfYear - totalDaysProcessed), (totalDaysProcessed - daysPassedSinceStartOfYear))
    ; int remainingDays = totalDaysProcessed - daysPassedSinceStartOfYear

    ; Debug("Utility::GetDateFromDaysPassed", "totalDaysProcessed: " + totalDaysProcessed + ", daysPassedSinceStartOfYear: " + daysPassedSinceStartOfYear + ", remainingDays: " + remainingDays + ", currentDay: " + currentDay)
    ; DebugWithArgs("Utility::GetDateFromDaysPassed", aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, "daysPassedSinceStartOfYear: " + daysPassedSinceStartOfYear + ", totalDaysPassed: " + totalDaysPassed + ", " + "totalDaysProcessed: " + totalDaysProcessed + ", " + currentDay + "/" + currentMonth + "/" + currentYear)

    int struct = JMap.object()
    JMap.setInt(struct, "day", currentDay)
    JMap.setInt(struct, "month", currentMonth)
    JMap.setInt(struct, "year", currentYear)

    return struct
endFunction

int function GetDateFromDaysPassed_NotWorking(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    ; int daysPassedSinceStartOfYear = CalculateDaysPassedFromDate(aiDay, aiMonth, aiYear)

    int debug_daysIncreased = 0
    int debug_monthsIncreased = 0
    int debug_yearsIncreased = 0

    int currentDay      = aiDay
    int currentMonth    = aiMonth
    int currentYear     = aiYear

    int currentMonthDays = GetDaysOfMonth(currentMonth)

    if ((currentDay + aiDaysPassed) <= currentMonthDays)
        currentDay += aiDaysPassed
        debug_daysIncreased += aiDaysPassed

        int retval = JMap.object()
        JMap.setInt(retval, "day", currentDay)
        JMap.setInt(retval, "month", currentMonth)
        JMap.setInt(retval, "year", currentYear)
        JMap.setInt(retval, "debug_daysIncreased", debug_daysIncreased)

        return retval
    endif

    ; If not in the same month
    ; Estimate how many months will go forward through aiDaysPassed
    ; TEST: aiDaysPassed = 97
    float estimatedMonthsForward = aiDaysPassed / 30.0
    int monthsToAdvance = floor(estimatedMonthsForward)
    int remainingDays = floor((estimatedMonthsForward - floor(estimatedMonthsForward)) * 30.0)

    ; DebugWithArgs("Utility::GetDateFromDaysPassedNew", \ 
    ;     aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
    ;     "currentDay: " + currentDay + "\n" + \
    ;     "currentMonth: " + currentMonth + "\n" + \
    ;     "currentYear: " + currentYear + "\n" + \
    ;     "estimatedMonthsForward: " + estimatedMonthsForward + "\n" + \
    ;     "monthsToAdvance: " + monthsToAdvance + "\n" + \
    ;     "aiDaysPassed: " + aiDaysPassed + "\n" \
    ; )

    if (monthsToAdvance >= 1)
        currentMonth += monthsToAdvance ; We have advanced in month
        debug_monthsIncreased += monthsToAdvance
        currentMonthDays = GetDaysOfMonth(currentMonth)

        remainingDays = floor((estimatedMonthsForward - floor(estimatedMonthsForward)) * 30.0)
        float remainingDaysAsDecimal = (estimatedMonthsForward - floor(estimatedMonthsForward)) * (GetDaysOfMonth(currentMonth) as float)
        float remainingDayDecimal = remainingDaysAsDecimal - floor(remainingDaysAsDecimal) ; 0.8
        if (remainingDayDecimal >= 0.5)
            currentDay += 1
            debug_daysIncreased += 1
        endif


        ; DebugWithArgs("Utility::GetDateFromDaysPassedNew", \ 
        ;     aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
        ;     "currentDay: " + currentDay + "\n" + \
        ;     "currentMonth: " + currentMonth + "\n" + \
        ;     "currentYear: " + currentYear + "\n" + \
        ;     "(currentDay + remainingDays): " + (currentDay + remainingDays) + "\n" + \
        ;     "currentMonthDays: " + currentMonthDays + "\n" + \
        ;     "remainingDays: " + remainingDays + "\n" \
        ; )
        ; 27 + 7 = 34 (34 > 30) <=> 
        if ((currentDay + remainingDays) > currentMonthDays)
            remainingDays = (currentDay + remainingDays) - currentMonthDays ; 4
            currentMonth += 1
            debug_monthsIncreased += 1
            currentDay = 1
            currentMonthDays = GetDaysOfMonth(currentMonth)

            ; Calculate again remainingDays
            currentDay += remainingDays
            debug_daysIncreased += remainingDays
            ; DebugWithArgs("Utility::GetDateFromDaysPassedNew", \ 
            ;     aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
            ;     "currentDay: " + currentDay + "\n" + \
            ;     "currentMonth: " + currentMonth + "\n" + \
            ;     "currentYear: " + currentYear + "\n" + \
            ;     "(currentDay + remainingDays): " + (currentDay + remainingDays) + "\n" + \
            ;     "currentMonthDays: " + currentMonthDays + "\n" + \
            ;     "remainingDays: " + remainingDays + "\n" \
            ; )
            ; Debug("Utility::GetDateFromDaysPassedNew", "Entered here | remainingDays: " + remainingDays + ", currentDay: " + currentDay + ", currentMonth: " + currentMonth)
        else
            currentDay += remainingDays
            debug_daysIncreased += remainingDays
        endif

        int retval = JMap.object()
        JMap.setInt(retval, "day", currentDay)
        JMap.setInt(retval, "month", currentMonth)
        JMap.setInt(retval, "year", currentYear)
        JMap.setInt(retval, "debug_monthsIncreased", debug_monthsIncreased)
        JMap.setInt(retval, "debug_daysIncreased", debug_daysIncreased)

        return retval
    else
        ; Enough to increase month, but not necessarily by the full days
        currentMonth += ceiling(estimatedMonthsForward)
        debug_monthsIncreased += ceiling(estimatedMonthsForward)
        ; remainingDays for the month:
        float remainingDaysDecimal = (1 - estimatedMonthsForward) * GetDaysOfMonth(currentMonth); 0.1666 * 30 = 5

        ; currentDay = 1
        ; int daysToReduce = remainingDays - aiDay
        ; currentDay += daysToReduce + 2
        ; debug_daysIncreased += daysToReduce + 2
        ; DebugWithArgs("Utility::GetDateFromDaysPassedNew", "\n" + \ 
        ;     aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
        ;     "currentDay: " + currentDay + "\n" + \
        ;     "currentMonth: " + currentMonth + "\n" + \
        ;     "currentYear: " + currentYear + "\n" + \
        ;     "remainingDaysDecimal: " + remainingDaysDecimal + "\n" + \
        ;     "monthsToAdvance: " + 1 + "\n" + \
        ;     "estimatedMonthsForward: " + estimatedMonthsForward + "\n" + \
        ;     "ceiling(estimatedMonthsForward): " + ceiling(estimatedMonthsForward) + "\n"\
        ; )

        float remainingDayDecimal = remainingDaysDecimal - floor(remainingDaysDecimal) ; 0.8
        ; if (remainingDayDecimal >= 0.5)
        ;     currentDay -= 1
        ; endif
        ; currentDay -= floor(remainingDaysDecimal) ; Take off the remaining days since we incremented by a full month

        ; DebugWithArgs("Utility::GetDateFromDaysPassedNew", "\n" + \ 
        ;     aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
        ;     "currentDay: " + currentDay + "\n" + \
        ;     "currentMonth: " + currentMonth + "\n" + \
        ;     "currentYear: " + currentYear + "\n" + \
        ;     "remainingDaysDecimal: " + remainingDaysDecimal + "\n" + \
        ;     "monthsToAdvance: " + 1 + "\n" + \
        ;     "estimatedMonthsForward: " + estimatedMonthsForward + "\n" + \
        ;     "ceiling(estimatedMonthsForward): " + ceiling(estimatedMonthsForward) + "\n" + \
        ;     "remainingDayDecimal: " + remainingDayDecimal + "\n"\
        ; )

        int retval = JMap.object()
        JMap.setInt(retval, "day", currentDay)
        JMap.setInt(retval, "month", currentMonth)
        JMap.setInt(retval, "year", currentYear)
        JMap.setInt(retval, "debug_monthsIncreased", debug_monthsIncreased)
        JMap.setInt(retval, "debug_daysIncreased", debug_daysIncreased)

        return retval
    endif

    return 0
endFunction

int[] function GetDateFromDaysPassed_NotWorking_2(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    int daysPassedSinceStartOfYear = CalculateDaysPassedFromDate(aiDay, aiMonth, aiYear)

    int currentDay      = aiDay
    int currentMonth    = aiMonth
    int currentYear     = aiYear

    int currentMonthDays = GetDaysOfMonth(currentMonth)

    if ((currentDay + aiDaysPassed) <= currentMonthDays)
        currentDay += aiDaysPassed

        int[] retval = new int[3]
        retval[0] = currentDay
        retval[1] = currentMonth
        retval[2] = currentYear

        return retval
    endif

    ; If not in the same month
    ; Estimate how many months will go forward through aiDaysPassed
    ; TEST: aiDaysPassed = 97
    float estimatedMonthsForward = aiDaysPassed / (GetDaysOfMonth(currentMonth) as float)
    int monthsToAdvance = floor(estimatedMonthsForward)

    DebugWithArgs("Utility::GetDateFromDaysPassedNew", \ 
        aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
        "currentDay: " + currentDay + "\n" + \
        "currentMonth: " + currentMonth + "\n" + \
        "currentYear: " + currentYear + "\n" + \
        "estimatedMonthsForward: " + estimatedMonthsForward + "\n" + \
        "monthsToAdvance: " + monthsToAdvance + "\n" + \
        "aiDaysPassed: " + aiDaysPassed + "\n" \
    )

    if (monthsToAdvance >= 1)
        currentMonth += monthsToAdvance ; We have advanced in month
        currentMonthDays = GetDaysOfMonth(currentMonth)

        int remainingDays = floor((estimatedMonthsForward - floor(estimatedMonthsForward)) * 30)

        ; 27 + 7 = 34 (34 > 30) <=> 
        if ((currentDay + remainingDays) > currentMonthDays)
            currentMonth += 1
            ; Calculate again remainingDays
            remainingDays = (currentDay + remainingDays) - currentMonthDays ; 4
            currentDay += remainingDays
            Debug("Utility::GetDateFromDaysPassedNew", "Entered here | remainingDays: " + remainingDays + ", currentDay: " + currentDay + ", currentMonth: " + currentMonth)
        else
            currentDay += remainingDays
        endif

        int[] retval = new int[3]
        retval[0] = currentDay
        retval[1] = currentMonth
        retval[2] = currentYear

        return retval
    else
        ; Enough to increase month, but not necessarily by the full days
        currentMonth += ceiling(estimatedMonthsForward)
        ; remainingDays for the month:
        float remainingDaysDecimal = (1 - estimatedMonthsForward) * GetDaysOfMonth(currentMonth); 0.1666 * 30 = 5

        DebugWithArgs("Utility::GetDateFromDaysPassedNew", "\n" + \ 
            aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
            "currentDay: " + currentDay + "\n" + \
            "currentMonth: " + currentMonth + "\n" + \
            "currentYear: " + currentYear + "\n" + \
            "remainingDaysDecimal: " + remainingDaysDecimal + "\n" + \
            "monthsToAdvance: " + 1 + "\n" + \
            "estimatedMonthsForward: " + estimatedMonthsForward + "\n" + \
            "ceiling(estimatedMonthsForward): " + ceiling(estimatedMonthsForward) + "\n"\
        )

        float remainingDayDecimal = remainingDaysDecimal - floor(remainingDaysDecimal) ; 0.8
        if (remainingDayDecimal >= 0.5)
            currentDay -= 1
        endif
        currentDay -= floor(remainingDaysDecimal) ; Take off the remaining days since we incremented by a full month

        DebugWithArgs("Utility::GetDateFromDaysPassedNew", "\n" + \ 
            aiDay + ", " + aiMonth + ", " + aiYear + ", " + aiDaysPassed, \
            "currentDay: " + currentDay + "\n" + \
            "currentMonth: " + currentMonth + "\n" + \
            "currentYear: " + currentYear + "\n" + \
            "remainingDaysDecimal: " + remainingDaysDecimal + "\n" + \
            "monthsToAdvance: " + 1 + "\n" + \
            "estimatedMonthsForward: " + estimatedMonthsForward + "\n" + \
            "ceiling(estimatedMonthsForward): " + ceiling(estimatedMonthsForward) + "\n" + \
            "remainingDayDecimal: " + remainingDayDecimal + "\n"\
        )

        int[] retval = new int[3]
        retval[0] = currentDay
        retval[1] = currentMonth
        retval[2] = currentYear

        return retval
    endif

    return none
endFunction

int function GetDateFromFutureDays_NotWorking_3(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    int debug_daysIncreased     = 0
    int debug_monthsIncreased   = 0
    int debug_yearsIncreased    = 0

    int currentDay      = aiDay
    int currentMonth    = aiMonth
    int currentYear     = aiYear

    int currentMonthDays = GetDaysOfMonth(currentMonth)

    bool dayDoesNotExceedCurrentMonth = (currentDay + aiDaysPassed) <= currentMonthDays

    if (dayDoesNotExceedCurrentMonth)
        currentDay += aiDaysPassed
        debug_daysIncreased += aiDaysPassed

        int retval = JMap.object()
        JMap.setInt(retval, "day", currentDay)
        JMap.setInt(retval, "month", currentMonth)
        JMap.setInt(retval, "year", currentYear)
        JMap.setInt(retval, "debug_daysIncreased", debug_daysIncreased)

        return retval
    endif

    int daysToAdvance   = (aiDay + aiDaysPassed) % 30
    int monthsToAdvance = (aiDay + aiDaysPassed) / 30

    ; Handle differently for Sun's Dawn since it only has 28 days (Sun's Dawn)
    if ((aiMonth + monthsToAdvance) == 2)
        daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 2

    ; elseif ((aiMonth + monthsToAdvance) == 4)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 1

    ; elseif ((aiMonth + monthsToAdvance) == 5)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 1

    ; elseif ((aiMonth + monthsToAdvance) == 6)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 2

    ; elseif ((aiMonth + monthsToAdvance) == 7)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 2

    ; elseif ((aiMonth + monthsToAdvance) == 8)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 3
    
    ; elseif ((aiMonth + monthsToAdvance) == 9)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 4

    ; elseif ((aiMonth + monthsToAdvance) == 10)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 4

    ; elseif ((aiMonth + monthsToAdvance) == 11)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 5

    ; elseif ((aiMonth + monthsToAdvance) == 12)
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 5
    ; elseif (Is31DayMonth(aiMonth + monthsToAdvance))
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 3

    ; elseif (Is30DayMonth(aiMonth + monthsToAdvance))
    ;     daysToAdvance = ((aiDay + aiDaysPassed) % 30) - 4
    endif

    ; currentMonth += monthsToAdvance
    ; debug_monthsIncreased += monthsToAdvance
    ; Debug("Utility::GetDateFromFutureDays", "daysToAdvance: " + daysToAdvance + ", monthsToAdvance: " + monthsToAdvance + ", currentMonth: " + currentMonth + ", (currentMonth + monthsToAdvance): " + (currentMonth + monthsToAdvance))



    while (currentMonth <= monthsToAdvance)
        currentMonth += 1
        debug_monthsIncreased += 1
        currentDay = 1
    endWhile



    currentDay += daysToAdvance
    debug_daysIncreased += daysToAdvance

    currentMonthDays = GetDaysOfMonth(currentMonth)

    ; Now process when we should increase months
    ; while (currentDay < currentMonthDays) ; while 17 <= 31
    ;     currentDay += 1
    ;     debug_daysIncreased += 1
    ; endWhile

    ; currentDay = 1
    ; currentMonth += 1

    int retval = JMap.object()
    JMap.setInt(retval, "day", currentDay)
    JMap.setInt(retval, "month", currentMonth)
    JMap.setInt(retval, "year", currentYear)
    JMap.setInt(retval, "debug_daysIncreased", debug_daysIncreased)
    JMap.setInt(retval, "debug_monthsIncreased", debug_monthsIncreased)

    return retval

endFunction