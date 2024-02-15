scriptname RPB_Utility hidden

import Math

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

; ==========================================================
;                        Log Functions
; ==========================================================

function Trace(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    debug.trace("["+ ModName() +"] TRACE: " + asCaller + "()" + " -> " + asLogInfo)
endFunction

function Debug(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    debug.trace("["+ ModName() +"] DEBUG: " + asCaller + "()" + " -> " + asLogInfo)
endFunction

function DebugWithArgs(string asCaller, string asArgs, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    debug.trace("["+ ModName() +"] DEBUG: " + asCaller + "("+ asArgs +")" + " -> " + asLogInfo)
endFunction

; ==========================================================
;                       Math Functions
; ==========================================================

float function Max(float a, float b) global
    if (a > b)
        return a
    else
        return b
    endif
endFunction

float function Min(float a, float b) global
    if (a < b)
        return a
    else
        return b
    endif
endFunction

int function Round(float value) global
    float fractionalPart = value - math.floor(value)

    if (fractionalPart >= 0.5)
        return math.ceiling(value)
    else
        return math.floor(value)
    endif
endFunction

; ==========================================================
;                 Ternary-Operator Functions
; ==========================================================

;/
	Ternary operator-like functions
	objective: float x = condition ? afTrue : afFalse
    usage: float x = float_if(condition, afTrue, afFalse)
    example: float x = float_if(y == 2, 4, 8)

/;
float function float_if(bool condition, float afTrue, float afFalse = 0.0) global
	if(condition)
		return afTrue
	endif
	return afFalse
endfunction

int function int_if(bool condition, int aiTrue, int aiFalse = 0) global
	if(condition)
		return aiTrue
	endif
	return aiFalse
endfunction

bool function bool_if(bool condition, bool abTrue, bool abFalse = false) global
	if(condition)
		return abTrue
	endif
	return abFalse
endfunction

string function string_if(bool condition, string asTrue, string asFalse = "") global
	if(condition)
		return asTrue
	endif
	return asFalse
endfunction

Form function form_if(bool condition, Form akTrue, Form akFalse = none) global
    if(condition)
        return akTrue
    else
        return akFalse
    endif
endfunction

ActiveMagicEffect function ame_if (bool condition, ActiveMagicEffect apTrue, ActiveMagicEffect apFalse) global
    if (condition)
        return apTrue
    else
        return apFalse
    endif
endFunction

RPB_Actor function rpb_actor_if(bool condition, RPB_Actor apTrue, RPB_Actor apFalse) global
    if (condition)
        return apTrue
    else
        return apFalse
    endif
endFunction

; ==========================================================
;                        AI Functions
; ==========================================================

function RetainAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(true)
        Game.DisablePlayerControls( \
            abMovement = true, \
            abFighting = true, \
            abCamSwitch = false, \
            abLooking = false, \
            abSneaking = true, \
            abMenu = true, \
            abActivate = true, \
            abJournalTabs = false, \
            aiDisablePOVType = 0 \
        )
    endif
endFunction

function ReleaseAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(false)
        Game.EnablePlayerControls()
    endif
endFunction



Form function GetFormOfType(string asFormType) global
    if (asFormType == "Gold")
        return Game.GetFormEx(0xF)

    elseif (asFormType == "Lockpick")
        return Game.GetFormEx(0xA)
    endif
endFunction

; ==========================================================
;                 Skill Stats/Perks Functions
; ==========================================================

string[] function GetAllSkills(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    int arr = JArray.object()

    if (abIncludeStatSkills)
        JArray.addStr(arr, "Health")
        JArray.addStr(arr, "Stamina")
        JArray.addStr(arr, "Magicka")
    endif

    if (abIncludePerkSkills)
        JArray.addStr(arr, "Heavy Armor")
        JArray.addStr(arr, "Light Armor")
        JArray.addStr(arr, "Sneak")
        JArray.addStr(arr, "One-Handed")
        JArray.addStr(arr, "Two-Handed")
        JArray.addStr(arr, "Archery")
        JArray.addStr(arr, "Block")
        JArray.addStr(arr, "Smithing")
        JArray.addStr(arr, "Speechcraft")
        JArray.addStr(arr, "Pickpocketing")
        JArray.addStr(arr, "Lockpicking")
        JArray.addStr(arr, "Alteration")
        JArray.addStr(arr, "Conjuration")
        JArray.addStr(arr, "Destruction")
        JArray.addStr(arr, "Illusion")
        JArray.addStr(arr, "Restoration")
        JArray.addStr(arr, "Enchanting")
        JArray.addStr(arr, "Alchemy")
    endif

    return JArray.asStringArray(arr)
endFunction

string[] function GetStatSkills() global
    return GetAllSkills(true, false)
endFunction

string[] function GetPerkSkills() global
    return GetAllSkills(false, true)
endFunction

bool function IsStatSkill(string asSkillName) global
    string[] statSkills = GetStatSkills()
    
    int i = 0
    while (i < statSkills.Length)
        if (asSkillName == statSkills[i])
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

bool function IsPerkSkill(string asSkillName) global
    return !IsStatSkill(asSkillName)
endFunction

string function GetRandomSkill(string asSkillType = "Stat") global
    if (asSkillType != "Stat" && asSkillType != "Perk")
        return none
    endif

    string[] skills = GetAllSkills(abIncludeStatSkills = asSkillType == "Stat", abIncludePerkSkills = asSkillType == "Perk")
    return skills[Utility.RandomInt(0, skills.Length - 1)]
endFunction

; ==========================================================
;                       Lock Functions
; ==========================================================

string[] function GetLockLevels() global
   int _lockLevels = JArray.object()

    JArray.addStr(_lockLevels, "Novice")
    JArray.addStr(_lockLevels, "Apprentice")
    JArray.addStr(_lockLevels, "Adept")
    JArray.addStr(_lockLevels, "Expert")
    JArray.addStr(_lockLevels, "Master")
    JArray.addStr(_lockLevels, "Requires Key")

    return JArray.asStringArray(_lockLevels)
endFunction

; ==========================================================
;                 Game-Time Related Functions
; ==========================================================

int function GetDaysOfMonth(int aiMonth) global
    if (aiMonth == 2) ; Sun's Dawn
        return 28
    elseif (aiMonth == 1 || aiMonth == 3 || aiMonth == 5 || aiMonth == 7 || aiMonth == 8 || aiMonth == 10 || aiMonth == 12)
        return 31
    elseif (aiMonth == 4 || aiMonth == 6 || aiMonth == 9 || aiMonth == 11)
        return 30
    else
        return -1
    endif
endFunction

int function GetCurrentMinute() global
    float hourWithMinutes = GetCurrentHourFloat()
    return GetMinutesFromHour(hourWithMinutes)
endFunction

int function GetCurrentHour() global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    return GameHour.GetValueInt()
endFunction

float function GetCurrentHourFloat() global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    return GameHour.GetValue()
endFunction


int function GetCurrentDay() global
    GlobalVariable GameDay = Game.GetFormEx(0x37) as GlobalVariable
    return GameDay.GetValueInt()
endFunction

int function GetCurrentMonth() global
    GlobalVariable GameMonth = Game.GetFormEx(0x36) as GlobalVariable
    return GameMonth.GetValueInt() + 1  ; starts at 0, ends at 11, the Getters/Setters are 1-12
endFunction

int function GetCurrentYear() global
    GlobalVariable GameYear = Game.GetFormEx(0x35) as GlobalVariable
    return GameYear.GetValueInt()
endFunction

int function GetLastDayOfMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth)
endFunction

bool function IsLastDayOfMonth() global
    return GetCurrentDay() == GetLastDayOfMonth(GetCurrentMonth())
endFunction

bool function IsLastDayOfYear() global
    return GetCurrentMonth() == 12 && IsLastDayOfMonth()
endFunction

bool function SetGameHour(int aiGameHour) global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    GameHour.SetValueInt(aiGameHour)
endFunction

bool function ModGameHour(float afIncrementByHours) global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    GameHour.Mod(afIncrementByHours)
endFunction

int function GetMinutesFromHour(float aiHour) global
    ; 13.50 = 1:30 PM
    ; Get the minutes from the hour
    float minutesOfHourAsDecimal = aiHour - math.floor(aiHour) ; 0.50 if x.50

    int resultAsMinutes = math.floor(60 * minutesOfHourAsDecimal) ; convert the decimal into minutes (0.5 becomes 30, half an hour)

    ; DebugWithArgs("Utility::GetMinutesFromHour", aiHour, "Getting minutes from hour " + aiHour + " = " + resultAsMinutes + " minutes" + " ("+ "minutesOfHourAsDecimal: " + minutesOfHourAsDecimal + ")")

    return resultAsMinutes
endFunction

string function GetTimeAs12Hour(int aiHour, int aiMinutes = 0) global
    int hourConverted = 0
    if (aiHour >= 0 && aiHour < 12) ; AM
        if (aiHour == 0)
            hourConverted = 12 ; 12 AM
        else
            hourConverted = aiHour ; No need to convert, already in the form of 1-11 AM
        endif

        return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " AM", ":00 AM")
    elseif (aiHour >= 12 && aiHour < 24) ; PM
        if (aiHour == 12)
            hourConverted = 12 ; 12 PM
        else
            hourConverted = aiHour - 12
        endif

        return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " PM", ":00 PM")
    endif
endFunction

bool function IsLeapYear(int aiYear) global
    return (aiYear % 4 == 0 && (aiYear % 100 != 0 || aiYear % 400 == 0))
endFunction

bool function IsWeekend(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Loredas") || dayOfWeek == GetDayOfWeekByName("Sundas")
endFunction

bool function IsLoredas(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Loredas")
endFunction

bool function IsSundas(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Sundas")
endFunction

bool function IsWeekday(int aiDay, int aiMonth, int aiYear) global
    return !IsWeekend(aiDay, aiMonth, aiYear)
endFunction

int function CalculateDaysPassedFromDate(int aiDay, int aiMonth, int aiYear) global
    int daysInMonth = GetDaysOfMonth(aiMonth)

    if (daysInMonth == -1)
        return -1
    endif

    int totalDaysPassed = 0 ; All days of all months

    int month = 1
    while (month < aiMonth)
        totalDaysPassed += GetDaysOfMonth(month)
        month += 1
    endWhile

    ; DebugWithArgs("Utility::CalculateDaysPassedFromDate", aiDay + ", " + aiMonth + ", " + aiYear, "month: " + month + ", " + "totalDaysPassed: " + totalDaysPassed)

    ; Add days in the current month
    totalDaysPassed += aiDay

    ; Adjust for leap year if needed
    if (IsLeapYear(aiYear) && aiMonth > 2)
        totalDaysPassed += 1
    endif

    return totalDaysPassed
endFunction

int function GetDayOfWeekByName(string asDayOfWeekName) global
    if (asDayOfWeekName == "Sundas")
        return 1
    elseif (asDayOfWeekName == "Morndas")
        return 2
    elseif (asDayOfWeekName == "Tirdas")
        return 3
    elseif (asDayOfWeekName == "Middas")
        return 4
    elseif (asDayOfWeekName == "Turdas")
        return 5
    elseif (asDayOfWeekName == "Fredas")
        return 6
    elseif (asDayOfWeekName == "Loredas")
        return 7
    endif
endFunction

string function GetDayOfWeekName(int aiDayOfWeek) global
    if (aiDayOfWeek == 1)
        return "Sundas"
    elseif (aiDayOfWeek == 2)
        return "Morndas"
    elseif (aiDayOfWeek == 3)
        return "Tirdas"
    elseif (aiDayOfWeek == 4)
        return "Middas"
    elseif (aiDayOfWeek == 5)
        return "Turdas"
    elseif (aiDayOfWeek == 6)
        return "Fredas"
    elseif (aiDayOfWeek == 7)
        return "Loredas"
    endif
endFunction

string function GetDayOfWeekGregorianName(int aiDayOfWeek) global
    if (aiDayOfWeek == 1)
        return "Monday"
    elseif (aiDayOfWeek == 2)
        return "Tuesday"
    elseif (aiDayOfWeek == 3)
        return "Wednesday"
    elseif (aiDayOfWeek == 4)
        return "Thursday"
    elseif (aiDayOfWeek == 5)
        return "Friday"
    elseif (aiDayOfWeek == 6)
        return "Saturday"
    elseif (aiDayOfWeek == 7)
        return "Sunday"
    endif
endFunction

int function GetFirstDayOfWeek(int aiYear) global
    int daysOfWeek = 7 ; (Morndas, Tirdas, Middas, Turdas, Fredas, Loredas, Sundas)
    
    ; Assign the day of week for 4E 201
    ; int dayOfWeek4E201 = 4 ; Middas
    int dayOfWeek4E201 = 3 ; Middas

    int dayOfWeek4EPassedYear = dayOfWeek4E201 ; Assume it's 4E 201 as default

    int startingYear = 201
    while (startingYear < aiYear)
        dayOfWeek4EPassedYear = (dayOfWeek4EPassedYear % daysOfWeek) + 1
        startingYear += 1
    endWhile

    return dayOfWeek4EPassedYear
endFunction

int function CalculateDayOfWeek(int aiDay, int aiMonth, int aiYear) global
    ; Constants
    int daysInWeek = 7

    ; Determine the starting day of the year
    int startingDay = GetFirstDayOfWeek(aiYear)

    ; Calculate total days passed from the beginning of the year
    int totalDaysPassed = CalculateDaysPassedFromDate(aiDay, aiMonth, aiYear)

    ; Determine the day of the week (1 for Morndas, 2 for Tirdas, ..., 7 for Sundas)
    int dayOfWeek = (((totalDaysPassed + startingDay - 1) % daysInWeek)) + 1

    ; DebugWithArgs("Utility::CalculateDayOfWeek", aiDay + ", " + aiMonth + ", " + aiYear, "startingDay: " + startingDay + ", totalDaysPassed: " + totalDaysPassed + ", dayOfWeek: " + dayOfWeek)

    return dayOfWeek
endFunction

int function GetDateFromDaysPassed(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
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

    int struct = new_struct()
    JMap.setInt(struct, "day", currentDay);
    JMap.setInt(struct, "month", currentMonth);
    JMap.setInt(struct, "year", currentYear);

    return struct;
endFunction

string function GetDateInFormat(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, string format = "d/m/Y") global
    string formattedDate = ""

    if (format == "d/m/Y")
        string day      = string_if(aiDay < 10, "0" + aiDay, aiDay)
        string month    = string_if (aiMonth < 10, "0" + aiMonth, aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + "/" + month + "/" + year

    elseif (format == "d M Y")
        string day      = RPB_Utility.ToOrdinalNthDay(aiDay)
        string month    = RPB_Utility.GetMonthName(aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + " of " + month + ", " + year
    endif

    return formattedDate
endFunction

int function GetPreviousDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    if (aiDayOfWeek < GetDayOfWeekByName("Sundas") || aiDayOfWeek > GetDayOfWeekByName("Loredas"))
        return -10
    endif

    int dayOfWeekForPassedDate      = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    int dayOfWeekDifference         = aiDayOfWeek - dayOfWeekForPassedDate
    bool dayOfWeekIsPreviousWeek    = dayOfWeekDifference >= 0
    int daysBackward                = int_if (dayOfWeekIsPreviousWeek, -7 + dayOfWeekDifference, dayOfWeekDifference)

    int newDateForDayOfWeek = GetDateFromDaysPassed(aiDay, aiMonth, aiYear, daysBackward)
    int day      = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "day")
    int month    = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "month")
    int year     = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "year")

    int retval = new_struct()
    SetStructMemberInt(retval, "day", day)
    SetStructMemberInt(retval, "month", month)
    SetStructMemberInt(retval, "year", year)
    SetStructMemberInt(retval, "daysAgo", daysBackward)

    return retval
endFunction

int function GetNextDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    if (aiDayOfWeek < GetDayOfWeekByName("Sundas") || aiDayOfWeek > GetDayOfWeekByName("Loredas"))
        return -10
    endif

    int dayOfWeekForPassedDate = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    int dayOfWeekDifference     = aiDayOfWeek - dayOfWeekForPassedDate
    bool dayOfWeekIsNextWeek    = dayOfWeekDifference <= 0
    int daysForward             = int_if (dayOfWeekIsNextWeek, 7 + dayOfWeekDifference, dayOfWeekDifference)

    int newDateForDayOfWeek = GetDateFromDaysPassed(aiDay, aiMonth, aiYear, daysForward)
    int day      = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "day")
    int month    = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "month")
    int year     = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "year")

    int retval = new_struct()
    SetStructMemberInt(retval, "day", day)
    SetStructMemberInt(retval, "month", month)
    SetStructMemberInt(retval, "year", year)
    SetStructMemberInt(retval, "daysFromNow", daysForward)

    return retval
endFunction


string function GetMonthName(int aiMonth) global
    if (aiMonth == 1)
        return "Morning Star"
    elseif (aiMonth == 2)
        return "Sun's Dawn"
    elseif (aiMonth == 3)
        return "First Seed"
    elseif (aiMonth == 4)
        return "Rain's Hand"
    elseif (aiMonth == 5)
        return "Second Seed"
    elseif (aiMonth == 6)
        return "Midyear"
    elseif (aiMonth == 7)
        return "Sun's Height"
    elseif (aiMonth == 8)
        return "Last Seed"
    elseif (aiMonth == 9)
        return "Heartfire"
    elseif (aiMonth == 10)
        return "Frostfall"
    elseif (aiMonth == 11)
        return "Sun's Dusk"
    elseif (aiMonth == 12)
        return "Evening Star"
    endif

    return none
endFunction

int function GetMonthByName(string asMonthName) global
    if (asMonthName == "Morning Star")
        return 1
    elseif (asMonthName == "Sun's Dawn")
        return 2
    elseif (asMonthName == "First Seed")
        return 3
    elseif (asMonthName == "Rain's Hand")
        return 4
    elseif (asMonthName == "Second Seed")
        return 5
    elseif (asMonthName == "Midyear")
        return 6
    elseif (asMonthName == "Sun's Height")
        return 7
    elseif (asMonthName == "Last Seed")
        return 8
    elseif (asMonthName == "Heartfire")
        return 9
    elseif (asMonthName == "Frostfall")
        return 10
    elseif (asMonthName == "Sun's Dusk")
        return 11
    elseif (asMonthName == "Evening Star")
        return 12
    endif

    return 0
endFunction

bool function Is28DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 28
endFunction

bool function Is30DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 30
endFunction

bool function Is31DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 31
endFunction


string function ToOrdinalNthDay(int aiDay) global
    return aiDay + GetDayOrdinality(aiDay)
endFunction

string function GetDayOrdinality(int aiDay) global
    if (aiDay > 3 && aiDay < 21)
        return "th"
    endif

    int nthDayOrdinalValue = aiDay % 10

    if (nthDayOrdinalValue == 1)
        return "st"
    elseif (nthDayOrdinalValue == 2)
        return "nd"
    elseif (nthDayOrdinalValue == 3)
        return "rd"
    else
        return "th"
    endif
endFunction

; TODO: Fix weeks calculations
string function GetTimeFormatted(float afTime, bool abIncludeMinutes = false, bool abIncludeHours = true, bool abIncludeDays = true, bool abIncludeWeeks = true, bool abIncludeMonths = true, bool abIncludeYears = true, string asNullValue = "") global
    float timeGameTime  = afTime
    float timeHours     = ((timeGameTime - floor(timeGameTime)) / 0.0416)
    float timeMinutes   = (timeHours - floor(timeHours)) * 60
    float timeDays      = timeGameTime
    float timeMonths    = timeGameTime / 30
    float timeWeeks     = (timeGameTime / 7)
    float timeYears     = (timeDays / 365)

    string timeString = ""

    ; Only display Years, Months or Years
    if (abIncludeYears && floor(timeYears) >= 1)
        timeString = math.floor(timeYears) + " " + string_if (floor(timeYears) == 1, "Year", "Years")

        timeMonths = ((timeYears - floor(timeYears)) * 12)

        if (abIncludeMonths && floor(timeMonths) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeMonths) + " " + string_if (floor(timeMonths) == 1, "Month", "Months"))
        endif

        return timeString
    endif

    ; Only display Months or Months, Days
    if (abIncludeMonths && floor(timeMonths) >= 1)
        timeString = floor(timeMonths) + " " + string_if (floor(timeMonths) == 1, "Month", "Months")

        timeDays = ((timeMonths - floor(timeMonths)) * 30)
        timeWeeks = (floor(timeDays) % 30) / 7

        if (abIncludeWeeks && floor(timeWeeks) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeWeeks) + " " + string_if (floor(timeWeeks) == 1, "Week", "Weeks"))
        elseif (abIncludeDays && floor(timeDays) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days"))
        endif

        return timeString
    endif

    if (abIncludeWeeks && floor(timeWeeks) >= 1)
        timeString = floor(timeWeeks) + " " + string_if (floor(timeWeeks) == 1, "Week", "Weeks")

        timeDays = (timeWeeks - floor(timeWeeks)) * 7

        if (abIncludeDays && floor(timeDays) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days"))
        endif

        return timeString
    endif

    ; Only display Days or Days, Hours
    if (abIncludeDays && floor(timeDays) >= 1)
        timeHours = ((timeDays - floor(timeDays)) * 24)

        if (timeHours > 24)
            timeDays += 1
            timeHours -= 24
        endif

        timeString = floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days")

        if (abIncludeHours && floor(timeHours) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeHours) + " " + string_if (floor(timeHours) == 1, "Hour", "Hours"))
        endif

        return timeString
    endif

    ; Only display Hours or Hours, Minutes
    if (abIncludeHours && floor(timeHours) >= 1)
        timeString = floor(timeHours) + " " + string_if (floor(timeHours) == 1, "Hour", "Hours")

        timeMinutes = ((timeHours - floor(timeHours)) * 60)

        if (abIncludeMinutes && floor(timeMinutes) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeMinutes) + " " + string_if (floor(timeMinutes) == 1, "Minute", "Minutes"))
        endif

        return timeString
    endif

    ; Only display Minutes
    if (abIncludeMinutes && floor(timeMinutes) >= 1)
        timeString = floor(timeMinutes) + " " + string_if (floor(timeMinutes) == 1, "Minute", "Minutes")

        return timeString
    endif

    return asNullValue
