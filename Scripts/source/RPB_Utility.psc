scriptname RPB_Utility hidden

import Math

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

string function PluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

Form function GetFormFromMod(int formId) global
    return Game.GetFormFromFile(formId, PluginName())
endFunction

; ==========================================================
;                       Form References
; ==========================================================

Message function ServeTimeMessage() global
    return GetFormFromMod(0x1EE08) as Message
endFunction

; ==========================================================
;                        Log Functions
; ==========================================================

function base_log(string asLogType = "DEBUG", string asLogInfo, string asCaller = "", string asCallerArgs = "") global
    if (asCaller)
        debug.trace("["+ ModName() +"] " + asLogType + ": " + asCaller + "("+ asCallerArgs +")" + " -> " + asLogInfo)
    else
        debug.trace("["+ ModName() +"] " + asLogType + ": " + asLogInfo)
    endif
endFunction

function Trace(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("TRACE", asLogInfo, asCaller)
endFunction

function Debug(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("DEBUG", asLogInfo, asCaller)
endFunction

function DebugWithArgs(string asCaller, string asArgs, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("DEBUG", asLogInfo, asCaller, asArgs)
endFunction

function LogNoType(string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    debug.trace("["+ ModName() +"] " + asLogInfo)
endFunction

function Info(string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("INFO", asLogInfo)
endFunction

function Warn(string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("WARN", asLogInfo)
endFunction

function Error(string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("ERROR", asLogInfo)
endFunction

function Fatal(string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    base_log("FATAL", asLogInfo)
endFunction

function LogProperty(string prop, string asLogInfo, bool condition = true) global
    if (condition)
        base_log("PROPERTY", asLogInfo)
    endif
endFunction

function ErrorProperty(string asProperty, string asLogInfo, bool condition = true) global
    if (condition)
        base_log("ERROR (PROPERTY)", asLogInfo)
    endif
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


; Converts the passed in percent number to its equivalent decimal percentage to do calculations.
; e.g: 5 becomes 0.05
float function GetPercentAsDecimal(float percentToConvert) global
    if (percentToConvert <= 0)
        return 0.0
    endif
    
    return percentToConvert / 100
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

; ==========================================================
;                       Actor Functions
; ==========================================================

function UnequipHandsForActor(Actor akActor) global
    UnequipWeaponForActor(akActor, false)
    UnequipWeaponForActor(akActor, false)
    UnequipWeaponForActor(akActor, true)
    UnequipSpellForActor(akActor)
    UnequipShieldForActor(akActor)
endFunction

function UnequipWeaponForActor(Actor akActor, bool abLeftHand = false, bool abPreventEquip = false, bool abSilentUnequip = true) global
    Weapon kWeapon = akActor.GetEquippedWeapon(abLeftHand)
    if (kWeapon != None)
        akActor.UnequipItem(kWeapon, abPreventEquip, abSilentUnequip)
    endif
endFunction

function UnequipShieldForActor(Actor akActor, bool abPreventEquip = false, bool abSilentUnequip = true) global
    Armor kShield = akActor.GetEquippedShield()
    if (kShield != None)
        akActor.UnequipItem(kShield, abPreventEquip, abSilentUnequip)
    endif
endFunction

function UnequipSpellForActor(Actor akActor) global
    int leftHand  = 0
    int rightHand = 1

    Spell kSpell = akActor.GetEquippedSpell(leftHand)
    if (kSpell != None)
        akActor.UnequipSpell(kSpell, leftHand)
    endif

    kSpell = akActor.GetEquippedSpell(rightHand)
    if (kSpell != None)
        akActor.UnequipSpell(kSpell, rightHand)
    endif
endFunction

function UnequipShoutForActor(Actor akActor) global
    Shout kShout = akActor.GetEquippedShout()
    if (kShout != None)
        akActor.UnequipShout(kShout)
    endif
endFunction

bool function ActorHasClothing(Actor akActor) global
    ;/
        TODO: Possibly check for more slotMasks, but for now Body should be fine.
    /;
    return akActor.GetWornForm(GetSlotMask("Body")) != none
endFunction

; ==========================================================
;                       Alias Functions
; ==========================================================

function BindAliasTo(ReferenceAlias akAlias, ObjectReference akObjectReference) global
    if (akObjectReference != None)
        akAlias.ForceRefTo(akObjectReference)
    else
        akAlias.Clear()
    endif
endFunction

; ==========================================================
;           Distance/Position/Translation Functions
; ==========================================================

float function UnitsToCentimeters(int unit)
    return unit * 1.428
endFunction

; Faces akObjA relative to akObjB
; 
; Examples:
; OrientRelative(objA, objB) 					; Sets A to face directly away from B
; OrientRelative(objA, objB, afRotZ = 180.0) 	; Sets A to face toward B
; 
function OrientRelative(ObjectReference akObjA, ObjectReference akObjB, Float afRotX = 0.0, Float afRotY = 0.0, Float afRotZ = 0.0) Global
	Float rotX = akObjB.GetAngleX()
	Float rotY = akObjB.GetAngleY()
	Float rotZ = akObjB.GetAngleZ()

	akObjA.SetAngle(rotX, rotY, rotZ)
endFunction

; ==========================================================
;                       Misc Functions
; ==========================================================

Form function GetFormOfType(string asFormType) global
    if (asFormType == "Gold")
        return Game.GetFormEx(0xF)

    elseif (asFormType == "Lockpick")
        return Game.GetFormEx(0xA)
    endif
endFunction

int function GetSlotMask(string bodyPart) global
    int kSlotMask30 = 0x00000001 ; HEAD
    int kSlotMask31 = 0x00000002 ; Hair
    int kSlotMask32 = 0x00000004 ; BODY
    int kSlotMask33 = 0x00000008 ; Hands
    int kSlotMask34 = 0x00000010 ; Forearms
    int kSlotMask35 = 0x00000020 ; Amulet
    int kSlotMask36 = 0x00000040 ; Ring
    int kSlotMask37 = 0x00000080 ; Feet
    int kSlotMask38 = 0x00000100 ; Calves
    int kSlotMask39 = 0x00000200 ; SHIELD
    int kSlotMask40 = 0x00000400 ; TAIL
    int kSlotMask41 = 0x00000800 ; LongHair
    int kSlotMask42 = 0x00001000 ; Circlet
    int kSlotMask43 = 0x00002000 ; Ears

    if (bodyPart == "Head")
        return kSlotMask30
    elseif (bodyPart == "Hair")
        return kSlotMask31
    elseif (bodyPart == "Body")
        return kSlotMask32
    elseif (bodyPart == "Hands")
        return kSlotMask33
    elseif (bodyPart == "Forearms")
        return kSlotMask34
    elseif (bodyPart == "Amulet")
        return kSlotMask35
    elseif (bodyPart == "Ring")
        return kSlotMask36
    elseif (bodyPart == "Feet")
        return kSlotMask37
    elseif (bodyPart == "Calves")
        return kSlotMask38
    elseif (bodyPart == "Shield")
        return kSlotMask39
    elseif (bodyPart == "Tail")
        return kSlotMask40
    elseif (bodyPart == "LongHair")
        return kSlotMask41
    elseif (bodyPart == "Circlet")
        return kSlotMask42
    elseif (bodyPart == "Ears")
        return kSlotMask43
    endif

endFunction

int function GetSlotMaskValue(int slotMask) global
    ; int slotMaskMap = JIntMap.object()

    int currentSlotMask = 30
    int slotMaskValue = 0x00000001
    while (currentSlotMask <= 61)
        ; JIntMap.setInt(slotMaskMap, currentSlotMask, slotMaskValue)
        if (slotMask == currentSlotMask)
            return slotMaskValue
            ; return JIntMap.getInt(slotMaskMap, slotMask)
        endif
        currentSlotMask += 1
        slotMaskValue *= 2 ; Get next slot mask by doubling the value
    endWhile

    return -1
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

float function GetCurrentTime() global
    return Utility.GetCurrentGameTime()
endFunction

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

int function GetDaysPassed() global
    GlobalVariable GameYear = Game.GetFormEx(0x39) as GlobalVariable
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

string function GetClockFormat(int aiHour, int aiMinutes = 0, string format = "12 Hour") global
    bool isTwelveHourClock = (format == "12 Hour" || format == "12h")

    if (isTwelveHourClock)
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

    else ; 24h
        string shownHour    = string_if (aiHour < 10, "0" + aiHour, aiHour)
        string shownMinutes = string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes)

        return shownHour + ":" + shownMinutes
    endif

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
    int currentDay = aiDay + aiDaysPassed
    int currentMonth = aiMonth
    int currentYear = aiYear

    while (currentDay > GetDaysOfMonth(currentMonth)) 
        currentDay -= GetDaysOfMonth(currentMonth)
        currentMonth += 1

        if (currentMonth > 12)
            currentYear += 1
            currentMonth = 1
        endif
    endWhile

    int struct = new_struct()
    SetStructMemberInt(struct, "day", currentDay)
    SetStructMemberInt(struct, "month", currentMonth)
    SetStructMemberInt(struct, "year", currentYear)

    return struct;
endFunction

string function GetDateFormat(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, string format = "d/m/Y") global
    string formattedDate = ""

    if (format == "d/m/Y")
        string day      = string_if(aiDay < 10, "0" + aiDay, aiDay)
        string month    = string_if (aiMonth < 10, "0" + aiMonth, aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + "/" + month + "/" + year

    elseif (format == "D M Y")
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
    string hour         = GetClockFormat(aiHour, aiMinute)
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


bool function PassTimeInDays(int aiPassByDays) global
    GlobalVariable GameDaysPassed = Game.GetFormEx(0x39) as GlobalVariable
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable

    int daysPassed = 0
    while (daysPassed < aiPassByDays)
        int currentDay      = GetCurrentDay()
        int currentMonth    = GetCurrentMonth()
        int daysInMonth     = GetDaysOfMonth(currentMonth)

        GameHour.Mod(24)
        Utility.Wait(0.01)
        string currentDate = GetCurrentDay() + "/" + GetCurrentMonth() + "/" + GetCurrentYear()
        DebugWithArgs("Utility::PassTimeInDays", aiPassByDays, "Date: " + currentDate +  " at " + GetTimeAs12Hour(GetCurrentHour()) + " ("+ GetTimeAs12Hour(GetCurrentHour()) +", "+  GetCurrentDay() +" of " + GetMonthName(GetCurrentMonth()) +")" + ", " + "GameDaysPassed: " + GameDaysPassed.GetValue())
        daysPassed += 1
    endWhile
    ; GameHour.Mod(-1) ; Take off one hour, for some reason, after passing the days, the time is incremented by 1h
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


; ==========================================================
;                    Benchmark Functions
; ==========================================================

float function StartBenchmark(bool condition = true) global
    if (condition)
        float startTime = Utility.GetCurrentRealTime()
        return startTime
    endif
endFunction

float function EndBenchmark(float startTime, string _message = "", bool condition = true) global
    if (condition)
        float endTime = Utility.GetCurrentRealTime()
        float elapsedTime = endTime - startTime
        debug.trace("[Realistic Prison and Bounty] DEBUG: " + _message + " execution took: " + ((elapsedTime * 1000)) + " ms")
        ; local_log(none, string_if(_message != "", _message + " ", "") + "execution took " + ((elapsedTime * 1000)) + " ms", LOG_DEBUG(), hideCall = true)
        return elapsedTime * 1000
    endif
endFunction


; ==========================================================
;                           Temporary
; ==========================================================

;/
    Temporary function
    Gets the Base Jail Door ID for the specified hold

    SDoorJail01 - 5E91D (Solitude) [Haafingar]
    WRJailDoor01 - A7613 (Whiterun) [Whiterun]
    ImpJailDoor01 - 40BB2 (Windhelm, Riften) [Eastmarch, The Rift]
    FarmhouseJailDoor01 - EC563 (Falkreath, Morthal, Dawnstar) [Falkreath, Hjaalmarch, The Pale]
/;
int function GetJailBaseDoorID(string hold) global
    if (hold == "Haafingar")
        return 0x5E91D

    elseif (hold == "Whiterun")
        return 0xA7613

    elseif (hold == "Windhelm" || hold == "The Rift")
        return 0x40BB2

    elseif (hold == "Falkreath" || hold == "Hjaalmarch" || hold == "The Pale")
        return 0xEC563
    endif
endFunction

ObjectReference function GetNearestJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    int i = 10

    Form doorRef = Game.GetFormEx(jailBaseDoorId)
    ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(doorRef, centerRef, radius)
    return _cellDoor

    ; while (i > 0)
    ;     ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(doorRef.GetBaseObject(), centerRef, radius)
    ;     if (_cellDoor)
    ;         return _cellDoor
    ;     endif

    ;     if (radius < 8000)
    ;         radius *= 2
    ;     endif
    ;     i -= 1
    ; endWhile

    return none
endFunction

ObjectReference function GetNearestJailDoorOfTypeEx(Form akJailBaseDoor, ObjectReference akCenterRef, float afRadius) global
    ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(akJailBaseDoor, akCenterRef, afRadius)
    return _cellDoor
endFunction

ObjectReference function GetRandomJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    Form doorRef = Game.GetFormEx(jailBaseDoorId)
    ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(doorRef, centerRef, radius)
    return _cellDoor
endFunction

function OpenMultipleDoorsOfType(int jailBaseDoorId, ObjectReference scanFromWhere, float radius) global
    int i = 10

    Form doorRef = Game.GetFormEx(jailBaseDoorId)

    while (i > 0)
        ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(doorRef, scanFromWhere, radius)
        bool isOpen = _cellDoor.GetOpenState() == 1 || _cellDoor.GetOpenState() == 2
        if (isOpen)
            OpenMultipleDoorsOfType(jailBaseDoorId, scanFromWhere, radius)
        endif

        if (_cellDoor)
            _cellDoor.SetOpen(true)
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile
endFunction

Actor function GetNearestActor(ObjectReference centerRef, float radius) global
    int i = 10

    while (i > 0)
        Actor _actor = Game.FindRandomActorFromRef(centerRef, radius)
        ; if (_actor && _actor.GetActorBase().GetSex() == 1 && _actor.GetFormID() != 0x14 && !_actor.IsChild())
        if (_actor && _actor.GetFormID() != 0x14 && !_actor.IsChild() && _actor.IsGuard())
            return _actor
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile

    return none
endFunction

Actor function GetNearestGuard(ObjectReference centerRef, float radius, ObjectReference exclude) global
    int i = 30

    while (i > 0)
        Actor _actor = Game.FindRandomActorFromRef(centerRef, radius)
        bool notPlayer = _actor.GetFormID() != 0x14
        if (_actor && notPlayer && !_actor.IsChild() && _actor.IsGuard() && _actor != exclude)
            return _actor
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile

    return none
endFunction

bool function IsActorNearReference(Actor akActor, ObjectReference akReference, float radius = 80.0) global
    ObjectReference referenceToFind = Game.FindClosestReferenceOfTypeFromRef(akReference.GetBaseObject(), akActor, radius)
    if (referenceToFind)
        return true
    endif

    return false
endFunction


;/
    Gets whether or not aiChance is in the specified range

    @aiValue: the value to check
    @aiMin: the minimum starting point
    @aiMax: the range specified

    returns true if aiValue is in the range
    returns false if it's not
/;
bool function IsWithin(int aiValue, int aiMin, int aiMax, bool abMinInclusive = true, bool abMaxInclusive = true) global
    return bool_if(abMinInclusive && abMaxInclusive, (aiValue >= aiMin && aiValue <= aiMax), \
            bool_if(abMinInclusive, (aiValue >= aiMin && aiValue < aiMax), \
            bool_if(abMaxInclusive, (aiValue > aiMin && aiValue <= aiMax))) \
    )
    ;return (aiChance >= aiMin && aiChance <= aiMax)
endfunction


string function __internal_GetMapElement( \
    int map, \
    string paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JMap.getInt(map, paramKey) as bool
    int paramValueInt = JMap.getInt(map, paramKey)
    float paramValueFlt = JMap.getFlt(map, paramKey)
    string paramValueStr = JMap.getStr(map, paramKey)
    int paramValueObj = JMap.getObj(map, paramKey)
    Form paramValueForm = JMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isFormValue = paramValueForm != none
    bool isObjValue = paramValueObj != 0

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetIntegerMapElement( \
    int map, \
    int paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JIntMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JIntMap.getInt(map, paramKey) as bool
    int paramValueInt = JIntMap.getInt(map, paramKey)
    float paramValueFlt = JIntMap.getFlt(map, paramKey)
    string paramValueStr = JIntMap.getStr(map, paramKey)
    int paramValueObj = JIntMap.getObj(map, paramKey)
    Form paramValueForm = JIntMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetFormMapElement( \
    int map, \
    Form paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JFormMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JFormMap.getInt(map, paramKey) as bool
    int paramValueInt = JFormMap.getInt(map, paramKey)
    float paramValueFlt = JFormMap.getFlt(map, paramKey)
    string paramValueStr = JFormMap.getStr(map, paramKey)
    int paramValueObj = JFormMap.getObj(map, paramKey)
    Form paramValueForm = JFormMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetArrayElement( \
    int array, \
    int index, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int arrayLength = JArray.count(array)

    if (arrayLength == 0)
        return ""
    endif

    bool paramValueBool = JArray.getInt(array, index) as bool
    int paramValueInt = JArray.getInt(array, index)
    float paramValueFlt = JArray.getFlt(array, index)
    string paramValueStr = JArray.getStr(array, index)
    int paramValueObj = JArray.getObj(array, index)
    Form paramValueForm = JArray.getForm(array, index)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return index + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return index + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return index + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return index + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return index + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return index + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetIndentLevel(int indentLevel) global
    string output
    if (indentLevel > 1)
        int currentIndentLevel = 0
        while (currentIndentLevel != indentLevel)
            output += "    "
            currentIndentLevel += 1
        endWhile
    endif

    return output
endFunction

string function GetContainerList( \
    int _container, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    string paramOutput

    int containerLength = JValue.count(_container)
    bool isArray = JValue.isArray(_container)

    if (containerLength == 0)
        return string_if (!isArray, "{}", "[]")
    endif

    int i = 0
    while (i < containerLength)
        ; Add indentation before getting the element
        paramOutput += __internal_GetIndentLevel(indentLevel)
        string elementSpacing = "\n" + string_if(i != containerLength - 1, "\t")
        
        if (JValue.isMap(_container))
            string paramKey = JMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeStringFilter != "" && StringUtil.Find(paramKey, includeStringFilter) != -1
            bool hasExcludeFilter = excludeStringFilter != "" && StringUtil.Find(paramKey, excludeStringFilter) != -1

            if (hasIncludeFilter || includeStringFilter == "")
                paramOutput += __internal_GetMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (JValue.isIntegerMap(_container))
            int paramKey = JIntMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeIntegerFilter != -1 && paramKey == includeIntegerFilter
            bool hasExcludeFilter = excludeIntegerFilter != -1 && paramKey == excludeIntegerFilter

            if ((hasIncludeFilter && !hasExcludeFilter) || (!hasIncludeFilter && !hasExcludeFilter))
                paramOutput += __internal_GetIntegerMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (JValue.isFormMap(_container))
            Form paramKey = JFormMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeFormFilter != none && paramKey == includeFormFilter
            bool hasExcludeFilter = excludeFormFilter != none && paramKey == excludeFormFilter

            if ((hasIncludeFilter && !hasExcludeFilter) || (!hasIncludeFilter && !hasExcludeFilter))
                paramOutput += __internal_GetFormMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (isArray)
            int index = i
            paramOutput += __internal_GetArrayElement( \
                _container, \
                index, \
                includeStringFilter = includeStringFilter, \
                excludeStringFilter = excludeStringFilter, \
                includeIntegerFilter = includeIntegerFilter, \
                excludeIntegerFilter = excludeIntegerFilter, \
                includeFormFilter = includeFormFilter, \
                excludeFormFilter = excludeFormFilter, \
                indentLevel = indentLevel + 1 \
            ) + elementSpacing
        endif

        i += 1
    endWhile

    if (paramOutput == "")
        return string_if (!isArray, "{}", "[]")
    endif

    ; Add indentation after getting the element
    paramOutput += __internal_GetIndentLevel(indentLevel)

    ; EndBenchmark(start, "GetContainerList [Length: "+ containerLength +", indentLevel: "+ indentLevel +"]")
    return string_if (!isArray, "{\n\t" + paramOutput + "}", "[\n\t" + paramOutput + "]")
endFunction