endFunction

string function GetFormattedDate(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, bool abShowDayOfWeek = true, bool abShowDay = true, bool abShowTime = true, bool abShowYear = true) global
    string dayOfWeek    = GetDayOfWeekName(CalculateDayOfWeek(aiDay, aiMonth, aiYear))
    string hour         = GetTimeAs12Hour(aiHour, aiMinute)
    string dayOrdinal   = ToOrdinalNthDay(aiDay)
    string monthName    = GetMonthName(aiMonth)
    string yearString   = "4E " + aiYear

    string dateResult = ""

    if (abShowDayOfWeek)
        dateResult += dayOfWeek + ", "
    endif

    if (abShowTime)
        dateResult += hour + ", "
    endif

    if (abShowDay)
        dateResult += dayOrdinal + " of "
    endif

    dateResult += monthName + ", "

    if (abShowYear)
        dateResult += yearString
    endif

    return dateResult
    ; Fredas, 7:00 AM, 21st of Sun's Dusk, 4E 201
    ; return dayOfWeek + ", " + hour + ", " + dayOrdinal + " of " + monthName + ", " + yearString
endFunction

string function GetFormattedDate24Hours(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0) global

endFunction

string function GetCurrentDateFormatted() global
    int currentDay      = GetCurrentDay()
    int currentMonth    = GetCurrentMonth()
    int currentYear     = GetCurrentYear()
    float currentHour   = GetCurrentHourFloat()
    int minutesFromHour = GetMinutesFromHour(currentHour)

    return GetFormattedDate(currentDay, currentMonth, currentYear, floor(currentHour), minutesFromHour)
endFunction

string function GetNextDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    int nextDayOfWeek       = GetNextDayOfWeekFromDate(GetCurrentDay(), GetCurrentMonth(), GetCurrentYear(), GetDayOfWeekByName(asDayOfWeek))
    int day                 = GetStructMemberInt(nextDayOfWeek, "day")
    int month               = GetStructMemberInt(nextDayOfWeek, "month")
    int year                = GetStructMemberInt(nextDayOfWeek, "year")
    int daysTillDayOfWeek   = GetStructMemberInt(nextDayOfWeek, "daysFromNow")

    return GetFormattedDate(day, month, year, GetCurrentHour(), GetCurrentMinute(), abShowTime = abShowTime)
endFunction

string function GetPreviousDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    int previousDayOfWeek   = GetPreviousDayOfWeekFromDate(GetCurrentDay(), GetCurrentMonth(), GetCurrentYear(), GetDayOfWeekByName(asDayOfWeek))
    int day                 = GetStructMemberInt(previousDayOfWeek, "day")
    int month               = GetStructMemberInt(previousDayOfWeek, "month")
    int year                = GetStructMemberInt(previousDayOfWeek, "year")
    int daysFromDayOfWeek   = GetStructMemberInt(previousDayOfWeek, "daysAgo")

    return GetFormattedDate(day, month, year, GetCurrentHour(), GetCurrentMinute(), abShowTime = abShowTime)
endFunction

bool function SetGameDay(int aiGameDay, bool abNoSafetyCheck = false) global
    int currentMonth = GetCurrentMonth()
    int daysInMonth = GetDaysOfMonth(currentMonth)
    
    GlobalVariable GameDay = Game.GetFormEx(0x37) as GlobalVariable

    if (abNoSafetyCheck)
        GameDay.SetValueInt(aiGameDay)
        return true
    endif

    if (aiGameDay > daysInMonth)
        GameDay.SetValueInt(daysInMonth) ; Cap to last day
    else
        GameDay.SetValueInt(aiGameDay)
    endif
endFunction

bool function SetGameMonth(int aiGameMonth) global
    if (aiGameMonth < 1 || aiGameMonth > 12)
        return false
    endif

    GlobalVariable GameMonth = Game.GetFormEx(0x36) as GlobalVariable
    GameMonth.SetValueInt(aiGameMonth - 1) ; starts at 0, ends at 11, the Getters/Setters are 1-12
endFunction

bool function SetGameYear(int aiGameYear) global
    GlobalVariable GameYear = Game.GetFormEx(0x35) as GlobalVariable
    GameYear.SetValueInt(aiGameYear)
endFunction

; bool function PassTimeInDays(int aiPassByDays) global
;     int currentDay      = GetCurrentDay()
;     int currentMonth    = GetCurrentMonth()
;     int daysInMonth     = GetDaysOfMonth(currentMonth)

;     ; if (aiPassByDays <= 0)
;     ;     return true
;     ; endif

;     GlobalVariable GameDaysPassed = Game.GetFormEx(0x39) as GlobalVariable

;     int daysLeftInMonth = daysInMonth - currentDay

;     if (daysLeftInMonth == 0)
;         ; Pass the time by hours
;         GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
;         GameHour.SetValueInt(24)
;         DebugWithArgs("Utility::PassTimeInDays", "int: " + aiPassByDays, "Called, there are no more days left in the month. - Day: "  + GetCurrentDay() + ", Month: " + GetCurrentMonth() + " at Hour: " + GetCurrentHour())

;     elseif (aiPassByDays > daysLeftInMonth)
;         ; More days than the month has left were passed, change the month and add the remaining days after that to the new month
;         int nextMonth = GetCurrentMonth() + 1
;         SetGameMonth(nextMonth)
;         SetGameDay(1)
;         PassTimeInDays((Math.abs(aiPassByDays - daysInMonth) - 1) as int)
;         DebugWithArgs("Utility::PassTimeInDays", "int: " + (Math.abs(aiPassByDays - daysInMonth) - 1) as int, "Recursively called - Day: " + GetCurrentDay() + ", Month: " + GetCurrentMonth() + " at Hour: " + GetCurrentHour())
;     else
;         SetGameDay(GetCurrentDay() + aiPassByDays)
;         DebugWithArgs("Utility::PassTimeInDays", "int: " + aiPassByDays, "Called, normal processing - Day: " + GetCurrentDay() + ", Month: " + GetCurrentMonth() + " at Hour: " + GetCurrentHour())
;     endif

;     Debug("Utility::PassTimeInDays", "GameDaysPassed: " + GameDaysPassed.GetValue())
;     ; GameDaysPassed.SetValue(12.7)
; endFunction

bool function PassTimeInDays(int aiPassByDays) global
    GlobalVariable GameDaysPassed = Game.GetFormEx(0x39) as GlobalVariable


    int daysPassed = 0
    while (daysPassed < aiPassByDays)
        int currentDay      = GetCurrentDay()
        int currentMonth    = GetCurrentMonth()
        int daysInMonth     = GetDaysOfMonth(currentMonth)


        ModGameHour(24)
        Utility.Wait(0.01)
        string currentDate = GetCurrentDay() + "/" + GetCurrentMonth() + "/" + GetCurrentYear()
        DebugWithArgs("Utility::PassTimeInDays", aiPassByDays, "Date: " + currentDate +  " at " + GetTimeAs12Hour(GetCurrentHour()) + " ("+ GetTimeAs12Hour(GetCurrentHour()) +", "+  GetCurrentDay() +" of " + GetMonthName(GetCurrentMonth()) +")" + ", " + "GameDaysPassed: " + GameDaysPassed.GetValue())
        daysPassed += 1
    endWhile
    ModGameHour(-1) ; Take off one hour, for some reason, after passing the days, the time is incremented by 1h
endFunction


; ==========================================================
;                           Struct
; ==========================================================

int function new_struct(bool abRetain = false, string asStructType = "") global
    int structObj = JMap.object()

    if (abRetain)
        JValue.retain(structObj, asStructType)
    endif

    return structObj
endFunction

bool function GetStructMemberBool(int apStructObject, string asMemberName) global
    return JMap.getInt(apStructObject, asMemberName) as bool
endFunction

int function GetStructMemberInt(int apStructObject, string asMemberName) global
    return JMap.getInt(apStructObject, asMemberName)
endFunction

float function GetStructMemberFloat(int apStructObject, string asMemberName) global
    return JMap.getFlt(apStructObject, asMemberName)
endFunction

string function GetStructMemberString(int apStructObject, string asMemberName) global
    return JMap.getStr(apStructObject, asMemberName)
endFunction

Form function GetStructMemberForm(int apStructObject, string asMemberName) global
    return JMap.getForm(apStructObject, asMemberName)
endFunction

function SetStructMemberBool(int apStructObject, string asMemberName, bool value) global
    JMap.setInt(apStructObject, asMemberName, value as int)
endFunction

function SetStructMemberInt(int apStructObject, string asMemberName, int value) global
    JMap.setInt(apStructObject, asMemberName, value)
endFunction

function SetStructMemberFloat(int apStructObject, string asMemberName, float value) global
    JMap.setFlt(apStructObject, asMemberName, value)
endFunction

function SetStructMemberString(int apStructObject, string asMemberName, string value) global
    JMap.setStr(apStructObject, asMemberName, value)
endFunction

function SetStructMemberForm(int apStructObject, string asMemberName, Form value) global
    JMap.setForm(apStructObject, asMemberName, value)
endFunction

function DestroyStruct(int apStructObject) global
    if (apStructObject)
        JValue.release(apStructObject)
    endif
endFunction

function DestroyStructsOfType(string asStructType) global
    JValue.releaseObjectsWithTag(asStructType)
endFunction